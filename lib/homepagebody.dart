import 'package:flutter/material.dart';
import 'package:flutter_php_new/constants.dart';
import 'package:flutter_php_new/donor_ops/donor_registration.dart';
import 'package:flutter_php_new/provider.dart';
import 'package:flutter_php_new/receiver_ops/receiver_registration.dart';
import 'package:flutter_php_new/report.dart';
import 'package:flutter_php_new/search_ops/view_donors_receivers.dart';
import 'package:lottie/lottie.dart';
import 'package:mysql1/mysql1.dart';
import 'package:provider/provider.dart';

class HomePageBody extends StatefulWidget {
  final int userId;

  HomePageBody({required this.userId});

  @override
  _HomePageBodyState createState() => _HomePageBodyState();
}

class _HomePageBodyState extends State<HomePageBody> {
  int _currentIndex = 0;
  late String donorStatus = '';
  Future<String> fetchDonorStatus(int userId) async {
    try {
      final MySqlConnection conn = await MySqlConnection.connect(settings);

      // Fetch donor status based on the provided user ID
      var results = await conn
          .query('SELECT odonor_status FROM donor WHERE oduid = ?', [userId]);
      if (results.isNotEmpty) {
        var row = results.first;
        // Return the donor status fetched from the database
        return row['odonar_status'];
      }

      // Close the database connection
      await conn.close();
    } catch (e) {
      // Handle error...
      print('Error fetching donor status: $e');
    }

    // Return a default value (for example, 'live donor') if no data is found
    return 'live donor';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromARGB(255, 233, 152, 105),
      child: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User ID: ${widget.userId}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  Consumer<UserDataProvider>(
                    builder: (context, userDataProvider, child) {
                      final userData = userDataProvider.userData;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            color: Color.fromARGB(255, 191, 161,
                                238), // Set your desired background color for the entire SingleChildScrollView
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Column(
                                children: [
                                  Card(
                                    elevation: 0,
                                    color: Color.fromARGB(255, 191, 161,
                                        238), // Set the card elevation for a shadow effect
                                    margin: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 20),
                                    child: Padding(
                                      padding: EdgeInsets.all(0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildInfoTile('Name', userData.name),
                                          _buildInfoTile(
                                              'Email', userData.email),
                                          _buildInfoTile('Phone Number',
                                              userData.phoneNumber),
                                          _buildInfoTile(
                                              'Date of Birth(yyyy-mm-dd)',
                                              userData.dob),
                                          _buildInfoTile(
                                              'Address', userData.address),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Divider(height: 1, thickness: 1, color: Colors.black),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Lottie.asset(
                                'assets/kidney.json',
                                width: 100,
                                height: 100,
                              ),
                              Lottie.asset(
                                'assets/blood_drop.json',
                                width: 100,
                                height: 100,
                              ),
                              Lottie.asset(
                                'assets/liver.json',
                                width: 100,
                                height: 100,
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DonorRegistrationPage(
                                        userId: widget.userId,
                                      ),
                                    ),
                                  );
                                },
                                child: Text('Register as Donor'),
                              ),
                              ElevatedButton(
                                onPressed: donorStatus != 'cardiac death' &&
                                        donorStatus != 'brain death'
                                    ? () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ReceiverRegistrationPage(
                                              userId: widget.userId,
                                            ),
                                          ),
                                        );
                                      }
                                    : null,
                                child: Text('Register as Receiver'),
                              ),
                            ],
                          ),
                          Text(
                              "                                   ALERT!!! \nBE CAREFUL WHILE REGISTERING AS DONOR OR RECEIVER,\nONCE YOU REGISTERED YOU CANNOT DELETE OR UPDATE "),
                          Divider(height: 1, thickness: 1, color: Colors.black),
                          SizedBox(height: 10),
                          Container(
                            alignment: Alignment.center,
                            width: double
                                .infinity, // Set the width to take up the available width
                            height: 200, // Set the desired height
                            child: Lottie.asset(
                              'assets/blood_donation.json', // Replace this with the path to your Lottie animation JSON file
                              width: 200,
                              height: 200,
                              fit: BoxFit.fill,
                            ),
                          ),
                          // ElevatedButton(
                          //   onPressed: () {
                          //     Navigator.of(context).push(
                          //       MaterialPageRoute(
                          //         builder: (context) =>
                          //             ViewDonorsReceiversPage(),
                          //       ),
                          //     );
                          //   },
                          //   child: Text('View Donors/Receivers'),
                          // ),
                          TransactionReportWidget(uid: widget.userId),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _refreshData() async {
    await Future.delayed(Duration(seconds: 2));
    // Refresh logic goes here
  }

  Widget _buildInfoTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        SizedBox(height: 10), // Add some vertical spacing between tiles
      ],
    );
  }
}
