import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_php_new/provider.dart';
import 'package:provider/provider.dart';

import 'login.dart';

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
                final userDataProvider =
                    Provider.of<UserDataProvider>(context, listen: false);

                // Clear user data using the clearUserData method
                userDataProvider.clearUserData();

                // Exit the app completely
                exit(0);
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
