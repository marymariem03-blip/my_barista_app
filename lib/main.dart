import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/page1_splash_screen.dart';
import 'screens/manager/manager_main_screen.dart'; //  this line must exist

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const BaristaApp());
}

class BaristaApp extends StatelessWidget {
  const BaristaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Barista's",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'LeagueSpartan',
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      ),
      initialRoute: '/',
      routes: {
        '/':        (_) => const SplashScreen(),
        '/manager': (_) => ManagerMainScreen(),
      },
    );
  }
}