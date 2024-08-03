import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms/screens/admin/AdminDashboard.dart';
import 'package:sms/screens/fire/FireDashboard.dart';
import 'package:sms/forms/ForgotPasswordPage.dart';
import 'package:sms/screens/hospital/Hospital.dart';
import 'package:sms/screens/police/PoliceDashboard.dart';
import 'package:sms/screens/police/PolicePage.dart';
import 'package:sms/forms/RegistrationScreen.dart';
import 'package:sms/screens/traffic/TrafficDashboard.dart';
import 'package:sms/screens/common/home.dart';
import 'package:sms/screens/traffic/traffic.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: FutureBuilder(
        future: isLoggedInAndRole(),
        builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          // Check if logged in and then navigate based on role
          if (snapshot.hasData &&
              snapshot.data!['isLoggedIn'] &&
              snapshot.data!['isEmailVerified']) {
            String role = snapshot.data!['role'] ?? '';
            switch (role) {
              case 'admin':
                return AdminDashboard();
              case 'police':
                return PoliceDashboard();
              case 'traffic':
                return Traffic();
              default:
                return Home();
            }
          } else {
            return LoginPage();
          }
        },
      ),
    );
  }

  Future<Map<String, dynamic>> isLoggedInAndRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('loggedIn') ?? false;
    String role = prefs.getString('role') ?? '';
    bool isEmailVerified = prefs.getBool('isEmailVerified') ?? false;
    return {
      'isLoggedIn': isLoggedIn,
      'role': role,
      'isEmailVerified': isEmailVerified
    };
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _loading = false;
  final DatabaseReference _userRef =
      FirebaseDatabase.instance.reference().child('Users');
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    autoLogin();
  }

  void autoLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('loggedIn') ?? false;
    String role = prefs.getString('role') ?? '';
    bool isEmailVerified = prefs.getBool('isEmailVerified') ?? false;
    if (isLoggedIn && isEmailVerified) {
      navigateBasedOnRole(role);
    }
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);
      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _email.trim(),
          password: _password,
        );
        User? user = userCredential.user;
        if (user != null) {
          DatabaseReference userRef = _userRef.child(user.uid);
          DatabaseEvent event = await userRef.once();
          Map<dynamic, dynamic>? userData =
              event.snapshot.value as Map<dynamic, dynamic>?;

          // Check if user data exists in the database
          if (userData == null) {
            await _auth.signOut(); // Sign out the user
            _showErrorDialog(
                "User does not exist. You might have been deleted.");
            return;
          }

          bool isBlocked = userData['isBlocked'] ?? false;
          if (isBlocked) {
            await _auth.signOut();
            _showErrorDialog(
                "Your account is blocked. Please contact support.");
            return;
          }

          if (!user.emailVerified) {
            _showErrorDialog(
                "Your email is not verified. Please check your email inbox for a verification link.");
            return;
          }

          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool('loggedIn', true);
          prefs.setBool('isEmailVerified', true);

          String? role = userData['role'];
          prefs.setString('role', role ?? '');

          navigateBasedOnRole(role);
        } else {
          _showErrorDialog("Login failed. Please try again.");
        }
      } on FirebaseAuthException catch (e) {
        _showErrorDialog(e.message ?? "An error occurred during login.");
      } catch (e) {
        _showErrorDialog("An unexpected error occurred.");
      } finally {
        setState(() => _loading = false);
      }
    }
  }

  void navigateBasedOnRole(String? role) {
    switch (role) {
      case 'admin':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminDashboard()),
        );
        break;
      case 'police':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PoliceDashboard(),
          ),
        );
        break;
      case 'traffic':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => TrafficDashboard()),
        );
        break;
      case 'fire':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FireDashboard()),
        );
        break;
      case 'medical':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HospitaleDashboard()),
        );
        break;
      default:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Login Error'),
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
      body: Stack(children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(
                    'assets/pages/loginbg.png'), // Your background image path
                fit: BoxFit.fill),
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
                      image: AssetImage('assets/logowhite.png'),
                      width: 120,
                      height: 150,
                    ),
                    Text(
                      'Welcome to Gargaar \n Emergency Services'.tr(),
                      style: GoogleFonts.openSans(
                          fontSize: 19, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 50),
                    TextFormField(
                      decoration: InputDecoration(
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
                        labelText: 'Email'.tr(),
                        labelStyle: TextStyle(color: Colors.white),
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color: Color.fromARGB(255, 255, 255, 255),
                          size: 25,
                        ),
                      ),
                      style: GoogleFonts.openSans(color: Colors.white),
                      onChanged: (value) => _email = value,
                      validator: (value) =>
                          value!.isEmpty ? 'Enter an email'.tr() : null,
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      decoration: InputDecoration(
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
                        labelText: 'Password'.tr(),
                        labelStyle: GoogleFonts.openSans(color: Colors.white),
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: Color.fromARGB(255, 255, 255, 255),
                          size: 25,
                        ),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                          child: Icon(
                            _obscureText
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Color.fromARGB(255, 255, 255, 255),
                            size: 25,
                          ),
                        ),
                      ),
                      obscureText: _obscureText,
                      style: GoogleFonts.openSans(color: Colors.white),
                      onChanged: (value) => _password = value,
                      validator: (value) => value!.length < 6
                          ? 'Password must be at least 6 characters'.tr()
                          : null,
                    ),
                    SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.only(left: 200.0),
                      child: TextButton(
                        onPressed: () {
                          // Navigator push logic here, for example:
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ForgotPasswordPage()),
                          );
                        },
                        child: Text(
                          'Forgot Password'.tr(),
                          style: GoogleFonts.openSans(
                              color: Colors.white, fontSize: 15),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _loading ? null : _login,
                      child: _loading
                          ? LoadingAnimationWidget.fourRotatingDots(
                              color: Color.fromARGB(255, 255, 255, 255),
                              size: 50.0,
                            )
                          : Text(
                              'Login'.tr(),
                              style: GoogleFonts.openSans(
                                  color: Color(0xff240b33), fontSize: 19),
                            ),
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromARGB(255, 255, 255, 255),
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => RegistrationScreen()),
                        );
                      },
                      child: Text(
                        "Don't have an account ? SignUp".tr(),
                        style: GoogleFonts.openSans(
                            color: Colors.white, fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
      ]),
    );
  }
}
