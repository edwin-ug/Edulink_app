import 'package:flutter/material.dart';

class CourseDetailsScreen extends StatelessWidget {
  // 1. Declare variables to hold the data passed from the previous screen
  final String title;
  final String code;

  // 2. Require these variables in the Constructor
  const CourseDetailsScreen({
    super.key, 
    required this.title, 
    required this.code
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Keep the pro look
      appBar: AppBar(
        title: Text(code), // Show "CS101" in the top bar
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black, // Makes the back arrow black
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
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
                  Text(title, // Display the passed Title
                    style: const TextStyle(
                      color: Colors.white, 
                      fontSize: 24, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            const Text("Syllabus", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            // Dummy List of Lessons
            _buildLessonItem("1", "Introduction to the Course"),
            _buildLessonItem("2", "Setting up the Environment"),
            _buildLessonItem("3", "Your First Hello World"),
            _buildLessonItem("4", "Understanding Variables"),
            
            const SizedBox(height: 30),
            
            // Start Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  // Logic to start lesson
                }, 
                child: const Text("Continue Learning"),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLessonItem(String number, String title) {
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
          child: Text(number, style: TextStyle(color: Colors.blue.shade800)),
        ),
        title: Text(title),
        trailing: const Icon(Icons.play_circle_outline, color: Colors.grey),
      ),
    );
  }
}