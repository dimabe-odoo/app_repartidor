import 'package:flutter/material.dart';

bool isNumber(String value) {
  if (value.isEmpty) return false;
  return num.tryParse(value) != null;
}

void showAlert(BuildContext context, String title, String message) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            FlatButton(
              child: Text('ok'),
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            )
          ],
        );
      });
}
