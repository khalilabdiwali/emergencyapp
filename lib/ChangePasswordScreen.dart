import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sms/customPadding.dart';

class ChangePasswordScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password'.tr()),
      ),
      body: ChangePasswordForm(),
    );
  }
}

class ChangePasswordForm extends StatefulWidget {
  @override
  _ChangePasswordFormState createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<ChangePasswordForm> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  void _changePassword() async {
    // Validate the form
    if (_formKey.currentState!.validate()) {
      // Get the current user
      User? currentUser = _auth.currentUser;

      // Check if the current user is authenticated
      if (currentUser != null) {
        // Get the email of the current user
        String? email = currentUser.email;

        // Sign in with email and password to reauthenticate the user
        try {
          await _auth.signInWithEmailAndPassword(
            email: email!,
            password: _oldPasswordController.text,
          );

          // Reauthentication successful, now update the password
          await currentUser.updatePassword(_newPasswordController.text);

          // Password updated successfully
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Password changed successfully'.tr()),
            ),
          );

          // Optionally, you can navigate back to the settings page or any other page
          Navigator.pop(context);
        } catch (e) {
          // Reauthentication failed, show error message
          print('Error reauthenticating user: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Failed to change password. Please check your old password.'
                      .tr()),
            ),
          );
        }
      } else {
        // No user signed in, show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No user signed in.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            customPadding(
              child: TextFormField(
                controller: _oldPasswordController,
                decoration: InputDecoration(labelText: 'Old Password'.tr()),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your old password'.tr();
                  }
                  return null;
                },
              ),
            ),
            customPadding(
              child: TextFormField(
                controller: _newPasswordController,
                decoration: InputDecoration(labelText: 'New Password'.tr()),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a new password'.tr();
                  }
                  return null;
                },
              ),
            ),
            customPadding(
              child: TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(labelText: 'Confirm Password'.tr()),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password'.tr();
                  }
                  return null;
                },
              ),
            ),
            SizedBox(height: 20),
            customPadding(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Color(0xff3f134e),
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: _changePassword,
                child: Text(
                  'Change Password'.tr(),
                  style:
                      GoogleFonts.nunitoSans(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
