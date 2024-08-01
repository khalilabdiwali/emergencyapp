import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _email = '';
  bool _loading = false;

  void _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);
      try {
        await _auth.sendPasswordResetEmail(email: _email.trim());
        _showSuccessDialog('Password Reset Email Sent');
      } catch (e) {
        _showErrorDialog(e.toString());
      } finally {
        setState(() => _loading = false);
      }
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Success'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   title: Text('Forgot Password'.tr()),
        // ),
        body: Stack(children: [
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
            padding: EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image(
                    image: AssetImage('assets/glogo.png'),
                    width: 120,
                    height: 150,
                  ),
                  Text(
                    'Reset Your Password'.tr(),
                    style:
                        GoogleFonts.openSans(fontSize: 19, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 50),
                  TextFormField(
                    style: GoogleFonts.openSans(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Email'.tr(),
                      labelStyle: GoogleFonts.openSans(color: Colors.white),
                      prefixIcon: Icon(
                        Icons.person_outline,
                        color: Color.fromARGB(255, 255, 255, 255),
                        size: 25,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    onChanged: (value) => _email = value,
                    validator: (value) =>
                        value!.isEmpty ? 'Enter an email'.tr() : null,
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _loading ? null : _resetPassword,
                    child: _loading
                        ? LoadingAnimationWidget.fourRotatingDots(
                            color: Color.fromARGB(255, 255, 255, 255),
                            size: 50.0)
                        : Text(
                            'Reset Password'.tr(),
                            style: GoogleFonts.openSans(
                                color: Color(0xff3f134e), fontSize: 19),
                          ),
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromARGB(255, 255, 255, 255),
                      minimumSize: Size(double.infinity, 50),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ]));
  }
}
