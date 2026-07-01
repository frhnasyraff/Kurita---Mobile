import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';
import 'screens/auth_gate.dart';
import 'services/api_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseDatabase.instance.databaseURL =
      'https://workwise-a6637-default-rtdb.asia-southeast1.firebasedatabase.app';

  await ApiClient.instance.init();

  runApp(const WorkwiseApp());
}

class WorkwiseApp extends StatelessWidget {
  const WorkwiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF17335C);
    const surface = Color(0xFFF4F7FB);
    const border = Color(0xFFD6DEE8);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Workwise',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: surface,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          primary: primary,
          surface: surface,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: primary, width: 1.4),
          ),
          hintStyle: const TextStyle(color: Color(0xFF8A99AD)),
        ),
      ),
      home: const AuthGate(),
    );
  }
}