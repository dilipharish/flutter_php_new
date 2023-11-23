import 'package:flutter/material.dart';
import 'package:flutter_php_new/admin_ops/organ_allocation.dart';
import 'package:flutter_php_new/constants.dart';
import 'package:lottie/lottie.dart';
import 'package:mysql1/mysql1.dart';

class DonorDetailsDialog extends StatefulWidget {
  final List<Map<String, dynamic>> donors;

  DonorDetailsDialog({required this.donors});

  @override
  _DonorDetailsDialogState createState() => _DonorDetailsDialogState();
}

class _DonorDetailsDialogState extends State<DonorDetailsDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Donors Details'),
      content: Container(
        width: 300, // Adjust the width as needed
        child: Scrollbar(
          child: SingleChildScrollView(
            child: Column(
              children: widget.donors.map((donor) {
                return ListTile(
                  title: Text('User Name: ${donor['user_name']}'),
                  subtitle: Text('Organs: ${donor['organ_names']}'),
                );
              }).toList(),
            ),
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Close'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

class AdminHomeScreen extends StatefulWidget {
  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  Future<List<Map<String, dynamic>>> _fetchDonors() async {
    final connection = await MySqlConnection.connect(settings);
    try {
      var results = await connection.query(
          'SELECT Users.name AS user_name, GROUP_CONCAT(Organ.organ_name SEPARATOR ", ") AS organs FROM Users JOIN Organ ON Users.uid = Organ.oduid WHERE (SELECT COUNT(*) FROM Organ WHERE oduid = Users.uid) > 4 GROUP BY Users.name;');

      // Convert ResultRow objects to Map<String, dynamic>
      List<Map<String, dynamic>> donors = [];
      for (var row in results) {
        Map<String, dynamic> donorMap = {
          'user_name': row['user_name'],
          'organ_names': row['organs'],
        };
        donors.add(donorMap);
      }

      return donors;
    } catch (e) {
      print('Error: $e');
      return [];
    } finally {
      await connection.close();
    }
  }

  Future<List<Map<String, dynamic>>> _fetchUsersNotConsultingDoctor() async {
    final connection = await MySqlConnection.connect(settings);
    try {
      var results = await connection.query(
          'SELECT DISTINCT users.uid, Users.name FROM Users WHERE NOT EXISTS (SELECT * FROM Consultation WHERE user_id = Users.uid);');

      // Convert ResultRow objects to Map<String, dynamic>
      List<Map<String, dynamic>> users = [];
      for (var row in results) {
        Map<String, dynamic> userMap = {
          'uid': row['uid'],
          'user_name': row['name'],
        };
        users.add(userMap);
      }

      return users;
    } catch (e) {
      print('Error: $e');
      return [];
    } finally {
      await connection.close();
    }
  }

  Future<List<Map<String, dynamic>>> _fetchUsersNotDonorOrReceiver() async {
    final connection = await MySqlConnection.connect(settings);
    try {
      var results = await connection.query(
          'SELECT U.uid, U.name, U.phone_number, U.email FROM Users U WHERE U.uid NOT IN (SELECT duid FROM Donor UNION SELECT ruid FROM Receiver);');

      // Convert ResultRow objects to Map<String, dynamic>
      List<Map<String, dynamic>> users = [];
      for (var row in results) {
        Map<String, dynamic> userMap = {
          'uid': row['uid'],
          'user_name': row['name'],
          'phone_number': row['phone_number'],
          'email': row['email'],
        };
        users.add(userMap);
      }

      return users;
    } catch (e) {
      print('Error: $e');
      return [];
    } finally {
      await connection.close();
    }
  }

  Future<List<Map<String, dynamic>>>
      _fetchDoctorsConsultingMultipleAgeGroups() async {
    final connection = await MySqlConnection.connect(settings);
    try {
      var results = await connection.query('''
      SELECT D.doctor_id,D.doctor_name
      FROM Doctor D
      JOIN Consultation C ON D.doctor_id = C.doctor_id
      JOIN Users U ON C.user_id = U.uid
      GROUP BY D.doctor_id, D.doctor_name
      HAVING COUNT(DISTINCT CASE
        WHEN U.date_of_birth BETWEEN DATE_SUB(DATE(NOW()), INTERVAL 40 YEAR) AND DATE_SUB(DATE(NOW()), INTERVAL 30 YEAR) THEN '30-40'
        WHEN U.date_of_birth BETWEEN DATE_SUB(DATE(NOW()), INTERVAL 50 YEAR) AND DATE_SUB(DATE(NOW()), INTERVAL 41 YEAR) THEN '41-50'
        ELSE 'Other'
      END) > 1;
    ''');

      // Convert ResultRow objects to Map<String, dynamic>
      List<Map<String, dynamic>> doctors = [];
      for (var row in results) {
        Map<String, dynamic> doctorMap = {
          'doctor_id': row['doctor_id'],
          'doctor_name': row['doctor_name'],
        };
        doctors.add(doctorMap);
      }

      return doctors;
    } catch (e) {
      print('Error: $e');
      return [];
    } finally {
      await connection.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 1.65,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            OrganAllocationScreen(),
            Lottie.asset(
              'assets/admin_men.json',
              width: 200,
              height: 139,
              fit: BoxFit.cover,
            ),
            Divider(height: 1, thickness: 2, color: Colors.black),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    children: [
                      SizedBox(
                        height: 2,
                        width: 10,
                      ),
                      Column(
                        children: [
                          Image.asset(
                            'assets/karna_child.jpg',
                            width: 90, // Adjust width as needed
                            height: 90, // Adjust height as needed
                            fit: BoxFit.cover,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                        width: 10,
                      ),
                      Column(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return FutureBuilder(
                                    future: _fetchDonors(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                              ConnectionState.waiting ||
                                          snapshot.hasData == null) {
                                        return CircularProgressIndicator();
                                      } else {
                                        if (snapshot.data!.isEmpty) {
                                          return AlertDialog(
                                            title: Text('No Donors Found'),
                                            actions: <Widget>[
                                              TextButton(
                                                child: Text('Close'),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        } else {
                                          var donors = snapshot.data
                                              as List<Map<String, dynamic>>;
                                          return DonorDetailsDialog(
                                            donors: donors,
                                          );
                                        }
                                      }
                                    },
                                  );
                                },
                              );
                            },
                            child: Text('See Dana Veera'),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                        width: 10,
                      ),
                      Column(
                        children: [
                          Image.asset(
                            'assets/organ_donation_karna.jpg',
                            width: 90, // Adjust width as needed
                            height: 90, // Adjust height as needed
                            fit: BoxFit.cover,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                    width: 20,
                  ),
                  Center(
                    child: Row(
                      children: [
                        Lottie.asset(
                          'assets/hand_shaking.json',
                          width: 60,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(
                          height: 20,
                          width: 40,
                        ),
                        Image.asset(
                          'assets/karna.webp',
                          width: 160, // Adjust width as needed
                          height: 150, // Adjust height as needed
                          fit: BoxFit.cover,
                        ),
                        SizedBox(
                          height: 20,
                          width: 40,
                        ),
                        Lottie.asset(
                          'assets/hand_shaking.json',
                          width: 60,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 10, thickness: 2, color: Colors.black),
            SizedBox(
              height: 2,
              width: 40,
            ),
            Center(
              child: Row(
                children: [
                  SizedBox(
                    height: 2,
                    width: 80,
                  ),
                  Lottie.asset(
                    'assets/fear_of_doctor.json',
                    width: 80,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
              width: 50,
            ),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return FutureBuilder(
                      future: _fetchUsersNotConsultingDoctor(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                                ConnectionState.waiting ||
                            snapshot.hasData == null) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        } else {
                          if (snapshot.data!.isEmpty) {
                            return AlertDialog(
                              title: Text('No Users Found'),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('Close'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          } else {
                            var users =
                                snapshot.data as List<Map<String, dynamic>>;
                            return AlertDialog(
                              title: Text('Users Not Consulting Doctor'),
                              content: Container(
                                width: 300,
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: users.map((user) {
                                      return ListTile(
                                        title: Text('UID: ${user['uid']}'),
                                        subtitle: Text(
                                            'User Name: ${user['user_name']}'),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('Close'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          }
                        }
                      },
                    );
                  },
                );
              },
              child: Text('See Users Not Consulted Doctor'),
            ),
            Divider(height: 10, thickness: 2, color: Colors.black),
            Center(
              child: Row(
                children: [
                  SizedBox(
                    height: 10,
                    width: 110,
                  ),
                  Lottie.asset(
                    'assets/users_neither_donors_nor_receivers.json',
                    width: 150,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(
                    height: 10,
                    width: 80,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
              width: 80,
            ),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return FutureBuilder(
                      future: _fetchUsersNotDonorOrReceiver(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                                ConnectionState.waiting ||
                            snapshot.hasData == null) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        } else {
                          if (snapshot.data!.isEmpty) {
                            return AlertDialog(
                              title: Text('No Users Found'),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('Close'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          } else {
                            var users =
                                snapshot.data as List<Map<String, dynamic>>;
                            return AlertDialog(
                              title:
                                  Text('Users Neither  Donors Nor Receivers'),
                              content: Container(
                                width: 300,
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: users.map((user) {
                                      return ListTile(
                                        title: Text('UID: ${user['uid']}'),
                                        subtitle: Text(
                                            'User Name: ${user['user_name']}\n Phone Number:${user['phone_number']}\n Email:${user['email']}'),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('Close'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          }
                        }
                      },
                    );
                  },
                );
              },
              child: Text('See Users Neither Donors nor Receivers'),
            ),
            Divider(height: 10, thickness: 2, color: Colors.black),
            Center(
              child: Row(
                children: [
                  SizedBox(
                    height: 10,
                    width: 110,
                  ),
                  Lottie.asset(
                    'assets/admin_doctor_con.json',
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(
                    height: 10,
                    width: 80,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
              width: 80,
            ),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return FutureBuilder(
                      future: _fetchDoctorsConsultingMultipleAgeGroups(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                                ConnectionState.waiting ||
                            snapshot.hasData == null) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        } else {
                          if (snapshot.data!.isEmpty) {
                            return AlertDialog(
                              title: Text('No Doctors Found'),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('Close'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          } else {
                            var doctors =
                                snapshot.data as List<Map<String, dynamic>>;
                            return AlertDialog(
                              title: Text(
                                  'Doctors Consulting Multiple Age Groups'),
                              content: Container(
                                width: 30,
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: doctors.map((doctor) {
                                      return ListTile(
                                        title: Text(
                                            'Doctor Id :${doctor['doctor_id']}\nDoctor Name: ${doctor['doctor_name']}'),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('Close'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          }
                        }
                      },
                    );
                  },
                );
              },
              child: Text('See Doctors Consulting Multiple Age Groups'),
            ),
            Divider(height: 1, thickness: 2, color: Colors.black),
          ],
        ),
      ),
    );
  }
}
