import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/theme/theme.dart';
import 'employee_home_page.dart';
import 'home_page.dart';
import 'register_page.dart';
import 'login_page.dart';
import 'create_business_page.dart';
import 'customer_content_page.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'splash_screen.dart';  // Import the SplashScreen file

const storage = FlutterSecureStorage();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
    return MaterialApp(
      title: 'Business Management System',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(), // Use SplashScreen as initial route
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/create_business': (context) => const CreateBusinessPage(),
        '/employees_home': (context) => const EmployeeHomePage(),
        '/customer_content': (context) => const CustomerContentPage(business: {}),
      },
    );
  }
}
