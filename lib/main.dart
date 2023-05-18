import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:boodbank/home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'login.dart';

//

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blood Alert',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "GoogleSans",
        primarySwatch: Colors.red,
      ),
      home: AnimatedSplashScreen(
        splash: "images/logo.png",
        splashIconSize: 250,
        nextScreen: const Loginpage(),
        splashTransition: SplashTransition.fadeTransition,
        duration: 1000,
      ),
    );
  }
}
