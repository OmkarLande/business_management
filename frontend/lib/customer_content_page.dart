import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:mailto/mailto.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class CustomerContentPage extends StatefulWidget {
  final Map<String, dynamic> business;

  const CustomerContentPage({super.key, required this.business});

  @override
  _CustomerContentPageState createState() => _CustomerContentPageState();
}

class _CustomerContentPageState extends State<CustomerContentPage> {
  List<List<dynamic>> customerData = [];

  Future<void> _pickCSVFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['csv'],
  );

  if (result != null && result.files.isNotEmpty) {
    try {
      // Get the file path
      String? path = result.files.single.path;

      // Ensure path is not null before proceeding
      if (path != null) {
        // Read the file as a string
        final file = File(path);
        String fileContent = await file.readAsString();

        // Convert the CSV string into a list of lists
        final fields = const CsvToListConverter().convert(fileContent);

        setState(() {
          customerData = fields.map((row) {
            return row.map((cell) {
              // Convert each cell to String to avoid any type issues.
              return cell.toString();
            }).toList();
          }).toList();
        });
      } else {
        // Handle the case where path is null
        print("Error: File path is null.");
      }
    } catch (e) {
      print("Error reading CSV file: $e");
    }
  } else {
    // Handle case where no file was selected
    print("No file was selected or file is empty.");
  }
}

  Future<void> _sendEmailNotification(String customerName, String email) async {
    final mailtoLink = Mailto(
      to: [email],
      subject: 'Special Sale for $customerName',
      body: 'Dear $customerName,\n\nWe have a special offer just for you!',
    );

    await launchUrl(Uri.parse(mailtoLink.toString()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Management'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.upload_file),
              label: const Text("Upload CSV"),
              onPressed: _pickCSVFile,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: customerData.isEmpty
                  ? const Center(
                      child: Text(
                          'No customer data available. Upload a CSV to see the data.'))
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        return SizedBox(
                          width: double
                              .infinity, // Make sure container uses full width
                          child: constraints.maxWidth > 600
                              ? SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    columns: const <DataColumn>[
                                      DataColumn(label: Text('Name')),
                                      DataColumn(label: Text('Email')),
                                      DataColumn(label: Text('Address')),
                                      DataColumn(label: Text('Phone')),
                                      DataColumn(label: Text('Actions')),
                                    ],
                                    rows: customerData.skip(1).map((customer) {
                                      return DataRow(
                                        cells: <DataCell>[
                                          DataCell(
                                              Text(customer[0].toString())),
                                          DataCell(
                                              Text(customer[1].toString())),
                                          DataCell(
                                              Text(customer[2].toString())),
                                          DataCell(
                                              Text(customer[3].toString())),
                                          DataCell(
                                            ElevatedButton(
                                              onPressed: () {
                                                _sendEmailNotification(
                                                    customer[0].toString(),
                                                    customer[1].toString());
                                              },
                                              style: ElevatedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 12,
                                                        horizontal: 16),
                                                textStyle: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                              child: const Text("Send Email"),
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                )
                              : ListView(
                                  children:
                                      customerData.skip(1).map((customer) {
                                    return Container(
                                      width: double.infinity,
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: Card(
                                        elevation: 4.0,
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Name: ${customer[0].toString()}',
                                                style: const TextStyle(
                                                    fontSize: 16),
                                              ),
                                              Text(
                                                'Email: ${customer[1].toString()}',
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                              Text(
                                                'Address: ${customer[2].toString()}',
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                              Text(
                                                'Phone: ${customer[3].toString()}',
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                              const SizedBox(height: 8),
                                              ElevatedButton(
                                                onPressed: () {
                                                  _sendEmailNotification(
                                                      customer[0].toString(),
                                                      customer[1].toString());
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 12,
                                                      horizontal: 16),
                                                  textStyle: const TextStyle(
                                                      fontSize: 12),
                                                ),
                                                child: const Text("Send Email"),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
