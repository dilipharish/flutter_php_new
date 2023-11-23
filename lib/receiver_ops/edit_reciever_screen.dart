import 'package:flutter/material.dart';
import 'package:flutter_php_new/receiver_ops/receiver_enum.dart';
import 'package:mysql1/mysql1.dart';
import 'package:flutter_php_new/constants.dart';

class EditReceiverScreen extends StatefulWidget {
  final int receiverId;

  EditReceiverScreen({required this.receiverId});

  @override
  _EditReceiverScreenState createState() => _EditReceiverScreenState();
}

class _EditReceiverScreenState extends State<EditReceiverScreen> {
  TextEditingController rhlaController = TextEditingController();
  BloodGroup? selectedBloodGroup;
  OrganName? selectedOrganName;
  AntibodyScreening? selectedAntibodyScreening = AntibodyScreening.low;
  HIVStatus? selectedHIVStatus = HIVStatus.negative;
  HepatitisBStatus? selectedHepatitisBStatus = HepatitisBStatus.negative;
  HepatitisCStatus? selectedHepatitisCStatus = HepatitisCStatus.negative;

  @override
  void initState() {
    super.initState();
    // Fetch receiver details based on widget.receiverId and populate the form fields
    // You need to implement a method to fetch data from the database here
    fetchReceiverDetails();
  }

  Future<void> fetchReceiverDetails() async {
    try {
      final MySqlConnection conn = await MySqlConnection.connect(settings);

      var result = await conn.query(
        'SELECT rhla, rbloodgroup, rorgan_name, rmedical_history, age, '
        'antibody_screening, hiv_status, hepatitis_b_status, hepatitis_c_status '
        'FROM receiver WHERE receiver_id = ?',
        [widget.receiverId],
      );

      if (result.isNotEmpty) {
        var receiverData = result.first;
        rhlaController.text = receiverData['rhla'];
        selectedBloodGroup = BloodGroupExtension.getBloodGroupFromString(
            receiverData['rbloodgroup']);
        selectedOrganName = OrganNameExtension.getOrganNameFromString(
            receiverData['rorgan_name']);
        selectedAntibodyScreening = AntibodyScreening.values.firstWhere(
          (e) =>
              e.toString().split('.').last ==
              receiverData['antibody_screening'],
          orElse: () => AntibodyScreening.low,
        );
        selectedHIVStatus = HIVStatus.values.firstWhere(
          (e) => e.toString().split('.').last == receiverData['hiv_status'],
          orElse: () => HIVStatus.negative,
        );
        selectedHepatitisBStatus = HepatitisBStatus.values.firstWhere(
          (e) =>
              e.toString().split('.').last ==
              receiverData['hepatitis_b_status'],
          orElse: () => HepatitisBStatus.negative,
        );
        selectedHepatitisCStatus = HepatitisCStatus.values.firstWhere(
          (e) =>
              e.toString().split('.').last ==
              receiverData['hepatitis_c_status'],
          orElse: () => HepatitisCStatus.negative,
        );
      }

      await conn.close();
    } catch (e) {
      print('Error fetching receiver details: $e');
      // Handle error here
    }
  }

  Future<void> _updateReceiver() async {
    // Validate input fields
    if (rhlaController.text.isEmpty ||
        selectedBloodGroup == null ||
        selectedOrganName == null ||
        selectedAntibodyScreening == null ||
        selectedHIVStatus == null ||
        selectedHepatitisBStatus == null ||
        selectedHepatitisCStatus == null) {
      // Show an error dialog if any field is empty
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

    try {
      final conn = await MySqlConnection.connect(settings);

      // Prepare data to send to the server
      var result = await conn.query(
        'UPDATE receiver SET rorgan_name = ?, rhla = ?, rbloodgroup = ?, rmedical_history = ? '
        'WHERE receiver_id = ?',
        [
          OrganNameExtension.getValue(selectedOrganName!),
          rhlaController.text,
          selectedBloodGroup?.value ?? '',
          'Antibody Screening: ${selectedAntibodyScreening.toString().split('.').last}, '
              'HIV: ${selectedHIVStatus.toString().split('.').last}, '
              'Hepatitis B: ${selectedHepatitisBStatus.toString().split('.').last}, '
              'Hepatitis C: ${selectedHepatitisCStatus.toString().split('.').last}',
          widget.receiverId,
        ],
      );

      if (result.affectedRows == 1) {
        // Show a snackbar for successful update
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Receiver details updated successfully.'),
        ));

        // Navigate back to the previous screen
        Navigator.of(context).pop();
      } else {
        // Handle update failure
        _showErrorDialog('Receiver details update failed. Please try again.');
      }
    } catch (e) {
      // Handle database connection error and other exceptions
      print("Exception during receiver details update: $e");
      _showErrorDialog('An error occurred during receiver details update.,$e,');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Receiver'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: rhlaController,
              decoration: InputDecoration(labelText: 'RHLA (Sequence of AGTC)'),
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
            ElevatedButton(
              onPressed: _updateReceiver,
              child: Text('Update Receiver'),
            ),
          ],
        ),
      ),
    );
  }
}
