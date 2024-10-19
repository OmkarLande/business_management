import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const storage = FlutterSecureStorage();

class EmployeeHomePage extends StatefulWidget {
  const EmployeeHomePage({super.key});

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
        Uri.parse('https://business-management-gagi.onrender.com/api/business/employees/buisness'),
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
        Uri.parse('https://business-management-gagi.onrender.com/api/auth/pending'),
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
        });
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
  }

  Future<void> _acceptRequest(String businessId) async {
    final token = await storage.read(key: 'jwt_token');
    if (token == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('https://business-management-gagi.onrender.com/api/business/accept'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'businessId': businessId}),
      );

      if (response.statusCode == 200) {
        // Successfully accepted the request, refresh pending requests
        _fetchPendingRequests();
        _fetchBusinesses(); // Optionally refresh businesses if needed
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to accept request')),
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
        Uri.parse('https://business-management-gagi.onrender.com/api/business/reject'),
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
          const SnackBar(content: Text('Failed to reject request')),
        );
      }
    } catch (e) {
      print('Error: ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  // Logout method
  Future<void> _logout() async {
    await storage.delete(key: 'jwt_token'); // Clear the token
    Navigator.pushReplacementNamed(context, '/login'); // Navigate to login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _logout, // Call the logout method on press
        label: const Text('Logout'),
        icon: const Icon(Icons.logout),
        backgroundColor: const Color(0xFFFFA500), // Set to your accent color
      ),
    );
  }

  Widget _buildBusinessesTab() {
    return _isLoadingBusinesses
        ? const Center(child: CircularProgressIndicator())
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
                            icon: const Icon(Icons.check),
                            onPressed: () {
                              _acceptRequest(businessId);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
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
