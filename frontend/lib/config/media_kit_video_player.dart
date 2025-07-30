import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'dart:developer' as developer;

class MediaKitVideoPlayer extends StatefulWidget {
  final Player? player;
  final VideoController? videoController;
  final bool isLoading;

  const MediaKitVideoPlayer({
    super.key,
    required this.player,
    required this.videoController,
    required this.isLoading,
  });

  @override
  State<MediaKitVideoPlayer> createState() => _MediaKitVideoPlayerState();
}

class _MediaKitVideoPlayerState extends State<MediaKitVideoPlayer> {
  bool _hovering = false;
  bool _showOverlay = false;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.secondary;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() { _hovering = false; _showOverlay = false; }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        height: 280,
        decoration: BoxDecoration(
          gradient: _hovering
              ? LinearGradient(colors: [accent.withOpacity(0.15), Colors.black])
              : null,
          color: Colors.black,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: _hovering ? accent.withOpacity(0.3) : Colors.black26,
              blurRadius: _hovering ? 24 : 12,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: _hovering ? accent : Colors.transparent,
            width: 2.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              _buildVideoContent(),
              if (_hovering && !_showOverlay && !widget.isLoading && widget.player != null)
                Positioned.fill(
                  child: AnimatedOpacity(
                    opacity: 0.7,
                    duration: const Duration(milliseconds: 200),
                    child: GestureDetector(
                      onTap: () async {
                        setState(() => _showOverlay = true);
                        if (widget.player!.state.playing) {
                          await widget.player!.pause();
                        } else {
                          await widget.player!.play();
                        }
                        await Future.delayed(const Duration(milliseconds: 600));
                        setState(() => _showOverlay = false);
                      },
                      child: Container(
                        color: Colors.black26,
                        child: Center(
                          child: AnimatedScale(
                            scale: _showOverlay ? 1.2 : 1.0,
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              widget.player!.state.playing ? Icons.pause_circle_filled : Icons.play_circle_fill,
                              color: accent,
                              size: 80,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoContent() {
    if (widget.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF00E676)),
            SizedBox(height: 16),
            Text(
              'Loading video...',
              style: TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    if (widget.player == null || widget.videoController == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.video_library_outlined, size: 48, color: Color(0xFF90CAF9)),
            SizedBox(height: 8),
            Text(
              'No video available',
              style: TextStyle(color: Color(0xFF90CAF9)),
            ),
          ],
        ),
      );
    }

    try {
      return Video(
        controller: widget.videoController!,
        controls: AdaptiveVideoControls,
      );
    } catch (e, stackTrace) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 8),
            Text(
              'Error loading video: $e',
              style: const TextStyle(color: Colors.redAccent),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
  }
}
