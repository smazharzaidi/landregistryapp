import 'package:flutter/material.dart';
import 'sale_purchase.dart';
import 'signup.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(apiKey: 'AIzaSyCJW60r7xh8sUlEiS-hGgaeiFybH2QWa0I', appId: '1:699692984203:ios:7b347eb500994f7115b18e', messagingSenderId: '699692984203', projectId: 'landregistry-15941'),
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.orange),
      debugShowCheckedModeBanner: false,
      home: SignUp(),
    );
  }
}
