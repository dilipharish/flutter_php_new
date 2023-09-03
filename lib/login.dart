// import 'package:flutter/material.dart';
// import 'package:mysql1/mysql1.dart';

// class LoginUser extends StatefulWidget {
//   const LoginUser({super.key});

//   @override
//   State<LoginUser> createState() => _LoginUserState();
// }

// abstract class _LoginUserState extends State<LoginUser> {
//   TextEditingController email = TextEditingController();
//   TextEditingController password = TextEditingController();
//   String status = '';
//   login() async {
//     try {
//       var settings = new ConnectionSettings(
//           host: '192.168.86.180',
//           port: 3306,
//           user: 'root',
//           password: '93420D@l',
//           db: 'flutter_test');
//       var connect = await MySqlConnection.connect(settings);
//       var result = connect.query(
//           "SELECT * FROM users where email = ${email.text} AND password=${password.text}");
//       print("result:${result}");
//     } catch (e) {
//       print("Exception in login function:$e");
//     }

//     @override
//     Widget build(BuildContext context) {
//       return MaterialApp(
//           home: Scaffold(
//               body: Center(
//                   child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           TextField(
//             controller: email,
//           ),
//           TextField(
//             controller: password,
//           ),
//           ElevatedButton(onPressed: login, child: Text('Login')),
//           Text('$status'),
//         ],
//       ))));
//     }
//   }
// }
