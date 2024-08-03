import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sms/screens/admin/AdminDashboardView.dart';
import 'package:sms/screens/admin/AdminPage.dart';
import 'package:sms/screens/announcement/Announcement.dart';
import 'package:sms/screens/chat/ChatScreen.dart';
import 'package:sms/screens/hospital/HealthInfoForm.dart';
import 'package:sms/incident/IncidentList.dart';
import 'package:sms/incident/IncidentService.dart';
import 'package:sms/screens/responder/Responders.dart';
import 'package:sms/screens/responder/RespondersDashboardView.dart';
import 'package:sms/screens/common/home.dart';

class HospitaleDashboard extends StatefulWidget {
  @override
  _HospitaleDashboardState createState() => _HospitaleDashboardState();
}

class _HospitaleDashboardState extends State<HospitaleDashboard> {
  int _selectedIndex = 0; // Default selected index for bottom nav

  static final List<Widget> _widgetOptions = <Widget>[
    RespondersDashboardView(),
    ProfilePage(),
    // ChatScreen(),
    IncidentReportView(),
    SettingsPage(), // Ensure this is defined or imported correctly
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Hospitale Dashboard',
            style: GoogleFonts.nunitoSans(fontSize: 25)),
        centerTitle: true,
      ),
      drawer: _buildDrawer(context),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home_outlined,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person_outlined,
            ),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.report_outlined,
            ),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.settings_outlined,
            ),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.black,
        backgroundColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(),

          // Assuming UserAccountsDrawerHeader or other widget for account info is here
          ListTile(
            leading: Icon(
              Icons.settings,
              // color: Colors.white,
            ),
            title: Text('settings'.tr(),
                style: GoogleFonts.nunito(
                    // color: Colors.white,
                    )),
            onTap: () {
              Navigator.pop(context); // Close the drawer before navigating
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => SettingsPage()),
              // );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.add,
              // color: Colors.white,
            ),
            title: Text('Add Incident'.tr(),
                style: GoogleFonts.nunito(
                    // color: Colors.white,
                    )),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AddIncidentForm()));
            },
          ),
          ListTile(
            leading: Icon(
              Icons.policy,
              // color: Colors.white,
            ),
            title: Text('HealthInfoForm'.tr(),
                style: GoogleFonts.nunito(
                    // color: Colors.white,
                    )),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              // Navigate to your policy page
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => HealthInfoForm()));
            },
          ),
          // ListTile(
          //   leading: Icon(
          //     Icons.language_outlined,
          //     color: Colors.white,
          //   ),
          //   title: Text('languages'.tr(),
          //       style: GoogleFonts.nunito(
          //         color: Colors.white,
          //       )),
          //   trailing: DropdownButton<String>(
          //     value: context.locale.languageCode,
          //     onChanged: (String? newValue) {
          //       if (newValue != null) {
          //         context.setLocale(Locale(newValue));
          //       }
          //     },
          //     items: [
          //       Locale('en'),
          //       Locale('fr'),
          //     ].map<DropdownMenuItem<String>>((Locale locale) {
          //       return DropdownMenuItem<String>(
          //         value: locale.languageCode,
          //         child: Text(locale.languageCode.toUpperCase()),
          //       );
          //     }).toList(),
          //   ),
          // ),
          ListTile(
            leading: Icon(
              Icons.info_rounded,
              // color: Colors.white,
            ),
            title: Text('about'.tr(),
                style: GoogleFonts.nunito(
                    // color: Colors.white,
                    )),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              // Navigate to your about page
            },
          ),
          // Additional drawer items...
        ],
      ),
    );
  }

  FutureBuilder<DataSnapshot> _buildDrawerHeader() {
    return FutureBuilder<DataSnapshot>(
      future: FirebaseDatabase.instance
          .ref('Users/${FirebaseAuth.instance.currentUser?.uid}')
          .get(),
      builder: (BuildContext context, AsyncSnapshot<DataSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          String userName = 'No Name'.tr();
          String profileImageUrl = 'https://via.placeholder.com/150';

          if (snapshot.hasData && snapshot.data?.value != null) {
            var userData = snapshot.data!.value as Map<dynamic, dynamic>;
            userName = userData['name'] ?? 'No Name'.tr();
            profileImageUrl = userData['profileImageUrl'] ??
                'https://via.placeholder.com/150';
          }

          return UserAccountsDrawerHeader(
            accountName: Text(userName,
                style: GoogleFonts.nunito(
                    // color: Colors.white,
                    )),
            currentAccountPicture: CircleAvatar(
              backgroundImage: NetworkImage(profileImageUrl),
              child: Text(
                userName.isNotEmpty ? userName[0] : 'U',
              ),
            ),
            accountEmail: null,
          );
        }
      },
    );
  }
}
