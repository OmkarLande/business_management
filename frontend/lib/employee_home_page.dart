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
  String? _business_error;
  String? _request_error;

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
        Uri.parse('http://10.0.2.2:5000/api/business/employees/buisness'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      // print("Response: ${response.body}");
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _businesses = List<Map<String, dynamic>>.from(data['businesses'] ?? []);
          _isLoadingBusinesses = false;
        });
      } else {
        setState(() {
          _business_error = 'Failed to load businesses';
          _isLoadingBusinesses = false;
        });
      }
    } catch (e) {
      print('Error: ${e.toString()}');
      setState(() {
        _business_error = 'Error: ${e.toString()}';
        _isLoadingBusinesses = false;
      });
    }
    // print("Businesses: $_businesses");
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
        Uri.parse('http://10.0.2.2:5000/api/auth/pending'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final userList = data['user'] as List<dynamic>;
        
        setState(() {
          _pendingRequests = userList.map((item) {
            return {
              'businessName': item['businessName'] ?? 'No Business Name',
              'businessId': item['businessId'] ?? '',
              'userId': item['_id'] ?? '',
            };
          }).toList();
          _isLoadingRequests = false;
        
        }
        );
          
      } else {
        setState(() {
          _request_error = 'Failed to load pending requests';
          _isLoadingRequests = false;
        });
      }
    } catch (e) {
      print('Error: ${e.toString()}');
      setState(() {
        _request_error = 'Error: ${e.toString()}';
        _isLoadingRequests = false;
      });
    }
    // print("Pending Requests: $_pendingRequests");
  }

  Future<void> _acceptRequest(String businessId) async {
    final token = await storage.read(key: 'jwt_token');
    if (token == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/api/business/accept'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'businessId': businessId}),
      );
      // print("Business ID: $businessId");
      // print("Response: ${response.body}");
      // print("Status Code: ${response.statusCode}");
      if (response.statusCode == 200) {
        // Successfully accepted the request, refresh pending requests
        _fetchPendingRequests();
        _fetchBusinesses(); // Optionally refresh businesses if needed
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to accept request')),
        );
      }
    } catch (e) {
      print('Error: ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _rejectRequest(String businessId) async {
    final token = await storage.read(key: 'jwt_token');
    if (token == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/api/business/reject'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'businessId': businessId}),
      );

      if (response.statusCode == 200) {
        // Successfully rejected the request, refresh pending requests
        _fetchPendingRequests();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to reject request')),
        );
      }
    } catch (e) {
      print('Error: ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
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
        : _business_error != null
            ? Center(child: Text(_business_error!))
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
        ? const Center(child: CircularProgressIndicator())
        : _request_error != null
            ? Center(child: Text(_request_error!))
            : ListView.builder(
                itemCount: _pendingRequests.length,
                itemBuilder: (context, index) {
                  final request = _pendingRequests[index];
                  final businessName = request['businessName'] ?? 'No Business Name';
                  final businessId = request['businessId'];

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
                              _acceptRequest(businessId);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {
                              _rejectRequest(businessId);
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
