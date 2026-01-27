import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'course_details_screen.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  // 1. THE LOGIC: Function to show the popup and save data
  void _showAddCourseDialog(BuildContext context) {
    final titleController = TextEditingController();
    final codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Course"),
        content: Column(
          mainAxisSize: MainAxisSize.min, // Make the popup just big enough
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Course Title (e.g. Intro to AI)",
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: codeController,
              decoration: const InputDecoration(
                labelText: "Course Code (e.g. CS202)",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Close popup
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              // 2. THE SAVE COMMAND: Write to Firebase
              if (titleController.text.isNotEmpty && codeController.text.isNotEmpty) {
                await FirebaseFirestore.instance.collection('courses').add({
                  'title': titleController.text.trim(),
                  'code': codeController.text.trim(),
                  'progress': 0.0, // Start fresh courses at 0%
                });
                
                if (context.mounted) Navigator.pop(context); // Close popup
              }
            },
            child: const Text("Add Course"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("My Courses", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      
      // 3. THE BUTTON: Floating Action Button
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showAddCourseDialog(context),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('courses').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Error loading courses'));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.requireData;

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: data.size,
            separatorBuilder: (context, index) => const SizedBox(height: 15),
            itemBuilder: (context, index) {
              final course = data.docs[index];
              final String docId = course.id; 
              
              final Map<String, dynamic> courseData = course.data() as Map<String, dynamic>;
              final String title = courseData.containsKey('title') ? courseData['title'] : 'Untitled';
              final String code = courseData.containsKey('code') ? courseData['code'] : 'N/A';
              final double progress = courseData.containsKey('progress') ? (courseData['progress'] as num).toDouble() : 0.0;

              return Dismissible(
                key: Key(docId),
                direction: DismissDirection.endToStart,
                
                // 1. CONFIRM DIALOG: This pauses the deletion
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Delete Course?"),
                        content: Text("Are you sure you want to delete '$title'? This cannot be undone."),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false), // Return False (Don't Delete)
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true), // Return True (Delete)
                            child: const Text("Delete", style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      );
                    },
                  );
                },

                // 2. BACKGROUND (Red Trash Can)
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white, size: 30),
                ),

                // 3. ACTION: Only runs if user clicked "Delete" in the dialog
                onDismissed: (direction) async {
                  await FirebaseFirestore.instance
                      .collection('courses')
                      .doc(docId)
                      .delete();

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$title deleted')),
                    );
                  }
                },

                // 4. THE CARD CONTENT
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          code,
                          style: TextStyle(
                              color: Colors.blue.shade800, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text("Progress: ${(progress * 100).toInt()}%"),
                        const SizedBox(height: 5),
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey.shade100,
                          color: Colors.blue,
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CourseDetailsScreen(
                            title: title,
                            code: code,
                            courseId: docId, // <--- ADD THIS LINE (Passes the ID)
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}