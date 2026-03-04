// Custom AppBar with BVM logo and current date/time
// (removed duplicate import)
import 'dart:async';
import 'package:bvm_manual_inspection_station/app.dart';
import 'package:bvm_manual_inspection_station/config/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:bvm_manual_inspection_station/models/user_session.dart';
import 'package:bvm_manual_inspection_station/main.dart';

class BvmAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String? title;
  final bool showLogoutButton;
  final bool showBackButton;

  const BvmAppBar({
    super.key,
    this.title,
    this.showLogoutButton = true,
    this.showBackButton = false,
  });

  @override
  Size get preferredSize => Size.fromHeight(title == null ? 64 : 80);

  @override
  State<BvmAppBar> createState() => _BvmAppBarState();
}

class _BvmAppBarState extends State<BvmAppBar> {
  late String _date;
  late String _time;
  late final StreamSubscription ticker;

  @override
  void initState() {
    super.initState();
    _updateDateTime();
    ticker = Stream.periodic(
      const Duration(seconds: 1),
    ).listen((_) => _updateDateTime());
  }

  void _updateDateTime() {
    final now = DateTime.now();
    const List<String> monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final String month = monthNames[now.month - 1];
    final String day = now.day.toString();
    final String year = now.year.toString();

    final int hour = now.hour;
    final int minute = now.minute;
    final String period = hour >= 12 ? 'PM' : 'AM';
    int hour12 = hour % 12;
    if (hour12 == 0) hour12 = 12;

    setState(() {
      _date = "$month $day, $year";
      _time =
          "${hour12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period";
    });
  }

  @override
  void dispose() {
    ticker.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasTitle = widget.title != null;
    return Container(
      height: hasTitle ? 80 : 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2F38),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Left Side: Back Button or Date
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.showBackButton && Navigator.canPop(context)) ...[
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppTheme.textBody,
                        size: 20,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    _date,
                    style: const TextStyle(
                      color: AppTheme.textBody,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Center: Logo and Shrunken Title
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.bubble_chart_rounded,
                        color: AppTheme.secondary,
                        size: hasTitle ? 24 : 32,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Inspection Station',
                        style: TextStyle(
                          color: AppTheme.textDark,
                          fontSize: hasTitle ? 22 : 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: hasTitle ? 3 : 6,
                        ),
                      ),
                    ],
                  ),
                  if (hasTitle)
                    Text(
                      widget.title!.toUpperCase(),
                      style: TextStyle(
                        color: AppTheme.primary.withOpacity(0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                ],
              ),
            ),

            // Right Side: Time and Logout
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _time,
                    style: const TextStyle(
                      color: AppTheme.textBody,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (widget.showLogoutButton) ...[
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(
                        Icons.logout_rounded,
                        color: AppTheme.error,
                        size: 20,
                      ),
                      onPressed: () {
                        UserSession.rollNumber = null;
                        UserSession.name = null;
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    const BvmManualInspectionStationApp(),
                          ),
                          (route) => false,
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
