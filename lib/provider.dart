import 'package:flutter/material.dart';

class UserData {
  String name;
  String email;

  UserData({required this.name, required this.email});
}

class UserDataProvider with ChangeNotifier {
  UserData _userData = UserData(name: '', email: '');

  UserData get userData => _userData;

  void updateUserData(UserData newData) {
    _userData = newData;
    notifyListeners();
  }
}
