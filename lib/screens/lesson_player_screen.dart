import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class LessonPlayerScreen extends StatefulWidget {
  final String title;
  final String videoUrl;

  const LessonPlayerScreen({
    super.key,
    required this.title,
    required this.videoUrl,
  });

  @override
  State<LessonPlayerScreen> createState() => _LessonPlayerScreenState();
}

class _LessonPlayerScreenState extends State<LessonPlayerScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    
    // 1. Extract the Video ID from the URL (e.g., gets "dQw4w9WgXcQ" from the link)
    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);

    // 2. Initialize the Player
    _controller = YoutubePlayerController(
      initialVideoId: videoId ?? "", // Handle bad URLs safely
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // Cleanup when we leave the screen
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Cinematic feel
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: _controller.initialVideoId.isEmpty 
            ? const Text("Invalid Video URL", style: TextStyle(color: Colors.white))
            : YoutubePlayer(
                controller: _controller,
                showVideoProgressIndicator: true,
                progressIndicatorColor: Colors.red,
              ),
      ),
    );
  }
}