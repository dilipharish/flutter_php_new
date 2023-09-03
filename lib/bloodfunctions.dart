// blood_functions.dart

import 'package:mysql1/mysql1.dart';
import 'constants.dart';

// var settings = ConnectionSettings(
//   host: '192.168.119.180',
//   port: 3306,
//   user: 'root',
//   password: '93420D@l',
//   db: 'flutter_test',
// );
// Your MySQL connection settings

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
    final donors = <String>{};

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
        'SELECT name FROM users WHERE blood_group = ?',
        [bloodType],
      );

      for (final row in queryResult) {
        donors.add(row['name']);
      }
    }

    final donorCount = donors.length;

    await conn.close();

    if (donorCount > 0) {
      final donorList = donors.join(', ');
      return 'Compatible Donors for blood group $selectedBloodGroup ($donorCount donors): $donorList';
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
        'SELECT name FROM users WHERE blood_group = ?',
        [recipientBloodType],
      );

      for (final row in queryResult) {
        recipients.add(row['name']);
      }
    }

    final recipientCount = recipients.length;

    await conn.close();

    if (recipientCount > 0) {
      final recipientList = recipients.join(', ');
      return 'Compatible Recipients for blood group $selectedBloodGroup ($recipientCount recipients): $recipientList';
    } else {
      return 'No compatible recipients found for blood group $selectedBloodGroup';
    }
  } catch (e) {
    print("Exception in searching recipients: $e");
    return 'An error occurred while searching recipients.';
  }
}
