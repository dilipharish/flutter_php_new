import 'package:flutter/material.dart';
import 'package:flutter_php_new/constants.dart';
import 'package:lottie/lottie.dart';
import 'package:mysql1/mysql1.dart';

class DoctorDetails {
  final int id;
  final String doctorName;
  final String phoneNumber;

  DoctorDetails({
    required this.id,
    required this.doctorName,
    required this.phoneNumber,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DoctorDetails &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          doctorName == other.doctorName &&
          phoneNumber == other.phoneNumber;

  @override
  int get hashCode => id.hashCode ^ doctorName.hashCode ^ phoneNumber.hashCode;
}

class DoctorDropdownButton extends StatefulWidget {
  final List<DoctorDetails> doctors;
  final Function(DoctorDetails?) onChanged;
  final DoctorDetails? selectedDoctor;

  DoctorDropdownButton({
    required this.doctors,
    required this.onChanged,
    required this.selectedDoctor,
  });

  @override
  _DoctorDropdownButtonState createState() => _DoctorDropdownButtonState();
}

class _DoctorDropdownButtonState extends State<DoctorDropdownButton> {
  String _dropdownHint = 'Select a Doctor';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Scrollbar(
        child: DropdownButton<DoctorDetails>(
          items: widget.doctors.map((DoctorDetails doctor) {
            return DropdownMenuItem<DoctorDetails>(
              value: doctor,
              child: Text(doctor.doctorName),
            );
          }).toList(),
          onChanged: (DoctorDetails? doctor) {
            setState(() {
              widget.onChanged(doctor);
              _dropdownHint = doctor?.doctorName ?? 'Select a Doctor';
            });
          },
          hint: Text(_dropdownHint),
        ),
      ),
    );
  }
}

class DoctorScreen extends StatefulWidget {
  final int userId;

  DoctorScreen({required this.userId});

  @override
  _DoctorScreenState createState() => _DoctorScreenState();
}

class _DoctorScreenState extends State<DoctorScreen> {
  late MySqlConnection _conn;
  late TextEditingController _doctorNameController;
  late TextEditingController _phoneNumberController;
  DoctorDetails? selectedDoctor;

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
        'SELECT doctor.doctor_id, doctor.doctor_name, doctor.dphone_number, consultation.consultation_id FROM doctor INNER JOIN consultation ON doctor.doctor_id = consultation.doctor_id WHERE ${widget.userId} = ? AND consultation.user_id = ?',
        [widget.userId, widget.userId]);

    setState(() {
      doctorDetailsList = results.map((row) {
        return DoctorDetails(
          id: row[0],
          doctorName: row[1],
          phoneNumber: row[2],
        );
      }).toList();
    });
  }

  Future<void> _showAddDoctorToConsultationDialog(BuildContext context) async {
    // Fetch all doctors from the doctor table
    var results = await _conn.query(
        'SELECT doctor.doctor_id, doctor.doctor_name, doctor.dphone_number FROM doctor');

    List<DoctorDetails> allDoctors = results.map((row) {
      return DoctorDetails(
        id: row[0],
        doctorName: row[1],
        phoneNumber: row[2],
      );
    }).toList();

    DoctorDetails? selectedDoctor;

    // Show the dialog with all doctors available in the dropdown
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Doctor to My Consultation'),
          content: Column(
            children: <Widget>[
              DoctorDropdownButton(
                doctors: allDoctors,
                onChanged: (DoctorDetails? doctor) {
                  selectedDoctor = doctor;
                },
                selectedDoctor: selectedDoctor,
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
                if (selectedDoctor != null) {
                  // Add selected doctor to user's consultation
                  await _addDoctorToConsultation(selectedDoctor!);
                  Navigator.of(context).pop(); // Close the dialog
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please select a doctor.'),
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

  Future<void> _addDoctorToConsultation(DoctorDetails selectedDoctor) async {
    try {
      // Check if the selected doctor is already in the user's consultation
      bool isDoctorInConsultation =
          doctorDetailsList.any((doctor) => doctor.id == selectedDoctor.id);

      if (isDoctorInConsultation) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selected doctor is already in your consultation.'),
          ),
        );
      } else {
        // Insert selected doctor into user's consultation
        var consultationResult = await _conn.query(
          'INSERT INTO consultation (doctor_id, user_id) VALUES (?, ?)',
          [selectedDoctor.id, widget.userId],
        );

        if (consultationResult.affectedRows! > 0) {
          // Doctor added to consultation successfully
          await _fetchDoctorDetails();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Doctor added to your consultation.'),
            ),
          );
        } else {
          // Show error message if the insertion fails
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Failed to add doctor to your consultation. Please try again.'),
            ),
          );
        }
      }
    } catch (error) {
      print('Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'An error occurred while adding doctor to your consultation.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          color: Color.fromARGB(255, 233, 152, 105),
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Column(
                children: <Widget>[
                  Lottie.asset(
                    'assets/doctor_consult.json',
                    width: 100,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        'assets/doctor_screen_upload.json',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(width: 3),

                      ElevatedButton(
                        onPressed: () {
                          _showAddDoctorToConsultationDialog(context);
                        },
                        child: Text('Doctor Consultation'),
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
                        'assets/doctor_setascope.json',
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
                        return Card(
                          margin: EdgeInsets.all(8.0),
                          elevation: 4, // Adds a shadow to the Card
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          color: Color.fromARGB(255, 234, 166, 236),
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                                SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    // IconButton(
                                    //   icon: Icon(Icons.edit),
                                    //   onPressed: () {
                                    //     _showEditDoctorDialog(context, doctor);
                                    //   },
                                    // ),
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

  Future<void> _addDoctorDetails(String doctorName, String phoneNumber) async {
    try {
      // Insert into the doctor table
      var doctorResult = await _conn.query(
        'INSERT INTO doctor (doctor_name, dphone_number) VALUES (?, ?)',
        [doctorName, phoneNumber],
      );

      if (doctorResult.affectedRows! > 0) {
        // Get the newly inserted doctor_id
        int? doctorId = doctorResult.insertId;

        // Insert into the consultation table
        var consultationResult = await _conn.query(
          'INSERT INTO consultation (doctor_id, user_id) VALUES (?, ?)',
          [doctorId, widget.userId],
        );

        if (consultationResult.affectedRows! > 0) {
          // Doctor details added successfully
          await _fetchDoctorDetails();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Doctor details added successfully.'),
            ),
          );
        } else {
          // Show error message if the insertion into the consultation table fails
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add doctor details. Please try again.'),
            ),
          );
        }
      } else {
        // Show error message if the insertion into the doctor table fails
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

  Future<void> _deleteDoctorDetails(int doctorId) async {
    try {
      // Delete from the consultation table only
      var consultationResult = await _conn.query(
        'DELETE FROM consultation WHERE doctor_id = ?',
        [doctorId],
      );

      if (consultationResult.affectedRows! > 0) {
        // Doctor reference deleted from consultation table successfully
        await _fetchDoctorDetails();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Doctor removed from your consultation.'),
          ),
        );
      } else {
        // Show error message if the deletion fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to remove doctor from your consultation. Please try again.'),
          ),
        );
      }
    } catch (error) {
      print('Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'An error occurred while removing doctor from your consultation.'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _conn.close();
    _doctorNameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }
}
