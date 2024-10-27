import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
 // Import the theme

const storage = FlutterSecureStorage();

class AddEmployeePage extends StatefulWidget {
  final String businessId;

  const AddEmployeePage({super.key, required this.businessId});

  @override
  _AddEmployeePageState createState() => _AddEmployeePageState();
}

class _AddEmployeePageState extends State<AddEmployeePage> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Future<void> _inviteEmployee() async {
    setState(() {
      _isLoading = true;
    });

    final token = await storage.read(key: 'jwt_token');
    if (token == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://192.168.0.102:5000/api/business/invite'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'businessId': widget.businessId,
          'email': _emailController.text,
        }),
      );

      final responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        Navigator.pop(context); // Go back to the previous page on success
      } else {
        setState(() {
          _error = responseData['error'];
        });
      }
    } catch (e) {
      print('Error: ${e.toString()}');
      setState(() {
        _error = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Employee'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Employee Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            _error != null
                ? Text(_error!, style: const TextStyle(color: Colors.red))
                : Container(),
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _inviteEmployee,
                  child: const Text('Send Invitation'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
                if (_isLoading)
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
