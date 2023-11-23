import 'package:flutter/material.dart';
import 'package:flutter_php_new/constants.dart';
import 'package:mysql1/mysql1.dart';

class UserData {
  String name;
  String email;
  String dob;
  String address;
  String phoneNumber;

  UserData({
    required this.name,
    required this.email,
    required this.dob,
    required this.address,
    required this.phoneNumber,
  });
}

class UserDataProvider with ChangeNotifier {
  UserData _userData =
      UserData(name: '', email: '', dob: '', phoneNumber: '', address: '');

  UserData get userData => _userData;

  Map<String, dynamic> _changes = {};

  Future<void> updateUserData(UserData newData) async {
    // Update the local data
    _userData = newData;
    notifyListeners();

    try {
      // Update the data in the database
      final conn = await MySqlConnection.connect(settings);

      //   await conn.query(
      //     'UPDATE users SET name = ?, email = ?, date_of_birth = ?, phone_number = ?, address = ? WHERE uid = ?',
      //     [
      //       newData.name,
      //       newData.email,
      //       newData.dob,
      //       newData.phoneNumber,
      //       newData.address,
      //     ],
      //   );

      //   await conn.close();
    } catch (e) {
      print("Exception in updating profile: $e");
      // Handle errors, e.g., show error message to the user
    }
  }

  void clearUserData() {
    _userData.name = '';
    _userData.email = '';
    _userData.address = '';
    _userData.dob = '';
    _userData.phoneNumber = '';
    _changes.clear(); // Clear changes when clearing user data
    notifyListeners();
  }

  void setChange(String key, dynamic value) {
    _changes[key] = value;
  }

  Map<String, dynamic> get changes => _changes;
}
