import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

Future<Map<String, int>> fetchIncidentTypes() async {
  final databaseReference = FirebaseDatabase.instance.ref().child('incidents');
  final snapshot = await databaseReference.once();

  Map<String, int> typeCounts = {
    'fire': 0,
    'medical': 0,
    'traffic': 0,
    'police': 0,
    //'accident': 0,
  };

  if (snapshot.snapshot.value != null) {
    final incidents = Map<String, dynamic>.from(snapshot.snapshot.value as Map);

    incidents.forEach((key, value) {
      final type = value['type'] as String?;
      if (type != null && typeCounts.containsKey(type)) {
        typeCounts[type] = typeCounts[type]! + 1;
      }
    });
  }

  return typeCounts;
}

class IncidentTypeChart extends StatelessWidget {
  final Future<Map<String, int>> typeData;

  IncidentTypeChart({Key? key})
      : typeData = fetchIncidentTypes(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Incident Type Overview'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Incident Type Distribution',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            SizedBox(height: 50), // Add space above the chart
            Expanded(
              child: FutureBuilder<Map<String, int>>(
                future: typeData,
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

                  final barGroups = data.entries.map((entry) {
                    return BarChartGroupData(
                      x: data.keys.toList().indexOf(entry.key),
                      barRods: [
                        BarChartRodData(
                          y: entry.value.toDouble(),
                          colors: [_getColor(entry.key)],
                          width: 20,
                        ),
                      ],
                    );
                  }).toList();

                  return Column(
                    children: [
                      SizedBox(
                        height: 250, // Increase the height for the chart
                        child: BarChart(
                          BarChartData(
                            barGroups: barGroups,
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              bottomTitles: SideTitles(
                                showTitles: true,
                                getTextStyles: (context, value) =>
                                    const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                getTitles: (double value) {
                                  switch (value.toInt()) {
                                    case 0:
                                      return 'Fire';
                                    case 1:
                                      return 'Medical';
                                    case 2:
                                      return 'Traffic';
                                    case 3:
                                      return 'Police';
                                    case 4:
                                      return 'Accident';
                                    default:
                                      return '';
                                  }
                                },
                                margin: 16,
                              ),
                              leftTitles: SideTitles(showTitles: true),
                            ),
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
                        'This chart represents the distribution of incident types. '
                        'The bars show the count of incidents by type.',
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

  Color _getColor(String type) {
    switch (type) {
      case 'fire':
        return Colors.red;
      case 'medical':
        return Colors.blue;
      case 'traffic':
        return Colors.orange;
      case 'police':
        return Colors.purple;
      case 'accident':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

void main() {
  runApp(MaterialApp(
    home: IncidentTypeChart(),
    theme: ThemeData(
      primarySwatch: Colors.teal,
    ),
  ));
}
