import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Information',
      home: HealthInfoForm(),
    );
  }
}

class HealthInfoForm extends StatefulWidget {
  @override
  _HealthInfoFormState createState() => _HealthInfoFormState();
}

class _HealthInfoFormState extends State<HealthInfoForm> {
  final _formKey = GlobalKey<FormState>();
  final _userIdController = TextEditingController();
  final _insuranceDetailsController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _doctorNotesController = TextEditingController();
  final _medicalHistoryController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _bloodTypeController = TextEditingController();
  final DatabaseReference _dbRef = FirebaseDatabase.instance.reference();

  @override
  void dispose() {
    _userIdController.dispose();
    _insuranceDetailsController.dispose();
    _emergencyContactController.dispose();
    _doctorNotesController.dispose();
    _medicalHistoryController.dispose();
    _medicationsController.dispose();
    _allergiesController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _bloodTypeController.dispose();
    super.dispose();
  }

  void _submitData() {
    final userId = _userIdController.text;
    final timestamp = DateTime.now().toIso8601String();

    if (_formKey.currentState!.validate()) {
      _dbRef.child('users').child(userId).set({
        'insuranceDetails': _insuranceDetailsController.text,
        'emergencyContact': _emergencyContactController.text,
        'doctorNotes': _doctorNotesController.text,
        'medicalHistory': _medicalHistoryController.text,
        'medications': _medicationsController.text,
        'allergies': _allergiesController.text,
        'bloodType': _bloodTypeController.text,
        'weight': _weightController.text,
        'height': _heightController.text,
        'timestamp': timestamp
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Data Successfully Added'),
          backgroundColor: Colors.green,
        ));
      }).catchError((onError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to add data'),
          backgroundColor: Colors.red,
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Health Information Form'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              // User ID
              buildTextField(
                  _userIdController, 'User ID', 'Please enter User ID', false),
              // Insurance Details
              buildTextField(_insuranceDetailsController, 'Insurance Details',
                  'Please enter insurance details', false),
              // Emergency Contact
              buildTextField(_emergencyContactController, 'Emergency Contact',
                  'Please enter emergency contact', false),
              // Doctor Notes
              buildTextField(_doctorNotesController, 'Doctor Notes',
                  'Please enter doctor notes', false),
              // Medical History
              buildTextField(_medicalHistoryController, 'Medical History',
                  'Please enter medical history', false),
              // Medications
              buildTextField(_medicationsController, 'Medications',
                  'Please enter medications', false),
              // Allergies
              buildTextField(_allergiesController, 'Allergies',
                  'Please enter allergies', false),
              // Blood Type
              buildTextField(_bloodTypeController, 'Blood Type',
                  'Please enter blood type', false),
              // Weight
              buildTextField(_weightController, 'Weight (kg)',
                  'Please enter weight', true),
              // Height
              buildTextField(_heightController, 'Height (cm)',
                  'Please enter height', true),
              // Submit Button
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitData,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label,
      String errorText, bool isNumeric) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return errorText;
        }
        return null;
      },
    );
  }
}
