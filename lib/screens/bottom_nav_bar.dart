// import 'package:flutter/material.dart';
// import 'package:flutter_php_new/homepage.dart';
// import 'package:flutter_php_new/screens/history_screen.dart';
// import 'package:flutter_php_new/screens/doctor_screen.dart';
// import 'package:flutter_php_new/screens/search_screens.dart';

// class BottomNavBar extends StatefulWidget {
//   final int userId;

//   BottomNavBar({required this.userId});

//   @override
//   _BottomNavBarState createState() => _BottomNavBarState();
// }

// class _BottomNavBarState extends State<BottomNavBar> {
//   int _currentIndex = 0;
//   late List<Widget> _screens;

//   @override
//   void initState() {
//     super.initState();

//     _screens = [
//       HomePage(userId: widget.userId),
//       SearchScreen(userId: widget.userId),
//       HistoryScreen(),
//       DoctorScreen(),
//     ];
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _screens[_currentIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _currentIndex,
//         onTap: (index) {
//           setState(() {
//             _currentIndex = index;
//           });
//         },
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.search),
//             label: 'Search',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.history),
//             label: 'History',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.local_hospital),
//             label: 'Doctor',
//           ),
//         ],
//       ),
//     );
//   }
// }
