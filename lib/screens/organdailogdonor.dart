import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_php_new/constants.dart';
import 'package:lottie/lottie.dart';
import 'package:mysql1/mysql1.dart';

import 'package:flutter/material.dart';

class SearchoScreen extends StatefulWidget {
  @override
  _SearchoScreenState createState() => _SearchoScreenState();
}

class _SearchoScreenState extends State<SearchoScreen> {
  late String selectedBloodType = 'A+';
  late String selectedOrganName = 'Left_Kidney';
  late int selectedAge = 25;
  Future<void> _fetchOrganDonors(
      String bloodType, String organName, int age) async {
    // Establish a database connection
    final MySqlConnection conn = await MySqlConnection.connect(settings);

    try {
      // Fetch compatible organ donors based on the selected blood type, organ name, and age
      var results = await conn.query(
        'Select  getCompatibleOrganDonors(?, ?, ?)',
        [organName, bloodType, age],
      );

      // Check if results contain data
      if (results.isNotEmpty) {
        // Parse JSON directly from the result
        var jsonData = results.first[0];

        // Check if jsonData is a List
        var donorsData = json.decode(jsonData.toString());

        // Parse JSON data and extract required fields
        List<Map<String, dynamic>> donors = donorsData
            .map<Map<String, dynamic>>((item) => {
                  'name': item['name'],
                  'phone_number': item['phone_number'],
                  'address': item['address'],
                  'age': item['age'],
                  'omedical_history': item['omedical_history'],
                  'obloodgroup': item['obloodgroup'],
                  'organ_ohla': item['organ_ohla'],
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

        // Show the organ donors dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Organ Donors List'),
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
                          DataColumn(label: Text('Organ Name')),
                        ],
                        rows: uniqueDonors.map((donor) {
                          return DataRow(
                            cells: <DataCell>[
                              DataCell(Text(donor['name'] ?? 'N/A')),
                              DataCell(Text(donor['phone_number'] ?? 'N/A')),
                              DataCell(Text(donor['address'] ?? 'N/A')),
                              DataCell(Text(donor['age']?.toString() ?? 'N/A')),
                              DataCell(
                                  Text(donor['omedical_history'] ?? 'N/A')),
                              DataCell(Text(donor['obloodgroup'] ?? 'N/A')),
                              DataCell(Text(donor['organ_ohla'] ?? 'N/A')),
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
          },
        );
      } else {
        print('No organ donors found for the selected criteria.');
      }
    } catch (e) {
      // Handle errors here
      print('Error fetching organ donors: $e');
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Organ Donors"),
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
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: TextStyle(
                                        color: const Color.fromARGB(
                                            255, 114, 33, 243),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              // SizedBox(height: 20),
                              Row(
                                children: [
                                  DropdownButton<String>(
                                    value: selectedOrganName,
                                    onChanged: (newValue) {
                                      setState(() {
                                        selectedOrganName = newValue!;
                                      });
                                    },
                                    items: [
                                      'Left_Kidney',
                                      'Right_Kidney',
                                      'Eyes',
                                      'Heart',
                                      'Liver'
                                    ].map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                          style: TextStyle(
                                            color: const Color.fromARGB(
                                                255, 114, 33, 243),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  SizedBox(
                                    width: 40,
                                  ),
                                  Lottie.asset(
                                    'assets/liver.json',
                                    width: 110,
                                    height: 70,
                                  ),
                                ],
                              ),
                              // SizedBox(height: 2),
                              Row(
                                children: [
                                  Text('Age: '),
                                  DropdownButton<int>(
                                    value: selectedAge,
                                    onChanged: (newValue) {
                                      setState(() {
                                        selectedAge = newValue!;
                                      });
                                    },
                                    items: List.generate(100, (index) {
                                      return DropdownMenuItem<int>(
                                        value: index + 1,
                                        child: Text('${index + 1}'),
                                      );
                                    }),
                                  ),
                                  SizedBox(
                                    width: 90,
                                  ),
                                  Lottie.asset(
                                    'assets/kidney.json',
                                    width: 100,
                                    height: 60,
                                  ),
                                ],
                              ),
                              // SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {
                                  _fetchOrganDonors(selectedBloodType,
                                      selectedOrganName, selectedAge);
                                },
                                child: Text('See Organ Donors'),
                              ),
                            ],
                          ),
                        ),
                        // SizedBox(width: 20),
                        // Lottie.asset(
                        //   'assets/organ_donor.json',
                        //   width: 100,
                        //   height: 100,
                        // ),
                      ],
                    ),
                  ],
                ),
                Divider(
                  height: 10,
                  thickness: 2,
                  color: const Color.fromARGB(255, 16, 15, 15),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
