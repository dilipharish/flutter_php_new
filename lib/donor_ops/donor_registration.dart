import 'package:flutter/material.dart';
import 'package:flutter_php_new/constants.dart';
import 'package:mysql1/mysql1.dart';

import 'package:flutter_php_new/donor_ops/donor_enums.dart';

class DonorRegistrationPage extends StatefulWidget {
  final int userId;

  DonorRegistrationPage({required this.userId});

  @override
  _DonorRegistrationPageState createState() => _DonorRegistrationPageState();
}

class _DonorRegistrationPageState extends State<DonorRegistrationPage> {
  TextEditingController ohlaController = TextEditingController();
  OrganName? selectedOrganName;
  BloodGroup? selectedBloodGroup;
  AntibodyScreening? selectedAntibodyScreening;
  HIVStatus? selectedHIVStatus;
  HepatitisBStatus? selectedHepatitisBStatus;
  HepatitisCStatus? selectedHepatitisCStatus;
  DonorStatus? selectedDonorStatus;
  List<String> branchNames = [];
  String? selectedBranch;
  Future<void> fetchBranchNames() async {
    final conn = await MySqlConnection.connect(settings);

    var results = await conn.query('SELECT bname FROM branch');
    await conn.close();

    List<String> names = [];
    for (var row in results) {
      names.add(row[0]);
    }

    setState(() {
      branchNames = names;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchBranchNames();
  }

  Future<void> _registerDonor() async {
    // Validate input fields
    if (ohlaController.text.isEmpty ||
        selectedOrganName == null ||
        selectedBloodGroup == null ||
        selectedAntibodyScreening == null ||
        selectedHIVStatus == null ||
        selectedHepatitisBStatus == null ||
        selectedHepatitisCStatus == null ||
        selectedDonorStatus == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Please fill in all the fields.'),
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
      return;
    }
    if (selectedBranch == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Please select a branch.'),
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
      return;
    }

    String medicalHistory =
        'Antibody Screening: ${selectedAntibodyScreening.toString().split('.').last}, '
        'HIV: ${selectedHIVStatus.toString().split('.').last}, '
        'Hepatitis B: ${selectedHepatitisBStatus.toString().split('.').last}, '
        'Hepatitis C: ${selectedHepatitisCStatus.toString().split('.').last}';

    try {
      final conn = await MySqlConnection.connect(settings);
      var donorDOBResult = await conn.query(
        'SELECT date_of_birth FROM users WHERE uid = ?',
        [widget.userId],
      );
      var branchIdResult = await conn.query(
        'SELECT bid FROM branch WHERE bname = ?',
        [selectedBranch],
      );

      var branchId = branchIdResult.first[0];

      var donorDOB = donorDOBResult.first[0] as DateTime;
      int organAge = calculateAgeFromBirthDate(donorDOB);

      var result = await conn.query(
        'INSERT INTO organ (oduid,ohla, obloodgroup, omedical_history, oage, organ_availability, organ_name, odonor_status) '
        'VALUES (?,?, ?, ?, ?, ?, ?, ?)',
        [
          widget.userId,
          ohlaController.text,
          selectedBloodGroup?.value ?? '',
          medicalHistory,
          organAge,
          1,
          selectedOrganName != null
              ? OrganNameExtension.getValue(selectedOrganName!)
              : '',
          selectedDonorStatus.toString().split('.').last.replaceAll('_', ' '),
        ],
      );

      if (result.affectedRows == 1) {
        int? organId = result.insertId;

        await conn.query(
          'INSERT INTO donor (duid, doid, date_of_donation) '
          'VALUES (?, ?, NOW())',
          [
            widget.userId,
            organId,
          ],
        );

        await conn.query(
          'INSERT INTO available (branch_id, organ_id) VALUES (?, ?)',
          [branchId, organId],
        );

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Success'),
            content: Text('Donor registration successful.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      } else {
        // Organ insertion failed
        // Check the trigger message for details
        var triggerMessageResult = await conn.query(
          'SELECT trigger_message FROM organ WHERE oid = ?',
          [result.insertId],
        );

        if (triggerMessageResult.isNotEmpty) {
          var triggerMessage = triggerMessageResult.first['trigger_message'];
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Error'),
              content: Text('Organ insertion failed. Reason: $triggerMessage'),
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

      await conn.close();
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('An error occurred during donor registration: $e'),
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

  int calculateAgeFromBirthDate(DateTime birthDate) {
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    if (currentDate.month < birthDate.month ||
        (currentDate.month == birthDate.month &&
            currentDate.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register as Donor'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: ohlaController,
              decoration: InputDecoration(labelText: 'OHLA (Sequence of AGTC)'),
            ),
            DropdownButtonFormField<OrganName>(
              value: selectedOrganName,
              onChanged: (newValue) {
                setState(() {
                  selectedOrganName = newValue;
                });
              },
              items: OrganName.values
                  .map<DropdownMenuItem<OrganName>>((OrganName value) {
                return DropdownMenuItem<OrganName>(
                  value: value,
                  child: Text(value.toString().split('.').last),
                );
              }).toList(),
              decoration: InputDecoration(labelText: 'Organ Name'),
            ),
            // Dropdowns for Blood Group, Antibody Screening, and Donor Status
            // ...
            DropdownButtonFormField<BloodGroup>(
              value: selectedBloodGroup,
              onChanged: (newValue) {
                setState(() {
                  selectedBloodGroup = newValue;
                });
              },
              items: BloodGroup.values
                  .map<DropdownMenuItem<BloodGroup>>((BloodGroup value) {
                return DropdownMenuItem<BloodGroup>(
                  value: value,
                  child: Text(value.toString().split('.').last),
                );
              }).toList(),
              decoration: InputDecoration(labelText: 'Blood Group'),
            ),

            DropdownButtonFormField<AntibodyScreening>(
              value: selectedAntibodyScreening,
              onChanged: (newValue) {
                setState(() {
                  selectedAntibodyScreening = newValue;
                });
              },
              items: AntibodyScreening.values
                  .map<DropdownMenuItem<AntibodyScreening>>(
                      (AntibodyScreening value) {
                return DropdownMenuItem<AntibodyScreening>(
                  value: value,
                  child: Text(value.toString().split('.').last),
                );
              }).toList(),
              decoration: InputDecoration(labelText: 'Antibody Screening'),
            ),

            DropdownButtonFormField<HIVStatus>(
              value: selectedHIVStatus,
              onChanged: (newValue) {
                setState(() {
                  selectedHIVStatus = newValue;
                });
              },
              items: HIVStatus.values
                  .map<DropdownMenuItem<HIVStatus>>((HIVStatus value) {
                return DropdownMenuItem<HIVStatus>(
                  value: value,
                  child: Text(value.toString().split('.').last),
                );
              }).toList(),
              decoration: InputDecoration(labelText: 'HIV Status'),
            ),

            DropdownButtonFormField<HepatitisBStatus>(
              value: selectedHepatitisBStatus,
              onChanged: (newValue) {
                setState(() {
                  selectedHepatitisBStatus = newValue;
                });
              },
              items: HepatitisBStatus.values
                  .map<DropdownMenuItem<HepatitisBStatus>>(
                      (HepatitisBStatus value) {
                return DropdownMenuItem<HepatitisBStatus>(
                  value: value,
                  child: Text(value.toString().split('.').last),
                );
              }).toList(),
              decoration: InputDecoration(labelText: 'Hepatitis B Status'),
            ),

            DropdownButtonFormField<HepatitisCStatus>(
              value: selectedHepatitisCStatus,
              onChanged: (newValue) {
                setState(() {
                  selectedHepatitisCStatus = newValue;
                });
              },
              items: HepatitisCStatus.values
                  .map<DropdownMenuItem<HepatitisCStatus>>(
                      (HepatitisCStatus value) {
                return DropdownMenuItem<HepatitisCStatus>(
                  value: value,
                  child: Text(value.toString().split('.').last),
                );
              }).toList(),
              decoration: InputDecoration(labelText: 'Hepatitis C Status'),
            ),

            DropdownButtonFormField<DonorStatus>(
              value: selectedDonorStatus,
              onChanged: (newValue) {
                setState(() {
                  selectedDonorStatus = newValue;
                });
              },
              items: DonorStatus.values
                  .map<DropdownMenuItem<DonorStatus>>((DonorStatus value) {
                return DropdownMenuItem<DonorStatus>(
                  value: value,
                  child: Text(value.toString().split('.').last),
                );
              }).toList(),
              decoration: InputDecoration(labelText: 'Donor Status'),
            ),
            DropdownButtonFormField<String>(
              value: selectedBranch,
              onChanged: (newValue) {
                setState(() {
                  selectedBranch = newValue;
                });
              },
              items: branchNames.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: InputDecoration(labelText: 'Branch Name'),
            ),

            ElevatedButton(
              onPressed: _registerDonor,
              child: Text('Register Donor'),
            ),
          ],
        ),
      ),
    );
  }
}
