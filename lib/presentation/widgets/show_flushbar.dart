import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

void showIVFlushbar(
    BuildContext context,
    String message, {
      required Icon icon,
      FlushbarPosition position = FlushbarPosition.TOP,
    }) {
  Flushbar(
    message: message,
    flushbarPosition: position,
    flushbarStyle: FlushbarStyle.FLOATING,
    duration: const Duration(milliseconds: 1500),
    animationDuration: const Duration(milliseconds: 1),
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    borderRadius: BorderRadius.circular(12),
    backgroundColor: Colors.black.withAlpha(200),
    icon: icon
  ).show(context);
}