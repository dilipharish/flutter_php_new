// class Donor {
//   final int id;
//   final String ohla;
//   final OrganName organName;
//   final BloodGroup organBloodGroup;
//   final HIVStatus hivStatus;
//   final HepatitisBStatus hepatitisBStatus;
//   final HepatitisCStatus hepatitisCStatus;
//   final DonorStatus donorStatus;
//   final AntibodyScreening
//       antibodyScreening; // Add this line to include antibodyScreening

//   Donor({
//     required this.id,
//     required this.ohla,
//     required this.organName,
//     required this.organBloodGroup,
//     required this.hivStatus,
//     required this.hepatitisBStatus,
//     required this.hepatitisCStatus,
//     required this.donorStatus,
//     required this.antibodyScreening, // Add this line to include antibodyScreening
//   });
// }

// class EditDonorScreen extends StatefulWidget {
//   final Donor donor;

//   EditDonorScreen({required this.donor});

//   @override
//   _EditDonorScreenState createState() => _EditDonorScreenState();
// }

// class _EditDonorScreenState extends State<EditDonorScreen> {
//   late TextEditingController _ohlaController;
//   OrganName? _selectedOrganName;
//   BloodGroup? _selectedBloodGroup;
//   AntibodyScreening? _selectedAntibodyScreening;
//   HIVStatus? _selectedHIVStatus;
//   HepatitisBStatus? _selectedHepatitisBStatus;
//   HepatitisCStatus? _selectedHepatitisCStatus;
//   DonorStatus? _selectedDonorStatus;

//   @override
//   void initState() {
//     super.initState();
//     _ohlaController = TextEditingController(text: widget.donor.ohla);
//     _selectedOrganName = widget.donor.organName as OrganName?;
//     _selectedBloodGroup = widget.donor.organBloodGroup as BloodGroup?;
//     _selectedAntibodyScreening = widget.donor.antibodyScreening;
//     _selectedHIVStatus = widget.donor.hivStatus;
//     _selectedHepatitisBStatus = widget.donor.hepatitisBStatus;
//     _selectedHepatitisCStatus = widget.donor.hepatitisCStatus;
//     _selectedDonorStatus = widget.donor.donorStatus as DonorStatus?;
//   }

//   Future<void> _updateDonorDetails() async {
//     try {
//       final MySqlConnection conn = await MySqlConnection.connect(settings);

//       // Update donor details in the database
//       await conn.query(
//         'UPDATE organ SET ohla = ?, organ_name = ?, obloodgroup = ?, '
//         'omedical_history = ?, odonor_status = ? '
//         'WHERE oid = ?',
//         [
//           _ohlaController.text,
//           _selectedOrganName.toString(),
//           _selectedBloodGroup.toString(),
//           _selectedAntibodyScreening.toString(),
//           _selectedHIVStatus.toString(),
//           _selectedHepatitisBStatus.toString(),
//           _selectedHepatitisCStatus.toString(),
//           _selectedDonorStatus.toString(),
//           widget.donor.id,
//         ],
//       );

//       // Close the database connection
//       await conn.close();

//       // Navigate back to the donor history screen
//       Navigator.of(context).pop();
//     } catch (e) {
//       // Handle error (show error message to user, log it, etc.)
//       print('Error updating donor details: $e');
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Text('Error'),
//           content:
//               Text('Failed to update donor details. Please try again later.'),
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

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Edit Donor Information'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Organ ID: ${widget.donor.id}',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 20,
//                   color: Colors.indigo,
//                 ),
//               ),
//               SizedBox(height: 12),
//               Text(
//                 'OHLA:',
//                 style: TextStyle(
//                   fontSize: 18,
//                   color: Colors.black,
//                 ),
//               ),
//               TextField(
//                 controller: _ohlaController,
//                 decoration: InputDecoration(
//                   hintText: 'Enter OHLA...',
//                 ),
//               ),
//               SizedBox(height: 12),
//               Text(
//                 'Organ Name:',
//                 style: TextStyle(
//                   fontSize: 18,
//                   color: Colors.black,
//                 ),
//               ),
//               DropdownButtonFormField<OrganName>(
//                 value: _selectedOrganName,
//                 onChanged: (newValue) {
//                   setState(() {
//                     _selectedOrganName = newValue;
//                   });
//                 },
//                 items: OrganName.values
//                     .map((value) => DropdownMenuItem<OrganName>(
//                           value: value,
//                           child: Text(value.toString().split('.').last),
//                         ))
//                     .toList(),
//                 decoration: InputDecoration(labelText: 'Organ Name'),
//               ),
//               // Other dropdowns and input fields for remaining enums...
//               ElevatedButton(
//                 onPressed: _updateDonorDetails,
//                 child: Text('Save Changes'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// 