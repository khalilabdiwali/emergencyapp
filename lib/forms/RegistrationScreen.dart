import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sms/forms/LoginPage.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _homeAddressController = TextEditingController();
  final _personToContactController = TextEditingController();
  final _contactPersonPhoneController = TextEditingController();
  final _bloodTypeController = TextEditingController();
  final _medicalHistoryController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _allergiesController = TextEditingController();
  File? _profileImage;
  String _role = "regular";
  String _gender = "Male";
  String _bloodtype = "A=";
  final ImagePicker _picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _userRef = FirebaseDatabase.instance.reference();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  bool _passwordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _dateOfBirthController.dispose();
    _homeAddressController.dispose();
    _personToContactController.dispose();
    _contactPersonPhoneController.dispose();
    // _bloodTypeController.dispose();
    _medicalHistoryController.dispose();
    _medicationsController.dispose();
    _allergiesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> registerUser() async {
    if (_formKey.currentState!.validate() && _profileImage != null) {
      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        User? user = userCredential.user;
        await user!.sendEmailVerification(); // Sending verification email

        if (user != null) {
          String? imageUrl = await _uploadImageToStorage();
          await _saveUserDataToDatabase(user.uid, imageUrl);
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Registration Successful'),
              content: Text(
                  'You are successfully registered and a verification email has been sent. Please verify your email.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => LoginPage(),
                      ),
                    ); // Navigate to login page
                  },
                  child: Text('OK'),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        print("Error registering user: $e");
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text(
              'Please ensure all fields are filled and a profile image is selected.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<String?> _uploadImageToStorage() async {
    try {
      final storageRef =
          _storage.ref('user_images/${_emailController.text}.jpg');
      final uploadTask = storageRef.putFile(_profileImage!);
      await uploadTask.whenComplete(() => null);
      return await storageRef.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _saveUserDataToDatabase(String userId, String? imageUrl) async {
    await _userRef.child('Users').child(userId).set({
      'uid': userId,
      'name': _fullNameController.text,
      'email': _emailController.text,
      'phoneNumber': _phoneNumberController.text,
      'dateOfBirth': _dateOfBirthController.text,
      'homeAddress': _homeAddressController.text,
      'personToContact': _personToContactController.text,
      'contactPersonPhone': _contactPersonPhoneController.text,
      'profileImageUrl': imageUrl ?? '',
      'role': _role,
      'gender': _gender,
    });
    await _userRef.child('MedicalInfo').child(userId).set({
      'bloodType': _bloodTypeController.text,
      'medicalHistory': _medicalHistoryController.text,
      'medications': _medicationsController.text,
      'allergies': _allergiesController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign Up "),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/pages/regisbg.png'), // Your background image path
                fit: BoxFit.fill,
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildPersonalInfoForm(),
                        _buildMedicalInfoForm(),
                        SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: registerUser,
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  Color.fromARGB(255, 255, 255, 255)),
                            ),
                            child: Text(
                              'Register',
                              style: GoogleFonts.nunitoSans(
                                  fontSize: 20, color: Color(0xff3f134e)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (_profileImage != null)
          CircleAvatar(
            radius: 60,
            backgroundImage: FileImage(_profileImage!),
            backgroundColor: Colors.white,
            // Adding background color to ensure complete image display
            child: ClipOval(
              child: Image.file(
                _profileImage!,
                fit: BoxFit.cover,
                width: 120,
                height: 120,
              ),
            ),
          ),
        GestureDetector(
          onTap: _pickImage,
          child: AbsorbPointer(
            child: _buildTextField(
              controller: TextEditingController(text: 'Profile Picture'.tr()),
              labelText: 'Profile Picture Upload'.tr(),
              icon: Icons.upload_file_outlined,
            ),
          ),
        ),
        _buildTextField(
          controller: _fullNameController,
          labelText: 'Full Name'.tr(),
          icon: Icons.person_outline,
        ),
        _buildTextField(
          controller: _emailController,
          labelText: 'Email'.tr(),
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        TextFormField(
          controller: _passwordController,
          decoration: InputDecoration(
            labelText: 'Password'.tr(),
            labelStyle: TextStyle(color: Colors.white),
            prefixIcon: Icon(Icons.lock_outline, color: Colors.white),
            suffixIcon: IconButton(
              icon: Icon(
                _passwordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _passwordVisible = !_passwordVisible;
                });
              },
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
          style: TextStyle(color: Colors.white),
          obscureText: !_passwordVisible,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter Password'.tr();
            }
            return null;
          },
        ),
        _buildDropdownGenderField(),
        _buildTextField(
          controller: _phoneNumberController,
          labelText: 'Phone Number'.tr(),
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        GestureDetector(
          onTap: () async {
            final DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (pickedDate != null) {
              _dateOfBirthController.text = pickedDate.toString().split(' ')[0];
            }
          },
          child: AbsorbPointer(
            child: _buildTextField(
              controller: _dateOfBirthController,
              labelText: 'Date of Birth'.tr(),
              icon: Icons.calendar_today_outlined,
            ),
          ),
        ),
        _buildTextField(
          controller: _homeAddressController,
          labelText: 'Home Address'.tr(),
          icon: Icons.home_outlined,
        ),
        _buildTextField(
          controller: _personToContactController,
          labelText: 'Person to Contact in Case of Emergency'.tr(),
          icon: Icons.contact_phone_outlined,
        ),
        _buildTextField(
          controller: _contactPersonPhoneController,
          labelText: 'Emergency Contact Phone Number'.tr(),
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  Widget _buildMedicalInfoForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _buildDropdownBloodField(),
        // _buildTextField(
        //   controller: _bloodTypeController,
        //   labelText: 'Blood Type'.tr(),
        //   icon: Icons.bloodtype,
        // ),
        _buildTextField(
          controller: _medicalHistoryController,
          labelText: 'Medical History Description'.tr(),
          icon: Icons.history,
        ),
        _buildTextField(
          controller: _medicationsController,
          labelText: 'Medications'.tr(),
          icon: Icons.medical_services,
        ),
        _buildTextField(
          controller: _allergiesController,
          labelText: 'Allergies'.tr(),
          icon: Icons.warning_amber_outlined,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.white),
          prefixIcon: Icon(icon, color: Colors.white),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
        style: TextStyle(color: Colors.white),
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $labelText'.tr();
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdownGenderField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: _gender,
        decoration: InputDecoration(
          labelText: "Gender".tr(),
          labelStyle: TextStyle(color: Colors.white),
          prefixIcon: Icon(Icons.group, color: Colors.white),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
        dropdownColor:
            Colors.grey[850], // Background color of the dropdown menu
        style: TextStyle(color: Colors.white),
        onChanged: (String? newValue) {
          setState(() => _gender = newValue!);
        },
        items: <String>[
          'Male'.tr(),
          'Female'.tr(),
        ].map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDropdownBloodField() {
    String initialValue = 'A+'; // Set initial value to match one of the items
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: _bloodTypeController.text.isNotEmpty
            ? _bloodTypeController.text
            : initialValue,
        decoration: InputDecoration(
          labelText: 'Blood Type'.tr(),
          labelStyle: TextStyle(color: Colors.white),
          prefixIcon: Icon(Icons.group, color: Colors.white),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
        dropdownColor: Colors.grey[850],
        style: TextStyle(color: Colors.white),
        onChanged: (String? newValue) {
          setState(() => _bloodTypeController.text = newValue!);
        },
        items: <String>['Unknown', 'A+'.tr(), 'B+'.tr(), 'O-', 'O+']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }
}
