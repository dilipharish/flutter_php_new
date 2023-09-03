import 'package:flutter/material.dart';
import 'package:flutter_php_new/authenticate/logout.dart';

import 'package:flutter_php_new/provider.dart';
import 'package:flutter_php_new/authenticate/resetpassword.dart';
import 'package:flutter_php_new/authenticate/updateprofilescreen.dart';
import 'package:mysql1/mysql1.dart';
import 'package:provider/provider.dart';
import 'constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.userId}) : super(key: key);

  final int userId;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = '';
  String userEmail = '';

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

  void _navigateToEditProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditProfilePage(userId: widget.userId),
      ),
    );
  }

  // void _logout() {
  //   // Save any updates (if needed)
  //   // For example, you can update the user's data to a server

  //   // Clear user data (if needed)
  //   // Provider.of<UserDataProvider>(context, listen: false).clearUserData();

  //   // Navigate back to the login screen
  //   Navigator.of(context).pushReplacement(
  //     MaterialPageRoute(
  //       builder: (context) =>
  //           LoginUser(), // Replace with your login screen widget
  //     ),
  //   );
  // }

  Future<void> _resetPassword() async {
    String currentPassword = '';
    String newPassword = '';

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Reset Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                obscureText: true,
                onChanged: (value) {
                  currentPassword = value;
                },
                decoration: InputDecoration(labelText: 'Current Password'),
              ),
              TextFormField(
                obscureText: true,
                onChanged: (value) {
                  newPassword = value;
                },
                decoration: InputDecoration(labelText: 'New Password'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Validate current password against the user's actual password
                if (await _validateCurrentPassword(currentPassword)) {
                  if (newPassword.isNotEmpty) {
                    // Update the user's password
                    await _updatePassword(newPassword);
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('New password cannot be empty.'),
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Incorrect current password.'),
                    ),
                  );
                }
              },
              child: Text('Reset Password'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _validateCurrentPassword(String currentPassword) async {
    try {
      // Your MySQL connection settings
      settings;

      final conn = await MySqlConnection.connect(settings);
      final queryResult = await conn.query(
        'SELECT * FROM users WHERE id = ? AND password = ?',
        [widget.userId, currentPassword],
      );

      await conn.close();

      return queryResult.isNotEmpty;
    } catch (e) {
      print("Exception in validating current password: $e");
      return false;
    }
  }

  Future<void> _updatePassword(String newPassword) async {
    try {
      // Your MySQL connection settings
      settings;

      final conn = await MySqlConnection.connect(settings);
      final queryResult = await conn.query(
        'UPDATE users SET password = ? WHERE id = ?',
        [newPassword, widget.userId],
      );

      await conn.close();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password updated successfully.'),
        ),
      );
    } catch (e) {
      print("Exception in updating password: $e");
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
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
              child: ListTile(
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
              child: ListTile(
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
              child: ListTile(
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
          ],
        ),
      ),
    );
  }
}
