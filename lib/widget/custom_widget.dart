import 'package:flutter/material.dart';

SnackBar customSnakBar({required String title}) {
  return SnackBar(
    backgroundColor: const Color(0xFF2A1A6E), // deep cosmic indigo
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: Color(0xFF7B61FF), width: 1),
    ),

    content: Text(
      title,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Color(0xFFFFD700), // golden text
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    ),
  );
}
