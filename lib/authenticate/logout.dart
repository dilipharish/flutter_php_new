// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';

import 'regi1.dart';

class LogoutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logout'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Are you sure you want to logout?'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Perform logout actions here, e.g., clearing user data
                // Replace this with your actual logout logic
                // Example: Provider.of<UserDataProvider>(context, listen: false).clearUserData();

                // Navigate back to the login screen
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) =>
                        const LoginUser(), // Replace with your login screen widget
                  ),
                );
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
