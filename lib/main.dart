import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pages/home.dart';
import 'pages/app/app.dart';
import 'pages/auth/signup.dart';
import 'pages/auth/login.dart';
import 'pages/settings.dart';
import 'pages/app/account.dart';
import 'pages/app/qr_page.dart';
//import 'splashscreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'REScycle',
      debugShowCheckedModeBanner: false,
      home: AuthWrapper(), // Use the AuthWrapper to decide the home page
      routes: {
        '/signup': (context) => const Signup(),
        '/login': (context) => Login(),
        '/app': (context) => const App(),
        '/account': (context) => const Account(),
        '/settings': (context) => const Settings(),
        '/qr': (context) => const QRPage(points: 0,),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Check if the user is logged in
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;

          // If the user is logged in, go to the App page, else go to Home
          if (user == null) {
            return const Home(); // Not logged in
          } else {
            return const App(); // Logged in
          }
        } else {
          // While waiting for the auth state to load, show a loading indicator
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
