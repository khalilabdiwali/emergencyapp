import 'dart:async';
import 'dart:io';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms/AboutUsPage.dart';
import 'package:sms/AnnouncementsPage.dart';
import 'package:sms/CustomAppBar.dart';
import 'package:sms/EmergencyAlertsPage.dart';
import 'package:sms/HelpSupportPage.dart';
import 'package:sms/LegalDocumentsScreen.dart';
import 'package:sms/MedicalPage.dart';
import 'package:sms/Policeoffline.dart';
import 'package:sms/SafetyGuide.dart';
import 'package:sms/ThemeProvider.dart';
import 'package:sms/customPadding.dart';
import 'package:sms/firechatscreen.dart';
import 'package:sms/firstaidpage.dart';
import 'package:sms/hospitalchat.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'ChangePasswordScreen.dart';
import 'ChatScreen.dart';
import 'LoginPage.dart';
import 'ProfilePage.dart';
import 'TrafficScreenChat.dart';
import 'gpd.dart';
import 'traffic.dart';
import 'IncidentService.dart';

// bool _iconBool = false;
// IconData _iconLight = Icons.wb_sunny;
// IconData _iconDark = Icons.nights_stay;
// ThemeData _lightTheme = ThemeData(
//   primarySwatch: Colors.amber,
//   brightness: Brightness.light,
// );

// ThemeData _darkTheme = ThemeData(
//   primarySwatch: Colors.red,
//   brightness: Brightness.dark,
// );
int _currentIndex = 0;
// final iconList = <IconData>[
//   Icons.home,
//   Icons.person,
//   FontAwesomeIcons.locationArrow,
//   Icons.settings,
// ];
final FirebaseAuth _auth = FirebaseAuth.instance;

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

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    HomePage(),
    ProfilePage(),
    MapScreen(
      initialPosition: null,
    ),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      //backgroundColor: Colors.grey[200],
      appBar: CustomAppBar(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => AnnouncementViewPage()),
          );
        },
      ),
      drawer: _buildDrawer(),
      body: _pages[
          _currentIndex], // Display the page selected by the navigation bar
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _currentIndex, // Connect the _currentIndex with the bar
        onTap: onTabTapped, // Update the view on item tap
        //backgroundColor: Color.fromARGB(255, 80, 128, 205),
        items: [
          /// Home
          SalomonBottomBarItem(
            icon: Icon(Icons.home_outlined),
            title: Text(
              "Home".tr(),
              style: GoogleFonts.openSans(),
            ),
            selectedColor: Color.fromARGB(255, 80, 128, 205),
          ),

          /// Profile
          SalomonBottomBarItem(
            icon: Icon(Icons.person_outline_outlined),
            title: Text(
              "Profile".tr(),
              style: GoogleFonts.openSans(),
            ),
            selectedColor: Color.fromARGB(255, 80, 128, 205),
          ),

          /// Map
          SalomonBottomBarItem(
            icon: Icon(Icons.location_searching_rounded),
            title: Text(
              "Location".tr(),
              style: GoogleFonts.openSans(),
            ),
            selectedColor: Color.fromARGB(255, 80, 128, 205),
          ),

          /// Settings
          SalomonBottomBarItem(
            icon: Icon(Icons.settings_outlined),
            title: Text(
              "Settings".tr(),
              style: GoogleFonts.openSans(),
            ),
            selectedColor: Color.fromARGB(255, 80, 128, 205),
          ),
        ],
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index; // Update the current index
    });
  }

  Drawer _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(),

          // Assuming UserAccountsDrawerHeader or other widget for account info is here

          ListTile(
            leading: Icon(
              Icons.file_open_outlined,
              // color: Colors.white,
            ),
            title: Text('Add Incident'.tr(),
                style: GoogleFonts.openSans(
                    // color: Colors.white,
                    )),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              // Implement dark mode toggle functionality here
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AddIncidentForm()));
            },
          ),
          ListTile(
            leading: Icon(
              Icons.bug_report,
              // color: Colors.white,
            ),
            title: Text('Report Incidents'.tr(),
                style: GoogleFonts.openSans(
                    // color: Colors.white,
                    )),
            onTap: () {
              Navigator.pop(context); // Close the drawer before navigating
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserIncidentReportView(),
                ),
              );
            },
          ),

          ListTile(
            leading: Icon(
              Icons.language_outlined,
              // color: Colors.white,
            ),
            title: Text('languages'.tr(),
                style: GoogleFonts.openSans(
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
                style: GoogleFonts.openSans(
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
          //       style: GoogleFonts.open(
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
                style: GoogleFonts.openSans(
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
                style: GoogleFonts.openSans(
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
                style: GoogleFonts.openSans(
                    // color: Colors.white,
                    )),
            currentAccountPicture: CircleAvatar(
              backgroundImage: NetworkImage(profileImageUrl),
              // child: Text(
              //   userName.isNotEmpty ? userName[0] : 'U',
              // ),
            ),
            accountEmail: null,
          );
        }
      },
    );
  }
}

class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // appBar: AppBar(
        //   title: Text('Settings', style: GoogleFonts.openSans()),
        //   centerTitle: true,
        //   // backgroundColor: Colors.teal,
        // ),
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
      ),
    );
  }

  // Widget _buildSettingsHeader() {
  //   return Text(
  //     '   Settings'.tr(),
  //     style: GoogleFonts.openSans(
  //       fontSize: 20,
  //     ),
  //   );
  // }

  // Widget _buildNotificationSwitch() {
  //   return ListTile(
  //     title: Text(
  //       'Notifications'.tr(),
  //       style: GoogleFonts.openSans(fontSize: 18),
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
        style: GoogleFonts.openSans(fontSize: 18),
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
        style: GoogleFonts.openSans(fontSize: 18),
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
        style: GoogleFonts.openSans(fontSize: 18),
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
        style: GoogleFonts.openSans(fontSize: 18),
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
        style: GoogleFonts.openSans(fontSize: 18),
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

// class LanguageTile extends StatelessWidget {
//   final Map<String, String> languageMap = {
//     'en': 'English',
//     'af': 'Af-Somali',
//     'ar': 'Arabic',
//     'fr': 'French',
//     'sw': 'Swahili'

//     // Ensure all entries here are also in supportedLocales
//   };

//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       trailing: const Icon(Icons.language_outlined),
//       title: Text('languages'.tr()),
//       onTap: () {
//         _showLanguagePicker(context);
//       },
//     );
//   }

//   void _showLanguagePicker(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return SafeArea(
//           child: ListView(
//             shrinkWrap: true,
//             children: languageMap.entries.map((entry) {
//               return ListTile(
//                 leading: _buildFlag(entry.key),
//                 title: Text(entry.value),
//                 trailing: context.locale.languageCode == entry.key
//                     ? const Icon(Icons.keyboard_arrow_right,
//                         color: Colors.green)
//                     : null,
//                 onTap: () {
//                   var newLocale = Locale(entry
//                       .key); // entry.key should match one of the supported locales
//                   context.setLocale(newLocale);
//                   Navigator.pop(context); // Close the modal bottom sheet
//                 },
//               );
//             }).toList(),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildFlag(String locale) {
//     // You can replace this with actual flag images if you have them
//     switch (locale) {
//       case 'en':
//         return const Icon(Icons.flag);
//       case 'fr':
//         return const Icon(Icons.flag);
//       case 'ar':
//         return const Icon(Icons.flag);
//       case 'af':
//         return const Icon(Icons.flag);
//       case 'sw':
//         return const Icon(Icons.flag);
//       default:
//         return const Icon(Icons.flag);
//     }
//   }
// }

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Text(
              //   'We are ready for you help 😋 ',
              //   style: GoogleFonts.openSansSans(fontSize: 25),
              // ),
              // SizedBox(
              //   height: 8,
              // ),
              _buildServiceRow(
                context,
                images: ['assets/police.gif', 'assets/fire.gif'],
                labels: ['Police'.tr(), 'Fire Fight'.tr()],
                actions: [
                  () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ChatScreen())),
                  () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FireChatScreen())),
                ],
              ),
              SizedBox(height: 15),
              _buildServiceRow(
                context,
                images: ['assets/medical.gif', 'assets/firstaid.gif'],
                labels: ['Medical'.tr(), 'First Aid'.tr()],
                actions: [
                  () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => HospitalChat())),
                  () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => FirstAidPage())),
                ],
              ),
              SizedBox(height: 15),
              _buildServiceRow(
                context,
                images: ['assets/traffic.gif', 'assets/disaster.gif'],
                labels: ['Traffic'.tr(), 'Disasters'.tr()],
                actions: [
                  () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => TrafficChat())),
                  () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SafetyGuide())),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceRow(BuildContext context,
      {required List<String> images,
      required List<String> labels,
      required List<VoidCallback> actions}) {
    assert(images.length == labels.length && labels.length == actions.length,
        'Images, labels, and actions lists must have the same length');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(images.length, (index) {
          return Expanded(
            child: _buildServiceImage(
              context,
              image: images[index],
              label: labels[index],
              onTap: actions[index],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildServiceImage(BuildContext context,
      {required String image, required String label, VoidCallback? onTap}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 18.0, horizontal: 30.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary,
            borderRadius: BorderRadius.circular(10.0),
            // boxShadow: [
            //   BoxShadow(
            //     color: theme.shadowColor.withOpacity(0.3),
            //     spreadRadius: 1,
            //     blurRadius: 0,
            //     offset: Offset(0, 2),
            //   ),
            // ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(image, width: 90, height: 75),
              SizedBox(height: 5),
              Text(label,
                  style: GoogleFonts.openSans(
                    fontSize: 18,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key, required initialPosition}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  LatLng? _currentPosition;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _checkAndRequestLocationPermissions();
    await _getCurrentLocation();
  }

  Future<void> _checkAndRequestLocationPermissions() async {
    var status = await Permission.locationWhenInUse.request();
    if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      return;
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _updateMapLocation();
    });
  }

  void _updateMapLocation() {
    if (_currentPosition != null) {
      _mapController.animateCamera(CameraUpdate.newLatLng(_currentPosition!));
      _markers.add(
        Marker(
          markerId: MarkerId('currentLocation'),
          position: _currentPosition!,
          infoWindow: InfoWindow(
            title: 'Your Current Location',
          ),
        ),
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _updateMapLocation();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          markers: _markers,
          polylines: _polylines,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: false,
          initialCameraPosition: CameraPosition(
            target: _currentPosition ??
                LatLng(5.152149,
                    46.199616), // Fallback to a default location if null
            zoom: 15,
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _updateMapLocation(),
          child: Icon(Icons.location_searching),
        ),
      ),
    );
  }
}

class UserIncidentReportView extends StatelessWidget {
  final FirebaseDatabase database = FirebaseDatabase.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<String> _getUserNameByUid(String uid) async {
    final ref = database.ref('Users/$uid');
    final snapshot = await ref.get();
    if (snapshot.exists) {
      final userData = snapshot.value as Map<dynamic, dynamic>;
      return userData['name'] as String? ?? 'Unknown';
    } else {
      return 'Unknown';
    }
  }

  String _formatTimestamp(int timestamp) {
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    var formatter = DateFormat('yyyy-MM-dd HH:mm'); // Custom format
    return formatter.format(date);
  }

  void _editDescription(
      BuildContext context, String incidentId, String currentDescription) {
    final TextEditingController descriptionController =
        TextEditingController(text: currentDescription);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Description'),
          content: TextField(
            controller: descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter new description',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final newDescription = descriptionController.text;
                database
                    .ref('incidents/$incidentId')
                    .update({'description': newDescription});
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? user = auth.currentUser;
    final String? uid = user?.uid;

    if (uid == null) {
      return Center(child: Text('User not logged in'));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('My Incident Reports'),
        // centerTitle: true,
        // backgroundColor: Color(0xff240b33),
      ),
      body: StreamBuilder(
        stream: database
            .ref('incidents')
            .orderByChild('reportedBy')
            .equalTo(uid)
            .onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return Center(
              child: LoadingAnimationWidget.fourRotatingDots(
                color: Color(0xff240b33),
                size: 50.0,
              ),
            );
          }
          Map<dynamic, dynamic> incidents =
              snapshot.data!.snapshot.value as Map<dynamic, dynamic>? ?? {};
          var filteredIncidents = incidents.entries.toList();

          return customPadding(
            child: ListView.builder(
              itemCount: filteredIncidents.length,
              itemBuilder: (context, index) {
                final entry = filteredIncidents[index];
                final incidentId = entry.key;
                final incidentData = Map<String, dynamic>.from(entry.value);
                final timestamp = incidentData['timestamp'] as int? ??
                    DateTime.now().millisecondsSinceEpoch;
                final reportedByUid =
                    incidentData['reportedBy'] as String? ?? 'Unknown';

                return FutureBuilder<String>(
                  future: _getUserNameByUid(reportedByUid),
                  builder: (context, AsyncSnapshot<String> nameSnapshot) {
                    if (!nameSnapshot.hasData) {
                      return ListTile(title: Text('Loading reporter name...'));
                    }
                    return Card(
                      margin: EdgeInsets.all(10.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              incidentData['type'] ?? 'No Type',
                              style: GoogleFonts.openSans(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                // color: Color(0xff240b33),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              incidentData['description'] ?? 'No Description',
                              style: GoogleFonts.openSans(
                                fontSize: 16,
                                // color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Location: ${incidentData['location'] ?? 'Not specified'}',
                              style: GoogleFonts.openSans(
                                fontSize: 16,
                                // color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Time: ${_formatTimestamp(timestamp)}',
                              style: GoogleFonts.openSans(
                                fontSize: 16,
                                // color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Reported by: ${nameSnapshot.data}',
                              style: GoogleFonts.openSans(
                                fontSize: 16,
                                // color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Status: ${incidentData['status'] ?? 'No Status'}',
                              style: GoogleFonts.openSans(
                                fontSize: 16,
                                // color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  color: Colors.blue,
                                  onPressed: () {
                                    _editDescription(context, incidentId,
                                        incidentData['description'] ?? '');
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user = FirebaseAuth.instance.currentUser;
  DatabaseReference _userRef = FirebaseDatabase.instance.ref().child('Users');
  Map userData = {};
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    if (user != null) {
      DataSnapshot snapshot = await _userRef.child(user!.uid).get();
      if (snapshot.exists) {
        setState(() {
          userData = snapshot.value as Map;
        });
      }
    }
  }

  Future<void> _updateProfileImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        isLoading = true; // Show loading indicator while uploading
      });
      File file = File(image.path);
      try {
        // Upload image to Firebase Storage
        String filePath = 'profileImages/${user!.uid}.png';
        await FirebaseStorage.instance.ref(filePath).putFile(file);
        // Get the download URL
        final String downloadUrl =
            await FirebaseStorage.instance.ref(filePath).getDownloadURL();
        // Update user profile data
        await _userRef
            .child(user!.uid)
            .update({'profileImageUrl': downloadUrl});
        // Refresh user data to reflect the update
        _getUserData();
      } catch (e) {
        print("Error updating profile image: $e");
      } finally {
        setState(() {
          isLoading = false; // Hide loading indicator
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: isLoading
          ? Center(child: CircularProgressIndicator())
          : userData.isNotEmpty
              ? _buildProfileView()
              : Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildProfileView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        _buildAvatar(),
        SizedBox(height: 24),
        _buildInfoSection(),
      ],
    );
  }

  Widget _buildAvatar() {
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: Center(
        child: GestureDetector(
          onTap:
              _updateProfileImage, // User can tap to update their profile image
          child: CircleAvatar(
            radius: 60,
            backgroundImage: NetworkImage(userData['profileImageUrl'] ?? ''),
            backgroundColor: Colors.grey.shade300,
            child: Icon(
              Icons.camera_alt, // Icon to indicate action
              color: Colors.white70,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return customPadding(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _infoTile('Name'.tr(), userData['name'] ?? ''),
          _infoTile('Email'.tr(), userData['email'] ?? ''),
          _infoTile('Phone'.tr(), userData['phoneNumber'] ?? ''),
          _infoTile('Date of Birth'.tr(), userData['dateOfBirth'] ?? ''),
          _infoTile('Home Address'.tr(), userData['homeAddress'] ?? ''),
          _infoTile(
              'Emergency Contact'.tr(), userData['personToContact'] ?? ''),
          _infoTile('Emergency Contact Phone'.tr(),
              userData['contactPersonPhone'] ?? ''),
        ],
      ),
    );
  }

  Widget _infoTile(String title, String subtitle) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(
          title,
          style: GoogleFonts.openSans(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Theme.of(context).textTheme.bodyText1!.color,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.openSans(
            fontSize: 16,
            color: Theme.of(context).textTheme.bodyText2!.color,
          ),
        ),
        tileColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
