import 'package:flutter/material.dart';
import 'package:flutter_php_new/authenticate/logout.dart';
import 'package:flutter_php_new/provider.dart';
import 'package:flutter_php_new/authenticate/resetpassword.dart';
import 'package:flutter_php_new/authenticate/updateprofilescreen.dart';
import 'package:mysql1/mysql1.dart';
import 'package:provider/provider.dart';
import 'constants.dart';
import 'bloodfunctions.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.userId}) : super(key: key);

  final int userId;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = '';
  String userEmail = '';
  String? selectedBloodGroup; // New variable to store selected blood group
  String? searchResult = ''; // Placeholder for search result

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

  Future<void> _searchDonor() async {
    if (selectedBloodGroup != null) {
      // Call the function from blood_functions.dart
      final result = await searchDonor(selectedBloodGroup!);

      setState(() {
        searchResult = result;
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

      setState(() {
        searchResult = result;
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
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              child: Text('Menu'),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 162, 121, 243),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        EditProfilePage(userId: widget.userId),
                  ),
                );
              },
              child: const ListTile(
                title: Text('Edit Profile'),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        ResetPasswordPage(userId: widget.userId),
                  ),
                );
              },
              child: const ListTile(
                title: Text('Reset Password'),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => LogoutPage(),
                  ),
                );
              },
              child: const ListTile(
                title: Text('Logout'),
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('User ID: ${widget.userId}'),
            Consumer<UserDataProvider>(
              builder: (context, userDataProvider, child) {
                return Column(
                  children: [
                    Text('Name: ${userDataProvider.userData.name}'),
                    Text('Email: ${userDataProvider.userData.email}'),
                  ],
                );
              },
            ),
            // Dropdown menu for selecting blood group
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButton<String>(
                hint: Text('Select Blood Group'),
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
                      child: const Text('Recipient'),
                    ),
                  ),
                ],
              ),
            ),

            // Placeholder for displaying search results
            Text(searchResult ?? ''),
          ],
        ),
      ),
    );
  }
}
