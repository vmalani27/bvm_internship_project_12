
import 'package:bvm_manual_inspection_station/models/user_session.dart';
import 'package:flutter/material.dart';
import 'package:bvm_manual_inspection_station/elements/common_elements/common_flushbar.dart';
import 'package:bvm_manual_inspection_station/config/app_theme.dart';
import 'package:bvm_manual_inspection_station/services/session_service.dart';

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
  final FocusNode _rollNumberFocusNode = FocusNode();
  final FocusNode _nameFocusNode = FocusNode();
  bool _showSubmit = false;

// void showFlushBar(BuildContext context, String message) {
//   Flushbar(  
//     message: message,
//     duration: const Dura+tion(seconds: 2),
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
    
    // Unfocus any active text fields to prevent keyboard event conflicts
    _rollNumberFocusNode.unfocus();
    _nameFocusNode.unfocus();
    FocusScope.of(context).unfocus();
    
    setState(() {
      _expanded = false;
    });
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        // Use SessionService instead of direct HTTP call
        final loginResponse = await SessionService.createUserSession(
          rollNumber: _rollNumberController.text.trim(),
          name: _nameController.text.trim(),
        );

        if (loginResponse != null) {
          if (loginResponse.status == 'welcome_back') {
            showCustomFlushBar(context, 'Welcome back!');
          } else {
            showCustomFlushBar(context, 'Session created successfully!');
          }
          
          // Notify parent about calibration requirement
          if (widget.onShouldCalibrateChanged != null) {
            widget.onShouldCalibrateChanged!(loginResponse.shouldCalibrate);
          }
          
          // Set global user session values
          UserSession.rollNumber = _rollNumberController.text.trim();
          UserSession.name = _nameController.text.trim();
          
          widget.onComplete();
          _closeForm();
        } else {
          showCustomFlushBar(context, 'Failed to create session. Please try again.');
        }
      } catch (e) {
        print(e);
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
    _rollNumberFocusNode.dispose();
    _nameFocusNode.dispose();
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
        color: _expanded ? AppTheme.cardBg : widget.buttonBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: _expanded ? AppTheme.primary.withOpacity(0.3) : widget.buttonFg.withOpacity(0.18),
          width: 1.2,
        ),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        child: _expanded
            ? PopScope(
                key: const ValueKey('form'),
                canPop: true,
                onPopInvoked: (didPop) {
                  if (didPop) {
                    // If system already handled the pop, clean up focus
                    _rollNumberFocusNode.unfocus();
                    _nameFocusNode.unfocus();
                    FocusScope.of(context).unfocus();
                    setState(() {
                      _expanded = false;
                    });
                  }
                },
                child: Padding(
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
                            color: AppTheme.textDark,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _rollNumberController,
                          focusNode: _rollNumberFocusNode,
                          style: TextStyle(color: AppTheme.textDark, fontSize: 16),
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.badge, color: AppTheme.primary),
                            labelText: 'Roll Number',
                            labelStyle: TextStyle(color: AppTheme.primary),
                            filled: true,
                            fillColor: AppTheme.bgColor.withOpacity(0.8),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: AppTheme.primary.withOpacity(0.3)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: AppTheme.primary, width: 2),
                            ),
                          ),
                          validator: (value) => value == null || value.isEmpty ? 'Enter your roll number' : null,
                          onFieldSubmitted: (_) => _nameFocusNode.requestFocus(),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _nameController,
                          focusNode: _nameFocusNode,
                          style: TextStyle(color: AppTheme.textDark, fontSize: 16),
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.person, color: AppTheme.secondary),
                            labelText: 'Name',
                            labelStyle: TextStyle(color: AppTheme.secondary),
                            filled: true,
                            fillColor: AppTheme.bgColor.withOpacity(0.8),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: AppTheme.secondary.withOpacity(0.3)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: AppTheme.secondary, width: 2),
                            ),
                          ),
                          validator: (value) => value == null || value.isEmpty ? 'Enter your name' : null,
                          onFieldSubmitted: (_) {
                            if (_showSubmit) {
                              _submitForm();
                            }
                          },
                        ),
                        const SizedBox(height: 22),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.textDark,
                                side: BorderSide(color: AppTheme.primary.withOpacity(0.3)),
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
                                  backgroundColor: AppTheme.primary,
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