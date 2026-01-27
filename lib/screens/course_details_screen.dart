import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class CourseDetailsScreen extends StatelessWidget {
  final String title;
  final String code;
  final String courseId; // 1. New Variable

  const CourseDetailsScreen({
    super.key,
    required this.title,
    required this.code,
    required this.courseId, // 2. Require it
  });

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
      body: Column(
        children: [
          // HEADER (Static Info)
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

          // LIST OF LESSONS (Dynamic Stream)
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // 3. LISTEN TO SUB-COLLECTION: courses -> [ID] -> lessons
              stream: FirebaseFirestore.instance
                  .collection('courses')
                  .doc(courseId)
                  .collection('lessons')
                  .orderBy('order') // Sort by the 'order' field (1, 2, 3...)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text("Error loading lessons"));
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snapshot.requireData;

                // Handle empty courses
                if (data.size == 0) {
                  return const Center(child: Text("No lessons added yet."));
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
                        onTap: () {
                           // Future: Open video player
                        },
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