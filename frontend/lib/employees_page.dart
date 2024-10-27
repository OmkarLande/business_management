import 'package:flutter/material.dart';
import 'add_employee_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart'; 

const storage = FlutterSecureStorage();

class EmployeePage extends StatefulWidget {
  final Map<String, dynamic> business;

  const EmployeePage({super.key, required this.business });

  @override
  _EmployeePageState createState() => _EmployeePageState();
}

class _EmployeePageState extends State<EmployeePage> {
  List<Map<String, dynamic>> _employees = [];
  bool _isLoading = true;
  String? _error;

  Future<void> _fetchEmployees() async {
    setState(() {
      _isLoading = true;
    });

    final token = await storage.read(key: 'jwt_token');
    if (token == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    try {
      final employeeIds = widget.business['employees'] as List<dynamic>;
      final decodedToken = JwtDecoder.decode(token);
      final role = decodedToken['role'];
      if (role != 'owner') {
        setState(() {
          _error = 'You do not have permission to view this page';
          _isLoading = false;
          return;
        });
      }
      final responses = await Future.wait(employeeIds.map((id) async {
        final response = await http.post(
          Uri.parse('http://192.168.0.102:5000/api/auth/user'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode({'userId': id}),
        );

        final responseData = json.decode(response.body);
        return responseData['user'] as Map<String, dynamic>;
      }));

      setState(() {
        _employees = responses.where((data) => data != null).toList().cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } catch (e) {
      print('Error: ${e.toString()}');
      setState(() {
        _error = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchEmployees(); // Fetch employees on page load
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employees of ${widget.business['name']}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchEmployees,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : ListView.builder(
                    itemCount: _employees.length,
                    itemBuilder: (context, index) {
                      final employee = _employees[index];
                      final name = employee['name'] ?? 'No Name';
                      final email = employee['email'] ?? 'No Email';

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16.0),
                          title: Text(name),
                          subtitle: Text(email),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEmployeePage(
                businessId: widget.business['_id'],
              ),
            ),
          );
        },
        tooltip: 'Add Employee',
        child: const Icon(Icons.add),
      ),
    );
  }
}
