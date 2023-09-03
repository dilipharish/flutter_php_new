import 'package:flutter/material.dart';
import 'package:flutter_php_new/constants.dart';
import 'package:mysql1/mysql1.dart';

class EditProfilePage extends StatefulWidget {
  final int userId;

  EditProfilePage({required this.userId});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch the user's existing data based on the userId and populate the form fields.
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      settings;

      final conn = await MySqlConnection.connect(settings);
      final queryResult = await conn.query(
        'SELECT name, email FROM users WHERE id = ?',
        [widget.userId],
      );

      if (queryResult.isNotEmpty) {
        final user = queryResult.first;
        setState(() {
          nameController.text = user['name'];
          emailController.text = user['email'];
        });
      }

      await conn.close();
    } catch (e) {
      print("Exception in fetching user data: $e");
    }
  }

  Future<void> _updateProfile() async {
    try {
      settings;

      final conn = await MySqlConnection.connect(settings);

      // Check if the updated email already exists (excluding the current user's email)
      final checkResult = await conn.query(
        'SELECT * FROM users WHERE email = ? AND id != ?',
        [emailController.text, widget.userId],
      );

      if (checkResult.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email already exists. Update failed.'),
          ),
        );
      } else {
        final queryResult = await conn.query(
          'UPDATE users SET name = ?, email = ? WHERE id = ?',
          [
            nameController.text,
            emailController.text,
            widget.userId,
          ],
        );

        if (queryResult.affectedRows! > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Profile updated successfully'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update profile'),
            ),
          );
        }
      }

      await conn.close();
    } catch (e) {
      print("Exception in updating profile: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            ElevatedButton(
              onPressed: _updateProfile,
              child: Text('Update Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
