// ignore_for_file: use_build_context_synchronously, avoid_print, unnecessary_string_interpolations, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_php_new/constants.dart';
import 'package:flutter_php_new/homepage.dart';
import 'package:mysql1/mysql1.dart';
import 'package:provider/provider.dart';

import '../provider.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController dob = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  DateTime? selectedDate; // Variable to store selected date

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dob.text = selectedDate!
            .toLocal()
            .toString()
            .split(' ')[0]; // Format the date and update the text field
      });
    }
  }

  String result = '';

  Future<void> _registerUser() async {
    try {
      var settings1 = settings;
      final conn = await MySqlConnection.connect(settings1);

      final checkResult = await conn.query(
        'SELECT * FROM users WHERE email = ?',
        [email.text],
      );

      if (checkResult.isNotEmpty) {
        setState(() {
          result = 'User with the same email already exists';
        });
      } else {
        final queryResult = await conn.query(
          'INSERT INTO users (name, email, password, date_of_birth, address, phone_number,date_of_user_registration) VALUES (?, ?, ?, ?, ?, ?, ?)',
          [
            name.text,
            email.text,
            password.text,
            dob.text,
            address.text,
            phoneNumber.text,
            DateTime.now().toString().split(' ')[0],
          ],
        );

        if (queryResult.affectedRows! > 0) {
          final insertedIdResult =
              await conn.query('SELECT LAST_INSERT_ID() as id');
          final userId1 = insertedIdResult.first['id'];

          Provider.of<UserDataProvider>(context, listen: false).updateUserData(
            UserData(
                name: name.text,
                email: email.text,
                dob: dob.text,
                address: address.text,
                phoneNumber: phoneNumber.text),
          );

          setState(() {
            result = 'Registration successful';
          });

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => HomePage(
                userId: userId1,
              ),
            ),
          );
        } else {
          setState(() {
            result = 'Registration failed';
          });
        }
      }

      await conn.close();
    } catch (e) {
      print("Exception in registration: $e");
      setState(() {
        result = 'An error occurred during registration';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Text(widget.title + 'Register and Save Lifes'),
        ),
        body: SingleChildScrollView(
          // Wrap with SingleChildScrollView to handle overflow
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Register a New User:',
                  ),
                  SizedBox(height: 20.0),
                  TextFormField(
                    controller: name,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                      hintText: 'Enter your name',
                      prefixIcon: Icon(Icons
                          .person), // Add an icon to the left of the input field
                    ),
                  ),
                  SizedBox(height: 20.0),
                  TextFormField(
                    controller: email,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      hintText: 'Enter your email',
                      prefixIcon: Icon(Icons
                          .email), // Add an icon to the left of the input field
                    ),
                  ),
                  SizedBox(height: 20.0),
                  TextFormField(
                    controller: password,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      hintText: 'Enter your password',
                      prefixIcon: Icon(Icons
                          .lock), // Add an icon to the left of the input field
                    ),
                  ),
                  SizedBox(height: 20.0),
                  InkWell(
                    onTap: () {
                      _selectDate(
                          context); // Call _selectDate function when tapped
                    },
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: dob,
                        decoration: const InputDecoration(
                          labelText: 'Date of Birth',
                          border: OutlineInputBorder(),
                          hintText: 'Select your date of birth',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  TextFormField(
                    controller: address,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(),
                      hintText: 'Enter your address',
                      prefixIcon: Icon(Icons.home),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  TextFormField(
                    controller: phoneNumber,
                    keyboardType: TextInputType.phone,
                    maxLength: 10, // Limit input to 10 digits
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                      hintText: 'Enter your phone number',
                      prefixIcon: Icon(Icons.phone),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    '$result',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _registerUser,
          tooltip: 'Register',
          child: const Icon(Icons.person_add),
        ));
  }
}
