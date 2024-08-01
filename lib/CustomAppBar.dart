import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final VoidCallback onPressed;

  CustomAppBar({required this.onPressed});

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  final DatabaseReference _announcementsRef =
      FirebaseDatabase.instance.ref().child('Announcements');
  List<Map<String, String>> _announcements = [];
  String? _userRole;
  int _announcementCount = 0;
  String _appBarTitle = 'Emergency App';

  @override
  void initState() {
    super.initState();
    _fetchUserRole().then((_) {
      _fetchAnnouncements();
    });
  }

  Future<void> _fetchUserRole() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final DatabaseReference userRef =
        FirebaseDatabase.instance.ref().child('Users/${user?.uid}');
    final snapshot = await userRef.get();
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        _userRole = data['role'];
        _setAppBarTitle();
      });
    }
  }

  void _setAppBarTitle() {
    switch (_userRole) {
      case 'police':
        _appBarTitle = 'Police Dashboard';
        break;
      case 'fire':
        _appBarTitle = 'Fire Dashboard';
        break;
      case 'traffic':
        _appBarTitle = 'Traffic Dashboard';
        break;
      case 'medical':
        _appBarTitle = 'Medical Dashboard';
        break;
      default:
        _appBarTitle = 'Emergency App';
    }
  }

  Future<int> _fetchAnnouncements() async {
    final snapshot = await _announcementsRef.get();
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      final List<Map<String, String>> announcements = [];
      data.forEach((key, value) {
        final targetGroup = value['targetGroup'];
        final message = value['message'];
        if (targetGroup == 'all' ||
            (targetGroup == 'regular' && _userRole == 'regular') ||
            (targetGroup == 'responders' &&
                (_userRole == 'police' ||
                    _userRole == 'fire' ||
                    _userRole == 'traffic' ||
                    _userRole == 'medical'))) {
          announcements.add({"message": message, "group": targetGroup});
        }
      });
      setState(() {
        _announcements = announcements;
        _announcementCount = announcements.length;
      });
      return announcements.length;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: IconThemeData(),
      leading: IconButton(
        icon: FaIcon(
          FontAwesomeIcons.barsStaggered,
          size: 25,
          color: Colors.blue,
        ),
        onPressed: () {
          Scaffold.of(context).openDrawer(); // Open the drawer
        },
      ),
      title: Text(
        _appBarTitle.tr(),
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
      actions: [
        Stack(
          children: <Widget>[
            IconButton(
              icon: Icon(
                Icons.notifications,
                size: 32,
                color: Colors.blue,
              ),
              onPressed: widget.onPressed,
              tooltip: 'Notifications',
            ),
            Positioned(
              right: 9,
              top: 3,
              child: Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(6),
                ),
                constraints: BoxConstraints(
                  minWidth: 14,
                  minHeight: 14,
                ),
                child: Text(
                  _announcementCount.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          ],
        ),
      ],
      centerTitle: true,
    );
  }
}
