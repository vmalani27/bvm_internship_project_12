import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;
import 'video_player_page.dart';
import '../config/app_config.dart';

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
    final url = Uri.parse('${AppConfig.backendBaseUrl}/video/list/$category');
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
            return Center(child: Text('Error: ${snapshot.error}'));
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