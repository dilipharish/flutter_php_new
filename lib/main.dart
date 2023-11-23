import 'package:flutter/material.dart';
import 'package:flutter_php_new/admin_ops/admin_home.dart';
import 'package:flutter_php_new/provider.dart';
import 'package:flutter_php_new/authenticate/login.dart';
import 'package:provider/provider.dart'; // Import your LoginUser widget
// import 'package:flutter_php_new/registration1.dart'; // Import your RegistrationPage widget

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserDataProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Organ Donation',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      routes: {
        '/login': (context) => LoginUser(),
        '/admin': (context) => AdminScreen(),
        // ... other routes ...
      },
      home: const LoginUser(),
      debugShowCheckedModeBanner: false,
      // Set the default home page to LoginUser
    );
  }
}

// ... Your LoginUser and RegistrationPage classes remain the same ...
