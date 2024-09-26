import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'business_detail_page.dart'; // Import the new page
import 'package:jwt_decoder/jwt_decoder.dart'; 

final storage = FlutterSecureStorage();

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> _businesses = [];
  bool _isLoading = true;
  String? _error;

  Future<void> _logout() async {
    await storage.delete(key: 'jwt_token');
    Navigator.pushReplacementNamed(context, '/login'); // Navigate to the login page
  }

  Future<void> _checkAuthentication() async {
    final token = await storage.read(key: 'jwt_token');
    if (token == null) {
      Navigator.pushReplacementNamed(context, '/login'); // Navigate to login if no token
    }
  }

  Future<void> _fetchBusinesses() async {
    setState(() {
      _isLoading = true;
    });

    final token = await storage.read(key: 'jwt_token');
    if (token == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    try {
      final decodedToken = JwtDecoder.decode(token);
      final role = decodedToken['role'];
      if (role != 'owner') {
        setState(() {
          _error = 'You do not have permission to view this page';
          _isLoading = false;
          return;
        });
      }
      final response = await http.get(
        Uri.parse('https://business-management-gagi.onrender.com/api/business/all'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Ensure token is sent in the header
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _businesses = data['businesses'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load businesses: ${response.reasonPhrase}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _checkAuthentication(); // Check authentication status on page load
    _fetchBusinesses(); // Fetch businesses on page load
  }

  String _truncateDescription(String? description) {
    if (description == null) return '';
    final words = description.split(' ');
    return words.length > 7 ? words.sublist(0, 7).join(' ') + '...' : description;
  }

  void _createBusiness() {
    Navigator.pushNamed(context, '/create_business');
  }

  void _refresh() {
    _fetchBusinesses(); // Re-fetch businesses on refresh
  }

  void _viewBusinessDetails(Map<String, dynamic> business) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BusinessDetailPage(business: business),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh), // Refresh icon
            onPressed: _refresh,
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
          SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : ListView.builder(
                    itemCount: _businesses.length,
                    itemBuilder: (context, index) {
                      final business = _businesses[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16.0),
                          title: Text(business['name']),
                          subtitle: Text(_truncateDescription(business['description'])),
                          onTap: () => _viewBusinessDetails(business), // Navigate to business details page
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createBusiness,
        child: Icon(Icons.add),
      ),
    );
  }
}
