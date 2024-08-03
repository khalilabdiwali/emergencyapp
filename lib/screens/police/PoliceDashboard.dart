import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:sms/screens/about/AboutUsPage.dart';
import 'package:sms/screens/admin/AdminDashboardView.dart';
import 'package:sms/screens/admin/AdminPage.dart';
import 'package:sms/screens/announcement/Announcement.dart';
import 'package:sms/screens/announcement/AnnouncementsPage.dart';
import 'package:sms/screens/chat/ChatScreen.dart';
import 'package:sms/components/CustomAppBar.dart';
import 'package:sms/screens/hospital/HealthInfoForm.dart';
import 'package:sms/screens/Support/HelpSupportPage.dart';
import 'package:sms/incident/IncidentList.dart';
import 'package:sms/incident/IncidentService.dart';
import 'package:sms/screens/Support/LegalDocumentsScreen.dart';
import 'package:sms/screens/responder/Responders.dart';
import 'package:sms/screens/responder/RespondersDashboardView.dart';
import 'package:sms/screens/common/home.dart';

class PoliceDashboard extends StatefulWidget {
  @override
  _PoliceDashboardState createState() => _PoliceDashboardState();
}

class _PoliceDashboardState extends State<PoliceDashboard> {
  int _selectedIndex = 0; // Default selected index for bottom nav

  static final List<Widget> _widgetOptions = <Widget>[
    RespondersDashboardView(),
    ProfilePage(),
    // ChatScreen(),
    // IncidentReportView(),
    // SettingsPage(), // Ensure this is defined or imported correctly
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
      appBar: CustomAppBar(onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => AnnouncementViewPage()),
        );
      }),
      drawer: _buildDrawer(context),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _selectedIndex, // Connect the _currentIndex with the bar
        onTap: _onItemTapped, // Update the view on item tap
        // backgroundColor: Color(0xffe6e7e9), // Add background color
        items: [
          /// Home
          SalomonBottomBarItem(
            icon: Icon(Icons.home_outlined),
            title: Text("Home"),
            selectedColor: Color.fromARGB(255, 80, 128, 205),
          ),

          /// Profile
          SalomonBottomBarItem(
            icon: Icon(Icons.person_outline_outlined),
            title: Text("Profile"),
            selectedColor: Color.fromARGB(255, 80, 128, 205),
          ),

          /// Map
          // SalomonBottomBarItem(
          //   icon: Icon(Icons.file_copy_outlined),
          //   title: Text("Incidents"),
          //   selectedColor: Color.fromARGB(255, 80, 128, 205),
          // ),

          // /// Settings
          // SalomonBottomBarItem(
          //   icon: Icon(Icons.settings_outlined),
          //   title: Text("Settings"),
          //   selectedColor: Color.fromARGB(255, 80, 128, 205),
          // ),
        ],
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
          // ListTile(
          //   leading: Icon(
          //     Icons.settings,
          //     // color: Colors.white,
          //   ),
          //   title: Text('settings'.tr(),
          //       style: GoogleFonts.nunito(
          //           // color: Colors.white,
          //           )),
          //   onTap: () {
          //     Navigator.pop(context); // Close the drawer before navigating
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => SettingsPage()),
          //     );
          //   },
          // ),
          // ListTile(
          //   leading: Icon(
          //     Icons.file_open_outlined,
          //     // color: Colors.white,
          //   ),
          //   title: Text('Add Incident'.tr(),
          //       style: GoogleFonts.nunito(
          //           // color: Colors.white,
          //           )),
          //   onTap: () {
          //     Navigator.pop(context); // Close the drawer
          //     // Implement dark mode toggle functionality here
          //     Navigator.push(context,
          //         MaterialPageRoute(builder: (context) => AddIncidentForm()));
          //   },
          // ),

          ListTile(
            leading: Icon(
              Icons.language_outlined,
              // color: Colors.white,
            ),
            title: Text('languages'.tr(),
                style: GoogleFonts.nunito(
                    // color: Colors.white,
                    )),
            trailing: DropdownButton<String>(
              value: context.locale.languageCode,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  context.setLocale(Locale(newValue));
                }
              },
              items: [
                Locale('en'),
                // Locale('es'),
                // Locale('fr'),
                // Locale('de'),
                Locale('ar'),
                // Locale('sw'),
                Locale('af')
              ].map<DropdownMenuItem<String>>((Locale locale) {
                return DropdownMenuItem<String>(
                  value: locale.languageCode,
                  child: Text(locale.languageCode.toUpperCase()),
                );
              }).toList(),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.help_outlined,
              // color: Colors.white,
            ),
            title: Text('Help and Support'.tr(),
                style: GoogleFonts.nunito(
                    // color: Colors.white,
                    )),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => HelpSupportPage()));
              // Navigate to your policy page
            },
          ),
          // ListTile(
          //   leading: Icon(
          //     Icons.help_outlined,
          //     // color: Colors.white,
          //   ),
          //   title: Text('Emergency Alerts'.tr(),
          //       style: GoogleFonts.nunito(
          //           // color: Colors.white,
          //           )),
          //   onTap: () {
          //     Navigator.pop(context); // Close the drawer
          //     Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //             builder: (context) => EmergencyAlertsPage()));
          //     // Navigate to your policy page
          //   },
          // ),
          ListTile(
            leading: Icon(
              Icons.privacy_tip_outlined,
              // color: Colors.white,
            ),
            title: Text('Privacy'.tr(),
                style: GoogleFonts.nunito(
                    // color: Colors.white,
                    )),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LegalDocumentsScreen()));
              // Navigate to your policy page
            },
          ),
          ListTile(
            leading: Icon(
              Icons.privacy_tip_outlined,
              // color: Colors.white,
            ),
            title: Text('About Us'.tr(),
                style: GoogleFonts.nunito(
                    // color: Colors.white,
                    )),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AboutUsPage()));
              // Navigate to your policy page
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
