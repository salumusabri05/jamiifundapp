import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class HomeVideoPlayer extends StatefulWidget {
  final String videoAssetPath;
  
  const HomeVideoPlayer({
    super.key,
    required this.videoAssetPath,
  });

  @override
  State<HomeVideoPlayer> createState() => _HomeVideoPlayerState();
}

class _HomeVideoPlayerState extends State<HomeVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _isVisible = false;
  bool _isInitialized = false;
  
  @override
  void initState() {
    super.initState();
    // Initialize the controller with an asset video
    _controller = VideoPlayerController.asset(widget.videoAssetPath)
      ..initialize().then((_) {
        // Ensure the first frame is shown
        setState(() {
          _isInitialized = true;
        });
      });
    
    _controller.setLooping(true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _playPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('video-${widget.videoAssetPath}'),
      onVisibilityChanged: (visibilityInfo) {
        final visiblePercentage = visibilityInfo.visibleFraction * 100;
        if (visiblePercentage > 70) {
          // When the video is mostly visible
          setState(() {
            _isVisible = true;
          });
          
          // Auto-play when visible and initialized
          if (_isInitialized && !_controller.value.isPlaying && !_isPlaying) {
            // Don't auto-play immediately, give user control
            setState(() {
              _isPlaying = false;
            });
          }
        } else {
          setState(() {
            _isVisible = false;
          });
          
          // Pause when not visible
          if (_controller.value.isPlaying) {
            _controller.pause();
            setState(() {
              _isPlaying = false;
            });
          }
        }
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Video player
                    VideoPlayer(_controller),
                    
                    // Play/Pause button overlay
                    AnimatedOpacity(
                      opacity: _isPlaying ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 42,
                          ),
                          onPressed: _playPause,
                        ),
                      ),
                    ),
                    
                    // Tap anywhere to play/pause
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: _playPause,
                        behavior: HitTestBehavior.translucent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Video controls and caption
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.transparent,
              child: Row(
                children: [
                  Text(
                    'How JamiiFund Works',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      Icons.fullscreen,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      // Future enhancement: Add fullscreen functionality
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
