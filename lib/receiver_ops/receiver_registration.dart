import 'package:flutter/material.dart';
import 'package:flutter_php_new/constants.dart';
import 'package:mysql1/mysql1.dart';
import 'package:flutter_php_new/receiver_ops/receiver_enum.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// enum OrganName {
//   leftKidney,
//   rightKidney,
//   eyes,
//   heart,
//   liver,
//   blood,
// }

class ReceiverRegistrationPage extends StatefulWidget {
  final int userId;

  ReceiverRegistrationPage({required this.userId});

  @override
  _ReceiverRegistrationPageState createState() =>
      _ReceiverRegistrationPageState();
}

class _ReceiverRegistrationPageState extends State<ReceiverRegistrationPage> {
  TextEditingController rhlaController = TextEditingController();
  BloodGroup? selectedBloodGroup;
  OrganName? selectedOrganName;
  AntibodyScreening? selectedAntibodyScreening;
  HIVStatus? selectedHIVStatus;
  HepatitisBStatus? selectedHepatitisBStatus;
  HepatitisCStatus? selectedHepatitisCStatus; // Change the type to OrganName
  DateTime? dateOfDonation;

  Future<void> _registerReceiver() async {
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

      // Fetch date_of_birth from users table using ruid
      var userData = await conn.query(
        'SELECT date_of_birth FROM users WHERE uid = ?',
        [widget.userId],
      );

      if (userData.isNotEmpty) {
        var userRow = userData.first;
        DateTime dateOfBirth = userRow[
            0]; // Assuming date_of_birth is stored as DateTime in the database

        // Calculate age based on current date
        DateTime currentDate = DateTime.now();
        int age = currentDate.year -
            dateOfBirth.year -
            (currentDate.month > dateOfBirth.month ||
                    (currentDate.month == dateOfBirth.month &&
                        currentDate.day >= dateOfBirth.day)
                ? 0
                : 1);

        // Prepare data to send to the server
        // Map<String, dynamic> requestData = {
        //   'organ_name': OrganNameExtension.getValue(selectedOrganName!),
        //   'blood_group': selectedBloodGroup?.value ?? '',
        //   'antibody_screening':
        //       selectedAntibodyScreening.toString().split('.').last,
        //   'hiv_status': selectedHIVStatus.toString().split('.').last,
        //   'hepatitis_b_status':
        //       selectedHepatitisBStatus.toString().split('.').last,
        //   'hepatitis_c_status':
        //       selectedHepatitisCStatus.toString().split('.').last,
        //   'age': age, // Add age here
        // };

        // Organ is available and compatible, proceed with registration
        var result = await conn.query(
          'INSERT INTO receiver (ruid, rorgan_name, rhla, rbloodgroup, rmedical_history, rage) '
          'VALUES (?, ?, ?, ?, ?, ?)',
          [
            widget.userId,
            OrganNameExtension.getValue(selectedOrganName!),
            rhlaController.text,
            selectedBloodGroup?.value ?? '',
            'Antibody Screening: ${selectedAntibodyScreening.toString().split('.').last}, '
                'HIV: ${selectedHIVStatus.toString().split('.').last}, '
                'Hepatitis B: ${selectedHepatitisBStatus.toString().split('.').last}, '
                'Hepatitis C: ${selectedHepatitisCStatus.toString().split('.').last}',
            age,
          ],
        );

        if (result.affectedRows == 1) {
          // Show a snackbar for successful registration
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Receiver registration successful.'),
          ));

          // Navigate back to the previous screen
          Navigator.of(context).pop();
        } else {
          // Handle registration failure
          _showErrorDialog('Receiver registration failed. Please try again.');
        }
      } else {
        // Organ is not available or not compatible, show an error message
        _showErrorDialog('Organ is not available or not compatible.');
      }
    } catch (e) {
      // Handle database connection error and other exceptions
      print("Exception during receiver registration: $e");
      _showErrorDialog('An error occurred during receiver registration.,$e,');
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
        title: Text('Register as Receiver'),
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

            // ElevatedButton(
            //   onPressed: () async {
            //     final selectedDate = await showDatePicker(
            //       context: context,
            //       initialDate: DateTime.now(),
            //       firstDate: DateTime(1900),
            //       lastDate: DateTime(2100),
            //     );
            //     if (selectedDate != null && selectedDate != dateOfDonation) {
            //       setState(() {
            //         dateOfDonation = selectedDate;
            //       });
            //     }
            //   },
            //   child: Text(
            //     dateOfDonation == null
            //         ? 'Select Date of Donation'
            //         : 'Date of Donation: ${dateOfDonation!.toLocal()}',
            //   ),
            // ),
            ElevatedButton(
              onPressed: _registerReceiver,
              child: Text('Register Receiver'),
            ),
          ],
        ),
      ),
    );
  }
}
