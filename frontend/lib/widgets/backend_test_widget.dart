import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../config/app_theme.dart';
import 'dart:developer' as developer;

class BackendTestWidget extends StatefulWidget {
  const BackendTestWidget({super.key});

  @override
  State<BackendTestWidget> createState() => _BackendTestWidgetState();
}

class _BackendTestWidgetState extends State<BackendTestWidget> {
  bool? _isConnected;
  bool _isLoading = false;
  List<String>? _housingTypes;
  List<String>? _shaftVideos;

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _isConnected = null;
      _housingTypes = null;
      _shaftVideos = null;
    });

    try {
      developer.log('[Test] Testing backend connection...');
      final connected = await ApiService.testConnection();
      
      if (connected) {
        developer.log('[Test] Connection successful, fetching housing types...');
        final types = await ApiService.getHousingTypes();
        
        developer.log('[Test] Fetching shaft videos...');
        final videos = await ApiService.getShaftVideos();
        
        setState(() {
          _isConnected = true;
          _housingTypes = types;
          _shaftVideos = videos;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isConnected = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      developer.log('[Test] Connection test failed: $e');
      setState(() {
        _isConnected = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: const Text('Backend Connection Test'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _testConnection,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Test Backend Connection'),
            ),
            const SizedBox(height: 20),
            if (_isConnected != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isConnected! ? Colors.green.shade100 : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isConnected! ? Colors.green : Colors.red,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isConnected! ? Icons.check_circle : Icons.error,
                      color: _isConnected! ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isConnected! ? 'Backend Connected' : 'Connection Failed',
                      style: TextStyle(
                        color: _isConnected! ? Colors.green.shade800 : Colors.red.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (_housingTypes != null) ...[
              const Text(
                'Housing Types:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _housingTypes!
                      .map((type) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              '• $type',
                              style: const TextStyle(color: AppTheme.textDark),
                            ),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (_shaftVideos != null) ...[
              const Text(
                'Shaft Videos:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _shaftVideos!
                      .map((video) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              '• $video',
                              style: const TextStyle(color: AppTheme.textDark),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
