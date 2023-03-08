import 'package:flutter/material.dart';

class DialogHelper {
  static showConfirmDialog(
    BuildContext context,
    String title,
    String description,
    String confirmBtnTxt,
    String cancelBtnTxt,
    Function onConfirmClicked,
  ) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text(cancelBtnTxt),
      onPressed: () {
        Navigator.of(context).pop(); // dismiss dialog
      },
    );
    Widget confirmButton = TextButton(
      child: Text(
        confirmBtnTxt,
        style: const TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
      onPressed: () {
        onConfirmClicked.call();
        Navigator.of(context).pop(); // dismiss dialog
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(description),
      actions: [
        cancelButton,
        confirmButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static showInfoDialog(BuildContext context, String title, String description,
      String confirmBtnTxt) {
    // set up the buttons

    Widget confirmButton = TextButton(
      child: Text(confirmBtnTxt),
      onPressed: () {
        Navigator.of(context).pop(); // dismiss dialog
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(description),
      actions: [
        confirmButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
