import 'package:flutter/material.dart';
import 'package:flutter_php_new/constants.dart';
import 'package:mysql1/mysql1.dart';

class ResetPasswordPage extends StatefulWidget {
  final int userId;

  ResetPasswordPage({required this.userId});

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  String currentPassword = '';
  String newPassword = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextFormField(
              obscureText: true,
              onChanged: (value) {
                currentPassword = value;
              },
              decoration: InputDecoration(labelText: 'Current Password'),
            ),
            TextFormField(
              obscureText: true,
              onChanged: (value) {
                newPassword = value;
              },
              decoration: InputDecoration(labelText: 'New Password'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Validate current password against the user's actual password
                if (await _validateCurrentPassword(currentPassword)) {
                  if (newPassword.isNotEmpty) {
                    // Update the user's password
                    await _updatePassword(newPassword);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Password updated successfully.'),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('New password cannot be empty.'),
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Incorrect current password.'),
                    ),
                  );
                }
              },
              child: Text('Reset Password'),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _validateCurrentPassword(String currentPassword) async {
    try {
      // Your MySQL connection settings
      settings;

      final conn = await MySqlConnection.connect(settings);
      final queryResult = await conn.query(
        'SELECT * FROM users WHERE id = ? AND password = ?',
        [widget.userId, currentPassword],
      );

      await conn.close();

      return queryResult.isNotEmpty;
    } catch (e) {
      print("Exception in validating current password: $e");
      return false;
    }
  }

  Future<void> _updatePassword(String newPassword) async {
    try {
      // Your MySQL connection settings
      settings;

      final conn = await MySqlConnection.connect(settings);
      final queryResult = await conn.query(
        'UPDATE users SET password = ? WHERE id = ?',
        [newPassword, widget.userId],
      );

      await conn.close();
    } catch (e) {
      print("Exception in updating password: $e");
    }
  }
}
