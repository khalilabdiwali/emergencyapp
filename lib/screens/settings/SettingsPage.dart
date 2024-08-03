import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms/screens/about/AboutUsPage.dart';
import 'package:sms/forms/ChangePasswordScreen.dart';
import 'package:sms/forms/LoginPage.dart';
import 'package:sms/screens/Theme/ThemeProvider.dart';
import 'package:sms/screens/common/home.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: GoogleFonts.nunitoSans()),
        // centerTitle: true,
        // backgroundColor: Colors.teal,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        children: [
          // _buildSettingsHeader(),
          // _buildNotificationSwitch(),
          _buildDarkModeSwitch(context),
          _buildChangePasswordTile(context),
          _buildLanguageTile(context),
          _buildAboutUsTile(context),
          _buildLogoutTile(context),
        ],
      ),
    );
  }

  // Widget _buildSettingsHeader() {
  //   return Text(
  //     '   Settings'.tr(),
  //     style: GoogleFonts.nunitoSans(
  //       fontSize: 20,
  //     ),
  //   );
  // }

  // Widget _buildNotificationSwitch() {
  //   return ListTile(
  //     title: Text(
  //       'Notifications'.tr(),
  //       style: GoogleFonts.nunitoSans(fontSize: 18),
  //     ),
  //     trailing: Switch(
  //       value: false, // Example switch value
  //       onChanged: (bool value) {
  //         // Handle switch state change
  //       },
  //     ),
  //   );
  // }

  Widget _buildDarkModeSwitch(BuildContext context) {
    return ListTile(
      title: Text(
        'Dark Mode'.tr(),
        style: GoogleFonts.nunitoSans(fontSize: 18),
      ),
      trailing: Switch(
        value: Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark,
        onChanged: (value) {
          Provider.of<ThemeProvider>(context, listen: false).toggleTheme(value);
        },
        activeTrackColor: Colors.teal.withOpacity(0.5),
        activeColor: Colors.teal,
        inactiveTrackColor: Colors.grey.withOpacity(0.3),
        inactiveThumbColor: Colors.grey,
      ),
    );
  }

  Widget _buildChangePasswordTile(BuildContext context) {
    return ListTile(
      title: Text(
        'Change Password'.tr(),
        style: GoogleFonts.nunitoSans(fontSize: 18),
      ),
      trailing: Icon(Icons.keyboard_arrow_right),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChangePasswordScreen()),
        );
      },
    );
  }

  Widget _buildLanguageTile(BuildContext context) {
    return ListTile(
      title: Text(
        'Languages'.tr(),
        style: GoogleFonts.nunitoSans(fontSize: 18),
      ),
      trailing: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          icon: Icon(Icons.keyboard_arrow_right, color: Colors.teal),
          value: context.locale.languageCode,
          onChanged: (String? newValue) {
            if (newValue != null) {
              context.setLocale(Locale(newValue));
            }
          },
          items: [
            Locale('en'),
            Locale('ar'),
            Locale('af'),
          ].map<DropdownMenuItem<String>>((Locale locale) {
            return DropdownMenuItem<String>(
              value: locale.languageCode,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Image.asset(
                    'assets/flags/${locale.languageCode}.png', // Adjust the path as necessary
                    width: 24,
                    height: 16,
                  ),
                  SizedBox(width: 8),
                  Text(
                    locale.languageCode.toUpperCase(),
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            );
          }).toList(),
          dropdownColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildAboutUsTile(BuildContext context) {
    return ListTile(
      title: Text(
        'About Us'.tr(),
        style: GoogleFonts.nunitoSans(fontSize: 18),
      ),
      trailing: Icon(Icons.keyboard_arrow_right),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AboutUsPage()),
        );
      },
    );
  }

  Widget _buildLogoutTile(BuildContext context) {
    return ListTile(
      title: Text(
        'Logout'.tr(),
        style: GoogleFonts.nunitoSans(fontSize: 18),
      ),
      trailing: Icon(Icons.exit_to_app),
      onTap: () => _logout(context),
    );
  }

  Future<void> _logout(BuildContext context) async {
    // Sign out from FirebaseAuth
    await FirebaseAuth.instance.signOut();

    // Clear user session data from SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('loggedIn', false);
    await prefs.remove('role'); // Assuming you're storing the user's role

    // Navigate to the login page and remove all routes behind it
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
      (Route<dynamic> route) => false,
    );
  }
}
