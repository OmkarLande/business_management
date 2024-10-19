import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart'; 

const storage = FlutterSecureStorage();

//Amigos

class CreateBusinessPage extends StatefulWidget {
  const CreateBusinessPage({super.key});

  @override
  _CreateBusinessPageState createState() => _CreateBusinessPageState();
}

class _CreateBusinessPageState extends State<CreateBusinessPage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _createBusiness() async {
    if (_formKey.currentState!.validate()) {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }
      final decodedToken = JwtDecoder.decode(token);
      final role = decodedToken['role'];
      if (role != 'owner') {
        setState(() {
          var error0 = 'You do not have permission to view this page';
          return;
        });
      }
      final response = await http.post(
        Uri.parse('https://business-management-gagi.onrender.com/api/business/create'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': _nameController.text,
          'description': _descriptionController.text,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Business created successfully')),
        );
        Navigator.pop(context);
      } else {
        final error = json.decode(response.body)['error'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Business'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Business Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the business name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createBusiness,
                child: const Text('Create Business'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
