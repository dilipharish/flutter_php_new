import 'package:flutter/material.dart';

void showBloodInfoDialog(
    BuildContext context, String title, List<String> items) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var item in items) ListTile(title: Text(item)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('Close'),
          ),
        ],
      );
    },
  );
}
