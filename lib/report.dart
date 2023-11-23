import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_php_new/constants.dart';
import 'package:mysql1/mysql1.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:flutter/services.dart' show rootBundle;

class TransactionReportWidget extends StatefulWidget {
  final int uid;

  const TransactionReportWidget({
    Key? key,
    required this.uid,
  }) : super(key: key);

  @override
  _TransactionReportWidgetState createState() =>
      _TransactionReportWidgetState();
}

class _TransactionReportWidgetState extends State<TransactionReportWidget> {
  late List<Map<String, dynamic>> receivers = [];

  @override
  void initState() {
    super.initState();
    fetchReceiverDetails();
  }

// Function to fetch and store donor details based on oduid (uid in users table)
  Future<Map<String, dynamic>> fetchDonorDetails(int oduid) async {
    try {
      final MySqlConnection conn = await MySqlConnection.connect(settings);

      var results = await conn.query(
        '''
      SELECT * FROM users WHERE uid = ?
      ''',
        [oduid],
      );

      Map<String, dynamic> donorDetails = {};

      for (var row in results) {
        donorDetails = row.fields;
      }

      await conn.close();
      return donorDetails;
    } catch (e) {
      // Handle error...
      print('Error fetching donor details: $e');
      return {}; // Return an empty map in case of an error
    }
  }

  Future<void> fetchReceiverDetails() async {
    try {
      final MySqlConnection conn = await MySqlConnection.connect(settings);

      var results = await conn.query(
        '''
        SELECT r.receiver_id, r.ruid, r.roid, r.date_of_allocation, r.rmedical_history,
               r.rorgan_name, r.rbloodgroup, u.name as user_name, u.phone_number as user_phone,
               u.email as user_email, u.address as user_address, u.date_of_birth as user_age
        FROM receiver r
        JOIN users u ON r.ruid = u.uid
        WHERE r.ruid = ? AND r.roid IS NOT NULL AND r.date_of_allocation IS NOT NULL
        ''',
        [widget.uid],
      );

      List<Map<String, dynamic>> fetchedReceivers = [];

      for (var row in results) {
        fetchedReceivers.add(row.fields);
      }

      setState(() {
        receivers = fetchedReceivers;
      });

      await conn.close();
    } catch (e) {
      // Handle error...
      print('Error fetching receiver details: $e');
    }
  }

  Future<Map<String, dynamic>> fetchBranchDetails(int roid) async {
    try {
      final MySqlConnection conn = await MySqlConnection.connect(settings);

      // Fetch branch_id from available table based on organ_id (roid)
      var availabilityResult = await conn.query(
        '''
      SELECT branch_id FROM available WHERE organ_id = ?
      ''',
        [roid],
      );

      // Extract branch_id from the result
      int branchId = availabilityResult.first['branch_id'];
      print(branchId);

      // Fetch branch details based on branch_id
      var branchResult = await conn.query(
        '''
      SELECT * FROM branch WHERE bid = ?
      ''',
        [branchId],
      );

      Map<String, dynamic> branchDetails = {};

      for (var row in branchResult) {
        branchDetails = row.fields;
      }

      await conn.close();
      return branchDetails;
    } catch (e) {
      // Handle error...
      print('Error fetching branch details: $e');
      return {}; // Return an empty map in case of an error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Divider(height: 1, thickness: 1, color: Colors.black),
          for (var receiver in receivers) ...[
            ElevatedButton(
              onPressed: () {
                _generateAndSendPDF(receiver);
              },
              child: Text(
                  'View oragn allocated Report for \nReceiver ID ${receiver['receiver_id']}'),
            ),
            Divider(height: 1, thickness: 1, color: Colors.black),
          ]
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> fetchOrganDetails(int roid) async {
    try {
      final MySqlConnection conn = await MySqlConnection.connect(settings);

      var results = await conn.query(
        '''
      SELECT * FROM organ WHERE oid = ?
      ''',
        [roid],
      );

      List<Map<String, dynamic>> organs = [];

      for (var row in results) {
        organs.add(row.fields);
      }

      // Print organ information in console
      print('Organ Details for ROID $roid:');
      organs.forEach((organ) {
        print('Organ ID: ${organ['oid']}');
        print('Organ HLA: ${organ['ohla']}');
        print('Organ Medical History: ${organ['omedical_history']}');
        print('Organ Age: ${organ['oage']}');
        print('Organ Blood Group: ${organ['obloodgroup']}');
        print('Organ Availability: ${organ['organ_availability']}');
        print('Organ Name: ${organ['organ_name']}');
        print('Organ Donor Status: ${organ['odonor_status']}');
        print('Organ Donor UID: ${organ['oduid']}');
        print('-----------------------------');
      });

      await conn.close();
      return organs;
    } catch (e) {
      // Handle error...
      print('Error fetching organ details: $e');
      return []; // Return an empty list in case of an error
    }
  }

  Future<Map<String, dynamic>> fetchOrganAndAvailableDetails(int roid) async {
    try {
      final MySqlConnection conn = await MySqlConnection.connect(settings);

      var results = await conn.query(
        '''
    SELECT o.*, a.branch_id
    FROM organ o
    LEFT JOIN available a ON o.oid = a.organ_id
    WHERE o.oid = ?
    ''',
        [roid],
      );

      Map<String, dynamic> organDetails = {};

      for (var row in results) {
        organDetails = row.fields;
      }

      await conn.close();
      return organDetails;
    } catch (e) {
      // Handle error...
      print('Error fetching organ and available details: $e');
      return {}; // Return an empty map in case of an error
    }
  }

  Future<void> _generateAndSendPDF(Map<String, dynamic> receiver) async {
    PdfDocument document = PdfDocument();
    document.pageSettings.size = PdfPageSize.a4;
    document.pageSettings.orientation = PdfPageOrientation.portrait;

    // Load the image from the assets (replace 'image_path.png' with your image file path)
    final Uint8List imageBytes =
        (await rootBundle.load('assets/Indian_Flag.png')).buffer.asUint8List();

    // Calculate image width and height to fit the page
    PdfBitmap image = PdfBitmap(imageBytes);
    // Calculate image width and reduced height to fit the page
    double imageWidth = 100;
    double imageHeight = 80; // Set your desired height in points

    // Extract roid from the receiver map
    int roid = receiver['roid'];

    // Fetch organ details based on roid

    // Fetch donor details based on oduid (uid in users table)

    // Example usage of donor details

    // Content

    List<Map<String, dynamic>> organs = await fetchOrganDetails(roid);
    // Fetch branch details based on roid
    Map<String, dynamic> branchDetails = await fetchBranchDetails(roid);
    int oduid = organs[0]['oduid'] as int;
    Map<String, dynamic> donorDetails = await fetchDonorDetails(oduid);
    String donorName = donorDetails['name'];
    String donorEmail = donorDetails['email'];
    String donorphoneNumber = donorDetails['phone_number'];
    String donoraddress = donorDetails['address'];
    // Split receiver medical history at commas and create a list of items
    List<String> medicalHistoryItems = [];
    dynamic medicalHistory = receiver['rmedical_history'];
    if (medicalHistory is String) {
      medicalHistoryItems =
          medicalHistory.split(',').map((e) => e.trim()).toList();
    } else if (medicalHistory is List) {
      medicalHistoryItems = List<String>.from(medicalHistory);
    }
// Extract organ medical history from the organs list
    String organMedicalHistory = organs[0]['omedical_history'];
    List<String> organMedicalHistoryItems =
        organMedicalHistory.split(',').map((e) => e.trim()).toList();

    // Extract branch address from branchDetails map
    String branchAddress = branchDetails['baddress'];
    List<String> branchAddressItems =
        branchAddress.split(',').map((e) => e.trim()).toList();

    // Extract receiver address from receiver map
    String receiverAddress = receiver['user_address'];
    List<String> receiverAddressItems =
        receiverAddress.split(',').map((e) => e.trim()).toList();
    String donorAddress = donorDetails['address'];
    List<String> donorAddressItems =
        donorAddress.split(',').map((e) => e.trim()).toList();

    String organDetails = '';
    organs.forEach((organ) async {
      organDetails += '''
    Allocated organ details
    --------------------------------------------------------
    Organ ID: ${organ['oid']}
    Organ HLA: ${organ['ohla']}
    Organ Medical History:
  ${organMedicalHistoryItems.join('\n')}
    Organ Age: ${organ['oage']}
    Organ Blood Group: ${organ['obloodgroup']}
    Organ Name: ${organ['organ_name']}
    Organ Donor Status: ${organ['odonor_status']}
    Organ Donor UID: ${organ['oduid']}
    
  ''';
      // Fetch and store branch details based on the branch_id from the 'available' table

      // Include branch details in the organDetails
    });
    organDetails += '''
  --------------------------------------------------------
  Branch Details:
  --------------------------------------------------------
  Branch ID: ${branchDetails['bid']}
  Branch Name: ${branchDetails['bname']}
   Branch Address:
  ${branchAddressItems.join('\n')}
  
  Branch Phone Number: ${branchDetails['bphone_number']}
  --------------------------------------------------------
  .
  .
  .
  ''';

    // ..
    String content = '''
  -------------CONGRATULATIONS ----------------
     U HAVE BEEN ALLOCATED A REQUIRED ORGAN
  ----------------------------------------------
  $organDetails
 
  
  Receiver Details
  ----------------------------------------------
  Receiver ID: ${receiver['receiver_id']}
  Allocated organ id: ${receiver['roid']}
  Date of Allocation: ${receiver['date_of_allocation']}
  Receiver Name: ${receiver['user_name']}
  Receiver Phone: ${receiver['user_phone']}
  Receiver Email: ${receiver['user_email']}
 
  
  Receiver Address:
  ${receiverAddressItems.join('\n')}
  Receiver Age: ${receiver['user_age']}
  
  ''';

    // Add medical history items to content lines
    int i = 0;
    for (String historyItem in medicalHistoryItems) {
      if (i == 0) {
        content += 'Receiver Medical History: $historyItem\n';
        i = 1;
      } else {
        content += ' $historyItem\n';
      }
    }

    content += '''
 
  Receiver required : ${receiver['rorgan_name']}
  
  Receiver Blood Group: ${receiver['rbloodgroup']}
 
  -------------------------------------------------------
  Donor Details
  -------------------------------------------------------
  Donor Name : ${donorName}
  Donor Email:${donorEmail}
  Donor Phone Number:${donorphoneNumber}
 
 Donor Address:
  ${donorAddressItems.join('\n')}
  -------------------------------------------------------
 
''';

    // Split content into lines
    List<String> lines =
        content.split('\n').map((line) => line.trim()).toList();

    double initialYPosition = imageHeight + 10; // Adjust the spacing as needed
    double yPosition = initialYPosition;

    PdfPage page = document.pages.add();
    PdfGraphics graphics = page.graphics;
    graphics.drawImage(image, Rect.fromLTWH(0, 0, imageWidth, imageHeight));

    for (String line in lines) {
      double textHeight = PdfStandardFont(PdfFontFamily.helvetica, 20)
          .measureString(line)
          .height;

      // Check if the line fits in the remaining space on the page
      if (yPosition + textHeight <= document.pageSettings.height) {
        graphics.drawString(
          line,
          PdfStandardFont(PdfFontFamily.helvetica, 20),
          bounds: Rect.fromLTWH(
              0, yPosition, document.pageSettings.width, textHeight),
        );
        yPosition += textHeight;
      } else {
        // Move to the next page if there is more content
        page = document.pages.add();
        graphics = page.graphics;

        // Draw the image on the new page (if needed)
        // graphics.drawImage(image, Rect.fromLTWH(0, 0, imageWidth, imageHeight));

        // Reset y-position for the new page
        yPosition = 0;

        // Draw text on the new page
        graphics.drawString(
          line,
          PdfStandardFont(PdfFontFamily.helvetica, 20),
          bounds: Rect.fromLTWH(
              0, yPosition, document.pageSettings.width, textHeight),
        );
        yPosition += textHeight;
      }
    }

    // Save the PDF to a file
    final directory = await getExternalStorageDirectory();
    final path = directory!.path;
    final filePath = '$path/TransactionReport.pdf';
    File file = File(filePath);
    file.writeAsBytes(await document.save());

    // Open the saved PDF file
    OpenFile.open(filePath);

    // Dispose the document
    document.dispose();
  }
}
