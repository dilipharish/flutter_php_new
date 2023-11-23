import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mysql1/mysql1.dart'; // Import MySQL package
import 'package:flutter_php_new/constants.dart'; // Import your provider file

class UnallocatedReceiversWidget extends StatefulWidget {
  @override
  _UnallocatedReceiversWidgetState createState() =>
      _UnallocatedReceiversWidgetState();
}

class _UnallocatedReceiversWidgetState
    extends State<UnallocatedReceiversWidget> {
  late List<Map<String, dynamic>> unallocatedReceivers = [];
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _fetchUnallocatedReceivers();
  }

  Future<void> _fetchUnallocatedReceivers() async {
    // Establish a database connection
    final MySqlConnection conn = await MySqlConnection.connect(settings);

    try {
      // Fetch unallocated receivers with additional information from users table
      var results = await conn.query('''
      SELECT r.receiver_id as receiver_id,u.name AS receiver_name, u.phone_number AS receiver_phone, 
             u.address AS receiver_address,  u.email as reciver_email,r.rorgan_name as reciever_organ,r.rage as reciver_age,r.rmedical_history as reciver_medical_history,r.rhla as reciver_hal,r.rbloodgroup as receiver_blood_group
      FROM receiver r
      JOIN users u ON r.ruid = u.uid
      WHERE r.roid IS NULL AND r.date_of_allocation IS NULL
    ''');
      print("Unallocated");
      print(results);
      // Check if results contain data
      if (results.isNotEmpty) {
        // Extract data from the results
        unallocatedReceivers = results
            .map<Map<String, dynamic>>((row) => {
                  'receiver_id': row['receiver_id'],
                  'receiver_name': row['receiver_name'],
                  'receiver_phone': row['receiver_phone'],
                  'receiver_address': row['receiver_address'],
                  'reciver_email': row['reciver_email'], // Add email
                  'reciever_organ': row['reciever_organ'], // Add organ name
                  'reciver_age': row['reciver_age'], // Add age
                  'reciver_medical_history':
                      row['reciver_medical_history'], // Add medical history
                  'reciver_hal': row['reciver_hal'], // Add HLA
                  'reciever_blood_group': row['receiver_blood_group'],
                })
            .toList();
      } else {
        // No unallocated receivers found
        unallocatedReceivers = [];
      }

      setState(() {}); // Update the widget with the fetched data
    } catch (e) {
      // Handle errors here
      print('Error fetching unallocated receivers: $e');
    } finally {
      // Close the database connection
      await conn.close();
    }
  }

  void _showDialogBox() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Unallocated Receivers List'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              controller: _scrollController,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const <DataColumn>[
                    DataColumn(label: Text('Receiver_id')),
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Phone Number')),
                    DataColumn(label: Text('Address')),
                    DataColumn(label: Text('Email')), // Add Email column
                    DataColumn(
                        label: Text('Organ Name')), // Add Organ Name column
                    DataColumn(label: Text('Age')), // Add Age column
                    DataColumn(
                        label: Text(
                            'Medical History')), // Add Medical History column
                    DataColumn(label: Text('HLA')),
                    DataColumn(label: Text('Blood Group')),
                    // Add HLA column
                  ],
                  rows: unallocatedReceivers
                      .map((receiver) => DataRow(
                            cells: <DataCell>[
                              DataCell(Text(
                                  receiver['receiver_id'].toString() ?? 'N/A')),
                              DataCell(
                                  Text(receiver['receiver_name'] ?? 'N/A')),
                              DataCell(
                                  Text(receiver['receiver_phone'] ?? 'N/A')),
                              DataCell(
                                  Text(receiver['receiver_address'] ?? 'N/A')),
                              DataCell(Text(receiver['reciver_email'] ??
                                  'N/A')), // Use 'reciver_email' key for email
                              DataCell(Text(receiver['reciever_organ'] ??
                                  'N/A')), // Use 'reciever_organ' key for organ name
                              DataCell(Text(
                                  receiver['reciver_age']?.toString() ??
                                      'N/A')), // Use 'reciver_age' key for age
                              DataCell(Text(receiver[
                                      'reciver_medical_history'] ??
                                  'N/A')), // Use 'reciver_medical_history' key for medical history
                              DataCell(Text(receiver['reciver_hal'] ?? 'N/A')),
                              DataCell(Text(receiver['reciever_blood_group'] ??
                                  'N/A')), // Use 'reciver_hal' key for HLA
                            ],
                          ))
                      .toList(),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController
        .dispose(); // Dispose the ScrollController when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.01,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/organ_donation_best.json',
            width: 500,
            height: 300,
          ),
          ElevatedButton(
            onPressed: () {
              _fetchUnallocatedReceivers();
              _showDialogBox();
            },
            child: Text('See Unallocated Receivers'),
          ),
          // SizedBox(height: 20),
        ],
      ),
    );
  }
}
