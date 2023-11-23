import 'package:flutter/material.dart';
import 'package:flutter_php_new/constants.dart';
import 'package:flutter_php_new/screens/donor_class.dart';
import 'package:flutter_php_new/screens/edit_donor_screen.dart';
import 'package:flutter_php_new/screens/histroy_reciever.dart';
// import 'package:flutter_php_new/screens/edit_donor_screen.dart' as editDonor;
import 'package:lottie/lottie.dart';
import 'package:mysql1/mysql1.dart'; // Import MySQL package

class HistoryScreen extends StatefulWidget {
  final int userId;

  HistoryScreen({required this.userId});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late List<Donore> donors = [];

  @override
  void initState() {
    super.initState();
    // Fetch donor data from the database when the widget is initialized
    fetchDataFromDatabase();
  }

  Future<void> fetchDataFromDatabase() async {
    try {
      final MySqlConnection conn = await MySqlConnection.connect(settings);
      var results = await conn.query(
        '''
      SELECT d.donor_id, d.duid, d.doid, d.date_of_donation, o.odonor_status,
             o.ohla, o.omedical_history, o.oage, o.obloodgroup, o.organ_availability, o.organ_name,
             a.branch_id, b.bname
      FROM donor d 
      JOIN organ o ON d.doid = o.oid 
      JOIN available a ON o.oid = a.organ_id
      JOIN branch b ON a.branch_id = b.bid
      WHERE d.duid = ?
      ''',
        [widget.userId],
      );
      await conn.close();

      setState(() {
        donors = results.map((row) {
          return Donore(
            donorId: row['donor_id'],
            duid: row['duid'],
            doid: row['doid'],
            dateOfDonation: row['date_of_donation'],
            organDetails: row['omedical_history'],
            organName: row['organ_name'],
            organAge: row['oage'],
            organBloodGroup: row['obloodgroup'],
            organAvailability: row['organ_availability'] == 1,
            ohla: row['ohla'],
            donorStatus: row['odonor_status'],
            branchId: row['branch_id'],
            branchName: row['bname'],
          );
        }).toList();
      });
    } catch (e) {
      // Handle database connection and query errors here
      print('Error fetching donor data: $e');
    }
  }

  Future<void> deleteDonor(int donorId) async {
    try {
      final MySqlConnection conn = await MySqlConnection.connect(settings);

      // Update the donor record to set organ_id to null
      await conn.query('Delete from available where organ_id = ?', [donorId]);

      // Delete the donor record(s) now that the foreign key reference is removed
      await conn.query('DELETE FROM donor WHERE doid = ?', [donorId]);

      // Now, you can safely delete the corresponding organ record(s)
      await conn.query('DELETE FROM organ WHERE oid = ?', [donorId]);

      // Close the database connection
      await conn.close();

      // Refresh the donor list
      await fetchDataFromDatabase();
    } catch (e) {
      // Handle error (show error message to user, log it, etc.)
      print('Error deleting donor: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 2,
      color: Color.fromARGB(255, 233, 152, 105),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: donors != null
            ? Scrollbar(
                child: Column(
                  children: [
                    // LottieAnimation(),
                    // SizedBox(height: 10),
                    Divider(height: 1, thickness: 1, color: Colors.black),
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: DonorListView(
                              donors: donors,
                              onDelete: deleteDonor,
                              fetchDataCallback: fetchDataFromDatabase,
                            ),
                          ),
                          Divider(height: 1, thickness: 1, color: Colors.black),
                          Expanded(
                            child: HistoryReciverScreen(userId: widget.userId),
                          ),
                          Divider(height: 1, thickness: 1, color: Colors.black),
                          // Expanded(
                          //   child: HistoryReciverScreen(userId: widget.userId),
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }
}

class LottieAnimation extends StatefulWidget {
  @override
  _LottieAnimationState createState() => _LottieAnimationState();
}

class _LottieAnimationState extends State<LottieAnimation> {
  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      'assets/history1.json',
      width: 130,
      height: 100,
      fit: BoxFit.cover,
    );
  }
}

class DonorListView extends StatefulWidget {
  final List<Donore> donors;
  final Function(int) onDelete;
  final VoidCallback fetchDataCallback; // Add this line

  DonorListView(
      {required this.donors,
      required this.onDelete,
      required this.fetchDataCallback});

  @override
  _DonorListViewState createState() => _DonorListViewState();
}

class _DonorListViewState extends State<DonorListView> {
  Widget buildEditButton(Donore donor) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditDonorScreen(
              organId: donor.doid,
            ),
          ),
        ).then((_) {
          // Refresh the donor list after returning from the edit screen
          widget.fetchDataCallback();
        });
      },
      icon: Icon(Icons.edit),
      label: Text('Edit'),
      style: ElevatedButton.styleFrom(
        primary: Colors.orange,
        onPrimary: Colors.white,
      ),
    );
  }

  Widget buildDeleteButton(Donore donor) {
    return ElevatedButton.icon(
      onPressed: () {
        widget.onDelete(donor.doid);
      },
      icon: Icon(Icons.delete),
      label: Text('Delete'),
      style: ElevatedButton.styleFrom(
        primary: Colors.red,
        onPrimary: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: ListView.builder(
        itemCount: widget.donors.length,
        itemBuilder: (context, index) {
          Donore donor = widget.donors[index];
          bool isOrganAvailable = donor.organAvailability == 1;
          String details = 'Organ ID :${donor.doid}\n'
              'Branch Name: ${donor.branchName}\n'
              'Medical history: ${donor.organDetails}\n'
              'Organ Name: ${donor.organName}\n'
              'Age: ${donor.organAge}\n'
              'Blood Group: ${donor.organBloodGroup}\n'
              'Availability: ${donor.organAvailability ? 'Available' : 'Not Available'}\n'
              'OHLA: ${donor.ohla}\n'
              'Donor_status: ${donor.donorStatus}\n'
              'Date of Donation: ${donor.dateOfDonation.toString()}';
          return Column(
            children: [
              Card(
                margin: EdgeInsets.all(8.0),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                color: Color.fromARGB(255, 201, 242, 249),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Donor ID: ${donor.donorId}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.indigo,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        details,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 1),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.end,
                      //   children: [
                      //     if (isOrganAvailable) buildEditButton(donor),
                      //     if (isOrganAvailable) SizedBox(width: 8),
                      //     if (isOrganAvailable) buildDeleteButton(donor),
                      //   ],
                      // ),
                    ],
                  ),
                ),
              ),
              Divider(height: 10, thickness: 2, color: Colors.black),
            ],
          );
        },
      ),
    );
  }
}
