import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

Future<void> showSuccessFlushbar(
  BuildContext context,
  String? title,
  String message,
) async {
  await Flushbar(
    title: title,
    message: message,
    backgroundGradient: const LinearGradient(colors: [
      Colors.green,
      Colors.teal,
    ]),
    flushbarStyle: FlushbarStyle.FLOATING,
    duration: const Duration(seconds: 2),
    flushbarPosition: FlushbarPosition.TOP,
    margin: const EdgeInsets.all(8),
    borderRadius: BorderRadius.circular(8),
  ).show(context);
}

void showErrorFlushbar(BuildContext context, String? title, String message) {
  Flushbar(
    title: title,
    message: message.length > 100 ? message.substring(0, 100) : message,
    backgroundColor: Colors.red,
    flushbarStyle: FlushbarStyle.FLOATING,
    margin: const EdgeInsets.all(8),
    duration: const Duration(seconds: 2),
    flushbarPosition: FlushbarPosition.TOP,
    borderRadius: BorderRadius.circular(8),
  ).show(context);
}
