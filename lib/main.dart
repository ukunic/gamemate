import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gamemate/screens/username_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const GameMateApp());
}

class GameMateApp extends StatelessWidget {
  const GameMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const UsernameScreen(),
    );
  }
}
