import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sms/components/customPadding.dart';

class IncidentReportView extends StatelessWidget {
  final FirebaseDatabase database = FirebaseDatabase.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<String> _getUserRole() async {
    final User? user = auth.currentUser;
    final uid = user?.uid;
    if (uid == null) {
      return 'Unknown';
    }
    final ref = database.ref('Users/$uid');
    final snapshot = await ref.get();
    if (snapshot.exists) {
      final userData = snapshot.value as Map<dynamic, dynamic>;
      return userData['role'] as String? ?? 'Unknown';
    } else {
      return 'Unknown';
    }
  }

  Future<String> _getUserNameByUid(String uid) async {
    final ref = database.ref('Users/$uid');
    final snapshot = await ref.get();
    if (snapshot.exists) {
      final userData = snapshot.value as Map<dynamic, dynamic>;
      return userData['name'] as String? ?? 'Unknown';
    } else {
      return 'Unknown';
    }
  }

  String _formatTimestamp(int timestamp) {
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    var formatter = DateFormat('yyyy-MM-dd HH:mm'); // Custom format
    return formatter.format(date);
  }

  Future<void> _updateStatus(String incidentId, String newStatus) async {
    final ref = database.ref('incidents/$incidentId');
    await ref.update({'status': newStatus});
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'In Progress':
        return Colors.orange;
      case 'Finished':
        return Colors.blue;
      case 'Resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reported Incidents'),
      ),
      body: FutureBuilder<String>(
        future: _getUserRole(),
        builder: (context, AsyncSnapshot<String> roleSnapshot) {
          if (!roleSnapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final userRole = roleSnapshot.data!;
          return StreamBuilder(
            stream: database.ref('incidents').onValue,
            builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                return Center(
                  child: LoadingAnimationWidget.fourRotatingDots(
                    color: Color(0xff240b33),
                    size: 50.0,
                  ),
                );
              }
              Map<dynamic, dynamic> incidents =
                  snapshot.data!.snapshot.value as Map<dynamic, dynamic>? ?? {};
              var filteredIncidents = incidents.entries.where((entry) {
                final incidentData = Map<String, dynamic>.from(entry.value);
                return incidentData['type'] == userRole; // Filter by user role
              }).toList();
              return customPadding(
                child: ListView.builder(
                  itemCount: filteredIncidents.length,
                  itemBuilder: (context, index) {
                    final entry = filteredIncidents[index];
                    final incidentId = entry.key;
                    final incidentData = Map<String, dynamic>.from(entry.value);
                    final timestamp = incidentData['timestamp'] as int? ??
                        DateTime.now().millisecondsSinceEpoch;
                    final reportedByUid =
                        incidentData['reportedBy'] as String? ?? 'Unknown';
                    final status =
                        incidentData['status'] as String? ?? 'In Progress';

                    return FutureBuilder<String>(
                      future: _getUserNameByUid(reportedByUid),
                      builder: (context, AsyncSnapshot<String> nameSnapshot) {
                        if (!nameSnapshot.hasData) {
                          return ListTile(
                              title: Text('Loading reporter name...'));
                        }
                        return Card(
                          margin: EdgeInsets.all(10.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  incidentData['type'] ?? 'No Type',
                                  style: GoogleFonts.openSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    // color: Color(0xff240b33),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  incidentData['description'] ??
                                      'No Description',
                                  style: GoogleFonts.openSans(
                                    fontSize: 16,
                                    // color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Location: ${incidentData['location'] ?? 'Not specified'}',
                                  style: GoogleFonts.openSans(
                                    fontSize: 16,
                                    // color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Time: ${_formatTimestamp(timestamp)}',
                                  style: GoogleFonts.openSans(
                                    fontSize: 16,
                                    // color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Reported by: ${nameSnapshot.data}',
                                  style: GoogleFonts.openSans(
                                    fontSize: 16,
                                    // color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Status:',
                                      style: GoogleFonts.openSans(
                                        fontSize: 16,
                                        // color: Colors.black87,
                                      ),
                                    ),
                                    DropdownButton<String>(
                                      value: [
                                        'In Progress',
                                        'Finished',
                                        'Resolved'
                                      ].contains(status)
                                          ? status
                                          : 'In Progress',
                                      items: <String>[
                                        'In Progress',
                                        'Finished',
                                        'Resolved'
                                      ].map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(
                                            value,
                                            style: GoogleFonts.openSans(
                                                color: _getStatusColor(value)),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (newValue) {
                                        if (newValue != null) {
                                          _updateStatus(incidentId, newValue);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
