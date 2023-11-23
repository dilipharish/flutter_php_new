import 'package:flutter/material.dart';
import 'package:flutter_php_new/constants.dart';
import 'package:mysql1/mysql1.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

class Organmanagement extends StatefulWidget {
  const Organmanagement({Key? key, required this.userId}) : super(key: key);
  final int userId;

  @override
  State<Organmanagement> createState() => _OrganmanagementState();
}

class _OrganmanagementState extends State<Organmanagement> {
  TextEditingController hlaController = TextEditingController();
  String errorMessage = '';
  PlatformFile? selectedFile; // Store the selected file

  Future<void> pickAndUploadFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        setState(() {
          selectedFile = result.files.first; // Store the selected file
          hlaController.text =
              selectedFile!.name; // Set the file name in the text field
        });

        // Now, call the function to save the file
        await saveFileToDatabase(selectedFile!);
      }
    } catch (e) {
      print("Exception in picking file: $e");
    }
  }

  Future<void> saveFileToDatabase(PlatformFile file) async {
    final MySqlConnection conn = await MySqlConnection.connect(settings);

    try {
      final userId = widget.userId;
      // final fileName = file.name;
      final fileBytes = file.bytes;

      await conn.query(
        'UPDATE users SET file = ? WHERE id = ?',
        [fileBytes, userId],
      );
      print("File saved successfully!");
      print(fileBytes.toString());
    } catch (e) {
      print("Exception in saving file: $e");
    } finally {
      await conn.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Organ Management'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.network(
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRfH2zY9G_PuLXKidX77vu4gbHtQtsg-ZxOZA&usqp=CAU',
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 20),

            // Text input for HLA sequence
            TextField(
              controller: hlaController,
              decoration: InputDecoration(
                labelText: 'Enter HLA Sequence',
                errorText: errorMessage,
              ),
            ),

            SizedBox(height: 20),

            // Combined button for picking and saving file
            ElevatedButton(
              onPressed: pickAndUploadFile,
              child: Text('Pick and Save File'),
            ),

            SizedBox(height: 20),

            // Display selected file name
            if (selectedFile != null)
              Text('Selected File: ${selectedFile!.name}'),
          ],
        ),
      ),
    );
  }
}
