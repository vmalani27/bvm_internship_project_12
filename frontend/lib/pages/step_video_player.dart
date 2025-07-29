import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:developer' as developer;

class StepVideoPlayer extends StatefulWidget {
  final VideoPlayerController? controller;
  final Future<void>? initializeFuture;
  final bool isLoading;

  const StepVideoPlayer({
    super.key,
    required this.controller,
    required this.initializeFuture,
    required this.isLoading,
  });

  @override
  State<StepVideoPlayer> createState() => _StepVideoPlayerState();
}

class _StepVideoPlayerState extends State<StepVideoPlayer> {
  @override
  Widget build(BuildContext context) {
    developer.log('StepVideoPlayer build called');
    developer.log('Controller: ${widget.controller}');
    developer.log('InitializeFuture: ${widget.initializeFuture}');
    developer.log('IsLoading: ${widget.isLoading}');
    
    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _buildVideoContent(),
      ),
    );
  }

  Widget _buildVideoContent() {
    developer.log('_buildVideoContent called');
    developer.log('IsLoading: ${widget.isLoading}');
    developer.log('Controller null: ${widget.controller == null}');
    developer.log('InitializeFuture null: ${widget.initializeFuture == null}');
    
    if (widget.isLoading) {
      developer.log('Showing loading indicator');
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Loading video...',
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ),
      );
    }

    if (widget.controller == null || widget.initializeFuture == null) {
      developer.log('Controller or initializeFuture is null, showing no video message');
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.video_library_outlined, size: 48, color: Colors.white54),
            SizedBox(height: 8),
            Text(
              'No video available',
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ),
      );
    }

    return FutureBuilder(
      future: widget.initializeFuture,
      builder: (context, snapshot) {
        developer.log('FutureBuilder - ConnectionState: ${snapshot.connectionState}');
        developer.log('FutureBuilder - HasError: ${snapshot.hasError}');
        if (snapshot.hasError) {
          developer.log('FutureBuilder - Error: ${snapshot.error}');
          developer.log('FutureBuilder - Stack trace: ${snapshot.stackTrace}');
        }
        
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            developer.log('Video initialization failed with error: ${snapshot.error}');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 8),
                  Text(
                    'Error loading video: ${snapshot.error}',
                    style: const TextStyle(color: Colors.white54),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          developer.log('Video initialization successful');
          developer.log('Video aspect ratio: ${widget.controller!.value.aspectRatio}');
          developer.log('Video duration: ${widget.controller!.value.duration}');
          developer.log('Controller initialized: ${widget.controller!.value.isInitialized}');
          
          return Stack(
            alignment: Alignment.center,
            children: [
              Center(
                child: AspectRatio(
                  aspectRatio: widget.controller!.value.aspectRatio,
                  child: VideoPlayer(widget.controller!),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: VideoProgressIndicator(
                          widget.controller!,
                          allowScrubbing: true,
                          colors: const VideoProgressColors(
                            playedColor: Colors.blue,
                            bufferedColor: Colors.grey,
                            backgroundColor: Colors.white24,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(
                              widget.controller!.value.isPlaying
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_filled,
                              color: Colors.white,
                              size: 36,
                            ),
                            onPressed: () {
                              setState(() {
                                if (widget.controller!.value.isPlaying) {
                                  widget.controller!.pause();
                                } else {
                                  widget.controller!.play();
                                }
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.replay_circle_filled,
                              color: Colors.white,
                              size: 32,
                            ),
                            onPressed: () {
                              widget.controller!.seekTo(Duration.zero);
                              widget.controller!.play();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        } else {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 16),
                Text(
                  'Initializing video...',
                  style: TextStyle(color: Colors.white54),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
