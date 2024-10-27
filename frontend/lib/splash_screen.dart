import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';  // Import Lottie package
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:async';

const storage = FlutterSecureStorage();

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    // Show splash screen for 3 seconds
    await Future.delayed(const Duration(seconds: 3));
    // Check user role and navigate accordingly
    final role = await _getUserRole();
    if (role == 'owner') {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (role == 'employee') {
      Navigator.pushReplacementNamed(context, '/employees_home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<String?> _getUserRole() async {
    final token = await storage.read(key: 'jwt_token');
    if (token == null) {
      return null;
    }
    final decodedToken = JwtDecoder.decode(token);
    return decodedToken['role'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/splash.json', // Path to your Lottie animation
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
            const Text("BizzMaster",style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),)
          ],
        ),
      ),
    );
  }
}
