import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

Future<Map<String, List<int>>> fetchIncidentTrends() async {
  final databaseReference = FirebaseDatabase.instance.ref().child('incidents');
  final snapshot = await databaseReference.once();

  Map<String, List<int>> trends = {
    'fire': [],
    'medical': [],
    'traffic': [],
    'police': [],
    //'accident': [],
  };

  if (snapshot.snapshot.value != null) {
    final incidents = Map<String, dynamic>.from(snapshot.snapshot.value as Map);

    incidents.forEach((key, value) {
      final type = value['type'] as String?;
      final timestamp = value['timestamp'] as int?;
      if (type != null && timestamp != null && trends.containsKey(type)) {
        trends[type]!.add(timestamp);
      }
    });
  }

  // Sort the timestamps for each type to ensure chronological order
  trends.forEach((key, value) {
    value.sort();
  });

  return trends;
}

class IncidentTrendChart extends StatelessWidget {
  final Future<Map<String, List<int>>> trendData;

  IncidentTrendChart({Key? key})
      : trendData = fetchIncidentTrends(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Incident Trend Overview'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Incident Trend Over Time',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            SizedBox(height: 50), // Add space above the chart
            Expanded(
              child: FutureBuilder<Map<String, List<int>>>(
                future: trendData,
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

                  final lineBarsData = data.entries.map((entry) {
                    final spots = entry.value.asMap().entries.map((e) {
                      final index = e.key;
                      final timestamp = e.value;
                      return FlSpot(index.toDouble(), timestamp.toDouble());
                    }).toList();

                    return LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      colors: [_getColor(entry.key)],
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        colors: [_getColor(entry.key).withOpacity(0.3)],
                      ),
                    );
                  }).toList();

                  return Column(
                    children: [
                      SizedBox(
                        height: 300, // Increase the height for the chart
                        child: LineChart(
                          LineChartData(
                            lineBarsData: lineBarsData,
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
                                  final dateTime =
                                      DateTime.fromMillisecondsSinceEpoch(data
                                          .values.first[value.toInt()]
                                          .toInt());
                                  return '${dateTime.month}/${dateTime.day}';
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
                                  '${entry.key} (${entry.value.length})',
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
                        'This chart represents the trend of incidents over time. '
                        'The lines show the count of incidents by date.',
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
    home: IncidentTrendChart(),
    theme: ThemeData(
      primarySwatch: Colors.teal,
    ),
  ));
}
