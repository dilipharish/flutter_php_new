import 'package:flutter/material.dart';
import 'package:flutter_php_new/bloodgroupfunctions.dart';
import 'package:flutter_php_new/constants.dart';
import 'package:flutter_php_new/provider.dart';
import 'package:mysql1/mysql1.dart';
import 'package:provider/provider.dart';

class Bloodmanagement_Page extends StatefulWidget {
  const Bloodmanagement_Page({Key? key, required this.userId})
      : super(key: key);
  final int userId;

  @override
  State<Bloodmanagement_Page> createState() => _Bloodmanagement_PageState();
}

class _Bloodmanagement_PageState extends State<Bloodmanagement_Page> {
  String userName = '';
  String userEmail = '';
  String? selectedBloodGroup; // New variable to store selected blood group
  String? searchResult = '';
  final GlobalKey<ScaffoldState> scaffoldKey =
      GlobalKey<ScaffoldState>(); // Placeholder for search result

  // Available blood group options
  final List<String> bloodGroupOptions = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      // Your MySQL connection settings
      settings;

      final conn = await MySqlConnection.connect(settings);
      final queryResult = await conn.query(
        'SELECT name, email FROM users WHERE id = ?',
        [widget.userId],
      );

      if (queryResult.isNotEmpty) {
        final user = queryResult.first;
        final userData = UserData(
          name: user['name'],
          email: user['email'],
          dob: user['dob'],
          address: '',
          phoneNumber: '',
        );
        Provider.of<UserDataProvider>(context, listen: false)
            .updateUserData(userData);
      }

      await conn.close();
    } catch (e) {
      print("Exception in fetching user data: $e");
    }
  }

  Future<void> _saveBloodGroup(String bloodGroup) async {
    // Call the function from blood_functions.dart
    await saveBloodGroup(widget.userId, bloodGroup);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Blood group saved successfully.'),
      ),
    );
  }

  void _showDonorsDialog(List<String> donorInfoList, String name) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$name List'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300, // Set the maximum height for the content
            child: Scrollbar(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0), // Add some padding
                  child: Table(
                    border: TableBorder.all(),
                    children: [
                      const TableRow(
                        children: [
                          TableCell(
                            child: Center(
                              child: Text(
                                'ID',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          TableCell(
                            child: Center(
                              child: Text(
                                'Name',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          TableCell(
                            child: Center(
                              child: Text(
                                'Blood Group',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                      for (final info in donorInfoList)
                        TableRow(
                          children: [
                            ..._buildTableCells(
                                info), // Create table cells for each piece of info
                          ],
                        ),
                    ],
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
  }

  List<Widget> _buildTableCells(String info) {
    final List<String> infoParts = info.split(',');
    final List<Widget> cells = [];

    // Ensure that each row has the same number of cells (ID, Name, Blood Group)
    for (int i = 0; i < 3; i++) {
      final String cellText = i < infoParts.length
          ? infoParts[i]
          : ''; // Fill with empty string if no data

      cells.add(
        TableCell(
          child: Center(
            child: Text(cellText),
          ),
        ),
      );
    }

    return cells;
  }

  Future<void> _searchDonor() async {
    if (selectedBloodGroup != null) {
      // Call the function from blood_functions.dart
      final result = await searchDonor(selectedBloodGroup!);

      // Split the result into a list of lines (each line contains donor info)
      final donorInfoList = result.split('\n');

      _showDonorsDialog(donorInfoList, 'Donors');

      setState(() {
        // searchResult = result;
      });
    } else {
      setState(() {
        searchResult = 'Please select a blood group to search.';
      });
    }
  }

  Future<void> _searchRecipient() async {
    if (selectedBloodGroup != null) {
      // Call the function from blood_functions.dart
      final result = await searchRecipient(selectedBloodGroup!);
      final donorInfoList = result.split('\n');

      _showDonorsDialog(donorInfoList, 'Recivers');

      setState(() {
        // searchResult = result;
      });
    } else {
      setState(() {
        searchResult = 'Please select a blood group to search.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text('Blood management'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Text('User ID: ${widget.userId}'),
            // Consumer<UserDataProvider>(
            //   builder: (context, userDataProvider, child) {
            //     return Column(
            //       children: [
            //         Text('Name: ${userDataProvider.userData.name}'),
            //         Text('Email: ${userDataProvider.userData.email}'),
            //       ],
            //     );
            //   },
            // ),
            // Dropdown menu for selecting blood group
            Image.network(
                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT8FIqFgl-QRg8_LSgVUD2RwDYCB06_JcpnYA&usqp=CAU'),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButton<String>(
                hint: const Text('Select Blood Group'),
                value: selectedBloodGroup,
                items: bloodGroupOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedBloodGroup = newValue;
                  });
                },
              ),
            ),
            // Button to save selected blood group
            ElevatedButton(
              onPressed: () {
                if (selectedBloodGroup != null) {
                  _saveBloodGroup(selectedBloodGroup!);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select a blood group.'),
                    ),
                  );
                }
              },
              child: const Text('Save Blood Group'),
            ),
            // Button to search for donors
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _searchDonor,
                      child: const Text('Search Donor'),
                    ),
                  ),
                  // Add some spacing between the buttons
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _searchRecipient,
                      child: const Text('Search Recipient'),
                    ),
                  ),
                ],
              ),
            ),

            // Placeholder for displaying search results
            // Text(searchResult ?? ''),
          ],
        ),
      ),
    );
  }
}
