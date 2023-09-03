import 'package:flutter/material.dart';
import 'package:flutter_php_new/regi1.dart'; // Import your LoginUser widget
// import 'package:flutter_php_new/registration1.dart'; // Import your RegistrationPage widget

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App Title',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginUser(), // Set the default home page to LoginUser
    );
  }
}

// ... Your LoginUser and RegistrationPage classes remain the same ...
