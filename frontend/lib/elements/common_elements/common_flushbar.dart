import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

void showCustomFlushBar(BuildContext context, String message) {
  Flushbar(
    message: message,
    duration: const Duration(seconds: 2),
    backgroundColor: AppTheme.cardBg,
    messageColor: AppTheme.textDark,
    margin: const EdgeInsets.all(8),
    borderRadius: BorderRadius.circular(8),
  ).show(context);
}