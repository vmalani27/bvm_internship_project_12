import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class VideoPlayerPage extends StatefulWidget {
  final String category;
  final String filename;
  const VideoPlayerPage({
    required this.category,
    required this.filename,
    super.key,
  });

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late final Player player;
  late final VideoController controller;
  final String backendBaseUrl = 'http://localhost:8000';

  @override
  void initState() {
    super.initState();
    final videoUrl =
        '$backendBaseUrl/video/${widget.category}/${Uri.encodeComponent(widget.filename)}';
    player = Player();
    controller = VideoController(player);
    player.open(Media(videoUrl));
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.filename)),
      body: Center(
        child: Video(controller: controller),
      ),
    );
  }
} 