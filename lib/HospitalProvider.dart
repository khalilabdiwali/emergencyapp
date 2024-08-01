// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:sms/HospitalService.dart';

// class HospitalProvider with ChangeNotifier {
//   List<Hospital> _hospitals = [];
//   List<Hospital> _filteredHospitals = [];
//   bool _isLoading = false;

//   List<Hospital> get hospitals => _filteredHospitals;
//   bool get isLoading => _isLoading;

//   Future<void> fetchHospitals() async {
//     _isLoading = true;
//     notifyListeners();

//     try {
//       Position position = await _determinePosition();
//       _hospitals = await HospitalService().fetchNearbyHospitals(position);
//       _filteredHospitals = _hospitals;
//     } catch (e) {
//       print("Error fetching hospitals: $e");
//     }

//     _isLoading = false;
//     notifyListeners();
//   }

//   Future<void> searchHospitals(String query) async {
//     print("Searching for: $query");
//     if (query.isEmpty) {
//       _filteredHospitals = _hospitals;
//       notifyListeners();
//       return;
//     }

//     _isLoading = true;
//     notifyListeners();

//     try {
//       Position position = await _determinePosition();
//       _filteredHospitals =
//           await HospitalService().searchHospitalsByName(query, position);
//     } catch (e) {
//       print("Error searching hospitals: $e");
//       _filteredHospitals = [];
//     }

//     _isLoading = false;
//     notifyListeners();
//   }

//   Future<Position> _determinePosition() async {
//     return await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);
//   }
// }
