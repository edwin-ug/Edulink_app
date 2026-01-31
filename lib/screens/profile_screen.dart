import 'dart:io'; // 1. Needed for File handling
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart'; // 2. Pick Image
import 'package:firebase_storage/firebase_storage.dart'; // 3. Upload Image

import 'login_screen.dart';

// CHANGED: Switched to StatefulWidget to handle loading states
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;
  bool _isUploading = false; // To show spinner when uploading

  // --- THE NEW UPLOAD LOGIC ---
  Future<void> _uploadProfilePicture() async {
    final picker = ImagePicker();
    // Open Gallery
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image == null) return; // User cancelled

    setState(() => _isUploading = true);

    try {
      // 1. Upload file to Firebase Storage
      // CHANGE THIS LINE:
      // We are forcing it to look at your specific bucket address
      final storageRef = FirebaseStorage.instanceFor(bucket: "gs://javeroin-db.firebasestorage.app")
          .ref()
          .child('user_images')
          .child('${user!.uid}.jpg');

      // Add Metadata (Helps iOS understand it's an image)
      await storageRef.putFile(
        File(image.path),
        SettableMetadata(contentType: 'image/jpeg'), 
      );

      final String downloadUrl = await storageRef.getDownloadURL();

      // 3. Save URL to Firestore User Profile
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .set({'photoUrl': downloadUrl}, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile photo updated!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }
  // ---------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Slightly off-white looks better
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- NEW DYNAMIC AVATAR SECTION ---
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      // A. The Profile Image (Listens to Firestore)
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(user!.uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          String? photoUrl;
                          if (snapshot.hasData && snapshot.data!.data() != null) {
                            final data = snapshot.data!.data() as Map<String, dynamic>;
                            if (data.containsKey('photoUrl')) {
                              photoUrl = data['photoUrl'];
                            }
                          }

                          return CircleAvatar(
                            radius: 50, // Made slightly bigger
                            backgroundColor: Colors.blue.shade100,
                            backgroundImage: photoUrl != null
                                ? NetworkImage(photoUrl)
                                : null,
                            child: _isUploading
                                ? const CircularProgressIndicator()
                                : (photoUrl == null
                                    ? const Icon(Icons.person, size: 50, color: Colors.white)
                                    : null),
                          );
                        },
                      ),

                      // B. The Blue Camera Button
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _uploadProfilePicture, // <--- Triggers the function
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.camera_alt,
                                color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    user?.email ?? "User",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Text("Student Account", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            // ----------------------------------
            
            const SizedBox(height: 30),

            // Settings List (Your existing code)
            _buildProfileItem(Icons.person_outline, "Edit Profile"),
            _buildProfileItem(Icons.notifications_outlined, "Notifications"),
            _buildProfileItem(Icons.lock_outline, "Privacy & Security"),
            _buildProfileItem(Icons.help_outline, "Help & Support"),
            
            const SizedBox(height: 20),
            
            // Logout Button (Your existing code)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
                child: const Text("Log Out", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Your Helper Widget
  Widget _buildProfileItem(IconData icon, String title) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueGrey),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: () {},
      ),
    );
  }
}