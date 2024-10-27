import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class InventoryPage extends StatefulWidget {
  final Map<String, dynamic> business;
  const InventoryPage({super.key, required this.business});

  @override
  _InventoryPageState createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  List<dynamic> products = [];

  @override
  void initState() {
    super.initState();
    _fetchProducts(widget.business['_id']); // Fetch products on page load
  }

  Future<void> _fetchProducts(String id) async {
    try {
      final response = await http.get(Uri.parse('http://192.168.0.102:5000/api/inventory/${id}/all'));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          products = responseData['products']; // Adjusted to match the response structure
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load products. Error: ${response.statusCode}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load products. Error: $error')),
      );
    }
  }

  Future<void> _addProduct(String name, String description, int quantity, double price, String id) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.0.102:5000/api/inventory/${id}/products'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'productName': name,
          'productDescription': description,
          'quantity': quantity,
          'price': price,
        }),
      );

      if (response.statusCode == 201) {
        _fetchProducts(widget.business['_id']); // Refresh products after adding a new one
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add product. Error: ${response.statusCode}. ${response.body}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add product. Error: $error')),
      );
    }
  }

  Future<void> _deleteProduct(String productId) async {
    print( 'URL = '+'http://192.168.0.102:5000/api/inventory/${widget.business['_id']}/products/$productId');
    try {
      final response = await http.delete(Uri.parse('http://192.168.0.102:5000/api/inventory/${widget.business['_id']}/products/$productId'));

      if (response.statusCode == 200) {
        _fetchProducts(widget.business['_id']); // Refresh products after deletion
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product deleted successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete product. Error: ${response.statusCode}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete product. Error: $error')),
      );
    }
  }

  Future<void> _editProduct(String productId, String name, String description, int quantity, double price) async {
    try {
      final response = await http.put(
        Uri.parse('http://192.168.0.102:5000/api/inventory/${widget.business['_id']}/products/$productId'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'productName': name,
          'productDescription': description,
          'quantity': quantity,
          'price': price,
        }),
      );

      if (response.statusCode == 200) {
        _fetchProducts(widget.business['_id']); // Refresh products after editing
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product updated successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update product. Error: ${response.statusCode}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update product. Error: $error')),
      );
    }
  }

  void _showEditProductDialog(Map<String, dynamic> product) {
    TextEditingController nameController = TextEditingController(text: product['productName']);
    TextEditingController descriptionController = TextEditingController(text: product['productDescription']);
    TextEditingController stockController = TextEditingController(text: product['quantity'].toString());
    TextEditingController priceController = TextEditingController(text: product['price'].toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Product'),
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
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _editProduct(
                  product['_id'],
                  nameController.text,
                  descriptionController.text,
                  int.tryParse(stockController.text) ?? 0,
                  double.tryParse(priceController.text) ?? 0.0,
                );
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Management'),
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: products.isEmpty
            ? const Center(child: CircularProgressIndicator()) // Show loading while fetching data
            : ListView(
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
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.shopping_bag, // Placeholder for image (replace with product['image'] if using actual images)
              size: 60,
              color: Theme.of(context).iconTheme.color ?? Colors.blueAccent,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['productName'],
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product['productDescription'],
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sold: ${product['unitsSold'] ?? 0}', // Handle undefined unitsSold
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        'Stock: ${product['quantity']}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    _showEditProductDialog(product); // Call the edit dialog
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    _deleteProduct(product['_id']); // Call the delete function
                  },
                ),
              ],
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
    TextEditingController priceController = TextEditingController();

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
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _addProduct(
                  nameController.text,
                  descriptionController.text,
                  int.tryParse(stockController.text) ?? 0,
                  double.tryParse(priceController.text) ?? 0.0,
                  widget.business['_id'],
                );
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
