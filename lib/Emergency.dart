// class Emergency {
//   String type;
//   double latitude;
//   double longitude;
//   String status;
//   DateTime timestamp;

//   Emergency({
//     required this.type,
//     required this.latitude,
//     required this.longitude,
//     required this.status,
//     DateTime? timestamp, // Make timestamp nullable
//   }) : this.timestamp =
//             timestamp ?? DateTime.now(); // Use null-coalescing operator

//   Map<String, dynamic> toJson() => {
//         'type': type,
//         'location': {
//           'latitude': latitude,
//           'longitude': longitude,
//         },
//         'status': status,
//         'timestamp': timestamp.toIso8601String(),
//       };
// }
