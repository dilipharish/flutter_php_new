import 'package:flutter/material.dart';
import 'package:flutter_php_new/provider.dart';
import 'package:flutter_php_new/regi1.dart';
import 'package:provider/provider.dart'; // Import your LoginUser widget
// import 'package:flutter_php_new/registration1.dart'; // Import your RegistrationPage widget

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserDataProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App Title',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: const LoginUser(),
      debugShowCheckedModeBanner: false,
      // Set the default home page to LoginUser
    );
  }
}

// ... Your LoginUser and RegistrationPage classes remain the same ...
