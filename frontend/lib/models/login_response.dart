class LoginResponse {
  final String sessionId;
  final String status; // 'new_user' or 'welcome_back'
  final bool shouldCalibrate;
  final String message;

  LoginResponse({
    required this.sessionId,
    required this.status,
    required this.shouldCalibrate,
    required this.message,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      sessionId: json['session_id'],
      status: json['status'],
      shouldCalibrate: json['should_calibrate'],
      message: json['message'],
    );
  }
}
