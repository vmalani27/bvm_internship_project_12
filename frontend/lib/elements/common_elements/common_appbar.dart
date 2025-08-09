// Custom AppBar with BVM logo and current date/time
// (removed duplicate import)
import 'dart:async';
import 'package:bvm_manual_inspection_station/config/app_theme.dart';
import 'package:flutter/material.dart';


class BvmAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String? title;
  const BvmAppBar({super.key, this.title});

  @override
  Size get preferredSize => Size.fromHeight(title == null ? 64 : 104);

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
    ticker = Stream.periodic(const Duration(seconds: 1)).listen((_) => _updateDateTime());
  }

  void _updateDateTime() {
    final now = DateTime.now();
    
    // More appealing date format: "August 1, 2025"
    const List<String> monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June', 'July',
      'August', 'September', 'October', 'November', 'December'
    ];
    final String month = monthNames[now.month - 1];
    final String day = now.day.toString();
    final String year = now.year.toString();

    // More appealing time format: "03:45 PM"
    final int hour = now.hour;
    final int minute = now.minute;
    final String period = hour >= 12 ? 'PM' : 'AM';
    int hour12 = hour % 12;
    if (hour12 == 0) {
      hour12 = 12; // Handle midnight and noon
    }

    setState(() {
      _date = "$month $day, $year";
      _time = "${hour12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period";
    });
  }

  @override
  void dispose() {
    ticker.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.title == null ? 64 : 104,
      padding: EdgeInsets.fromLTRB(24, widget.title == null ? 0 : 6, 24, widget.title == null ? 0 : 10),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2F38),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Date on the far left
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _date,
              style: const TextStyle(color: AppTheme.textBody, fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          // BVM logo/text and optional title in the center
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.bubble_chart_rounded, color: AppTheme.secondary, size: 32),
                    const SizedBox(width: 10),
                    Text(
                      'BVM',
                      style: const TextStyle(
                        color: AppTheme.textDark,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 6,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
                if (widget.title != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      widget.title!,
                      style: const TextStyle(
                        color: AppTheme.textBody,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Time on the far right
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              _time,
              style: const TextStyle(color: AppTheme.textBody, fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}