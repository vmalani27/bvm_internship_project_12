import 'package:flutter/material.dart';
import 'home_content.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;
import 'video_player_page.dart';
import 'package:media_kit/media_kit.dart';

// === CONFIGURABLE BACKEND BASE URL ===
// Change this to your computer's LAN IP for real device testing
const String backendBaseUrl = 'http://localhost:8000';

void main() {
  MediaKit.ensureInitialized();
  developer.log('Starting Flutter app with backend URL: $backendBaseUrl');
  runApp(const BvmManualInspectionStationApp());
}

class BvmManualInspectionStationApp extends StatelessWidget {
  const BvmManualInspectionStationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BVM Manual Inspection Station',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const BvmManualInspectionStationPage(),
    );
  }
}

class BvmManualInspectionStationPage extends StatelessWidget {
  const BvmManualInspectionStationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A237E), // Dark indigo
      appBar: AppBar(
        title: const Text('BVM Manual Inspection Station'),
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF1A237E),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BVM Manual Inspection Station',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Frontend Only',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Expanded(
              child: Center(
                child: Text(
                  'Sidebar content goes here',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
      body: const HomeContent(),
    );
  }
}

// Custom slide up route for NextPage
Route createSlideUpRoute() {
  return PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 500),
    pageBuilder: (context, animation, secondaryAnimation) => const NextPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final begin = const Offset(0.0, 1.0);
      final end = Offset.zero;
      final curve = Curves.easeInOut;
      final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
    );
  }

// NextPage widget (move to its own file if desired)
class NextPage extends StatelessWidget {
  const NextPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Next Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'This is the next page. Add your logic here.',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const VideoCategorySelectPage(),
                  ),
                );
              },
              child: const Text('Go to Video Selection'),
            ),
          ],
        ),
      ),
    );
  }
}

// VideoCategorySelectPage: Ask user to select Shaft or Housing
class VideoCategorySelectPage extends StatelessWidget {
  const VideoCategorySelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Item to Measure')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Which item are you measuring?', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => VideoListPage(category: 'housing'),
                  ),
                );
              },
              child: const Text('Housing'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => VideoListPage(category: 'shaft'),
                  ),
                );
              },
              child: const Text('Shaft'),
            ),
          ],
        ),
      ),
    );
  }
}

// VideoListPage: Fetch and show list of videos for the selected category
class VideoListPage extends StatefulWidget {
  final String category;
  const VideoListPage({required this.category, super.key});

  @override
  State<VideoListPage> createState() => _VideoListPageState();
}

class _VideoListPageState extends State<VideoListPage> {
  late Future<List<String>> _videoListFuture;

  @override
  void initState() {
    super.initState();
    _videoListFuture = fetchVideoList(widget.category);
  }

  Future<List<String>> fetchVideoList(String category) async {
    final url = Uri.parse('$backendBaseUrl/video/list/$category');
    developer.log('Fetching video list from: $url');
    
    try {
      final response = await http.get(url);
      developer.log('Response status code: ${response.statusCode}');
      developer.log('Response headers: ${response.headers}');
      developer.log('Response body length: ${response.body.length}');
      developer.log('Response body: "${response.body}"');
      
      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          developer.log('ERROR: Response body is empty');
          throw Exception('Empty response from server');
        }
        
        final List<dynamic> data = json.decode(response.body);
        developer.log('Parsed JSON data: $data');
        return data.cast<String>();
      } else {
        developer.log('ERROR: HTTP ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load video list: HTTP ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      developer.log('Exception in fetchVideoList: $e');
      developer.log('Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Video (${widget.category})')),
      body: FutureBuilder<List<String>>(
        future: _videoListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: \\${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No videos found.'));
          }
          final videos = snapshot.data!;
          return ListView.separated(
            itemCount: videos.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final filename = videos[index];
              return ListTile(
                title: Text(filename),
                trailing: const Icon(Icons.play_arrow),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => VideoPlayerPage(
                        category: widget.category,
                        filename: filename,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
} 