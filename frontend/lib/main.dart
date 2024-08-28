import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'employee_home_page.dart';
import 'home_page.dart';
import 'register_page.dart';
import 'login_page.dart';
import 'create_business_page.dart'; // Ensure you have this page created
import 'package:jwt_decoder/jwt_decoder.dart';

final storage = FlutterSecureStorage();

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => FutureBuilder<String?>(
              future: _getUserRole(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Scaffold(body: Center(child: CircularProgressIndicator()));
                }

                if (!snapshot.hasData) {
                  return LoginPage();
                }

                final role = snapshot.data;
                if (role == 'owner') {
                  return HomePage();
                } else if (role == 'employee') {
                  return EmployeeHomePage();
                } else {
                  return LoginPage();
                }
              },
            ),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/home': (context) => HomePage(),
        '/create_business': (context) => CreateBusinessPage(),
        '/employees_home': (context) => EmployeeHomePage(),

      },
    );
  }
}
