// import 'package:flutter/material.dart';
// import 'package:flutter_php_new/constants.dart';
// import 'package:mysql1/mysql1.dart';
// import 'package:intl/intl.dart';
// import 'dart:convert';

// enum OrganName { heart, leftKidney, rightKidney, eyes }

// enum BloodGroup {
//   APositive,
//   ANegative,
//   BPositive,
//   BNegative,
//   OPositive,
//   ONegative,
//   ABPositive,
//   ABNegative,
// }

// extension BloodGroupExtension on BloodGroup {
//   String get value {
//     switch (this) {
//       case BloodGroup.APositive:
//         return 'A+';
//       case BloodGroup.ANegative:
//         return 'A-';
//       case BloodGroup.BPositive:
//         return 'B+';
//       case BloodGroup.BNegative:
//         return 'B-';
//       case BloodGroup.OPositive:
//         return 'O+';
//       case BloodGroup.ONegative:
//         return 'O-';
//       case BloodGroup.ABPositive:
//         return 'AB+';
//       case BloodGroup.ABNegative:
//         return 'AB-';
//       default:
//         return '';
//     }
//   }
// }

// enum AntibodyScreening { low, medium, high }

// enum DonorStatus {
//   liveDonor,

//   cardiacDeath,

//   brainDeath,
// }

// class JsonValue {
//   const JsonValue(String s);
// }

// class DonorRegistrationPage extends StatefulWidget {
//   final int userId;

//   DonorRegistrationPage({required this.userId});

//   @override
//   _DonorRegistrationPageState createState() => _DonorRegistrationPageState();
// }

// class _DonorRegistrationPageState extends State<DonorRegistrationPage> {
//   TextEditingController ohlaController = TextEditingController();
//   OrganName? selectedOrganName;
//   BloodGroup? selectedBloodGroup;
//   AntibodyScreening? selectedAntibodyScreening;
//   DonorStatus? selectedDonorStatus;

//   Future<void> _registerDonor() async {
//     // Validate input fields
//     if (ohlaController.text.isEmpty ||
//         selectedOrganName == null ||
//         selectedBloodGroup == null ||
//         selectedAntibodyScreening == null ||
//         selectedDonorStatus == null) {
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Text('Error'),
//           content: Text('Please fill in all the fields.'),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('OK'),
//             ),
//           ],
//         ),
//       );
//       return;
//     }

//     try {
//       final conn = await MySqlConnection.connect(settings);

//       // Insert into organ table
//       var result = await conn.query(
//         'INSERT INTO organ (ohla, obloodgroup, omedical_history, oage, organ_availability, organ_name) '
//         'VALUES (?, ?, ?, ?, ?, ?)',
//         [
//           ohlaController.text,
//           selectedBloodGroup.toString().split('.').last,
//           selectedAntibodyScreening.toString().split('.').last,
//           calculateAgeFromBirthDate(), // Implement this function to calculate age
//           true,
//           selectedOrganName.toString().split('.').last,
//         ],
//       );

//       if (result.affectedRows == 1) {
//         var organId = result.insertId;

//         // Insert into donor table
//         await conn.query(
//           'INSERT INTO donor (duid, doid, date_of_donation, donor_status) '
//           'VALUES (?, ?, NOW(), ?)',
//           [
//             widget.userId,
//             organId,
//             selectedDonorStatus.toString().split('.').last,
//           ],
//         );

//         showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: Text('Success'),
//             content: Text('Donor registration successful.'),
//             actions: <Widget>[
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: Text('OK'),
//               ),
//             ],
//           ),
//         );
//       } else {
//         showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: Text('Error'),
//             content: Text('Donor registration failed. Please try again.'),
//             actions: <Widget>[
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: Text('OK'),
//               ),
//             ],
//           ),
//         );
//       }

//       await conn.close();
//     } catch (e) {
//       print("Exception during donor registration: $e");
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Text('Error'),
//           content: Text('An error occurred during donor registration.'),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('OK'),
//             ),
//           ],
//         ),
//       );
//     }
//   }

//   int calculateAgeFromBirthDate() {
//     // Implement this function to calculate age from the user's birthdate
//     // Example:
//     // DateTime birthDate = ...; // Get the birthdate from user input
//     // DateTime currentDate = DateTime.now();
//     // int age = currentDate.year - birthDate.year;
//     // if (currentDate.month < birthDate.month || (currentDate.month == birthDate.month && currentDate.day < birthDate.day)) {
//     //   age--;
//     // }
//     // return age;
//     return 0; // Placeholder, replace with actual implementation
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Register as Donor'),
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           children: <Widget>[
//             TextField(
//               controller: ohlaController,
//               decoration: InputDecoration(labelText: 'OHLA (Sequence of AGTC)'),
//             ),
//             DropdownButtonFormField<OrganName>(
//               value: selectedOrganName,
//               onChanged: (newValue) {
//                 setState(() {
//                   selectedOrganName = newValue;
//                 });
//               },
//               items: OrganName.values
//                   .map<DropdownMenuItem<OrganName>>((OrganName value) {
//                 return DropdownMenuItem<OrganName>(
//                   value: value,
//                   child: Text(value.toString().split('.').last),
//                 );
//               }).toList(),
//               decoration: InputDecoration(labelText: 'Organ Name'),
//             ),
//             // Dropdowns for Blood Group, Antibody Screening, and Donor Status
//             // ...
//             DropdownButtonFormField<BloodGroup>(
//               value: selectedBloodGroup,
//               onChanged: (newValue) {
//                 setState(() {
//                   selectedBloodGroup = newValue;
//                 });
//               },
//               items: BloodGroup.values
//                   .map<DropdownMenuItem<BloodGroup>>((BloodGroup value) {
//                 return DropdownMenuItem<BloodGroup>(
//                   value: value,
//                   child: Text(value.toString().split('.').last),
//                 );
//               }).toList(),
//               decoration: InputDecoration(labelText: 'Blood Group'),
//             ),

//             DropdownButtonFormField<AntibodyScreening>(
//               value: selectedAntibodyScreening,
//               onChanged: (newValue) {
//                 setState(() {
//                   selectedAntibodyScreening = newValue;
//                 });
//               },
//               items: AntibodyScreening.values
//                   .map<DropdownMenuItem<AntibodyScreening>>(
//                       (AntibodyScreening value) {
//                 return DropdownMenuItem<AntibodyScreening>(
//                   value: value,
//                   child: Text(value.toString().split('.').last),
//                 );
//               }).toList(),
//               decoration: InputDecoration(labelText: 'Antibody Screening'),
//             ),

//             DropdownButtonFormField<DonorStatus>(
//               value: selectedDonorStatus,
//               onChanged: (newValue) {
//                 setState(() {
//                   selectedDonorStatus = newValue;
//                 });
//               },
//               items: DonorStatus.values
//                   .map<DropdownMenuItem<DonorStatus>>((DonorStatus value) {
//                 return DropdownMenuItem<DonorStatus>(
//                   value: value,
//                   child: Text(value.toString().split('.').last),
//                 );
//               }).toList(),
//               decoration: InputDecoration(labelText: 'Donor Status'),
//             ),

//             ElevatedButton(
//               onPressed: _registerDonor,
//               child: Text('Register Donor'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
