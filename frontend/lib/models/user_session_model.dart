class UserSessionModel {
  final String sessionId;
  final String rollNumber;
  final String name;
  final DateTime createdAt;
  final String status; // 'pending_calibration', 'calibrated', 'expired'
  final bool calibrationRequired;

  UserSessionModel({
    required this.sessionId,
    required this.rollNumber,
    required this.name,
    required this.createdAt,
    required this.status,
    required this.calibrationRequired,
  });

  factory UserSessionModel.fromJson(Map<String, dynamic> json) {
    return UserSessionModel(
      sessionId: json['session_id'],
      rollNumber: json['roll_number'],
      name: json['name'],
      createdAt: DateTime.parse(json['created_at']),
      status: json['status'],
      calibrationRequired: json['calibration_required'],
    );
  }
}
