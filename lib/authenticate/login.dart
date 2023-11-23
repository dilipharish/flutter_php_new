// ignore_for_file: avoid_print, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_php_new/admin_ops/admin_home.dart';
import 'package:flutter_php_new/homepage.dart';
import 'package:flutter_php_new/authenticate/registration1.dart';
import 'package:flutter_php_new/provider.dart';
import 'package:mysql1/mysql1.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import 'package:flutter_php_new/constants.dart';
import 'package:provider/provider.dart';

class LoginUser extends StatefulWidget {
  const LoginUser({Key? key}) : super(key: key);

  @override
  State<LoginUser> createState() => _LoginUserState();
}

class _LoginUserState extends State<LoginUser> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  String status = '';
  String adminPassword = 'admin123';

  Future<void> login() async {
    try {
      settings;

      final connect = await MySqlConnection.connect(settings);
      final result = await connect.query(
        "SELECT * FROM users WHERE email = ? AND password = ?",
        [email.text, password.text],
      );

      if (result.isNotEmpty) {
        setState(() {
          final userIdL = result.first['uid'] as int;
          final userName = result.first['name'] as String;
          final userEmail = result.first['email'] as String;
          final userDobRaw = result.first['date_of_birth'] as DateTime?;
          // Format the date_of_birth to a string using Dart's built-in DateTime methods

          final userdob = userDobRaw != null
              ? '${userDobRaw.year}-${userDobRaw.month}-${userDobRaw.day}'
              : ''; // Use empty string if date_of_birth is null
          final useraddress = result.first['address'] as String;
          final userphonenumber = result.first['phone_number'] as String;
          print(userName +
              userphonenumber +
              useraddress +
              userIdL.toString() +
              userEmail +
              userdob);

          Provider.of<UserDataProvider>(context, listen: false).updateUserData(
            UserData(
              name: userName,
              email: userEmail,
              dob: userdob,
              address: useraddress,
              phoneNumber: userphonenumber,
            ),
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => HomePage(userId: userIdL),
            ),
          );
        });
      } else {
        setState(() {
          status = 'Login failed';
        });
      }

      await connect.close();
    } catch (e) {
      print("Exception in login function: $e");
      setState(() {
        status = 'An error occurred during login';
      });
    }
  }

  // Function to navigate to the registration page
  void _navigateToRegistrationPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const RegistrationPage(
          title: 'Registeration page',
        ),
      ),
    );
  }

  void _showAdminDialog(BuildContext context) {
    TextEditingController adminPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Admin Password'),
          content: TextField(
            controller: adminPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Submit'),
              onPressed: () {
                if (adminPasswordController.text == adminPassword) {
                  Navigator.of(context).pop(); // Close the password dialog
                  // Navigate to the admin screen
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => AdminScreen(),
                    ),
                  );
                } else {
                  // Show an error message for incorrect password
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Incorrect password. Please try again.'),
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Login Page'),
          backgroundColor: Colors.red,
        ),
        backgroundColor: Color.fromARGB(255, 231, 171, 104),
        body: Scrollbar(
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Text(
                  //   'Organ And Blood Donation Save Lives',
                  //   textAlign: TextAlign.center,
                  //   style: TextStyle(
                  //     fontSize: 24, // Change the font size
                  //     fontWeight:
                  //         FontWeight.bold, // Set the font weight to bold
                  //     color: Color.fromARGB(
                  //         255, 225, 220, 89), // Set the text color to blue
                  //     fontStyle:
                  //         FontStyle.italic, // Set the font style to italic
                  //     letterSpacing: 1.5, // Add letter spacing
                  //     decoration:
                  //         TextDecoration.underline, // Add underline decoration
                  //     decorationColor:
                  //         Colors.red, // Set the underline color to red
                  //     decorationStyle:
                  //         TextDecorationStyle.double, // Set the underline style
                  //     // Add shadow
                  //   ),
                  // ),
                  // Image.asset(
                  //   'assets/organ_image.jpg',
                  //   width: 240,
                  //   height: 150,
                  // ),
                  Text(
                    "Organ Donation Save Lifes",
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.purpleAccent,
                        fontSize: 23),
                  ),
                  Lottie.asset(
                    'assets/animation_lnj2ixl8.json',
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  TextField(
                    controller: email,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter your email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 30.0),
                  TextField(
                    controller: password,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  ElevatedButton(onPressed: login, child: const Text('Login')),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () {
                      _showAdminDialog(context);
                    },
                    child: Text('Admin?', style: TextStyle(fontSize: 18)),
                  ),
                  Text(status),
                  SizedBox(
                    height: 20.0,
                  ),
                  Text("New Users,Click Down button to Register"),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _navigateToRegistrationPage,
          tooltip: 'Register New User',
          child: const Icon(Icons.person_add),
        ),
      ),
    );
  }
}
