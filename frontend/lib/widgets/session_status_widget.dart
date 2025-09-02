import 'package:flutter/material.dart';
import '../services/session_service.dart';
import '../models/user_session_model.dart';

class SessionStatusWidget extends StatefulWidget {
  const SessionStatusWidget({super.key});

  @override
  State<SessionStatusWidget> createState() => _SessionStatusWidgetState();
}

class _SessionStatusWidgetState extends State<SessionStatusWidget> {
  UserSessionModel? _currentSession;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkSessionStatus();
  }

  Future<void> _checkSessionStatus() async {
    setState(() {
      _loading = true;
    });

    try {
      final session = await SessionService.getSessionStatus();
      setState(() {
        _currentSession = session;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
    }
  }

  String _getStatusMessage() {
    if (_currentSession == null) return 'No active session';
    
    switch (_currentSession!.status) {
      case 'pending_calibration':
        return 'Session pending - calibration required';
      case 'calibrated':
        return 'Session completed successfully';
      case 'expired':
        return 'Session expired';
      default:
        return 'Unknown session status';
    }
  }

  Color _getStatusColor() {
    if (_currentSession == null) return Colors.grey;
    
    switch (_currentSession!.status) {
      case 'pending_calibration':
        return Colors.orange;
      case 'calibrated':
        return Colors.green;
      case 'expired':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        border: Border.all(color: _getStatusColor()),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _currentSession?.status == 'calibrated' 
              ? Icons.check_circle 
              : _currentSession?.status == 'pending_calibration'
                ? Icons.pending
                : Icons.info,
            size: 16,
            color: _getStatusColor(),
          ),
          const SizedBox(width: 4),
          Text(
            _getStatusMessage(),
            style: TextStyle(
              fontSize: 12,
              color: _getStatusColor(),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
