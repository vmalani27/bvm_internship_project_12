import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:bvm_manual_inspection_station/elements/custom_flushbar.dart';
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

        final response = await http.post(
          Uri.parse('http://127.0.0.1:8000/user_entry'),
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
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeInOut,
      width: _expanded ? 260 : 140,
      height: _expanded ? 190 : 56,
      decoration: BoxDecoration(
        color: widget.buttonBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _expanded
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
        border: widget.buttonBorder is RoundedRectangleBorder && !_expanded && (widget.buttonBorder as RoundedRectangleBorder).side != BorderSide.none
            ? Border.all(
                color: (widget.buttonBorder as RoundedRectangleBorder).side.color,
                width: (widget.buttonBorder as RoundedRectangleBorder).side.width,
              )
            : null,
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        child: _expanded
            ? Padding(
                key: const ValueKey('form'),
                padding: const EdgeInsets.all(14.0),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        
                        
                        TextFormField(
                          controller: _rollNumberController,
                          style: TextStyle(color: widget.buttonFg, fontSize: 15),
                          decoration: InputDecoration(
                            labelText: 'Roll Number',
                            labelStyle: TextStyle(color: widget.buttonFg, fontSize: 14),
                            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            filled: true,
                            fillColor: widget.buttonBg.withOpacity(0.95),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: widget.buttonFg.withOpacity(0.2)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: widget.buttonFg, width: 1.5),
                            ),
                          ),
                          validator: (value) => value == null || value.isEmpty ? 'Enter your roll number' : null,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _nameController,
                          style: TextStyle(color: widget.buttonFg, fontSize: 15),
                          decoration: InputDecoration(
                            labelText: 'Name',
                            labelStyle: TextStyle(color: widget.buttonFg, fontSize: 14),
                            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            filled: true,
                            fillColor: widget.buttonBg.withOpacity(0.95),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: widget.buttonFg.withOpacity(0.2)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: widget.buttonFg, width: 1.5),
                            ),
                          ),
                          validator: (value) => value == null || value.isEmpty ? 'Enter your name' : null,
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: widget.buttonFg,
                                textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: _closeForm,
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: 8),
                            if (_showSubmit)
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: widget.buttonFg,
                                  foregroundColor: widget.buttonBg,
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                  textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 0,
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
                  borderRadius: BorderRadius.circular(16),
                  onTap: widget.enabled ? _openForm : null,
                  child: Center(
                    child: Text(
                      'User Entry',
                      style: TextStyle(
                        color: widget.buttonFg,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}