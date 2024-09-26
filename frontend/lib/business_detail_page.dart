import 'package:flutter/material.dart';
import 'inventory_page.dart'; // Import InventoryPage
import 'sales_tracking_page.dart'; // Import SalesTrackingPage
import 'employees_page.dart'; // Import EmployeePage
import 'customer_content_page.dart'; // Import CustomerContentPage

class BusinessDetailPage extends StatelessWidget {
  final Map<String, dynamic> business;

  BusinessDetailPage({required this.business});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            business['name'] ?? 'Business Details'), // Fallback if name is null
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Determine the number of columns based on screen width
            int columns = constraints.maxWidth < 600
                ? 2
                : 4; // 2 columns on mobile, 4 on PC

            return GridView(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
              ),
              shrinkWrap: true,
              children: [
                _buildSectionCard(
                  context,
                  'Inventory Management',
                  Icons.inventory,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InventoryPage(),
                      ),
                    );
                  },
                ),
                _buildSectionCard(
                  context,
                  'Customer Content',
                  Icons.person,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CustomerContentPage(business: business),
                      ),
                    );
                  },
                ),
                _buildSectionCard(
                  context,
                  'Sales Tracking',
                  Icons.trending_up,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SalesTrackingPage(),
                      ),
                    );
                  },
                ),
                _buildSectionCard(
                  context,
                  'Employees',
                  Icons.group,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EmployeePage(business: business),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, String title, IconData icon,
      {VoidCallback? onTap}) {
    return Card(
      elevation: 6.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: onTap ??
            () {
              // Default action, if not provided
            },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 60, color: Colors.blue),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
