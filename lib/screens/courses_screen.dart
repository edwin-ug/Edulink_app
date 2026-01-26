import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 1. Import Firestore
import 'course_details_screen.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

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
      // 2. USE STREAM BUILDER: This listens to the database live!
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('courses').snapshots(),
        builder: (context, snapshot) {
          // A. Handle Errors
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          // B. Handle Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // C. Get the data
          final data = snapshot.requireData;

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: data.size, // Count comes from DB
            separatorBuilder: (context, index) => const SizedBox(height: 15),
            itemBuilder: (context, index) {
              // D. Extract individual course fields
              final course = data.docs[index];
              final String title = course['title'];
              final String code = course['code'];
              // Safely handle numbers (sometimes they come as int or double)
              final double progress = (course['progress'] as num).toDouble(); 

              return Container(
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
                  title: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
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
                  // <--- PASTE THIS HERE
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CourseDetailsScreen(
                          title: title,
                          code: code,
                        ),
                      ),
                    );
                  },
                  // <--- END PASTE
                ),
              );
            },
          );
        },
      ),
    );
  }
}