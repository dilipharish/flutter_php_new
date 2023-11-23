import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_php_new/constants.dart';
import 'package:mysql1/mysql1.dart';

class OrganAllocationScreen extends StatefulWidget {
  @override
  _OrganAllocationScreenState createState() => _OrganAllocationScreenState();
}

class _OrganAllocationScreenState extends State<OrganAllocationScreen> {
  TextEditingController receiverIdController = TextEditingController();
  late MySqlConnection _connection;

  @override
  void initState() {
    super.initState();
    _connectToDatabase();
  }

  Future<void> _connectToDatabase() async {
    // Establish a database connection
    _connection = await MySqlConnection.connect(settings);
  }

  Future<void> _allocateOrganToReceiver(
      int receiverId, BuildContext context) async {
    final MySqlConnection conn = await MySqlConnection.connect(settings);

    try {
      var checkReceiver = await conn.query(
        'SELECT COUNT(*) as count, rbloodgroup, rorgan_name FROM receiver WHERE receiver_id = ?',
        [receiverId],
      );

      var count = checkReceiver.first['count'] ?? 0;
      var rbloodgroup = checkReceiver.first['rbloodgroup'];
      var rorganName = checkReceiver.first['rorgan_name'];
      print(count.toString() + rbloodgroup.toString() + rorganName.toString());

      if (count == 0 || rbloodgroup == null || rorganName == null) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Organ Allocation'),
              content:
                  Text('Receiver ID does not exist or invalid data received.'),
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
        return;
      }

      var rescheck = await conn.query(
        "Select roid from receiver WHERE receiver_id = ?",
        [receiverId],
      );
      var roidcheck = rescheck.first['roid'];
      if (roidcheck != null) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Organ Allocation'),
              content: Text('Organ already allocated for this receiver.'),
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
        return;
      }

      if (rorganName == 'Blood') {
        var receiverResults = await conn.query(
          'SELECT rbloodgroup, rage, roid, date_of_allocation FROM receiver WHERE receiver_id = ? AND (roid IS NULL OR date_of_allocation IS NULL)',
          [receiverId],
        );
        print(receiverResults);
        // print(receiverResults.first['roid']);
        if (receiverResults.isNotEmpty) {
          var receiverData = receiverResults.first;

          String rbloodgroup = receiverData['rbloodgroup'];
          int rage = receiverData['rage'];
          // int roid = receiverData['roid'];
          // print(roid);

          var compatibleBloodGroups = {
            'A+': ['A+', 'A-', 'O+', 'O-'],
            'A-': ['A-', 'O-'],
            'B+': ['B+', 'B-', 'O+', 'O-'],
            'B-': ['B-', 'O-'],
            'AB+': ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'],
            'AB-': ['A-', 'B-', 'AB-', 'O-'],
            'O+': ['O+', 'O-'],
            'O-': ['O-'],
          };

          var results = await conn.query(
            'SELECT oid, oage, obloodgroup FROM organ WHERE organ_name = ? AND organ_availability = 1 AND obloodgroup IN (${compatibleBloodGroups[rbloodgroup]!.map((e) => "'$e'").join(', ')})',
            ['Blood'],
          );
          print("blood\n");
          print(results);

          if (results.isNotEmpty) {
            var organData = results.first;

            int oid = organData['oid'];
            int oage = organData['oage'];

            int maxAgeDifference = 100;
            if ((rage - oage).abs() <= maxAgeDifference) {
              await conn.query(
                'UPDATE receiver SET roid = ?, date_of_allocation = CURDATE() WHERE receiver_id = ?',
                [oid, receiverId],
              );

              await conn.query(
                'UPDATE organ SET organ_availability = 0 WHERE oid = ?',
                [oid],
              );

              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Organ Allocation'),
                    content: Text('Organ allocated successfully! OID: $oid'),
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
            } else {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Organ Allocation'),
                    content: Text(
                        'Age difference constraint not met for the receiver.'),
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
          } else {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Organ Allocation'),
                  content: Text(
                      'No compatible organ donors found for the receiver.'),
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
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Organ Allocation'),
                content: Text('Organ already allocated for this receiver.'),
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
      } else {
        var receiverResults = await conn.query(
          'SELECT rbloodgroup, rage, rorgan_name, roid, date_of_allocation FROM receiver WHERE receiver_id = ? AND (roid IS NULL OR date_of_allocation IS NULL)',
          [receiverId],
        );
        print("organ\n");
        print(receiverResults);
        if (receiverResults.isNotEmpty) {
          var receiverData = receiverResults.first;

          String rbloodgroup = receiverData['rbloodgroup'];
          int rage = receiverData['rage'];
          // int roid = receiverData['roid'];

          var compatibleBloodGroups = {
            'A+': ['A+', 'A-', 'O+', 'O-'],
            'A-': ['A-', 'O-'],
            'B+': ['B+', 'B-', 'O+', 'O-'],
            'B-': ['B-', 'O-'],
            'AB+': ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'],
            'AB-': ['A-', 'B-', 'AB-', 'O-'],
            'O+': ['O+', 'O-'],
            'O-': ['O-'],
          };

          var organResults = await conn.query(
            'SELECT oid, oage, obloodgroup FROM organ WHERE organ_availability = 1 AND obloodgroup IN (${compatibleBloodGroups[rbloodgroup]!.map((e) => '"$e"').join(', ')}) AND organ_name = ?',
            [rorganName],
          );
          print("compact1");
          print(organResults);
          print("compact2");
          // if (results.isNotEmpty) {
          //   var organData = results.first;

          //   int oid = organData['oid'];
          //   int oage = organData['oage'];

          //   int maxAgeDifference = (rage < 25) ? 10 : 20;
          //   if ((rage - oage).abs() <= maxAgeDifference) {
          //     await conn.query(
          //       'UPDATE receiver SET roid = ?, date_of_allocation = CURDATE() WHERE receiver_id = ?',
          //       [oid, receiverId],
          //     );

          //     await conn.query(
          //       'UPDATE organ SET organ_availability = 0 WHERE oid = ?',
          //       [oid],
          //     );

          //     showDialog(
          //       context: context,
          //       builder: (BuildContext context) {
          //         return AlertDialog(
          //           title: Text('Organ Allocation'),
          //           content: Text('Organ allocated successfully! OID: $oid'),
          //           actions: [
          //             TextButton(
          //               onPressed: () {
          //                 Navigator.of(context).pop(); // Close the dialog
          //               },
          //               child: const Text('Close'),
          //             ),
          //           ],
          //         );
          //       },
          //     );
          //   } else {
          //     showDialog(
          //       context: context,
          //       builder: (BuildContext context) {
          //         return AlertDialog(
          //           title: Text('Organ Allocation'),
          //           content: Text(
          //               'Age difference constraint not met for the receiver.'),
          //           actions: [
          //             TextButton(
          //               onPressed: () {
          //                 Navigator.of(context).pop(); // Close the dialog
          //               },
          //               child: const Text('Close'),
          //             ),
          //           ],
          //         );
          //       },
          //     );
          //   }
          //   //important
          // }
          if (organResults.isNotEmpty) {
            for (var organData in organResults) {
              int oid = organData['oid'];
              int oage = organData['oage'];

              int maxAgeDifference = (rage < 25) ? 10 : 20;
              if ((rage - oage).abs() <= maxAgeDifference) {
                await conn.query(
                  'UPDATE receiver SET roid = ?, date_of_allocation = CURDATE() WHERE receiver_id = ?',
                  [oid, receiverId],
                );

                await conn.query(
                  'UPDATE organ SET organ_availability = 0 WHERE oid = ?',
                  [oid],
                );

                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Organ Allocation'),
                      content: Text('Organ allocated successfully! OID: $oid'),
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
                return; // Allocation successful, exit the function
              }
            }

            // No valid organ donors found
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Organ Allocation'),
                  content: Text(
                      'No compatible organ donors found for the receiver.'),
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
          } else {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Organ Allocation'),
                  content: Text(
                      'No compatible organ donors found for the receiver.'),
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
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Organ Allocation'),
                content: Text('Organ already allocated for this receiver.'),
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
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Organ Allocation'),
            content: Text('Error allocating organ to receiver: $e'),
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
    } finally {
      await conn.close();
    }
  }

  Future<void> _showUnallocatedReceiversDialog(BuildContext context) async {
    final MySqlConnection conn = await MySqlConnection.connect(settings);
    try {
      var unallocatedReceivers = await conn.query(
          'SELECT receiver_id, rorgan_name, rbloodgroup, rage FROM receiver WHERE roid IS NULL');

      if (unallocatedReceivers.isNotEmpty) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Unallocated Receivers'),
              content: Column(
                children: unallocatedReceivers.map((receiver) {
                  return ListTile(
                    title: Text('Receiver ID: ${receiver['receiver_id']}'),
                    subtitle: Text(
                        'Organ Name: ${receiver['rorgan_name']}, Blood Group: ${receiver['rbloodgroup']}, Age: ${receiver['rage']}'),
                  );
                }).toList(),
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
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Unallocated Receivers'),
              content: Text('No unallocated receivers found.'),
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
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Error fetching unallocated receivers: $e'),
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
    } finally {
      await conn.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(1.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              _showUnallocatedReceiversDialog(context);
            },
            child: Text('Show Unallocated Receivers'),
          ),
          SizedBox(height: 2),
          TextField(
            controller: receiverIdController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Enter Receiver ID'),
          ),
          SizedBox(height: 1),
          ElevatedButton(
            onPressed: () {
              // Get the receiver ID from the text box and call allocation function
              int receiverId = int.tryParse(receiverIdController.text) ?? 0;
              if (receiverId > 0) {
                _allocateOrganToReceiver(receiverId, context);
              } else {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Organ Allocation'),
                      content: Text('Invalid Receiver ID. Please try again.'),
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
            },
            child: Text('Allocate Organ'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _connection.close();
    super.dispose();
  }
}
