import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();

class EmployeeHomePage extends StatefulWidget {
  @override
  _EmployeeHomePageState createState() => _EmployeeHomePageState();
}

class _EmployeeHomePageState extends State<EmployeeHomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _businesses = [];
  List<Map<String, dynamic>> _pendingRequests = [];
  bool _isLoadingBusinesses = true;
  bool _isLoadingRequests = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchBusinesses();
    _fetchPendingRequests();
  }

  Future<void> _fetchBusinesses() async {
    setState(() {
      _isLoadingBusinesses = true;
    });

    final token = await storage.read(key: 'jwt_token');
    if (token == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/business/employees/business'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _businesses = List<Map<String, dynamic>>.from(data['businesses'] ?? []);
          _isLoadingBusinesses = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load businesses';
          _isLoadingBusinesses = false;
        });
      }
    } catch (e) {
      print('Error: ${e.toString()}');
      setState(() {
        _error = 'Error: ${e.toString()}';
        _isLoadingBusinesses = false;
      });
    }
  }

  Future<void> _fetchPendingRequests() async {
    setState(() {
      _isLoadingRequests = true;
    });

    final token = await storage.read(key: 'jwt_token');
    if (token == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/auth/pending'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print(response.body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final userList = data['user'] as List<dynamic>;
        for (var item in userList) {
          print(item);
        }
        setState(() {
          _pendingRequests = userList.map((item) {
            return {
              'businessName': item['businessName'] ?? 'No Business Name',
              'businessId': item['businessId'] ?? '',
              'userId': item['_id'] ?? '',
            };
          }).toList();
          _isLoadingRequests = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load pending requests';
          _isLoadingRequests = false;
        });
      }
    } catch (e) {
      print('Error: ${e.toString()}');
      setState(() {
        _error = 'Error: ${e.toString()}';
        _isLoadingRequests = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employee Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Businesses'),
            Tab(text: 'Pending Requests'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBusinessesTab(),
          _buildPendingRequestsTab(),
        ],
      ),
    );
  }

  Widget _buildBusinessesTab() {
    return _isLoadingBusinesses
        ? Center(child: CircularProgressIndicator())
        : _error != null
            ? Center(child: Text(_error!))
            : ListView.builder(
                itemCount: _businesses.length,
                itemBuilder: (context, index) {
                  final business = _businesses[index];
                  final name = business['name'] ?? 'No Name';

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16.0),
                      title: Text(name),
                    ),
                  );
                },
              );
  }

  Widget _buildPendingRequestsTab() {
    return _isLoadingRequests
        ? Center(child: CircularProgressIndicator())
        : _error != null
            ? Center(child: Text(_error!))
            : ListView.builder(
                itemCount: _pendingRequests.length,
                itemBuilder: (context, index) {
                  final request = _pendingRequests[index];
                  final businessName = request['businessName'] ?? 'No Business Name';

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16.0),
                      title: Text('Invitation from $businessName'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.check),
                            onPressed: () {
                              // Handle accept request
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {
                              // Handle decline request
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
  }
}
