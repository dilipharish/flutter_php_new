import 'package:flutter/material.dart';
import 'package:flutter_php_new/admin_ops/fl_bar_chart_screen.dart';
import 'package:flutter_php_new/admin_ops/fl_line_chart_allocation.dart';
import 'package:flutter_php_new/admin_ops/fl_line_chart_no_of_don.dart';
import 'package:flutter_php_new/admin_ops/fl_line_chart_no_of_users.dart';
import 'package:lottie/lottie.dart';
import 'package:mysql1/mysql1.dart';
import 'package:flutter_php_new/constants.dart';

class AdminGraphScreen extends StatefulWidget {
  @override
  _AdminGraphScreenState createState() => _AdminGraphScreenState();
}

class _AdminGraphScreenState extends State<AdminGraphScreen> {
  late MySqlConnection connection;
  Map<String, double> organAverages = {};

  Future<void> fetchData() async {
    connection = await MySqlConnection.connect(settings);

    var results = await connection.query('''
      SELECT 
        organ_name, 
        AVG(oage) as avg_oage 
      FROM 
        Organ 
      WHERE 
        organ_name IN ('Left_Kidney', 'Right_Kidney', 'Eyes', 'Heart', 'Liver','Blood')
      GROUP BY 
        organ_name;
    ''');

    for (var row in results) {
      organAverages[row['organ_name']] = row['avg_oage'];
    }

    await connection.close();
    setState(() {}); // Update the UI with fetched data
  }

  Future<void> _showRecentUsersDialog() async {
    connection = await MySqlConnection.connect(settings);

    try {
      var results = await connection.query(
        'SELECT uid, name, phone_number, email FROM users ORDER BY date_of_user_registration DESC LIMIT 10',
      );

      await connection.close();

      if (results.isNotEmpty) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Last 10 Recent Users'),
              content: SingleChildScrollView(
                child: Column(
                  children: results.map((row) {
                    return ListTile(
                      title: Text('Name: ${row[1]}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('UID: ${row[0]}'),
                          Text('Phone Number: ${row[2]}'),
                          Text('Email: ${row[3]}'),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
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
              title: Text('No Recent Users'),
              actions: <Widget>[
                TextButton(
                  child: Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> showBelowAverageOrgansDialog() async {
    final connection = await MySqlConnection.connect(settings);

    try {
      var results = await connection.query('''
      SELECT B.bid, B.bname, 
             (SELECT COUNT(*) FROM Available A WHERE A.branch_id = B.bid) as num_organs
      FROM Branch B 
      WHERE (SELECT COUNT(*) 
             FROM Available A 
             WHERE A.branch_id = B.bid) < 
            (SELECT AVG(num_organs) 
             FROM (SELECT branch_id, COUNT(*) as num_organs 
                   FROM Available 
                   GROUP BY branch_id) as OrgansPerBranch);
    ''');

      await connection.close();

      List<List<dynamic>> belowAverageBranches = results.toList();

      if (belowAverageBranches.isNotEmpty) {
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Branches with Below Average Organs'),
              content: SingleChildScrollView(
                child: Column(
                  children: belowAverageBranches
                      .map((branchData) => ListTile(
                            title: Text('Branch ID: ${branchData[0]}'),
                            subtitle: Text('Branch Name: ${branchData[1]}'),
                            trailing: Text('Total Organs: ${branchData[2]}'),
                          ))
                      .toList(),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else {
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('No Branches with Below Average Organs'),
              actions: <Widget>[
                TextButton(
                  child: Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData(); // Fetch data when the screen initializes
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height * 2,
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Lottie.asset(
              'assets/admin_graph.json',
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
            SizedBox(
              height: 20,
            ),
            Divider(height: 10, thickness: 2, color: Colors.black),
            ElevatedButton(
              onPressed: () {
                _showRecentUsersDialog();
              },
              child: Text('Show Last 10 Recent Users'),
            ),
            Divider(height: 10, thickness: 2, color: Colors.black),
            ElevatedButton(
              onPressed: () {
                showBelowAverageOrgansDialog();
              },
              child: Text('Branches with Below Average Organs'),
            ),
            Divider(height: 10, thickness: 2, color: Colors.black),
            Text(
              'Organ Availability',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(child: BarChartWidget()),
            SizedBox(height: 20),
            Text(
              'Average Age of Donors',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // Displaying average oage for specific organs
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: organAverages.entries
                  .map((entry) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          '${entry.key}: ${entry.value.toStringAsFixed(2)} years',
                          style: TextStyle(fontSize: 18),
                        ),
                      ))
                  .toList(),
            ),
            Divider(height: 10, thickness: 2, color: Colors.black),
            Text(
              'Donors Donations Registered from past 7 Days',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            // Expanded(child: ExpenseGraphDesign()),
            Expanded(child: LineChartSample5()),
            Divider(height: 10, thickness: 2, color: Colors.black),
            Text(
              'Users Registered from past 7 Weeks',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            // Expanded(child: ExpenseGraphDesign()),
            Expanded(child: LineChartSample6()),
            Divider(height: 10, thickness: 2, color: Colors.black),
            Text(
              "Oragns Allocated to Receivers",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Expanded(child: LineChartSamplealloc()),
            Divider(height: 10, thickness: 2, color: Colors.black),
          ],
        ),
      ),
    );
  }
}
