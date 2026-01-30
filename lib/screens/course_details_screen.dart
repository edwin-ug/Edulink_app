import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'lesson_player_screen.dart';

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
    final urlController = TextEditingController(); // 1. NEW CONTROLLER

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Lesson"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Lesson Title"),
            ),
            TextField(
              controller: durationController,
              decoration: const InputDecoration(labelText: "Duration"),
            ),
            const SizedBox(height: 10),
            // 2. NEW TEXT FIELD
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: "YouTube URL",
                hintText: "https://youtu.be/..."
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
                await FirebaseFirestore.instance
                    .collection('courses')
                    .doc(courseId)
                    .collection('lessons')
                    .add({
                  'title': titleController.text.trim(),
                  'duration': durationController.text.trim(),
                  'videoUrl': urlController.text.trim(), // 3. SAVE THE URL
                  'order': DateTime.now().millisecondsSinceEpoch,
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

  // 2. THE MATH LOGIC
  Future<void> _updateCourseProgress() async {
    // A. Get all lessons for this course
    final allLessons = await FirebaseFirestore.instance
        .collection('courses')
        .doc(courseId)
        .collection('lessons')
        .get();

    final totalLessons = allLessons.docs.length;
    
    // B. Count how many are marked 'isCompleted'
    final completedLessons = allLessons.docs
        .where((doc) => doc.data().containsKey('isCompleted') && doc['isCompleted'] == true)
        .length;

    // C. Calculate Percentage (Avoid dividing by zero!)
    final double newProgress = totalLessons == 0 ? 0 : completedLessons / totalLessons;

    // D. Update the Main Course Document
    await FirebaseFirestore.instance
        .collection('courses')
        .doc(courseId)
        .update({'progress': newProgress});
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
                    
                    // Safely get the URL (default to empty string if missing)
                    final String videoUrl = lessonData.containsKey('videoUrl') 
                        ? lessonData['videoUrl'] 
                        : "";

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        // 1. LEADING: The Checkbox
                        leading: Checkbox(
                          value: lessonData['isCompleted'] ?? false, // Default to false
                          activeColor: Colors.deepPurple,
                          onChanged: (bool? newValue) async {
                            // A. Update the specific lesson
                            await FirebaseFirestore.instance
                                .collection('courses')
                                .doc(courseId)
                                .collection('lessons')
                                .doc(lesson.id)
                                .update({'isCompleted': newValue});

                            // B. Run the Math to update the Course Progress
                            await _updateCourseProgress();
                          },
                        ),
                        
                        // 2. TITLE & DURATION
                        title: Text(
                          lessonData['title'] ?? "Untitled",
                          style: TextStyle(
                            decoration: (lessonData['isCompleted'] ?? false)
                                ? TextDecoration.lineThrough // Cross out text if done
                                : TextDecoration.none,
                            color: (lessonData['isCompleted'] ?? false)
                                ? Colors.grey
                                : Colors.black,
                          ),
                        ),
                        subtitle: Text(lessonData['duration'] ?? "N/A"),
                        
                        // 3. TRAILING: The Play Button
                        trailing: IconButton(
                          icon: const Icon(Icons.play_circle_fill, color: Colors.red),
                          onPressed: () {
                             if (videoUrl.isNotEmpty) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LessonPlayerScreen(
                                    title: lessonData['title'] ?? "Lesson",
                                    videoUrl: videoUrl,
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("No video added")),
                              );
                            }
                          },
                        ),
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