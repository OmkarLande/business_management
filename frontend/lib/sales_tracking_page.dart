import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class SalesTrackingPage extends StatefulWidget {
  const SalesTrackingPage({super.key});

  @override
  _SalesTrackingPageState createState() => _SalesTrackingPageState();
}

class _SalesTrackingPageState extends State<SalesTrackingPage> {
  List<List<dynamic>> salesData = [];
  List<FlSpot> spots = [];
  String selectedFilter = 'All Products';
  String selectedYear = '2023';
  List<String> products = [];
  List<String> years = [];

  Future<void> _pickCSVFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      var fileBytes = result.files.single.bytes;
      var filePath = result.files.single.path;

      try {
        if (fileBytes == null && filePath != null) {
          // Read file content directly if bytes are null
          fileBytes = await File(filePath).readAsBytes();
        }

        if (fileBytes != null) {
          final fields =
              const CsvToListConverter().convert(utf8.decode(fileBytes));

          setState(() {
            salesData = fields;
            products = [];
            spots.clear();

            // Debug output
            print("Parsed CSV Data: $salesData");

            _updateGraph();
          });
        } else {
          print("Error: Could not read file bytes.");
        }
      } catch (e) {
        print("Error reading CSV file: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Tracking'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05, vertical: 16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.upload_file),
              label: const Text("Upload Sales Data (CSV)"),
              onPressed: _pickCSVFile,
            ),
            const SizedBox(height: 20),
            // DropdownButton<String>(
            //   value: selectedYear,
            //   items: years.map((String year) {
            //     return DropdownMenuItem<String>(
            //       value: year,
            //       child: Text(year),
            //     );
            //   }).toList(),
            //   onChanged: (newValue) {
            //     setState(() {
            //       selectedYear = newValue!;
            //       _updateGraph();
            //     });
            //   },
            // ),
            // DropdownButton<String>(
            //   value: selectedFilter,
            //   items: ['All Products', ...products].map((String product) {
            //     return DropdownMenuItem<String>(
            //       value: product,
            //       child: Text(product),
            //     );
            //   }).toList(),
            //   onChanged: (newValue) {
            //     setState(() {
            //       selectedFilter = newValue!;
            //       _updateGraph();
            //     });
            //   },
            // ),
            const SizedBox(height: 20),
            Expanded(
              child: spots.isEmpty
                  ? const Center(
                      child: Text(
                          'No sales data available. Upload a CSV to see the graph.'))
                  : LineChart(
                      LineChartData(
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                final date =
                                    DateTime.fromMillisecondsSinceEpoch(
                                        value.toInt());
                                final formattedDate =
                                    DateFormat('dd-MM').format(date);
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  space: 8.0,
                                  child: Transform.rotate(
                                    angle: -45 * 3.1415927 / 180,
                                    child: Text(formattedDate,
                                        style: const TextStyle(fontSize: 10)),
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: false, // Hide Y-axis labels
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: true),
                        gridData: const FlGridData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            color: Colors.blue,
                            barWidth: 4,
                            belowBarData: BarAreaData(show: false),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateGraph() {
    spots.clear(); // Clear previous data
    DateFormat dateFormat = DateFormat("dd-MM-yyyy");

    for (int i = 1; i < salesData.length; i++) {
      String productName = salesData[i][2];

      if (selectedFilter == 'All Products' || selectedFilter == productName) {
        String date = salesData[i][1];
        String year = date.split('-')[2];

        if (selectedYear == year || selectedYear == 'All Years') {
          double salesValue;
          try {
            salesValue = salesData[i][0] is String
                ? double.parse(salesData[i][0].toString())
                : (salesData[i][0] as num).toDouble(); // Ensure it's double
          } catch (e) {
            print("Error converting sales amount to double: $e");
            continue; // Skip this row if there's an error
          }

          try {
            DateTime dateTime = dateFormat.parse(date);
            int dateIndex = dateTime.millisecondsSinceEpoch;

            spots.add(FlSpot(dateIndex.toDouble(), salesValue));
          } catch (e) {
            print("Error parsing date: $e");
          }
        }
      }
    }

    print("Spots: $spots"); // Debugging output for verification
    setState(() {}); // Trigger rebuild
  }
}
