import 'package:flutter/material.dart';
import 'package:flutter_php_new/constants.dart';
import 'package:lottie/lottie.dart';
import 'package:mysql1/mysql1.dart';

class DoctorDetails {
  final int id;
  final String doctorName;
  final String phoneNumber;
  final int? totalConsultations;

  DoctorDetails({
    required this.id,
    required this.doctorName,
    required this.phoneNumber,
    this.totalConsultations,
  });
}

class AdminDoctorScreen extends StatefulWidget {
  @override
  _AdminDoctorScreenState createState() => _AdminDoctorScreenState();
}

class _AdminDoctorScreenState extends State<AdminDoctorScreen> {
  late MySqlConnection _conn;
  late TextEditingController _doctorNameController;
  late TextEditingController _phoneNumberController;

  List<DoctorDetails> doctorDetailsList = [];

  @override
  void initState() {
    super.initState();
    _initializeDatabaseConnection();
    _doctorNameController = TextEditingController();
    _phoneNumberController = TextEditingController();
  }

  Future<void> _initializeDatabaseConnection() async {
    _conn = await MySqlConnection.connect(settings);
    await _fetchDoctorDetails();
  }

  Future<void> _fetchDoctorDetails() async {
    var results = await _conn.query(
      'SELECT doctor.doctor_id, doctor.doctor_name, doctor.dphone_number, COUNT(consultation.consultation_id) as totalConsultations FROM doctor LEFT JOIN consultation ON doctor.doctor_id = consultation.doctor_id GROUP BY doctor.doctor_id',
    );

    setState(() {
      doctorDetailsList = results.map((row) {
        return DoctorDetails(
          id: row[0],
          doctorName: row[1],
          phoneNumber: row[2],
          totalConsultations: row[3],
        );
      }).toList();
    });
  }

  Future<void> _showAddDoctorDialog(BuildContext context) async {
    _doctorNameController.text = '';
    _phoneNumberController.text = '';

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Doctor Details'),
          content: Column(
            children: <Widget>[
              TextField(
                controller: _doctorNameController,
                decoration: InputDecoration(labelText: 'Doctor Name'),
              ),
              TextField(
                controller: _phoneNumberController,
                decoration: InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                maxLength: 10,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () async {
                String doctorName = _doctorNameController.text.trim();
                String phoneNumber = _phoneNumberController.text.trim();

                // Validate and save doctor details to the database
                if (doctorName.isNotEmpty && phoneNumber.length == 10) {
                  await _addDoctorDetails(doctorName, phoneNumber);
                  Navigator.of(context).pop(); // Close the dialog
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Invalid input. Please try again.'),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _addDoctorDetails(String doctorName, String phoneNumber) async {
    try {
      // Insert into the doctor table
      var doctorResult = await _conn.query(
        'INSERT INTO doctor (doctor_name, dphone_number) VALUES (?, ?)',
        [doctorName, phoneNumber],
      );

      if (doctorResult.affectedRows! > 0) {
        // Doctor details added successfully
        await _fetchDoctorDetails();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Doctor details added successfully.'),
          ),
        );
      } else {
        // Show error message if the insertion fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add doctor details. Please try again.'),
          ),
        );
      }
    } catch (error) {
      print('Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred while adding doctor details.'),
        ),
      );
    }
  }

  Future<void> _showEditDoctorDialog(
      BuildContext context, DoctorDetails doctor) async {
    _doctorNameController.text = doctor.doctorName;
    _phoneNumberController.text = doctor.phoneNumber;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Doctor Details'),
          content: Column(
            children: <Widget>[
              TextField(
                controller: _doctorNameController,
                decoration: InputDecoration(labelText: 'Doctor Name'),
              ),
              TextField(
                controller: _phoneNumberController,
                decoration: InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                maxLength: 10,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () async {
                String updatedDoctorName = _doctorNameController.text.trim();
                String updatedPhoneNumber = _phoneNumberController.text.trim();

                // Validate and update doctor details in the database
                if (updatedDoctorName.isNotEmpty &&
                    updatedPhoneNumber.length == 10) {
                  await _updateDoctorDetails(
                      doctor.id, updatedDoctorName, updatedPhoneNumber);
                  Navigator.of(context).pop(); // Close the dialog
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Invalid input. Please try again.'),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateDoctorDetails(
      int doctorId, String updatedDoctorName, String updatedPhoneNumber) async {
    try {
      // Update the doctor table
      var doctorResult = await _conn.query(
        'UPDATE doctor SET doctor_name = ?, dphone_number = ? WHERE doctor_id = ?',
        [updatedDoctorName, updatedPhoneNumber, doctorId],
      );

      if (doctorResult.affectedRows! > 0) {
        // Doctor details updated successfully
        await _fetchDoctorDetails();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Doctor details updated successfully.'),
          ),
        );
      } else {
        // Show error message if the update fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update doctor details. Please try again.'),
          ),
        );
      }
    } catch (error) {
      print('Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred while updating doctor details.'),
        ),
      );
    }
  }

  Future<void> _deleteDoctorDetails(int doctorId) async {
    try {
      if ([2, 5, 6, 9, 10].contains(doctorId)) {
        // Do not delete permanent doctors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Permanent doctors cannot be deleted.'),
          ),
        );
      } else {
        // Call stored procedure to delete doctor and redistribute data
        await _conn.query(
          'CALL DeleteDoctorAndRedistributeConsultations(?)',
          [doctorId],
        );

        // Check if the doctor was deleted successfully in the database
        bool isDeleted = await _checkDoctorDeletion(doctorId);

        if (isDeleted) {
          // Remove the deleted doctor from the doctorDetailsList
          setState(() {
            doctorDetailsList.removeWhere((doctor) => doctor.id == doctorId);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Doctor deleted successfully.'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete doctor. Please try again.'),
            ),
          );
        }
      }
    } catch (error) {
      print('Error in deleting doctor: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred while deleting doctor.'),
        ),
      );
    }
  }

  Future<bool> _checkDoctorDeletion(int doctorId) async {
    // Check if the doctor with given doctorId still exists in the database
    var results = await _conn.query(
      'SELECT * FROM doctor WHERE doctor_id = ?',
      [doctorId],
    );

    return results.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          color: Color.fromARGB(255, 147, 231, 248),
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Column(
                children: <Widget>[
                  Lottie.asset(
                    'assets/admin_doctor.json',
                    width: 180,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        'assets/admin_doctor_injection.json',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(width: 3),

                      ElevatedButton(
                        onPressed: () {
                          _showAddDoctorDialog(context);
                        },
                        child: Text('Add Doctor'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ), // Adjust padding as needed
                        ),
                      ),
                      SizedBox(
                          width:
                              7), // Add some horizontal space between the animations
                      Lottie.asset(
                        'assets/admin_nurse.json',
                        width: 60,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ],
                  ),
                  Divider(height: 10, thickness: 2, color: Colors.black),
                  Expanded(
                    child: ListView.builder(
                      itemCount: doctorDetailsList.length,
                      itemBuilder: (context, index) {
                        var doctor = doctorDetailsList[index];
                        bool isPermanentDoctor =
                            [2, 5, 6, 9, 10].contains(doctor.id);

                        return Card(
                          margin: EdgeInsets.all(8.0),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          color: Color.fromARGB(255, 240, 183, 114),
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Doctor Id:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  doctor.id.toString(),
                                  style: TextStyle(fontSize: 16),
                                ),
                                Text(
                                  'Doctor Name:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  doctor.doctorName,
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Phone Number:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  doctor.phoneNumber,
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Total Consultations: ${doctor.totalConsultations ?? 'N/A'}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        _showEditDoctorDialog(context, doctor);
                                      },
                                    ),
                                    // Render delete button only if the doctor is not permanent
                                    if (!isPermanentDoctor)
                                      IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () {
                                          _deleteDoctorDetails(doctor.id);
                                        },
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _conn.close();
    _doctorNameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }
}
