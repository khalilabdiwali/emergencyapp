import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // appBar: AppBar(
        //   // title: Text('Police Reports'),
        //   centerTitle: true,
        // ),
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
                if (!snapshot.hasData ||
                    snapshot.data!.snapshot.value == null) {
                  return Center(
                      child: LoadingAnimationWidget.fourRotatingDots(
                    color: Color(0xff240b33),
                    size: 50.0,
                  ));
                }
                Map<dynamic, dynamic> incidents =
                    snapshot.data!.snapshot.value as Map<dynamic, dynamic>? ??
                        {};
                var filteredIncidents = incidents.entries.where((entry) {
                  final incidentData = Map<String, dynamic>.from(entry.value);
                  return incidentData['type'] ==
                      userRole; // Filter by user role
                }).toList();
                return ListView.builder(
                  itemCount: filteredIncidents.length,
                  itemBuilder: (context, index) {
                    final entry = filteredIncidents[index];
                    final incidentData = Map<String, dynamic>.from(entry.value);
                    final timestamp = incidentData['timestamp'] as int? ??
                        DateTime.now().millisecondsSinceEpoch;
                    final reportedByUid =
                        incidentData['reportedBy'] as String? ?? 'Unknown';

                    return FutureBuilder<String>(
                      future: _getUserNameByUid(reportedByUid),
                      builder: (context, AsyncSnapshot<String> nameSnapshot) {
                        if (!nameSnapshot.hasData) {
                          return ListTile(
                              title: Text('Loading reporter name...'));
                        }
                        return Card(
                          child: ListTile(
                            title: Text(incidentData['type'] ?? 'No Type'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(incidentData['description'] ??
                                    'No Description'),
                                Text(
                                    'Location: ${incidentData['location'] ?? 'Not specified'}'),
                                Text('Time: ${_formatTimestamp(timestamp)}'),
                                Text('Reported by: ${nameSnapshot.data}'),
                              ],
                            ),
                            isThreeLine: true,
                            trailing:
                                Text(incidentData['status'] ?? 'No Status'),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
