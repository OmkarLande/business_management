import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart'; // For date formatting

class SalesTrackingPage extends StatefulWidget {
  @override
  _SalesTrackingPageState createState() => _SalesTrackingPageState();
}

class _SalesTrackingPageState extends State<SalesTrackingPage> {
  List<List<dynamic>> salesData = [];
  List<FlSpot> spots = [];

  String selectedFilter = 'All Products';
  String selectedYear = '2023';
  List<String> products = [];
  List<String> years = ['2023', '2024']; // Add more years as needed

  // Function to pick a CSV file and parse it
  Future<void> _pickCSVFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      var fileBytes = result.files.single.bytes;
      final fields =
          const CsvToListConverter().convert(utf8.decode(fileBytes!));

      setState(() {
        salesData = fields;
        products = []; // Reset products

        // Clear previous data
        spots.clear();

        // Assuming the first row contains headers and sales data starts from the second row
        for (int i = 1; i < salesData.length; i++) {
          String productName = salesData[i][2];
          if (!products.contains(productName)) {
            products.add(productName); // Add unique products
          }

          // Filter by selected year
          String date = salesData[i][1];
          String year = date.split('-')[2]; // Extract year from date

          if (selectedYear == year || selectedYear == 'All Years') {
            double salesValue = salesData[i][0] is String
                ? double.tryParse(salesData[i][0]) ?? 0.0
                : salesData[i][0];

            // Parse the date into DateTime object
            DateFormat dateFormat = DateFormat("dd-MM-yyyy");
            DateTime dateTime = dateFormat.parse(date);
            int dateIndex = dateTime.millisecondsSinceEpoch;

            spots.add(FlSpot(dateIndex.toDouble(), salesValue));
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Sales Tracking'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05, vertical: 16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              icon: Icon(Icons.upload_file),
              label: Text("Upload Sales Data (CSV)"),
              onPressed: _pickCSVFile,
            ),
            const SizedBox(height: 20),
            DropdownButton<String>(
              value: selectedYear,
              items: years.map((String year) {
                return DropdownMenuItem<String>(
                  value: year,
                  child: Text(year),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedYear = newValue!;
                  _updateGraph(); // Method to update graph based on current filter
                });
              },
            ),
            DropdownButton<String>(
              value: selectedFilter,
              items: ['All Products', ...products].map((String product) {
                return DropdownMenuItem<String>(
                  value: product,
                  child: Text(product),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedFilter = newValue!;
                  _updateGraph(); // Method to update graph based on current filter
                });
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: spots.isEmpty
                  ? Center(
                      child: Text(
                          'No sales data available. Upload a CSV to see the graph.'))
                  : LineChart(
                      LineChartData(
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final date =
                                    DateTime.fromMillisecondsSinceEpoch(
                                        value.toInt());
                                final formattedDate =
                                    DateFormat('dd-MM').format(date);
                                return Text(formattedDate);
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true)),
                        ),
                        borderData: FlBorderData(show: true),
                        gridData: FlGridData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            color: Colors.blue,
                            barWidth: 4,
                            isStrokeCapRound: true,
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
    // Logic to filter sales data based on selected year and product
    spots.clear(); // Clear previous data

    DateFormat dateFormat = DateFormat("dd-MM-yyyy");
    for (int i = 1; i < salesData.length; i++) {
      String productName = salesData[i][2];
      // Check if product matches the selected filter
      if (selectedFilter == 'All Products' || selectedFilter == productName) {
        String date = salesData[i][1];
        String year = date.split('-')[2]; // Extract year from date

        if (selectedYear == year || selectedYear == 'All Years') {
          double salesValue = salesData[i][0] is String
              ? double.tryParse(salesData[i][0]) ?? 0.0
              : salesData[i][0];

          // Parse the date into DateTime object
          DateTime dateTime = dateFormat.parse(date);
          int dateIndex = dateTime.millisecondsSinceEpoch;

          spots.add(FlSpot(dateIndex.toDouble(), salesValue));
        }
      }
    }
    setState(() {}); // Trigger rebuild to show updated graph
  }
}
