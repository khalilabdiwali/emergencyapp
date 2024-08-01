// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:loading_animation_widget/loading_animation_widget.dart';

// class EmergencyAlertsPage extends StatefulWidget {
//   @override
//   _EmergencyAlertsPageState createState() => _EmergencyAlertsPageState();
// }

// class _EmergencyAlertsPageState extends State<EmergencyAlertsPage> {
//   final DatabaseReference _alertsRef =
//       FirebaseDatabase.instance.reference().child('alerts');
//   List<Map<dynamic, dynamic>> _alerts = [];

//   @override
//   void initState() {
//     super.initState();
//     _listenToAlerts();
//   }

//   void _listenToAlerts() {
//     _alertsRef.onValue.listen((event) {
//       final data = event.snapshot.value;
//       if (data != null && data is Map<dynamic, dynamic>) {
//         final List<Map<dynamic, dynamic>> alerts = [];
//         data.forEach((key, value) {
//           if (value is Map<dynamic, dynamic>) {
//             alerts.add(value);
//           }
//         });
//         setState(() {
//           _alerts = alerts;
//         });
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Emergency Alerts'),
//       ),
//       body: _alerts.isEmpty
//           ? Center(
//               child: LoadingAnimationWidget.fourRotatingDots(
//               color: Color(0xff240b33),
//               size: 50.0,
//             ))
//           : ListView.builder(
//               itemCount: _alerts.length,
//               itemBuilder: (context, index) {
//                 final alert = _alerts[index];
//                 return ListTile(
//                   title: Text(alert['title'] ?? 'No Title'),
//                   subtitle: Text(alert['description'] ?? 'No Description'),
//                   trailing: Text(alert['timestamp'] ?? 'No Timestamp'),
//                 );
//               },
//             ),
//     );
//   }
// }
