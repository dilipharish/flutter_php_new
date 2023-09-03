import 'package:flutter/material.dart';
import 'package:flutter_php_new/homepage.dart';
import 'package:flutter_php_new/authenticate/registration1.dart';
import 'package:mysql1/mysql1.dart';

import 'package:flutter_php_new/constants.dart';

class LoginUser extends StatefulWidget {
  const LoginUser({Key? key}) : super(key: key);

  @override
  State<LoginUser> createState() => _LoginUserState();
}

class _LoginUserState extends State<LoginUser> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  String status = '';

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
          final userIdL = result.first['id'] as int;
          // Now you have the userId as an int, you can use it as needed
          // For example, you can navigate to the HomePage and pass userId as an argument
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
        builder: (context) => RegistrationPage(
          title: 'Registeration page',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Login Page'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                controller: email,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: password,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password'),
              ),
              ElevatedButton(onPressed: login, child: Text('Login')),
              Text(status),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed:
              _navigateToRegistrationPage, // Navigate to registration page
          tooltip: 'Register New User',
          child: const Icon(Icons.person_add),
        ),
      ),
    );
  }
}
