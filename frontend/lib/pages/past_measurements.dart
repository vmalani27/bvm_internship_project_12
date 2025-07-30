import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/user_session.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
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

  Future<void> fetchMeasurements() async {
    if (userRollNumber == null) return;
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final uri = Uri.parse('http://127.0.0.1:8000/measured_units/$userRollNumber');
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

  Widget buildTable(String title, List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) return const SizedBox();
    final columns = rows.first.keys.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: columns.map((c) => DataColumn(label: Text(c, style: const TextStyle(fontWeight: FontWeight.bold)))).toList(),
            rows: rows.map((row) => DataRow(
              cells: columns.map((c) => DataCell(Text(row[c]?.toString() ?? ''))).toList(),
            )).toList(),
            headingRowColor: MaterialStateProperty.all(AppTheme.cardBg),
            dataRowColor: MaterialStateProperty.all(AppTheme.bgColor),
            border: TableBorder.all(color: AppTheme.cardBg),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: const Text('Past Measurements', style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.cardBg,
        foregroundColor: AppTheme.textDark,
        elevation: 1,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: isLoading
              ? const CircularProgressIndicator()
              : error != null
                  ? Text('Error: $error', style: const TextStyle(color: Colors.red))
                  : (data == null || (data!['shaft_measurements']?.isEmpty ?? true) && (data!['housing_measurements']?.isEmpty ?? true))
                      ? const Text('No measurements found.')
                      : SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (userName != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: Text('User: $userName ($userRollNumber)', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                ),
                              buildTable('Shaft Measurements', List<Map<String, dynamic>>.from(data!['shaft_measurements'] ?? [])),
                              const SizedBox(height: 32),
                              buildTable('Housing Measurements', List<Map<String, dynamic>>.from(data!['housing_measurements'] ?? [])),
                            ],
                          ),
                        ),
        ),
      ),
    );
  }
}
