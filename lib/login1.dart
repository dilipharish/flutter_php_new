import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';

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
      var settings = ConnectionSettings(
        host: '192.168.86.180',
        port: 3306,
        user: 'root',
        password: '93420D@l',
        db: 'flutter_test',
      );

      final connect = await MySqlConnection.connect(settings);
      final result = await connect.query(
        "SELECT * FROM users WHERE email = ? AND password = ?",
        [email.text, password.text],
      );

      if (result.isNotEmpty) {
        setState(() {
          status = 'Login successful $result';
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
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
      ),
    );
  }
}
