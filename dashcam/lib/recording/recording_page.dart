import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'video_player_page.dart';

class RecordingsPage extends StatefulWidget {
  const RecordingsPage({Key? key}) : super(key: key);

  @override
  State<RecordingsPage> createState() => _RecordingsPageState();
}

class _RecordingsPageState extends State<RecordingsPage> {
  List<FileSystemEntity> videoFiles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadVideos();
  }

  //load videos
  Future<void> loadVideos() async {
    setState(() {
      isLoading = true;
    });

    final directory = await getApplicationDocumentsDirectory();
    final files = directory.listSync();

    videoFiles = files.where((file) {
      return file.path.endsWith('.mp4');
    }).toList();

    // Newest first
    videoFiles.sort(
      (a, b) => b.statSync().modified.compareTo(a.statSync().modified),
    );

    setState(() {
      isLoading = false;
    });
  }

  //get file name
  String getFileName(String path) {
    return path.split('/').last;
  }

  //format date
  String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  //delete video
  Future<void> deleteVideo(FileSystemEntity file) async {
    await file.delete();
    loadVideos();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Recording deleted"),
      ),
    );
  }

  //confirm delete
  void showDeleteDialog(FileSystemEntity file) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          "Delete Recording?",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "Are you sure you want to delete this recording?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              deleteVideo(file);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),

      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 2,
        title: const Text(
          "Saved Recordings",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadVideos,
          ),
        ],
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : videoFiles.isEmpty
              ? const Center(
                  child: Text(
                    "No Recordings Found",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadVideos,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: videoFiles.length,
                    itemBuilder: (context, index) {
                      final file = videoFiles[index];
                      final modified = file.statSync().modified;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 6,
                              color: Colors.black45,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(14),

                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.videocam,
                              color: Colors.redAccent,
                              size: 28,
                            ),
                          ),

                          title: Text(
                            getFileName(file.path),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              formatDate(modified),
                              style: const TextStyle(
                                color: Colors.white60,
                              ),
                            ),
                          ),

                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.play_circle_fill,
                                  color: Colors.greenAccent,
                                  size: 30,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => VideoPlayerPage(
                                        videoPath: file.path,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () {
                                  showDeleteDialog(file);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}