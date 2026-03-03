import 'dart:ui';
import 'package:bvm_manual_inspection_station/config/app_config.dart';
import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../elements/common_elements/common_appbar.dart';
import '../models/user_session.dart';
import '../services/api_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class PastMeasurementsPage extends StatefulWidget {
  const PastMeasurementsPage({super.key});

  @override
  State<PastMeasurementsPage> createState() => _PastMeasurementsPageState();
}

class _PastMeasurementsPageState extends State<PastMeasurementsPage> {
  String? get userRollNumber => UserSession.rollNumber;
  String? get userName => UserSession.name;
  bool isLoading = true;
  Map<String, dynamic>? data;
  String? error;
  // Tracks which measurement type is currently being exported (null = idle)
  String? _exportingType;

  @override
  void initState() {
    super.initState();

    if (userRollNumber == null) {
      setState(() {
        error = 'User not logged in.';
        isLoading = false;
      });
    } else {
      fetchMeasurements();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  double _getColumnWidth(String columnName) {
    // Define specific widths for different column types
    switch (columnName.toLowerCase()) {
      case 'unit_id':
        return 80;
      case 'timestamp':
      case 'date':
      case 'time':
        return 140;
      case 'housing_type':
      case 'measurement_type':
        return 120;
      case 'value':
      case 'measurement_value':
        return 100;
      case 'user_roll_number':
      case 'roll_number':
        return 130;
      case 'product_id':
        return 110;
      case 'step_label':
        return 150;
      case 'name':
        return 120;
      default:
        return 100; // Default width for any other columns
    }
  }

  Future<void> fetchMeasurements() async {
    final String baseUrl = AppConfig.backendBaseUrl;
    if (userRollNumber == null) return;
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final uri = Uri.parse('$baseUrl/measured_units/$userRollNumber');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        data = jsonDecode(response.body);
      } else {
        error = 'Failed to fetch data: ${response.statusCode}';
      }
    } catch (e) {
      error = e.toString();
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _exportCsv(String type) async {
    final roll = userRollNumber;
    if (roll == null) return;
    setState(() => _exportingType = type);
    try {
      final url = await ApiService.exportCsv(type: type, rollNumber: roll);
      if (!mounted) return;
      if (url == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Export failed — please try again')),
        );
      } else {
        // Open the presigned URL in a new browser tab
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open download URL')),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _exportingType = null);
    }
  }

  Widget buildMeasurementCard(
    String title,
    List<Map<String, dynamic>> rows,
    Color accentColor,
    String measurementType, // 'shaft' or 'housing'
  ) {
    if (rows.isEmpty) return const SizedBox();

    final List<String> columns = rows.first.keys.toList();
    final int columnCount = columns.length;
    final double baseSum = columns
        .map((c) => _getColumnWidth(c))
        .fold<double>(0, (a, b) => a + b);
    final bool isShaft = title.toLowerCase().contains('shaft');

    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.03),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accentColor.withOpacity(0.1),
                  accentColor.withOpacity(0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    title.contains('Shaft')
                        ? Icons.settings_rounded
                        : Icons.straighten_rounded,
                    size: 22,
                    color: accentColor,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  child:
                      _exportingType == measurementType
                          ? Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: accentColor,
                              ),
                            ),
                          )
                          : OutlinedButton.icon(
                            onPressed: () => _exportCsv(measurementType),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: accentColor,
                              side: BorderSide(
                                color: accentColor.withOpacity(0.6),
                                width: 1,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              backgroundColor: accentColor.withOpacity(0.08),
                            ),
                            icon: const Icon(Icons.download_rounded, size: 18),
                            label: const Text(
                              'Export CSV',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                ),
                // Container(
                //   padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                //   decoration: BoxDecoration(
                //     color: accentColor.withOpacity(0.2),
                //     borderRadius: BorderRadius.circular(14),
                //   ),
                //   child: Text(
                //     '${rows.length}',
                //     style: TextStyle(
                //       fontSize: 15,
                //       fontWeight: FontWeight.bold,
                //       color: accentColor,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double avail = constraints.maxWidth;
                final bool needsScroll = avail < baseSum;
                // When expanding: either distribute extra proportionally or evenly for shaft.
                double widthFor(String col) {
                  // Divide the container width equally among all columns
                  final double inner =
                      avail - 48; // account for horizontal margin/padding
                  return inner / columns.length;
                }

                final table = DataTable(
                  columnSpacing: 8.0, // Reduced space between columns
                  horizontalMargin: 24,
                  headingRowHeight: 54,
                  dataRowMinHeight: 44,
                  dataRowMaxHeight: 56,
                  headingRowColor: WidgetStateProperty.all(Colors.transparent),
                  dataRowColor: WidgetStateProperty.all(Colors.transparent),
                  border: TableBorder(
                    horizontalInside: BorderSide(
                      color: Colors.white.withOpacity(0.08),
                      width: 1,
                    ),
                  ),
                  columns:
                      columns
                          .map(
                            (c) => DataColumn(
                              label: SizedBox(
                                width:
                                    c.toLowerCase() == 'timestamp'
                                        ? 160
                                        : widthFor(c),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                    horizontal: 8,
                                  ),
                                  child: Text(
                                    c.replaceAll('_', ' ').toUpperCase(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textDark.withOpacity(
                                        0.85,
                                      ),
                                      fontSize: 12,
                                      letterSpacing: 0.6,
                                    ),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                  rows:
                      rows
                          .map(
                            (row) => DataRow(
                              cells:
                                  columns.map((c) {
                                    final val = row[c];
                                    String displayValue;
                                    if (c.toLowerCase() == 'timestamp' &&
                                        val != null) {
                                      try {
                                        // Try to parse and format the timestamp
                                        final dt =
                                            val is DateTime
                                                ? val
                                                : DateTime.tryParse(
                                                  val.toString(),
                                                );
                                        if (dt != null) {
                                          displayValue = DateFormat(
                                            'dd MMM yyyy, hh:mm a',
                                          ).format(dt);
                                        } else {
                                          displayValue = val.toString();
                                        }
                                      } catch (_) {
                                        displayValue = val.toString();
                                      }
                                    } else {
                                      displayValue = val?.toString() ?? '';
                                    }
                                    return DataCell(
                                      SizedBox(
                                        width:
                                            c.toLowerCase() == 'timestamp'
                                                ? 160
                                                : widthFor(c),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10,
                                            horizontal: 8,
                                          ),
                                          child: Text(
                                            displayValue,
                                            style: TextStyle(
                                              color: AppTheme.textDark
                                                  .withOpacity(0.92),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                            ),
                          )
                          .toList(),
                );

                return Container(
                  width: avail,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.12),
                      width: 1,
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.04),
                        Colors.white.withOpacity(0.02),
                      ],
                    ),
                  ),
                  child:
                      needsScroll
                          ? SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minWidth: baseSum),
                              child: table,
                            ),
                          )
                          : table,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = AppTheme.bgColor;
    final Color cardBg = AppTheme.cardBg;
    final Color accent = AppTheme.primary;
    final Color secondary = AppTheme.secondary;
    final Color textColor = AppTheme.textDark;

    return Scaffold(
      backgroundColor: bgColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              bgColor,
              bgColor.withOpacity(0.95),
              accent.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const BvmAppBar(title: 'History', showBackButton: true),

              Expanded(
                child: Center(
                  child: Container(
                    // Make central content much wider to fit full-width tables
                    constraints: BoxConstraints(
                      maxWidth: () {
                        final w = MediaQuery.of(context).size.width;
                        final target = w * 0.95; // use 95% of available width
                        final capped =
                            target > 1500
                                ? 1500
                                : target; // cap at 1500 for ultra-wide
                        return capped.toDouble();
                      }(),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child:
                        isLoading
                            ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        accent.withOpacity(0.15),
                                        accent.withOpacity(0.05),
                                      ],
                                    ),
                                  ),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: accent,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'Loading measurements...',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: textColor.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            )
                            : error != null
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 20,
                                  sigmaY: 20,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppTheme.error.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: AppTheme.error.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(32),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.error_outline_rounded,
                                        size: 48,
                                        color: AppTheme.error,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Error Loading Data',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        error!,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: textColor.withOpacity(0.7),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      ElevatedButton.icon(
                                        onPressed: fetchMeasurements,
                                        icon: const Icon(Icons.refresh_rounded),
                                        label: const Text('Retry'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.error,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                            : (data == null ||
                                (data!['shaft_measurements']?.isEmpty ??
                                        true) &&
                                    (data!['housing_measurements']?.isEmpty ??
                                        true))
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 20,
                                  sigmaY: 20,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: cardBg.withOpacity(0.95),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(32),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              accent.withOpacity(0.15),
                                              accent.withOpacity(0.05),
                                            ],
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.inbox_rounded,
                                          size: 40,
                                          color: accent,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No Measurements Found',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Start measuring components to see your history here.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: textColor.withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                            : SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 24),
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          cardBg.withOpacity(0.95),
                                          cardBg.withOpacity(0.98),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.2),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 15,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                accent.withOpacity(0.2),
                                                accent.withOpacity(0.1),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.history_rounded,
                                            size: 24,
                                            color: accent,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Measurement History',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: textColor,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                              Text(
                                                'View all your previous measurements',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: textColor.withOpacity(
                                                    0.7,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      buildMeasurementCard(
                                        'Shaft Measurements',
                                        List<Map<String, dynamic>>.from(
                                          data!['shaft_measurements'] ?? [],
                                        ),
                                        accent,
                                        'shaft',
                                      ),
                                      buildMeasurementCard(
                                        'Housing Measurements',
                                        List<Map<String, dynamic>>.from(
                                          data!['housing_measurements'] ?? [],
                                        ),
                                        secondary,
                                        'housing',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
