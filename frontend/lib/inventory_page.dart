import 'package:flutter/material.dart';

class InventoryPage extends StatefulWidget {
  @override
  _InventoryPageState createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  // Sample inventory data
  List<Map<String, dynamic>> products = [
    {
      'name': 'Pants',
      'sold': 30,
      'stock': 70,
      'description': 'Comfortable cotton pants, available in multiple colors.',
      'imagePlaceholder': Icons.shopping_bag,
    },
    {
      'name': 'T-Shirts',
      'sold': 45,
      'stock': 55,
      'description': 'Soft fabric T-shirts, suitable for casual wear.',
      'imagePlaceholder': Icons.checkroom,
    },
    {
      'name': 'Dress',
      'sold': 25,
      'stock': 75,
      'description': 'Elegant summer dress, perfect for any occasion.',
      'imagePlaceholder': Icons.dry_cleaning,
    },
    {
      'name': 'Caps',
      'sold': 15,
      'stock': 85,
      'description': 'Stylish caps to complement any outfit.',
      'imagePlaceholder': Icons.sports_baseball,
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Get screen width for responsive padding
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Inventory Management'),
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05), // Responsive padding
        child: ListView(
          children:
              products.map((product) => _buildProductCard(product)).toList(),
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0), // Space between cards
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              product['imagePlaceholder'],
              size: 60,
              color: Colors.blueAccent,
            ),
            const SizedBox(width: 12), // Space between icon and text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product['description'],
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sold: ${product['sold']}',
                        style: TextStyle(fontSize: 12),
                      ),
                      Text(
                        'Stock: ${product['stock']}',
                        style: TextStyle(fontSize: 12),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('View details of ${product['name']}')),
                          );
                        },
                        child: Text('Details', style: TextStyle(fontSize: 10)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
