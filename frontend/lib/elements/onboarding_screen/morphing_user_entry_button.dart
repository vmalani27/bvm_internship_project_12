import 'dart:io';

import 'package:bvm_manual_inspection_station/models/user_session.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:bvm_manual_inspection_station/elements/custom_flushbar.dart';
import 'package:bvm_manual_inspection_station/config/app_config.dart';
// import 'package:bvm_manual_inspection_station/config/user_session.dart';
import 'dart:convert';

class MorphingUserEntryButton extends StatefulWidget {
  final bool enabled;
  final VoidCallback onComplete;
  final Color buttonBg;
  final Color buttonFg;
  final OutlinedBorder buttonBorder;
  final ValueChanged<bool>? onShouldCalibrateChanged;  // New callback added

  const MorphingUserEntryButton({
    required this.enabled,
    required this.onComplete,
    required this.buttonBg,
    required this.buttonFg,
    required this.buttonBorder,
    this.onShouldCalibrateChanged,  // New callback added to constructor
    super.key,
  });

  @override
  State<MorphingUserEntryButton> createState() => _MorphingUserEntryButtonState();
}

class _MorphingUserEntryButtonState extends State<MorphingUserEntryButton> {
  bool _expanded = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _rollNumberController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _showSubmit = false;


// void showFlushBar(BuildContext context, String message) {
//   Flushbar(
//     message: message,
//     duration: const Duration(seconds: 2),
//     backgroundColor: Colors.white,
//     messageColor: Colors.black,
//     margin: const EdgeInsets.all(8),
//     borderRadius: BorderRadius.circular(8),
//   ).show(context);
// }
  void _openForm() {
    if (widget.enabled) {
      // Logging: Step 1 form opened
      // ignore: avoid_print
      print('[LOG] Step 1: User Entry form opened');
      setState(() {
        _expanded = true;
      });

      showCustomFlushBar(context, "Please enter your details");
    }
  }

  void _closeForm() {
    // Logging: Step 1 form closed/cancelled
    // ignore: avoid_print
    print('[LOG] Step 1: User Entry form closed/cancelled');
    setState(() {
      _expanded = false;
    });
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final now = DateTime.now();
        final date = "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
        final time = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
        final entry = {
          "roll_number": _rollNumberController.text.trim(),
          "name": _nameController.text.trim(),
          "date": date,
          "time": time,
          "last_login": ""
        };
        final baseurl= AppConfig.backendBaseUrl;
        final response = await http.post(
          Uri.parse('$baseurl/user_entry'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(entry),
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> resp = jsonDecode(response.body);
          if (resp['status'] == 'welcome_back') {
            showCustomFlushBar(context, 'Welcome back!');
          }
          // Check for should_calibrate flag in response and notify parent
          if (resp.containsKey('should_calibrate') && widget.onShouldCalibrateChanged != null) {
            widget.onShouldCalibrateChanged!(resp['should_calibrate'] as bool);
          }
          // Set global user session values
          UserSession.rollNumber = _rollNumberController.text.trim();
          UserSession.name = _nameController.text.trim();
          widget.onComplete();
          _closeForm();
        } 
      
        
        else {
          // Handle error (show flushbar)
          print(response.body);
          showCustomFlushBar(context, 'Failed to submit: \\${response.body}');
        }
        
      } catch (e) {
        print(e);
        if(e is http.ClientException) {
          showCustomFlushBar(context, 'please check the backend: ${e.message}');
        } else {
          showCustomFlushBar(context, 'Error: ${e.toString()}');
        }
        showCustomFlushBar(context, 'Error: ${e.toString()}');

      }
    }
  }

  void _updateShowSubmit() {
    setState(() {
      _showSubmit =
          _rollNumberController.text.trim().isNotEmpty && _nameController.text.trim().isNotEmpty;
    });
  }

  @override
  void initState() {
    super.initState();
    _rollNumberController.addListener(_updateShowSubmit);
    _nameController.addListener(_updateShowSubmit);
  }

  @override
  void dispose() {
    _rollNumberController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      width: _expanded ? 340 : 160,
      height: _expanded ? 270 : 60,
      decoration: BoxDecoration(
        color: _expanded ? const Color(0xFFF7FAFC) : widget.buttonBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: _expanded ? const Color(0xFFb6c1d1) : widget.buttonFg.withOpacity(0.18),
          width: 1.2,
        ),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        child: _expanded
            ? Padding(
                key: const ValueKey('form'),
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'User Entry',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2d3a4a),
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _rollNumberController,
                          style: TextStyle(color: Color(0xFF2d3a4a), fontSize: 16),
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.badge, color: Color(0xFF1976D2)),
                            labelText: 'Roll Number',
                            labelStyle: TextStyle(color: Color(0xFF1976D2)),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.85),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: Color(0xFFb6c1d1)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: Color(0xFF1976D2), width: 2),
                            ),
                          ),
                          validator: (value) => value == null || value.isEmpty ? 'Enter your roll number' : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _nameController,
                          style: TextStyle(color: Color(0xFF2d3a4a), fontSize: 16),
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.person, color: Color(0xFF388E3C)),
                            labelText: 'Name',
                            labelStyle: TextStyle(color: Color(0xFF388E3C)),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.85),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: Color(0xFFb6c1d1)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: Color(0xFF388E3C), width: 2),
                            ),
                          ),
                          validator: (value) => value == null || value.isEmpty ? 'Enter your name' : null,
                        ),
                        const SizedBox(height: 22),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Color(0xFF2d3a4a),
                                side: BorderSide(color: Color(0xFFb6c1d1)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: _closeForm,
                              child: const Text('Cancel'),
                            ),
                            if (_showSubmit)
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF1976D2),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 2,
                                ),
                                onPressed: _submitForm,
                                child: const Text('Submit'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : Material(
                key: const ValueKey('button'),
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: widget.enabled ? _openForm : null,
                  child: Center(
                    child: Text(
                      'User Entry',
                      style: TextStyle(
                        color: widget.buttonFg,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.7,
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}