import 'package:flutter/material.dart';
import 'package:flutter_php_new/constants.dart';
import 'package:flutter_php_new/receiver_ops/edit_reciever_screen.dart';
import 'package:mysql1/mysql1.dart';

class Receiver {
  final int receiverId;
  final int ruid;
  final int roid;
  final String rhla;
  final String rbloodgroup;
  final DateTime dateOfAllocation;
  final String rmedicalHistory;
  final String rorganName;
  final int rage;

  Receiver({
    required this.receiverId,
    required this.ruid,
    required this.roid,
    required this.rhla,
    required this.rbloodgroup,
    required this.dateOfAllocation,
    required this.rmedicalHistory,
    required this.rorganName,
    required this.rage,
  });
}

class HistoryReciverScreen extends StatefulWidget {
  final int userId;

  HistoryReciverScreen({required this.userId});

  @override
  _HistoryReciverScreenState createState() => _HistoryReciverScreenState();
}

class _HistoryReciverScreenState extends State<HistoryReciverScreen> {
  late List<Receiver> receivers = [];

  @override
  void initState() {
    super.initState();
    // Fetch receiver data from the database when the widget is initialized
    fetchReciverDataFromDatabase();
  }

  Future<void> fetchReciverDataFromDatabase() async {
    try {
      final MySqlConnection conn = await MySqlConnection.connect(settings);
      var results = await conn.query(
        '''
      SELECT r.receiver_id, r.ruid, r.roid, r.rhla, r.rbloodgroup, r.date_of_allocation,
             r.rmedical_history, r.rorgan_name, r.rage
      FROM receiver r
      WHERE r.ruid = ?
      ''',
        [widget.userId],
      );
      await conn.close();

      setState(() {
        receivers = results.map((row) {
          return Receiver(
            receiverId: row['receiver_id'] ??
                0, // Provide a default value (0 in this case) for null values
            ruid: row['ruid'] ?? 0,
            roid: row['roid'] ?? 0,
            rhla: row['rhla'] ?? '',
            rbloodgroup: row['rbloodgroup'] ?? '',
            dateOfAllocation: row['date_of_allocation'] ??
                DateTime(0000, 1, 1), // Provide a default DateTime if null
            rmedicalHistory: row['rmedical_history'] ?? '',
            rorganName: row['rorgan_name'] ?? '',
            rage: row['rage'] ?? 0,
          );
        }).toList();
      });
    } catch (e) {
      // Handle database connection and query errors here
      print('Error fetching receiver data: $e');
    }
  }

  Future<void> deleteReceiver(int receiverId) async {
    try {
      final MySqlConnection conn = await MySqlConnection.connect(settings);

      // Delete the receiver record
      await conn
          .query('DELETE FROM receiver WHERE receiver_id = ?', [receiverId]);

      // Close the database connection
      await conn.close();

      // Refresh the receiver list
      await fetchReciverDataFromDatabase();
    } catch (e) {
      // Handle error (show error message to user, log it, etc.)
      print('Error deleting receiver: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: receivers.isNotEmpty
          ? SingleChildScrollView(
              child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: receivers.length,
              itemBuilder: (context, index) {
                Receiver receiver = receivers[index];
                String details = 'RUID: ${receiver.ruid}\n'
                    'Allocated Organ Id: ${receiver.roid}\n'
                    'RHLA: ${receiver.rhla}\n'
                    'Blood Group: ${receiver.rbloodgroup}\n'
                    '${receiver.dateOfAllocation != DateTime(0000, 1, 1) ? 'Date of Allocation: ${receiver.dateOfAllocation.toString()}\n' : 'Organ not allocated\n'}'
                    'Medical history: ${receiver.rmedicalHistory}\n'
                    'Organ Name: ${receiver.rorganName}\n'
                    'Age: ${receiver.rage}\n';

                return Card(
                  margin: EdgeInsets.all(8.0),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  color: Color.fromARGB(255, 148, 251, 179),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Receiver ID: ${receiver.receiverId}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.indigo,
                          ),
                        ),
                        SizedBox(height: 1),
                        Text(
                          details,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 1),
                        Divider(
                            height: 1,
                            thickness: 2,
                            color: const Color.fromARGB(255, 16, 15, 15)),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.end,
                        //   children: [
                        //     ElevatedButton.icon(
                        //       onPressed: () {
                        //         // Navigate to EditReceiverScreen with receiverId
                        //         Navigator.push(
                        //           context,
                        //           MaterialPageRoute(
                        //             builder: (context) => EditReceiverScreen(
                        //                 receiverId: receiver.receiverId),
                        //           ),
                        //         ).then((_) {
                        //           // Callback after returning from EditReceiverScreen
                        //           // Refresh the receiver list
                        //           fetchReciverDataFromDatabase();
                        //         });
                        //       },
                        //       icon: Icon(Icons.edit),
                        //       label: Text('Edit'),
                        //       style: ElevatedButton.styleFrom(
                        //         primary: Colors.orange,
                        //         onPrimary: Colors.white,
                        //       ),
                        //     ),
                        //     SizedBox(width: 8),
                        //     ElevatedButton.icon(
                        //       onPressed: () {
                        //         deleteReceiver(receiver.receiverId);
                        //       },
                        //       icon: Icon(Icons.delete),
                        //       label: Text('Delete'),
                        //       style: ElevatedButton.styleFrom(
                        //         primary: Colors.red,
                        //         onPrimary: Colors.white,
                        //       ),
                        //     ),
                        //   ],
                        // ),
                      ],
                    ),
                  ),
                );
              },
            ))
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
