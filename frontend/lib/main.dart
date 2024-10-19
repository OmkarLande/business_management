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
      theme: AppTheme.lightTheme, // Apply the light theme
      darkTheme: AppTheme.darkTheme, // Apply the dark theme (optional)
      themeMode: ThemeMode.system, // Use system theme setting (light/dark)
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => FutureBuilder<String?>(
              future: _getUserRole(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                      body: Center(child: CircularProgressIndicator()));
                }

                if (!snapshot.hasData) {
                  return const LoginPage();
                }

                final role = snapshot.data;
                if (role == 'owner') {
                  return const HomePage();
                } else if (role == 'employee') {
                  return const EmployeeHomePage();
                } else {
                  return const LoginPage();
                }
              },
            ),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/create_business': (context) => const CreateBusinessPage(),
        '/employees_home': (context) => const EmployeeHomePage(),
        '/customer_content': (context) => const CustomerContentPage(
            business: {}), // Update this with the appropriate business data
      },
    );
  }
}
