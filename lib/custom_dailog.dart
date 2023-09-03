import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final List<String> items;

  CustomDialog({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            offset: const Offset(0, 10),
            blurRadius: 10.0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 8.0,
          ),
          Container(
            height: 200.0, // Adjust the height as needed
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(items[index]),
                );
              },
            ),
          ),
          SizedBox(
            height: 8.0,
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
