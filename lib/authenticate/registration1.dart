// ignore_for_file: use_build_context_synchronously, avoid_print, unnecessary_string_interpolations, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_php_new/constants.dart';
import 'package:flutter_php_new/homepage.dart';
import 'package:mysql1/mysql1.dart';

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
  String result = '';

  Future<void> _registerUser() async {
    try {
      var settings1 = settings;
      final conn = await MySqlConnection.connect(settings1);

      // Check if a user with the same name and email already exists
      final checkResult = await conn.query(
        'SELECT * FROM users WHERE  email = ?',
        [email.text],
      );

      if (checkResult.isNotEmpty) {
        setState(() {
          result = 'User with the same  email already exists';
        });
      } else {
        // If no user with the same name and email exists, proceed with registration
        final queryResult = await conn.query(
          'INSERT INTO users (name, email, password) VALUES (?, ?, ?)',
          [name.text, email.text, password.text],
        );

        if (queryResult.affectedRows! > 0) {
          final insertedIdResult =
              await conn.query('SELECT LAST_INSERT_ID() as id');
          final userId1 = insertedIdResult.first['id'];
          setState(() {
            result = 'Registration successful';
          });

          // Navigate to the homepage after successful registration
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Register a New User:',
            ),
            TextFormField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextFormField(
              controller: email,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              controller: password,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            Text(
              '$result',
              style: Theme.of(context).textTheme.headline6,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _registerUser,
        tooltip: 'Register',
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
