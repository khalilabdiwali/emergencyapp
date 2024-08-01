// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:geolocator/geolocator.dart';

// class HospitalService {
//   static const String apiKey = 'AIzaSyBEMGLIt92NsoEOQ1_x4UKyOuypEfwsrj0';
//   static const String baseUrl =
//       'https://maps.googleapis.com/maps/api/place/nearbysearch/json';

//   Future<List<Hospital>> fetchNearbyHospitals(Position position) async {
//     final response = await http.get(
//       Uri.parse(
//         '$baseUrl?location=${position.latitude},${position.longitude}&radius=5000&type=hospital&key=$apiKey',
//       ),
//     );

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       List<Hospital> hospitals = [];
//       for (var item in data['results']) {
//         hospitals.add(Hospital.fromJson(item));
//       }
//       return hospitals;
//     } else {
//       throw Exception('Failed to load hospitals');
//     }
//   }

//   Future<List<Hospital>> searchHospitalsByName(
//       String query, Position position) async {
//     final response = await http.get(
//       Uri.parse(
//         '$baseUrl?location=${position.latitude},${position.longitude}&radius=5000&type=hospital&keyword=$query&key=$apiKey',
//       ),
//     );

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       List<Hospital> hospitals = [];
//       for (var item in data['results']) {
//         hospitals.add(Hospital.fromJson(item));
//       }
//       return hospitals;
//     } else {
//       throw Exception('Failed to load hospitals');
//     }
//   }
// }

// class Hospital {
//   final String name;
//   final String address;

//   Hospital({required this.name, required this.address});

//   factory Hospital.fromJson(Map<String, dynamic> json) {
//     return Hospital(
//       name: json['name'],
//       address: json['vicinity'],
//     );
//   }
// }
