import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sms/incident/IncidentStatusChart.dart';
import 'package:sms/Charts/UserPieChart.dart';
import 'package:sms/Charts/file.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Incident Analytics',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AnalyticsPage(),
      routes: {
        '/incidentStatusChart': (context) => IncidentStatusChart(),
      },
    );
  }
}

class AnalyticsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Analytics Page'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text(
            //   'Incident Analytics',
            //   style: TextStyle(
            //     fontSize: 28,
            //     fontWeight: FontWeight.bold,
            //     color: Colors.teal[800],
            //   ),
            // ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildAnalyticsCard(
                    context,
                    'Incident Pie Chart',
                    'Shows the percentage or count of different types of incidents',
                    Icons.bar_chart,
                    IncidentTypeChart(),
                  ),
                  _buildAnalyticsCard(
                    context,
                    'Incident Status Chart',
                    'View the status distribution of incidents',
                    Icons.pie_chart,
                    IncidentStatusChart(),
                  ),
                  _buildAnalyticsCard(
                    context,
                    'Incident Trend Chart',
                    'View the status distribution of incidents',
                    Icons.stacked_line_chart_outlined,
                    IncidentTrendChart(),
                  ),
                  // Add more ListTiles here for additional analytics pages
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsCard(BuildContext context, String title,
      String subtitle, IconData icon, Widget page) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16.0),
        leading: Icon(
          icon,
          color: Colors.teal,
          size: 36,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.teal[900],
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.teal[700],
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.teal[900],
          size: 16,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
      ),
    );
  }
}
