import 'package:flutter/material.dart';
import 'employees_page.dart'; // Assuming you have created an EmployeePage for rendering employee details

class BusinessDetailPage extends StatelessWidget {
  final Map<String, dynamic> business;

  BusinessDetailPage({required this.business});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(business['name'] ?? 'Business Details'), // Fallback if name is null
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
          ),
          shrinkWrap: true,
          children: [
            _buildSectionCard(context, 'Inventory Management', Icons.inventory),
            _buildSectionCard(context, 'Customer Content', Icons.person),
            _buildSectionCard(context, 'Sales Tracking', Icons.trending_up),
            _buildSectionCard(context, 'Employees', Icons.group, onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EmployeePage(business: business,),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, String title, IconData icon, {VoidCallback? onTap}) {
    return Card(
      elevation: 4.0,
      child: InkWell(
        onTap: onTap ?? () {
          // Default action, if not provided
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.blue),
            const SizedBox(height: 10),
            Text(title, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
