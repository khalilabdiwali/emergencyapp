import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

Future<Map<String, int>> fetchIncidentStatuses() async {
  final databaseReference = FirebaseDatabase.instance.ref().child('incidents');
  final snapshot = await databaseReference.once();

  Map<String, int> statusCounts = {
    'In Progress': 0,
    'Finished': 0,
    'Resolved': 0
  };

  if (snapshot.snapshot.value != null) {
    final incidents = Map<String, dynamic>.from(snapshot.snapshot.value as Map);

    incidents.forEach((key, value) {
      final status = value['status'] as String?;
      if (status != null && statusCounts.containsKey(status)) {
        statusCounts[status] = statusCounts[status]! + 1;
      }
    });
  }

  return statusCounts;
}

class IncidentStatusChart extends StatelessWidget {
  final Future<Map<String, int>> statusData;

  IncidentStatusChart({Key? key})
      : statusData = fetchIncidentStatuses(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Incident Status Overview'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Incident Status Distribution',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            SizedBox(height: 50), // Add space above the chart
            Expanded(
              child: FutureBuilder<Map<String, int>>(
                future: statusData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final data = snapshot.data ?? {};
                  if (data.isEmpty) {
                    return Center(child: Text('No incident data available.'));
                  }

                  final total =
                      data.values.fold(0, (sum, count) => sum + count);

                  return Column(
                    children: [
                      SizedBox(
                        height: 250, // Increase the height for the chart
                        child: PieChart(
                          PieChartData(
                            sections: data.entries.map((entry) {
                              final percentage = entry.value / total;
                              return PieChartSectionData(
                                value: entry.value.toDouble(),
                                title:
                                    '${(percentage * 100).toStringAsFixed(1)}%',
                                color: _getColor(entry.key),
                                radius:
                                    80, // Increase the radius of each section
                                titleStyle: TextStyle(
                                  fontSize:
                                      14, // Increase the font size of the titles
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              );
                            }).toList(),
                            centerSpaceRadius:
                                40, // Increase the center space radius
                            sectionsSpace: 0,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: data.entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  color: _getColor(entry.key),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '${entry.key} (${entry.value})',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'This chart represents the current status of incidents. '
                        'The sections show the percentage and count of incidents that are '
                        'In Progress, Finished, or Resolved.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColor(String status) {
    switch (status) {
      case 'Resolved':
        return Colors.green;
      case 'In Progress':
        return Colors.orange;
      case 'Finished':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

void main() {
  runApp(MaterialApp(
    home: IncidentStatusChart(),
    theme: ThemeData(
      primarySwatch: Colors.teal,
    ),
  ));
}
