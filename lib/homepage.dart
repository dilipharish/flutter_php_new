import 'package:flutter/material.dart';
import 'package:flutter_php_new/authenticate/logout.dart';
import 'package:flutter_php_new/authenticate/resetpassword.dart';
import 'package:flutter_php_new/authenticate/updateprofilescreen.dart';
import 'package:flutter_php_new/homepagebody.dart';
import 'package:flutter_php_new/provider.dart';
import 'package:flutter_php_new/screens/bottom_nav_bar.dart';
import 'package:flutter_php_new/screens/doctor_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_php_new/donor_ops/donor_registration.dart'; // Import donor registration page
import 'package:flutter_php_new/receiver_ops/receiver_registration.dart'; // Import receiver registration page
import 'package:flutter_php_new/search_ops/view_donors_receivers.dart'; // Import view donors/receivers page
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import 'screens/history_screen.dart';
import 'screens/search_screens.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.userId}) : super(key: key);

  final int userId;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // List of widgets/screens for each index of the bottom navigation bar
  late List<Widget> _children;
  late List<AppBar> _appBars;

  @override
  void initState() {
    super.initState();
    _children = [
      HomePageBody(
        userId: widget.userId,
      ), // Widget for Home icon
      SearchScreen(
        userId: widget.userId,
      ), // Widget for Search icon
      HistoryScreen(userId: widget.userId),
      // Widget for History icon
      DoctorScreen(userId: widget.userId),
      // Widget for Doctor icon
    ];
    _appBars = [
      AppBar(
        title: Text(
          'Home Page',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 222, 62, 62),
      ),
      AppBar(
        title: Text('Search'),
        backgroundColor: Color.fromARGB(
            255, 222, 62, 62), // Set the background color to green
      ),
      AppBar(
        title: Text('History'),
        backgroundColor: Color.fromARGB(
            255, 222, 62, 62), // Set the background color to green
      ),
      AppBar(
        title: Text('Doctor'),
        backgroundColor: Color.fromARGB(
            255, 222, 62, 62), // Set the background color to green
      ),
    ];
  }

  Future<void> _refreshData() async {
    // Simulate a delay to show the refresh indicator for a brief moment.
    await Future.delayed(Duration(seconds: 2));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBars[_currentIndex],
      backgroundColor: Color.fromARGB(255, 233, 152, 105),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.red,
              ),
            ),
            ListTile(
              title: Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        EditProfilePage(userId: widget.userId),
                  ),
                );
              },
            ),
            ListTile(
              title: Text(
                'Reset Password',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        ResetPasswordPage(userId: widget.userId),
                  ),
                );
              },
            ),
            ListTile(
              title: Text(
                'Logout',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => LogoutPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
            // gradient: LinearGradient(
            //   begin: Alignment.topRight,
            //   end: Alignment.bottomLeft,
            //   colors: [
            //     Colors.blue, Colors.purple // Dark blue color at the bottom
            //   ],
            // ),
            ),
        child: _children[_currentIndex],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        color: Colors.green, // Background color of the navigation bar
        buttonBackgroundColor:
            Color.fromARGB(255, 218, 45, 45), // Background color of the items
        height: 50,
        items: <Widget>[
          Icon(Icons.home,
              size: 24, color: Color.fromARGB(255, 244, 245, 244)), // Home icon
          Icon(Icons.search, size: 24, color: Colors.white), // Search icon
          Icon(Icons.history, size: 24, color: Colors.white), // History icon
          Icon(Icons.health_and_safety,
              size: 24, color: Colors.white), // Doctor icon
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
