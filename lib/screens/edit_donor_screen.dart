import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:flutter_php_new/constants.dart';
import 'package:flutter_php_new/donor_ops/donor_enums.dart';

class EditDonorScreen extends StatefulWidget {
  final int organId;

  EditDonorScreen({required this.organId});

  @override
  _EditDonorScreenState createState() => _EditDonorScreenState();
}

class _EditDonorScreenState extends State<EditDonorScreen> {
  BuildContext? _dialogContext;
  late TextEditingController _ohlaController;
  OrganName? _selectedOrganName;
  BloodGroup? _selectedBloodGroup;
  AntibodyScreening? _selectedAntibodyScreening;
  HIVStatus? _selectedHIVStatus;
  HepatitisBStatus? _selectedHepatitisBStatus;
  HepatitisCStatus? _selectedHepatitisCStatus;
  DonorStatus? _selectedDonorStatus;
  String? _selectedBranchName;
  int flag = 0;
  // String? _selectedBranchAddress;
  // String? _selectedBranchPhoneNumber;
  int? _selectedBranchId;
  int? _selectedAvailabilityId;
  List<String> _branchNames = [];

  @override
  void initState() {
    super.initState();
    _ohlaController = TextEditingController();
    fetchDataFromDatabase(widget.organId);
    fetchBranchNames();
  }

  Future<void> fetchDataFromDatabase(int donorId) async {
    try {
      final MySqlConnection conn = await MySqlConnection.connect(settings);

      var results =
          await conn.query('SELECT * FROM organ WHERE oid = ?', [donorId]);
      if (results.isNotEmpty) {
        var row = results.first;
        setState(() {
          _ohlaController.text = row['ohla'];
          _selectedOrganName = OrganNameExtension.fromString(row['organ_name']);
          _selectedBloodGroup =
              BloodGroupExtension.fromString(row['obloodgroup']);
          _selectedAntibodyScreening =
              AntibodyScreeningExtension.fromString(row['antibody_screening']);
          _selectedHIVStatus = HIVStatusExtension.fromString(row['hiv_status']);
          _selectedHepatitisBStatus =
              HepatitisBStatusExtension.fromString(row['hepatitis_b_status']);
          _selectedHepatitisCStatus =
              HepatitisCStatusExtension.fromString(row['hepatitis_c_status']);
          _selectedDonorStatus =
              DonorStatusExtension.fromString(row['donor_status']);
          // _selectedBranch = row[
          //     'branch_name']; // Assuming the column name in organs table is 'branch_name'
        });
      }
      await conn.close();
    } catch (e) {
      print('Error fetching donor data: $e');
    }
  }

  Future<void> fetchBranchNames() async {
    try {
      final MySqlConnection conn = await MySqlConnection.connect(settings);
      var results = await conn.query('SELECT bname FROM branch');
      await conn.close();

      List<String> branchNames = [];
      for (var row in results) {
        branchNames.add(row[0]);
      }

      setState(() {
        _branchNames = branchNames;
      });
    } catch (e) {
      print('Error fetching branch names: $e');
    }
  }

  Future<void> _showSuccessDialog() async {
    // Store the dialog context
    _dialogContext = context;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Success'),
        content: Text('Donor details updated successfully.'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateDonorDetails() async {
    try {
      final MySqlConnection conn = await MySqlConnection.connect(settings);

      // Create medical history string
      String medicalHistory =
          'Antibody Screening: ${_selectedAntibodyScreening?.toString().split('.').last}, '
          'HIV: ${_selectedHIVStatus?.toString().split('.').last}, '
          'Hepatitis B: ${_selectedHepatitisBStatus?.toString().split('.').last}, '
          'Hepatitis C: ${_selectedHepatitisCStatus?.toString().split('.').last}';

      // Convert BloodGroup enum to String
      // String? _selectedBloodGroupString;
      // if (_selectedBloodGroup != null) {
      //   _selectedBloodGroupString =
      //       (BloodGroupExtension.getValue(_selectedBloodGroup! as String))
      //           as String?;
      // }

      // Update donor details in Organs table including medical history
      await conn.query(
        'UPDATE organ SET ohla = ?, organ_name = ?, obloodgroup = ?, omedical_history = ? ,odonor_status=?  WHERE oid = ?',
        [
          _ohlaController.text,
          OrganNameExtension.getValue(_selectedOrganName ?? OrganName.liver),
          _selectedBloodGroup?.value ?? '',
          medicalHistory,
          _selectedDonorStatus.toString().split('.').last.replaceAll('_', ' '),
          widget.organId,
        ],
      );

      // Update branch details in Branch table
      // await conn.query(
      //   'UPDATE branch SET bname = ?, baddress = ?, bphone_number = ? WHERE bid = ?',
      //   [
      //     _selectedBranchName ?? '',
      //     _selectedBranchAddress ?? '',
      //     _selectedBranchPhoneNumber ?? '',
      //     _selectedBranchId ?? 0,
      //   ],
      // );

      // Update availability details in Available table
      await conn.query(
        'UPDATE available SET organ_id = ?, branch_id = ? WHERE availability_id = ?',
        [
          widget.organId,
          _selectedBranchId ?? 0,
          _selectedAvailabilityId ?? 0,
        ],
      );

      await conn.close();

      // Show success dialog
      _showSuccessDialog();
      setState(() {
        flag = 1;
      });

      // Close the edit screen using the stored dialog context
      if (_dialogContext != null) {
        Navigator.of(_dialogContext!).pop(); // Close the dialog
      } // Close the edit screen after successful update
    } catch (e) {
      print('Error updating donor details: $e');
      if (e is MySqlException) {
        if (e.errorNumber == 1644) {
          // Handle the specific SQL error 1644 (45000) here
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Error'),
              content: Text(
                  e.message), // Display the SQL error message in the dialog
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            ),
          );
        } else {
          // Handle other MySQL exceptions here
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Error'),
              content: Text(
                  'Failed to update donor details. Please try again later.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            ),
          );
        }
      } else {
        // Handle other exceptions (non-MySQL) here
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content:
                Text('Failed to update donor details. Please try again later.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _dialogContext = context;
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Donor Information'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Organ ID: ${widget.organId}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.indigo,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'OHLA:',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              TextField(
                controller: _ohlaController,
                decoration: InputDecoration(
                  hintText: 'Enter OHLA...',
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Organ Name:',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              DropdownButtonFormField<OrganName>(
                value: _selectedOrganName,
                onChanged: (newValue) {
                  setState(() {
                    _selectedOrganName = newValue;
                  });
                },
                items: OrganName.values
                    .map((value) => DropdownMenuItem<OrganName>(
                          value: value,
                          child: Text(value.toString().split('.').last),
                        ))
                    .toList(),
                decoration: InputDecoration(labelText: 'Organ Name'),
              ),
              SizedBox(height: 12),
              Text(
                'Blood Group:',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              DropdownButtonFormField<BloodGroup>(
                value: _selectedBloodGroup,
                onChanged: (newValue) {
                  setState(() {
                    _selectedBloodGroup = newValue;
                  });
                },
                items: BloodGroup.values
                    .map((value) => DropdownMenuItem<BloodGroup>(
                          value: value,
                          child: Text(value.toString().split('.').last),
                        ))
                    .toList(),
                decoration: InputDecoration(labelText: 'Blood Group'),
              ),
              SizedBox(height: 12),
              Text(
                'Antibody Screening:',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              DropdownButtonFormField<AntibodyScreening>(
                value: _selectedAntibodyScreening,
                onChanged: (newValue) {
                  setState(() {
                    _selectedAntibodyScreening = newValue;
                  });
                },
                items: AntibodyScreening.values
                    .map((value) => DropdownMenuItem<AntibodyScreening>(
                          value: value,
                          child: Text(value.toString().split('.').last),
                        ))
                    .toList(),
                decoration: InputDecoration(labelText: 'Antibody Screening'),
              ),
              SizedBox(height: 12),
              Text(
                'HIV Status:',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              DropdownButtonFormField<HIVStatus>(
                value: _selectedHIVStatus,
                onChanged: (newValue) {
                  setState(() {
                    _selectedHIVStatus = newValue;
                  });
                },
                items: HIVStatus.values
                    .map((value) => DropdownMenuItem<HIVStatus>(
                          value: value,
                          child: Text(value.toString().split('.').last),
                        ))
                    .toList(),
                decoration: InputDecoration(labelText: 'HIV Status'),
              ),
              SizedBox(height: 12),
              Text(
                'Hepatitis B Status:',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              DropdownButtonFormField<HepatitisBStatus>(
                value: _selectedHepatitisBStatus,
                onChanged: (newValue) {
                  setState(() {
                    _selectedHepatitisBStatus = newValue;
                  });
                },
                items: HepatitisBStatus.values
                    .map((value) => DropdownMenuItem<HepatitisBStatus>(
                          value: value,
                          child: Text(value.toString().split('.').last),
                        ))
                    .toList(),
                decoration: InputDecoration(labelText: 'Hepatitis B Status'),
              ),
              SizedBox(height: 12),
              Text(
                'Hepatitis C Status:',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              DropdownButtonFormField<HepatitisCStatus>(
                value: _selectedHepatitisCStatus,
                onChanged: (newValue) {
                  setState(() {
                    _selectedHepatitisCStatus = newValue;
                  });
                },
                items: HepatitisCStatus.values
                    .map((value) => DropdownMenuItem<HepatitisCStatus>(
                          value: value,
                          child: Text(value.toString().split('.').last),
                        ))
                    .toList(),
                decoration: InputDecoration(labelText: 'Hepatitis C Status'),
              ),
              SizedBox(height: 12),
              Text(
                'Donor Status:',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              DropdownButtonFormField<DonorStatus>(
                value: _selectedDonorStatus,
                onChanged: (newValue) {
                  setState(() {
                    _selectedDonorStatus = newValue;
                  });
                },
                items: DonorStatus.values
                    .map((value) => DropdownMenuItem<DonorStatus>(
                          value: value,
                          child: Text(value.toString().split('.').last),
                        ))
                    .toList(),
                decoration: InputDecoration(labelText: 'Donor Status'),
              ),
              SizedBox(height: 12),
              // Text(
              //   'Branch Name:',
              //   style: TextStyle(
              //     fontSize: 18,
              //     color: Colors.black,
              //   ),
              // ),
              // // DropdownButtonFormField<String>(
              //   value:
              //       _selectedBranchName, // Change this line to _selectedBranchName
              //   onChanged: (newValue) {
              //     setState(() {
              //       _selectedBranchName =
              //           newValue; // Change this line to _selectedBranchName
              //     });
              //   },
              //   items: _branchNames
              //       .map((value) => DropdownMenuItem<String>(
              //             value: value,
              //             child: Text(value),
              //           ))
              //       .toList(),
              //   decoration: InputDecoration(labelText: 'Branch Name'),
              // ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _updateDonorDetails();

                  Navigator.of(context).pop();
                  if (flag == 1) {
                    _showSuccessDialog();
                  }
                  // _showSuccessDialog();
                },
                child: Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
