import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart'; 

final storage = FlutterSecureStorage();

class AddEmployeePage extends StatefulWidget {
  final String businessId;

  AddEmployeePage({required this.businessId});

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
    final token = await storage.read(key: 'jwt_token');
    if (token == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }
    final response = await http.post(
      Uri.parse('http://localhost:5000/api/business/invite'), // Replace with your API endpoint
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
      title: Text('Add Employee'),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Employee Email',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          _error != null
              ? Text(_error!, style: TextStyle(color: Colors.red))
              : Container(),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isLoading ? null : _inviteEmployee,
            child: _isLoading
                ? CircularProgressIndicator()
                : Text('Send Invitation'),
          ),
        ],
      ),
    ),
  );
}
}