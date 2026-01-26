import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // 1. Must import Firebase Core
import 'firebase_options.dart'; // 2. Import the config file
import 'screens/login_screen.dart'; // 3. Import the REAL login screen

void main() async {
  // 4. PREPARE THE ENGINE
  WidgetsFlutterBinding.ensureInitialized();

  // 5. START FIREBASE
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const EduLinkApp());
}

class EduLinkApp extends StatelessWidget {
  const EduLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EduLink',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // 6. This now points to the REAL LoginScreen in 'lib/screens/login_screen.dart'
      home: const LoginScreen(), 
    );
  }
}

// STOP! Do not add the old "class LoginScreen" here anymore. 
// It now lives in the 'screens' folder.