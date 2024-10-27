import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'business_detail_page.dart'; // Import the new page
import 'package:jwt_decoder/jwt_decoder.dart';

const storage = FlutterSecureStorage();

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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
        Uri.parse('http://192.168.0.102:5000/api/business/all'),
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
    return words.length > 7 ? '${words.sublist(0, 7).join(' ')}...' : description;
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
        title: const Text('Home Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!, style: TextStyle(color: Colors.red)))
                : ListView.builder(
                    itemCount: _businesses.length,
                    itemBuilder: (context, index) {
                      final business = _businesses[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        color: Theme.of(context).cardColor, // Use card color from theme
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16.0),
                          title: Text(
                            business['name'],
                            style: Theme.of(context).textTheme.titleLarge, // Apply headline style
                          ),
                          subtitle: Text(
                            _truncateDescription(business['description']),
                            style: Theme.of(context).textTheme.titleMedium, // Apply subtitle style
                          ),
                          onTap: () => _viewBusinessDetails(business),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createBusiness,
        backgroundColor: Theme.of(context).primaryColor, // Ensure FAB uses primary color
        child: const Icon(Icons.add),
      ),
    );
  }
}
