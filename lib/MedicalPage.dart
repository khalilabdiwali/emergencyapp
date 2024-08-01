import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show ByteData, Uint8List, rootBundle;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nearby Hospitals',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MedicalPage(),
    );
  }
}

class MedicalPage extends StatefulWidget {
  @override
  _MedicalPageState createState() => _MedicalPageState();
}

class _MedicalPageState extends State<MedicalPage> {
  GoogleMapController? mapController;
  Position? currentPosition;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  BitmapDescriptor? currentLocationMarker;
  BitmapDescriptor? hospitalMarker;

  List<HospitalInfo> hospitalInfoList = [
    HospitalInfo(
      name: "Banadir Hospital",
      address: "Mogadishu, Somalia",
      contact: "+252 61 5522828",
    ),
    HospitalInfo(
      name: "Digfer Hospital",
      address: "Mogadishu, Somalia",
      contact: "+252 61 5532222",
    ),
    HospitalInfo(
      name: "Madinat Hospital",
      address: "Mogadishu, Somalia",
      contact: "+252 61 5543333",
    ),
  ];

  List<LatLng> hospitalLocations = [
    LatLng(2.0408, 45.3441), // Banadir Hospital
    LatLng(2.043194, 45.304528), // Digfer Hospital
    LatLng(2.0371, 45.3414), // Madinat Hospital
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadCustomMarkers();
  }

  Future<void> _loadCustomMarkers() async {
    currentLocationMarker =
        await _createCustomMarker('assets/current_location_marker.png', 80);
    hospitalMarker =
        await _createCustomMarker('assets/hospital_marker.png', 60);
  }

  Future<BitmapDescriptor> _createCustomMarker(
      String imagePath, int size) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..isAntiAlias = true;
    final double radius = size / 2;

    final ui.Image image = await _loadImage(imagePath);
    canvas.drawImageRect(
      image,
      Rect.fromLTRB(0.0, 0.0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromCircle(center: Offset(radius, radius), radius: radius),
      paint,
    );

    final ui.Image markerImage =
        await pictureRecorder.endRecording().toImage(size, size);
    final ByteData? byteData =
        await markerImage.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List resizedMarkerImageBytes = byteData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(resizedMarkerImageBytes);
  }

  Future<ui.Image> _loadImage(String imagePath) async {
    final Completer<ui.Image> completer = Completer();
    final ByteData data = await rootBundle.load(imagePath);
    ui.decodeImageFromList(Uint8List.view(data.buffer), (ui.Image img) {
      completer.complete(img);
    });
    return completer.future;
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      markers.add(
        Marker(
          markerId: MarkerId('currentLocation'),
          position:
              LatLng(currentPosition!.latitude, currentPosition!.longitude),
          icon: currentLocationMarker!,
        ),
      );
    });

    _getNearbyHospitals();
  }

  Future<void> _getNearbyHospitals() async {
    for (int i = 0; i < hospitalLocations.length; i++) {
      LatLng hospital = hospitalLocations[i];
      markers.add(
        Marker(
          markerId: MarkerId(hospitalInfoList[i].name),
          position: hospital,
          icon: hospitalMarker!,
        ),
      );

      String estimatedTime = await _getEstimatedTravelTime(
        LatLng(currentPosition!.latitude, currentPosition!.longitude),
        hospital,
      );

      setState(() {
        hospitalInfoList[i].estimatedTime = estimatedTime;
      });
    }

    setState(() {});
  }

  Future<String> _getEstimatedTravelTime(
      LatLng origin, LatLng destination) async {
    String url =
        'https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=${origin.latitude},${origin.longitude}&destinations=${destination.latitude},${destination.longitude}&key=AIzaSyBEMGLIt92NsoEOQ1_x4UKyOuypEfwsrj0';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['rows'] != null &&
          data['rows'].isNotEmpty &&
          data['rows'][0]['elements'] != null &&
          data['rows'][0]['elements'].isNotEmpty &&
          data['rows'][0]['elements'][0]['status'] == 'OK') {
        return data['rows'][0]['elements'][0]['duration']['text'];
      } else {
        return 'N/A';
      }
    } else {
      return 'N/A';
    }
  }

  Future<void> _createRoute(LatLng destination) async {
    // Clear any existing polylines
    polylines.clear();

    // Get current location
    LatLng currentLocation =
        LatLng(currentPosition!.latitude, currentPosition!.longitude);

    // Add polyline
    setState(() {
      polylines.add(
        Polyline(
          polylineId: PolylineId('route'),
          visible: true,
          points: [currentLocation, destination],
          color: Colors.blue,
          width: 4,
        ),
      );
    });

    // Zoom and center the map to show the route
    mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(
              currentLocation.latitude < destination.latitude
                  ? currentLocation.latitude
                  : destination.latitude,
              currentLocation.longitude < destination.longitude
                  ? currentLocation.longitude
                  : destination.longitude),
          northeast: LatLng(
              currentLocation.latitude > destination.latitude
                  ? currentLocation.latitude
                  : destination.latitude,
              currentLocation.longitude > destination.longitude
                  ? currentLocation.longitude
                  : destination.longitude),
        ),
        100.0,
      ),
    );
  }

  void _onHospitalTap(LatLng hospitalLocation) {
    _createRoute(hospitalLocation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nearby Hospitals in Mogadishu'),
      ),
      body: currentPosition == null
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  flex: 2,
                  child: GoogleMap(
                    onMapCreated: (GoogleMapController controller) {
                      mapController = controller;
                    },
                    initialCameraPosition: CameraPosition(
                      target: LatLng(currentPosition!.latitude,
                          currentPosition!.longitude),
                      zoom: 14.0,
                    ),
                    markers: markers,
                    polylines: polylines,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: ListView.builder(
                    itemCount: hospitalInfoList.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          hospitalInfoList[index].name,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(hospitalInfoList[index].address),
                            Text(
                              'Contact: ${hospitalInfoList[index].contact}',
                              style: TextStyle(color: Colors.grey),
                            ),
                            Text(
                              'Estimated Time: ${hospitalInfoList[index].estimatedTime}',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                        onTap: () => _onHospitalTap(hospitalLocations[index]),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class HospitalInfo {
  final String name;
  final String address;
  final String contact;
  String estimatedTime;

  HospitalInfo({
    required this.name,
    required this.address,
    required this.contact,
    this.estimatedTime = '',
  });
}
