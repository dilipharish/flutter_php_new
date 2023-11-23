import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_php_new/admin_ops/admin_branch.dart';
import 'package:flutter_php_new/admin_ops/admin_doctor.dart';
import 'package:flutter_php_new/admin_ops/admin_graph.dart';
import 'package:flutter_php_new/admin_ops/admin_home_screen.dart';
import 'package:lottie/lottie.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _currentIndex = 0;

  // List of widgets/screens for each index of the bottom navigation bar
  late List<Widget> _children;
  late List<AppBar> _appBars;

  @override
  void initState() {
    super.initState();
    _children = [
      AdminHomeScreen(),
      BranchScreen(),
      AdminGraphScreen(),
      AdminDoctorScreen(),
    ];
    _appBars = [
      AppBar(
        title: Text(
          'Admin Home Page',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 222, 62, 62),
      ),
      AppBar(
        title: Text('Branch'),
        backgroundColor: Color.fromARGB(
            255, 222, 62, 62), // Set the background color to green
      ),
      AppBar(
        title: Text('Statistics'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 147, 231, 248),
      appBar: _appBars[_currentIndex],
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
                color: Color.fromARGB(255, 243, 33, 33),
              ),
            ),
            ListTile(
              title: Text(
                'Log Out',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              onTap: () {
                // Log out and navigate back to the login page
                Navigator.of(context).pushReplacementNamed('/login');
              },
            ),
          ],
        ),
      ),
      body: Container(
        color: Color.fromARGB(255, 147, 231, 248),
        child: Center(
          child: _children[_currentIndex],
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        color: Colors.green, // Background color of the navigation bar
        buttonBackgroundColor:
            Color.fromARGB(255, 218, 45, 45), // Background color of the items
        height: 50,
        items: <Widget>[
          Icon(Icons.admin_panel_settings,
              size: 24, color: Color.fromARGB(255, 244, 245, 244)), // Home icon
          Icon(Icons.business_sharp,
              size: 24, color: Colors.white), // Search icon
          Icon(Icons.auto_graph_rounded,
              size: 24, color: Colors.white), // History icon
          Icon(Icons.local_hospital_rounded,
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
