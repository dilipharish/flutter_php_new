// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors_in_immutables, library_private_types_in_public_api, avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_php_new/constants.dart';
import 'package:flutter_php_new/provider.dart';
import 'package:mysql1/mysql1.dart';
import 'package:provider/provider.dart';

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
  TextEditingController phoneNumberController = TextEditingController();
  // TextEditingController dobController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  DateTime? selectedDate;

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
        'SELECT name, email, phone_number, date_of_birth, address FROM users WHERE uid = ?',
        [widget.userId],
      );

      if (queryResult.isNotEmpty) {
        final user = queryResult.first;
        setState(() {
          nameController.text = user['name'];
          emailController.text = user['email'];
          phoneNumberController.text = user['phone_number'];
          // Parse the date_of_birth string into DateTime
          addressController.text = user['address'].toString();
          selectedDate = user['date_of_birth'];
        });
      }

      await conn.close();
    } catch (e) {
      // print("Exception in fetching user data: $e");
    }
  }

  Future<void> _updateProfile() async {
    try {
      settings;

      final conn = await MySqlConnection.connect(settings);

      // Check if the updated email already exists (excluding the current user's email)
      final checkResult = await conn.query(
        'SELECT * FROM users WHERE email = ? AND uid != ?',
        [emailController.text, widget.userId],
      );

      if (checkResult.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email already exists. Update failed.'),
          ),
        );
      } else {
        final queryResult = await conn.query(
          'UPDATE users SET name = ?, email = ?, phone_number = ?, date_of_birth = ?, address = ? WHERE uid = ?',
          [
            nameController.text,
            emailController.text,
            phoneNumberController.text,
            selectedDate!.toLocal().toString().split(' ')[0],
            addressController.text,
            widget.userId,
          ],
        );

        if (queryResult.affectedRows! > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update profile'),
            ),
          );
        }
      }

      await conn.close();
    } catch (e) {}
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<UserDataProvider>(
          builder: (context, userDataProvider, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: nameController,
                  onChanged: (value) {
                    userDataProvider.setChange('name', value);
                  },
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: emailController,
                  onChanged: (value) {
                    userDataProvider.setChange('email', value);
                  },
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: phoneNumberController,
                  onChanged: (value) {
                    userDataProvider.setChange('phoneNumber', value);
                  },
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                ),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: TextField(
                      controller: TextEditingController(
                          text: selectedDate?.toString() ?? ''),
                      decoration:
                          const InputDecoration(labelText: 'Date of Birth'),
                    ),
                  ),
                ),
                TextField(
                  controller: addressController,
                  onChanged: (value) {
                    userDataProvider.setChange('address', value);
                  },
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Apply the changes to the user data

                    _updateProfile();
                    UserData newData = UserData(
                      name: nameController.text,
                      email: emailController.text,
                      dob: selectedDate!.toLocal().toString().split(' ')[0],
                      address: addressController.text,
                      phoneNumber: phoneNumberController.text,
                    );
                    // Update the user data provider with the new data
                    userDataProvider.updateUserData(newData);

                    // Show a snackbar with the changes made
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   SnackBar(
                    //     content: Text(
                    //         'Profile updated with changes: ${userDataProvider.changes}'),
                    //   ),
                    // );
                  },
                  child: const Text('Update Profile'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
