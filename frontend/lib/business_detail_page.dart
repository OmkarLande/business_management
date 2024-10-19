import 'package:flutter/material.dart';
import 'inventory_page.dart'; // Import InventoryPage
import 'sales_tracking_page.dart'; // Import SalesTrackingPage
import 'employees_page.dart'; // Import EmployeePage
import 'customer_content_page.dart'; // Import CustomerContentPage

class BusinessDetailPage extends StatelessWidget {
  final Map<String, dynamic> business;

  const BusinessDetailPage({super.key, required this.business});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          business['name'] ?? 'Business Details',
          style: Theme.of(context).appBarTheme.titleTextStyle, // Use theme's appBar title style
        ), // Fallback if name is null
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Determine the number of columns based on screen width
            int columns = constraints.maxWidth < 600 ? 2 : 4; // 2 columns on mobile, 4 on larger screens

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
                        builder: (context) => const InventoryPage(),
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
                        builder: (context) => CustomerContentPage(business: business),
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
                        builder: (context) => const SalesTrackingPage(),
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

  Widget _buildSectionCard(BuildContext context, String title, IconData icon, {VoidCallback? onTap}) {
    return Card(
      elevation: 6.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      color: Theme.of(context).cardColor, // Use the theme's card color
      child: InkWell(
        onTap: onTap ?? () {},
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 60,
                color: Theme.of(context).iconTheme.color ?? Colors.blue, // Use theme's icon color
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ), // Use the theme's text style with customization
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
