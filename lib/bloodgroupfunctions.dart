// blood_functions.dart

// ignore_for_file: avoid_print, unnecessary_string_interpolations, unused_import

import 'package:mysql1/mysql1.dart';
import 'constants.dart';
import 'package:flutter_php_new/show2.dart';

Future<void> saveBloodGroup(int userId, String bloodGroup) async {
  try {
    final conn = await MySqlConnection.connect(settings);
    await conn.query(
      'UPDATE users SET blood_group = ? WHERE id = ?',
      [bloodGroup, userId],
    );
    await conn.close();
  } catch (e) {
    print("Exception in saving blood group: $e");
  }
}

Future<String> searchDonor(String selectedBloodGroup) async {
  try {
    final conn = await MySqlConnection.connect(settings);
    final donorsInfo = <String>[];

    final bloodTypeMap = {
      'A+': ['A+', 'A-', 'O+', 'O-'],
      'A-': ['A-', 'O-'],
      'B+': ['B+', 'B-', 'O+', 'O-'],
      'B-': ['B-', 'O-'],
      'AB+': ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'],
      'AB-': ['A-', 'B-', 'AB-', 'O-'],
      'O+': ['O+', 'O-'],
      'O-': ['O-'],
    };

    final canDonateTo = bloodTypeMap[selectedBloodGroup];

    for (final bloodType in canDonateTo!) {
      final queryResult = await conn.query(
        'SELECT id, name, blood_group FROM users WHERE blood_group = ?',
        [bloodType],
      );

      for (final row in queryResult) {
        final donorInfo = '${row['id']},${row['name']}, ${row['blood_group']}';
        donorsInfo.add(donorInfo);
      }
    }

    await conn.close();

    if (donorsInfo.isNotEmpty) {
      final donorList =
          donorsInfo.join('\n'); // Separate each donor's info with a newline
      return '$donorList';
    } else {
      return 'No donors found for blood group $selectedBloodGroup';
    }
  } catch (e) {
    print("Exception in searching donors: $e");
    return 'An error occurred while searching donors.';
  }
}

Future<String> searchRecipient(String selectedBloodGroup) async {
  try {
    final conn = await MySqlConnection.connect(settings);
    final recipients = <String>{};

    final compatibilityMap = {
      'A+': ['A+', 'AB+'],
      'A-': ['A+', 'A-', 'AB+', 'AB-'],
      'B+': ['B+', 'AB+'],
      'B-': ['B+', 'B-', 'AB+', 'AB-'],
      'AB+': ['AB+'],
      'AB-': ['AB+', 'AB-'],
      'O+': ['A+', 'B+', 'AB+', 'O+'],
      'O-': ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'],
    };

    final compatibleRecipients = compatibilityMap[selectedBloodGroup];

    for (final recipientBloodType in compatibleRecipients!) {
      final queryResult = await conn.query(
        'SELECT id, name, blood_group FROM users WHERE blood_group = ?',
        [recipientBloodType],
      );

      // for (final row in queryResult) {
      //   recipients.add(row['name']);
      // }
      for (final row in queryResult) {
        final recipInfo = '${row['id']},${row['name']}, ${row['blood_group']}';
        recipients.add(recipInfo);
      }
    }

    final recipientCount = recipients.length;

    await conn.close();

    if (recipientCount > 0) {
      final recipientList =
          recipients.join('\n'); // Separate each donor's info with a newline

      return '$recipientList';
    } else {
      return 'No compatible recipients found for blood group $selectedBloodGroup';
    }
  } catch (e) {
    print("Exception in searching recipients: $e");
    return 'An error occurred while searching recipients.';
  }
}
