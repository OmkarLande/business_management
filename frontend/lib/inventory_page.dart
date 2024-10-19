import 'package:flutter/material.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

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

  IconData? _selectedIcon; // Variable to store selected icon

  @override
  Widget build(BuildContext context) {
    // Get screen width for responsive padding
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Management'),
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05), // Responsive padding
        child: ListView(
          children: products.map((product) => _buildProductCard(context, product)).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProductDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> product) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0), // Space between cards
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0), // Rounded corners for the card
      ),
      color: Theme.of(context).cardColor, // Use theme's card color
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              product['imagePlaceholder'],
              size: 60,
              color: Theme.of(context).iconTheme.color ?? Colors.blueAccent, // Use theme's icon color
            ),
            const SizedBox(width: 12), // Space between icon and text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'],
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black, // Ensure title color is visible
                        ), // Use theme's text style with custom boldness
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product['description'],
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600], // Adjust description color
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sold: ${product['sold']}',
                        style: Theme.of(context).textTheme.bodyMedium, // Use theme's caption style
                      ),
                      Text(
                        'Stock: ${product['stock']}',
                        style: Theme.of(context).textTheme.bodyMedium, // Use theme's caption style
                      ),
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('View details of ${product['name']}'),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 8.0,
                          ),
                          textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 12),
                        ),
                        child: const Text('Details'),
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

  void _showAddProductDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController stockController = TextEditingController();
    TextEditingController soldController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Product'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Product Name'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: stockController,
                  decoration: const InputDecoration(labelText: 'Stock'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: soldController,
                  decoration: const InputDecoration(labelText: 'Sold'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                const Text('Select an Icon:'),
                Wrap(
                  spacing: 8.0,
                  children: [
                    _buildIconOption(Icons.shopping_bag),
                    _buildIconOption(Icons.checkroom),
                    _buildIconOption(Icons.dry_cleaning),
                    _buildIconOption(Icons.sports_baseball),
                    _buildIconOption(Icons.star), // Add more icons as needed
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _addProduct(
                  nameController.text,
                  descriptionController.text,
                  int.tryParse(stockController.text) ?? 0,
                  int.tryParse(soldController.text) ?? 0,
                );
                Navigator.of(context).pop(); // Close the dialog
              },
              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.primary), // Make sure the text color is visible
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildIconOption(IconData icon) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIcon = icon; // Set the selected icon
        });
      },
      child: Icon(
        icon,
        size: 40,
        color: _selectedIcon == icon ? Colors.blue : Colors.grey, // Highlight selected icon
      ),
    );
  }

  void _addProduct(String name, String description, int stock, int sold) {
    if (name.isNotEmpty && description.isNotEmpty) {
      setState(() {
        products.add({
          'name': name,
          'description': description,
          'stock': stock,
          'sold': sold,
          'imagePlaceholder': _selectedIcon ?? Icons.shopping_bag, // Default icon if none selected
        });
      });
    }
  }
}
