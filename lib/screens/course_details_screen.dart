import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CourseDetailsScreen extends StatelessWidget {
  final String title;
  final String code;
  final String courseId; // We need this ID to know WHERE to save the lesson

  const CourseDetailsScreen({
    super.key,
    required this.title,
    required this.code,
    required this.courseId,
  });

  // 1. THE LOGIC: Function to add a lesson to THIS specific course
  void _showAddLessonDialog(BuildContext context) {
    final titleController = TextEditingController();
    final durationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Lesson"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Lesson Title (e.g. Intro to Widgets)",
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: durationController,
              decoration: const InputDecoration(
                labelText: "Duration (e.g. 10 min)",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty) {
                // 2. THE SAVE COMMAND: Note the path!
                // courses -> [courseId] -> lessons -> [new document]
                await FirebaseFirestore.instance
                    .collection('courses')
                    .doc(courseId) // Use the ID passed from the previous screen
                    .collection('lessons')
                    .add({
                  'title': titleController.text.trim(),
                  'duration': durationController.text.trim(),
                  'order': DateTime.now().millisecondsSinceEpoch, // Simple way to sort by time added
                });

                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text("Add Lesson"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(code),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      
      // 3. THE BUTTON
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple, // Different color to distinguish from Course add
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showAddLessonDialog(context),
      ),

      body: Column(
        children: [
          // Header Area
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue[800],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("COURSE",
                    style: TextStyle(color: Colors.white54, letterSpacing: 2)),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("Syllabus",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 10),

          // Lesson List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('courses')
                  .doc(courseId)
                  .collection('lessons')
                  .orderBy('order')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text("Error loading lessons"));
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snapshot.requireData;

                if (data.size == 0) {
                  return const Center(child: Text("No lessons added yet. Tap + to start."));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: data.size,
                  itemBuilder: (context, index) {
                    final lesson = data.docs[index];
                    final lessonData = lesson.data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade50,
                          child: Text(
                            "${index + 1}",
                            style: TextStyle(color: Colors.blue.shade800),
                          ),
                        ),
                        title: Text(lessonData['title'] ?? "Untitled Lesson"),
                        subtitle: Text(lessonData['duration'] ?? "Unknown duration"),
                        trailing: const Icon(Icons.play_circle_outline, color: Colors.grey),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}