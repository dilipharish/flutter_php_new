import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_php_new/screens/organdailogdonor.dart';
import 'package:flutter_php_new/screens/unallocated_receivers.dart';
import 'package:lottie/lottie.dart';
import 'package:mysql1/mysql1.dart'; // Import MySQL package
import 'package:flutter_php_new/constants.dart'; // Import your provider file

class DonorsDialog extends StatelessWidget {
  final List<Map<String, dynamic>> donors;

  DonorsDialog({required this.donors});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Blood Donors List'),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: Scrollbar(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                columns: const <DataColumn>[
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Phone Number')),
                  DataColumn(label: Text('Address')),
                  DataColumn(label: Text('Age')),
                  DataColumn(label: Text('Medical History')),
                  DataColumn(label: Text('Blood Group')),
                ],
                rows: donors.map((donor) {
                  return DataRow(
                    cells: <DataCell>[
                      DataCell(Text(donor['name'] ?? 'N/A')),
                      DataCell(Text(donor['phone_number'] ?? 'N/A')),
                      DataCell(Text(donor['address'] ?? 'N/A')),
                      DataCell(Text(donor['age']?.toString() ?? 'N/A')),
                      DataCell(Text(donor['omedical_history'] ?? 'N/A')),
                      DataCell(Text(donor['obloodgroup'] ?? 'N/A')),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class SearchScreen extends StatefulWidget {
  final int userId;

  SearchScreen({required this.userId});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late String selectedBloodType = 'A+';
  // Default selected blood type
  late String selectedOrganName = 'Left_Kidney';
  late int selectedAge = 25;

  // Future<void> _fetchOrganDonors(
  //     String bloodType, String organName, int age) async {
  //   // Establish a database connection
  //   final MySqlConnection conn = await MySqlConnection.connect(settings);

  //   try {
  //     // Fetch compatible organ donors based on the selected blood type, organ name, and age
  //     var results = await conn.query(
  //       'CALL GetOrganDonors(?, ?, ?)',
  //       [organName, bloodType, age],
  //     );

  //     // Check if results contain data
  //     if (results.isNotEmpty) {
  //       // Extract JSON blob from the row
  //       var jsonData =
  //           results.first[0]; // Assuming the JSON blob is in the first column

  //       // Parse JSON data
  //       var donorsData = json.decode(jsonData.toString());

  //       // Extract required values from JSON
  //       List<Map<String, dynamic>> donors = donorsData
  //           .map<Map<String, dynamic>>((item) => {
  //                 'name': item['name'],
  //                 'phone_number': item['phone_number'],
  //                 'address': item['address'],
  //                 'age': item['age'],
  //                 'omedical_history': item['omedical_history'],
  //                 'obloodgroup': item['obloodgroup'],
  //                 'organ_name': item['organ_name'],
  //               })
  //           .toList();

  //       // Remove duplicates based on 'name' field
  //       List<Map<String, dynamic>> uniqueDonors = [];

  //       for (var donor in donors) {
  //         if (!uniqueDonors
  //             .any((uniqueDonor) => uniqueDonor['name'] == donor['name'])) {
  //           uniqueDonors.add(donor);
  //         }
  //       }

  //       print(uniqueDonors); // Print the unique organ donors list

  //       // Show the organ donors dialog
  //       showDialog(
  //         context: context,
  //         builder: (BuildContext context) {
  //           return OrganDonorsDialog(donors: uniqueDonors);
  //         },
  //       );
  //     } else {
  //       print('No organ donors found for the selected criteria.');
  //     }
  //   } catch (e) {
  //     // Handle errors here
  //     print('Error fetching organ donors: $e');
  //   } finally {
  //     // Close the database connection
  //     await conn.close();
  //   }
  // }

  // void _showDonorsDialog(List<Map<String, dynamic>> donors) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return DonorsDialog(donors: donors);
  //     },
  //   );
  // }

  Future<void> _fetchDonors(String bloodType) async {
    // Establish a database connection
    final MySqlConnection conn = await MySqlConnection.connect(settings);

    try {
      // Fetch compatible donors based on the selected blood type
      var results = await conn
          .query('SELECT GetCompatibleDonorsForBloodGroup(?)', [bloodType]);
      print("Blood group results");
      print(results);

      // Check if results contain data
      if (results.isNotEmpty) {
        // Extract JSON blob from the row
        var jsonData =
            results.first[0]; // Assuming the JSON blob is in the first column

        // Parse JSON data
        var donorsData = json.decode(jsonData.toString());

        // Extract required values from JSON
        List<Map<String, dynamic>> donors = donorsData
            .map<Map<String, dynamic>>((item) => {
                  'name': item['name'],
                  'phone_number': item['phone_number'],
                  'address': item['address'],
                  'age': item['age'],
                  'omedical_history': item['omedical_history'],
                  'obloodgroup': item['obloodgroup'],
                })
            .toList();

        // Remove duplicates based on 'name' field
        List<Map<String, dynamic>> uniqueDonors = [];

        for (var donor in donors) {
          if (!uniqueDonors
              .any((uniqueDonor) => uniqueDonor['name'] == donor['name'])) {
            uniqueDonors.add(donor);
          }
        }

        print(uniqueDonors); // Print the unique donors list

        // Show the donors dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return DonorsDialog(donors: uniqueDonors);
          },
        );
      } else {
        print('No donors found for the selected blood type.');
      }
    } catch (e) {
      // Handle errors here
      print('Error fetching donors: $e');
    } finally {
      // Close the database connection
      await conn.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromARGB(255, 223, 157, 113),
      child: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height * 1.077,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Blood Donors"),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                DropdownButton<String>(
                                  value: selectedBloodType,
                                  onChanged: (newValue) {
                                    setState(() {
                                      selectedBloodType = newValue!;
                                    });
                                  },
                                  items: [
                                    'A+',
                                    'A-',
                                    'B+',
                                    'B-',
                                    'O+',
                                    'O-',
                                    'AB+',
                                    'AB-'
                                  ].map<DropdownMenuItem<String>>(
                                      (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: TextStyle(
                                          color: const Color.fromARGB(
                                              255,
                                              114,
                                              33,
                                              243), // Set your desired color here
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                // SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    _fetchDonors(selectedBloodType);
                                  },
                                  child: Text('See Blood Donors'),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                              width: 20), // Add spacing between the columns
                          Lottie.asset(
                            'assets/blood_drop.json',
                            width: 100,
                            height: 70,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Divider(
                      height: 1,
                      thickness: 2,
                      color: const Color.fromARGB(255, 16, 15, 15)),
                  Expanded(child: SearchoScreen()),
                  // Divider(
                  //     height: 10,
                  //     thickness: 2,
                  //     color: const Color.fromARGB(255, 16, 15, 15)),
                  Expanded(child: UnallocatedReceiversWidget()),
                  Divider(
                      height: 1,
                      thickness: 2,
                      color: const Color.fromARGB(255, 16, 15, 15)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
