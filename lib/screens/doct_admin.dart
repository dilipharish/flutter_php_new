  // Future<void> _showEditDoctorDialog(
  //     BuildContext context, DoctorDetails doctor) async {
  //   _doctorNameController.text = doctor.doctorName;
  //   _phoneNumberController.text = doctor.phoneNumber;

  //   await showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Edit Doctor Details'),
  //         content: Column(
  //           children: <Widget>[
  //             TextField(
  //               controller: _doctorNameController,
  //               decoration: InputDecoration(labelText: 'Doctor Name'),
  //             ),
  //             TextField(
  //               controller: _phoneNumberController,
  //               decoration: InputDecoration(labelText: 'Phone Number'),
  //               keyboardType: TextInputType.phone,
  //               maxLength: 10,
  //             ),
  //           ],
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: Text('Cancel'),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //           TextButton(
  //             child: Text('Save'),
  //             onPressed: () async {
  //               String updatedDoctorName = _doctorNameController.text.trim();
  //               String updatedPhoneNumber = _phoneNumberController.text.trim();

  //               // Validate and update doctor details in the database
  //               if (updatedDoctorName.isNotEmpty &&
  //                   updatedPhoneNumber.length == 10) {
  //                 await _updateDoctorDetails(
  //                     doctor.id, updatedDoctorName, updatedPhoneNumber);
  //                 Navigator.of(context).pop(); // Close the dialog
  //               } else {
  //                 ScaffoldMessenger.of(context).showSnackBar(
  //                   SnackBar(
  //                     content: Text('Invalid input. Please try again.'),
  //                   ),
  //                 );
  //               }
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // Future<void> _updateDoctorDetails(
  //     int doctorId, String updatedDoctorName, String updatedPhoneNumber) async {
  //   try {
  //     // Update the doctor table
  //     var doctorResult = await _conn.query(
  //       'UPDATE doctor SET doctor_name = ?, dphone_number = ? WHERE doctor_id = ?',
  //       [updatedDoctorName, updatedPhoneNumber, doctorId],
  //     );

  //     if (doctorResult.affectedRows! > 0) {
  //       // Doctor details updated successfully
  //       await _fetchDoctorDetails();
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Doctor details uploaded successfully.'),
  //         ),
  //       );
  //     } else {
  //       // Show error message if the update fails
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Failed to update doctor details. Please try again.'),
  //         ),
  //       );
  //     }
  //   } catch (error) {
  //     print('Error: $error');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('An error occurred while updating doctor details.'),
  //       ),
  //     );
  //   }
  // }
    // Future<void> _showAddDoctorDialog(BuildContext context) async {
  //   _doctorNameController.text = '';
  //   _phoneNumberController.text = '';

  //   await showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Add Doctor Details'),
  //         content: Column(
  //           children: <Widget>[
  //             TextField(
  //               controller: _doctorNameController,
  //               decoration: InputDecoration(labelText: 'Doctor Name'),
  //             ),
  //             TextField(
  //               controller: _phoneNumberController,
  //               decoration: InputDecoration(labelText: 'Phone Number'),
  //               keyboardType: TextInputType.phone,
  //               maxLength: 10,
  //             ),
  //           ],
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: Text('Cancel'),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //           TextButton(
  //             child: Text('Save'),
  //             onPressed: () async {
  //               String doctorName = _doctorNameController.text.trim();
  //               String phoneNumber = _phoneNumberController.text.trim();

  //               // Validate and save doctor details to the database
  //               if (doctorName.isNotEmpty && phoneNumber.length == 10) {
  //                 await _addDoctorDetails(doctorName, phoneNumber);
  //                 Navigator.of(context).pop(); // Close the dialog
  //               } else {
  //                 ScaffoldMessenger.of(context).showSnackBar(
  //                   SnackBar(
  //                     content: Text('Invalid input. Please try again.'),
  //                   ),
  //                 );
  //               }
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }