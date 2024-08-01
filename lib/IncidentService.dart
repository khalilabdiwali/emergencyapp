import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sms/customPadding.dart';


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Incident Reporting App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AddIncidentForm(),
    );
  }
}

class AddIncidentForm extends StatefulWidget {
  @override
  _AddIncidentFormState createState() => _AddIncidentFormState();
}

class _AddIncidentFormState extends State<AddIncidentForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final IncidentService _incidentService = IncidentService();
  late User _currentUser;
  String? _selectedType; // Change here

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  void _getCurrentUser() {
    _currentUser = FirebaseAuth.instance.currentUser!;
  }

  Future<Position> _getCurrentLocation() async {
    return Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  void _submitIncident() async {
    if (_formKey.currentState!.validate()) {
      try {
        final Position position = await _getCurrentLocation();
        final newIncident = Incident(
          location: GeoPoint(
              latitude: position.latitude, longitude: position.longitude),
          type: _selectedType!, // Change here
          description: _descriptionController.text,
          status: _statusController.text,
          timestamp: DateTime.now().millisecondsSinceEpoch,
          reportedBy: _currentUser.uid,
        );
        await _incidentService.addIncident(newIncident);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Incident added successfully')));
        _descriptionController.clear();
        _statusController.clear();
        setState(() {
          _selectedType = null; // Change here
        });
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding incident: $error')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Add New Incident')),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xff6a5f6d), Color(0xff42214f)],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    customPadding(
                      child: DropdownButtonFormField<String>(
                        value: _selectedType,
                        onChanged: (value) {
                          setState(() {
                            _selectedType = value!;
                          });
                        },
                        items: ['police', 'traffic', 'medical', 'fire']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white, // Default border color
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors
                                  .blue, // Color of the border when the TextField is focused
                              width: 2, // Width of the border when focused
                            ),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors
                                  .white, // Color of the border under normal circumstances
                            ),
                          ),
                          labelText: 'Send to',
                          labelStyle: TextStyle(color: Colors.white),

                          // border: OutlineInputBorder(),
                          prefixIcon: Icon(
                            Icons.label,
                            color: Colors.white,
                          ),
                        ),
                        validator: (value) =>
                            value == null ? 'Please choose a type' : null,
                      ),
                    ),
                    SizedBox(height: 20),
                    customPadding(
                      child: TextFormField(
                        controller: _descriptionController,
                        style: GoogleFonts.openSans(color: Colors.white),
                        decoration: const InputDecoration(
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white, // Default border color
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors
                                    .blue, // Color of the border when the TextField is focused
                                width: 2, // Width of the border when focused
                              ),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors
                                    .white, // Color of the border under normal circumstances
                              ),
                            ),
                            labelText: 'Description',
                            labelStyle: TextStyle(color: Colors.white),

                            // border: OutlineInputBorder(),
                            prefixIcon: Icon(
                              Icons.description,
                              color: Colors.white,
                            )),
                        validator: (value) => value!.isEmpty
                            ? 'Please enter a description'
                            : null,
                        maxLines: 3,
                      ),
                    ),
                    SizedBox(height: 20),
                    // customPadding(
                    //   child: TextFormField(
                    //     controller: _statusController,
                    //     style: TextStyle(color: Colors.white),
                    //     decoration: const InputDecoration(
                    //         border: UnderlineInputBorder(
                    //           borderSide: BorderSide(
                    //             color: Colors.white, // Default border color
                    //           ),
                    //         ),
                    //         focusedBorder: UnderlineInputBorder(
                    //           borderSide: BorderSide(
                    //             color: Colors
                    //                 .blue, // Color of the border when the TextField is focused
                    //             width: 2, // Width of the border when focused
                    //           ),
                    //         ),
                    //         enabledBorder: UnderlineInputBorder(
                    //           borderSide: BorderSide(
                    //             color: Colors
                    //                 .white, // Color of the border under normal circumstances
                    //           ),
                    //         ),
                    //         labelText: 'Status',
                    //         labelStyle: TextStyle(color: Colors.white),
                    //         // border: OutlineInputBorder(),
                    //         prefixIcon: Icon(
                    //           Icons.flag,
                    //           color: Colors.white,
                    //         )),
                    //     validator: (value) =>
                    //         value!.isEmpty ? 'Please enter a status' : null,
                    //   ),
                    // ),
                    SizedBox(height: 20),
                    customPadding(
                      child: ElevatedButton.icon(
                        icon: Icon(
                          Icons.save,
                          color: Colors.white,
                        ),
                        label: Text(
                          'Submit',
                          style: GoogleFonts.openSans(
                              color: Colors.white, fontSize: 19),
                        ),
                        onPressed: _submitIncident,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xff3f134e),
                            padding: EdgeInsets.symmetric(vertical: 10)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _statusController.dispose();
    super.dispose();
  }
}

class IncidentService {
  final DatabaseReference _incidentRef =
      FirebaseDatabase.instance.reference().child('incidents');

  Future<String> addIncident(Incident incident) async {
    final newIncidentRef = _incidentRef.push();
    await newIncidentRef.set(incident.toJson());
    return newIncidentRef.key!;
  }

  getIncidentsStream() {}
}

class Incident {
  final GeoPoint location;
  final String type;
  final String description;
  final String status;
  final int timestamp;
  final String reportedBy;

  Incident(
      {required this.location,
      required this.type,
      required this.description,
      required this.status,
      required this.timestamp,
      required this.reportedBy});

  Map<String, dynamic> toJson() {
    return {
      'location': location.toJson(),
      'type': type,
      'description': description,
      'status': status,
      'timestamp': timestamp,
      'reportedBy': reportedBy,
    };
  }
}

class GeoPoint {
  final double latitude;
  final double longitude;

  GeoPoint({required this.latitude, required this.longitude});

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
