import 'package:flutter/material.dart';

Widget appBar(BuildContext context, String title) {
  return AppBar(
    title: Text(
      '$title',
    ),
  );
}

Future<dynamic> confirmationDialog(
    BuildContext context, String title, String content, dynamic confirmDel) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          title: Text(title),
          content: Text(content),
          actions: [
            FlatButton(
              onPressed: confirmDel,
              child: Text('Yes'),
            ),
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
          ],
        );
      });
}
