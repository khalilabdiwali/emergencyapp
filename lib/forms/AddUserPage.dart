import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

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
  File? _profileImage;
  String _role = "regular";
  final ImagePicker _picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _userRef =
      FirebaseDatabase.instance.reference().child('Users');
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
                  onPressed: () => Navigator.of(context).pop(),
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
    await _userRef.child(userId).set({
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Sign Up"),
        ),
        body: Stack(children: [
          Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(
                        'assets/pages/regisbg.png'), // Your background image path
                    fit: BoxFit.fill),
              ),
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          if (_profileImage != null)
                            CircleAvatar(
                              radius: 60,
                              backgroundImage: FileImage(_profileImage!),
                            ),
                          _buildTextField(
                            controller: _fullNameController,
                            labelText: 'Name',
                            icon: Icons.person_outline,
                          ),
                          _buildTextField(
                            controller: _emailController,
                            labelText: 'Email',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          _buildDropdownRoleField(),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors
                                      .blue, // Color of the border when the TextField is focused
                                  width: 2, // Width of the border when focused
                                ),
                              ),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors
                                      .white, // Color of the border under normal circumstances
                                ),
                              ),
                              labelText: 'Password',
                              labelStyle: TextStyle(color: Colors.white),
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: Colors.white,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _passwordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _passwordVisible = !_passwordVisible;
                                  });
                                },
                              ),
                            ),
                            obscureText: !_passwordVisible,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Password';
                              }
                              return null;
                            },
                          ),
                          _buildTextField(
                            controller: _phoneNumberController,
                            labelText: 'Phone Number',
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
                                _dateOfBirthController.text =
                                    pickedDate.toString().split(' ')[0];
                              }
                            },
                            child: AbsorbPointer(
                              child: _buildTextField(
                                controller: _dateOfBirthController,
                                labelText: 'Date of Register',
                                icon: Icons.calendar_today_outlined,
                              ),
                            ),
                          ),
                          _buildTextField(
                            controller: _homeAddressController,
                            labelText: 'Home Address',
                            icon: Icons.home_outlined,
                          ),
                          _buildTextField(
                            controller: _personToContactController,
                            labelText: 'Person to Contact',
                            icon: Icons.person_search_outlined,
                          ),
                          _buildTextField(
                            controller: _contactPersonPhoneController,
                            labelText: 'Emergency Contact Phone',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),
                          GestureDetector(
                            onTap: _pickImage,
                            child: AbsorbPointer(
                              child: _buildTextField(
                                controller: TextEditingController(
                                    text: 'Profile Picture'),
                                labelText: 'Profile Picture Upload',
                                icon: Icons.upload_file_outlined,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
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
                        ],
                      ),
                    ),
                  ),
                ),
              ))
        ]));
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
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.white),
          prefixIcon: Icon(
            icon,
            color: Colors.white,
          ),
        ),
        style: TextStyle(color: Colors.white),
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $labelText';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdownRoleField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: _role,
        decoration: const InputDecoration(
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
          labelText: "Role",
          labelStyle: TextStyle(color: Colors.white),
          prefixIcon:
              Icon(Icons.group, color: Color.fromARGB(255, 255, 255, 255)),
        ),
        onChanged: (String? newValue) {
          setState(() => _role = newValue!);
        },
        items: <String>[
          'regular',
          'admin',
          'police',
          'fire',
          'medical',
          'traffic'
        ].map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value, style: GoogleFonts.nunitoSans()),
          );
        }).toList(),
      ),
    );
  }
}
