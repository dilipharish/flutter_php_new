// Import statements
import 'package:flutter/material.dart';
import 'package:flutter_php_new/constants.dart';
import 'package:lottie/lottie.dart';
import 'package:mysql1/mysql1.dart';

// Constants

// Model class for Branch details
class BranchDetails {
  final int id;
  final String name;
  final String address;
  final String phoneNumber;
  final int organCount;

  BranchDetails({
    required this.id,
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.organCount,
  });
}

class BranchScreen extends StatefulWidget {
  @override
  _BranchScreenState createState() => _BranchScreenState();
}

class _BranchScreenState extends State<BranchScreen> {
  late MySqlConnection _conn;
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneNumberController;
  List<BranchDetails> branchDetailsList = [];

  @override
  void initState() {
    super.initState();
    _initializeDatabaseConnection();
    _nameController = TextEditingController();
    _addressController = TextEditingController();
    _phoneNumberController = TextEditingController();
  }

  Future<void> _initializeDatabaseConnection() async {
    _conn = await MySqlConnection.connect(settings);
    await _fetchBranchDetails();
  }

  Future<void> _fetchBranchDetails() async {
    var results = await _conn.query('SELECT * FROM branch');
    var branchDetailsFutures = results.map((row) async {
      var organCountResult = await _conn.query(
        'SELECT COUNT(*) FROM Available WHERE branch_id = ?',
        [row[0]], // Assuming branch_id is at index 0 in the branch table
      );

      var organCount = organCountResult?.first?.values?.first as int ?? 0;

      return BranchDetails(
        id: row[0] as int,
        name: row[1] as String,
        address: row[2] as String,
        phoneNumber: row[3] as String,
        organCount: organCount,
      );
    }).toList();

    var branchDetails = await Future.wait(branchDetailsFutures);

    setState(() {
      branchDetailsList = branchDetails;
    });
  }

  Future<void> _showAddBranchDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Branch'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Branch Name'),
                ),
                TextField(
                  controller: _addressController,
                  decoration: InputDecoration(labelText: 'Branch Address'),
                ),
                TextField(
                  controller: _phoneNumberController,
                  decoration: InputDecoration(labelText: 'Phone Number'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                _addBranchDetails(
                  _nameController.text,
                  _addressController.text,
                  _phoneNumberController.text,
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _addBranchDetails(
      String name, String address, String phoneNumber) async {
    try {
      var result = await _conn.query(
        'INSERT INTO branch (bname, baddress, bphone_number) VALUES (?, ?, ?)',
        [name, address, phoneNumber],
      );

      if (result.affectedRows! > 0) {
        await _fetchBranchDetails();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Branch added successfully.'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add branch. Please try again.'),
          ),
        );
      }
    } catch (error) {
      print('Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred while adding branch.'),
        ),
      );
    }
  }

  Future<void> _showEditBranchDialog(
      BuildContext context, BranchDetails branch) async {
    _nameController.text = branch.name;
    _addressController.text = branch.address;
    _phoneNumberController.text = branch.phoneNumber;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Branch'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Branch Name'),
                ),
                TextField(
                  controller: _addressController,
                  decoration: InputDecoration(labelText: 'Branch Address'),
                ),
                TextField(
                  controller: _phoneNumberController,
                  decoration: InputDecoration(labelText: 'Phone Number'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                _editBranchDetails(
                  branch.id,
                  _nameController.text,
                  _addressController.text,
                  _phoneNumberController.text,
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _editBranchDetails(
      int id, String name, String address, String phoneNumber) async {
    try {
      var result = await _conn.query(
        'UPDATE branch SET bname = ?, baddress = ?, bphone_number = ? WHERE bid = ?',
        [name, address, phoneNumber, id],
      );

      if (result.affectedRows! > 0) {
        await _fetchBranchDetails();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Branch updated successfully.'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update branch. Please try again.'),
          ),
        );
      }
    } catch (error) {
      print('Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred while updating branch.'),
        ),
      );
    }
  }

  Future<bool> _checkBranchDeletion(int id) async {
    try {
      var result =
          await _conn.query('SELECT * FROM Branch WHERE bid = ?', [id]);
      return result
          .isEmpty; // If true, branch is deleted; if false, branch still exists
    } catch (error) {
      print('Error checking branch deletion: $error');
      return false; // Assume deletion failed in case of an error
    }
  }

  Future<void> _deleteBranchDetails(int id) async {
    try {
      if (id == 1) {
        // Do not delete main branch (bid=1)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Main branch cannot be deleted.'),
          ),
        );
      } else {
        // Call stored procedure to delete branch and transfer data
        var results = await _conn.query(
          'CALL DeleteBranch(?)',
          [id],
        );

        // Check if the branch was deleted successfully in the database
        bool isDeleted = await _checkBranchDeletion(id);

        if (isDeleted) {
          // Remove the deleted branch from the branchDetailsList
          setState(() {
            branchDetailsList.removeWhere((branch) => branch.id == id);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Branch deleted successfully.'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete branch. Please try again.'),
            ),
          );
        }
      }
    } catch (error) {
      print('Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred while deleting branch.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          color: Color.fromARGB(255, 147, 231, 248),
          child: Padding(
            padding: const EdgeInsets.only(top: 50),
            child: Column(
              children: <Widget>[
                Lottie.asset(
                  'assets/admin_main_branch.json',
                  width: 150,
                  height: 120,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(right: 10),
                      child: Lottie.asset(
                        'assets/admin_branch_woman.json',
                        width: 70,
                        height: 75,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 7),
                      child: ElevatedButton(
                        onPressed: () {
                          _showAddBranchDialog(context);
                        },
                        child: Text('Add Branch'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 10),
                      child: Lottie.asset(
                        'assets/admin_branch_loc_mob.json',
                        width: 80,
                        height: 85,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
                Divider(height: 10, thickness: 2, color: Colors.black),
                Expanded(
                  child: ListView.builder(
                    itemCount: branchDetailsList.length,
                    itemBuilder: (context, index) {
                      var branch = branchDetailsList[index];
                      return Card(
                        margin: EdgeInsets.all(8.0),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        color: Color.fromARGB(255, 208, 166, 236),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Branch Id:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                branch.id.toString(),
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Branch Name:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                branch.name,
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Address:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                branch.address,
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Phone Number:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                branch.phoneNumber,
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Organ Count:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                branch.organCount.toString(),
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      _showEditBranchDialog(context, branch);
                                    },
                                  ),
                                  if (branch.id !=
                                      1) // Conditionally show delete button
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () {
                                        _deleteBranchDetails(branch.id);
                                      },
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _conn.close();
    _nameController.dispose();
    _addressController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }
}
