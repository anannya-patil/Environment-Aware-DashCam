import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerPage extends StatefulWidget {
  final String videoPath;

  const VideoPlayerPage({
    Key? key,
    required this.videoPath,
  }) : super(key: key);

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController controller;
  bool isReady = false;

  @override
  void initState() {
    super.initState();

    controller = VideoPlayerController.file(
      File(widget.videoPath),
    )..initialize().then((_) {
        setState(() {
          isReady = true;
        });
        controller.play();
      });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  String format(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Playback"),
        backgroundColor: Colors.black,
      ),
      body: isReady
          ? Column(
              children: [
                /// VIDEO AREA (FIXED)
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: controller.value.aspectRatio,
                      child: Container(
                        color: Colors.black, // prevents visual artifacts
                        child: VideoPlayer(controller),
                      ),
                    ),
                  ),
                ),

                /// CONTROLS
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    children: [
                      VideoProgressIndicator(
                        controller,
                        allowScrubbing: true,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 20),
                      ),

                      const SizedBox(height: 10),

                      ValueListenableBuilder(
                        valueListenable: controller,
                        builder: (context, value, child) {
                          return Text(
                            "${format(controller.value.position)} / ${format(controller.value.duration)}",
                            style: const TextStyle(color: Colors.white),
                          );
                        },
                      ),

                      const SizedBox(height: 10),

                      IconButton(
                        iconSize: 60,
                        color: Colors.white,
                        icon: Icon(
                          controller.value.isPlaying
                              ? Icons.pause_circle
                              : Icons.play_circle,
                        ),
                        onPressed: () {
                          setState(() {
                            controller.value.isPlaying
                                ? controller.pause()
                                : controller.play();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
      body: Center(
        child: isReady
            ? SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: controller.value.aspectRatio,
                      child: VideoPlayer(controller),
                    ),

                    const SizedBox(height: 20),

                    VideoProgressIndicator(
                      controller,
                      allowScrubbing: true,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),

                    const SizedBox(height: 15),

                    ValueListenableBuilder(
                      valueListenable: controller,
                      builder: (context, value, child) {
                        return Text(
                          "${format(controller.value.position)} / ${format(controller.value.duration)}",
                          style: const TextStyle(color: Colors.white),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    IconButton(
                      iconSize: 60,
                      color: Colors.white,
                      icon: Icon(
                        controller.value.isPlaying
                            ? Icons.pause_circle
                            : Icons.play_circle,
                      ),
                      onPressed: () {
                        setState(() {
                          controller.value.isPlaying
                              ? controller.pause()
                              : controller.play();
                        });
                      },
                    ),
                  ],
                ),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}