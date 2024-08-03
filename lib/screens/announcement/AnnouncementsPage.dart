import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnnouncementViewPage extends StatefulWidget {
  @override
  _AnnouncementViewPageState createState() => _AnnouncementViewPageState();
}

class _AnnouncementViewPageState extends State<AnnouncementViewPage> {
  final DatabaseReference _announcementsRef =
      FirebaseDatabase.instance.ref().child('Announcements');
  List<Map<String, dynamic>> _announcements = [];
  Set<int> _selectedAnnouncements = Set<int>();
  bool _selectAll = false;
  String? _userRole;
  Set<String> _deletedAnnouncementIds = Set<String>();

  @override
  void initState() {
    super.initState();
    _fetchUserRole().then((_) {
      _loadDeletedAnnouncementIds().then((_) {
        _fetchAnnouncements();
      });
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
      });
    }
  }

  Future<void> _loadDeletedAnnouncementIds() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _deletedAnnouncementIds =
        Set<String>.from(prefs.getStringList('deletedAnnouncements') ?? []);
  }

  Future<void> _saveDeletedAnnouncementIds() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        'deletedAnnouncements', _deletedAnnouncementIds.toList());
  }

  Future<int> _fetchAnnouncements() async {
    final snapshot = await _announcementsRef.get();
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      final List<Map<String, dynamic>> announcements = [];
      data.forEach((key, value) {
        if (!_deletedAnnouncementIds.contains(key)) {
          final targetGroup = value['targetGroup'];
          final message = value['message'];
          final timestamp = value['timestamp'];
          if (targetGroup == 'all' ||
              (targetGroup == 'regular' && _userRole == 'regular') ||
              (targetGroup == 'responders' &&
                  (_userRole == 'police' ||
                      _userRole == 'fire' ||
                      _userRole == 'traffic' ||
                      _userRole == 'medical'))) {
            announcements.add({
              "id": key,
              "message": message,
              "group": targetGroup,
              "timestamp": timestamp,
            });
          }
        }
      });
      setState(() {
        _announcements = announcements;
      });
    }
    return _announcements.length;
  }

  void _toggleSelectAll() {
    setState(() {
      _selectAll = !_selectAll;
      if (_selectAll) {
        _selectedAnnouncements = Set.from(
            Iterable.generate(_announcements.length, (index) => index));
      } else {
        _selectedAnnouncements.clear();
      }
    });
  }

  void _deleteSelected() {
    setState(() {
      _selectedAnnouncements.forEach((index) {
        _deletedAnnouncementIds.add(_announcements[index]['id']);
      });
      _announcements.removeWhere((element) =>
          _selectedAnnouncements.contains(_announcements.indexOf(element)));
      _saveDeletedAnnouncementIds();
      _selectedAnnouncements.clear();
      _selectAll = false;
    });
  }

  Widget _announcementCard(int index) {
    final announcement = _announcements[index];
    IconData iconData;
    Color iconColor;

    switch (announcement['group']) {
      case 'regular':
        iconData = Icons.person_outline;
        iconColor = Colors.blue;
        break;
      case 'responders':
        iconData = Icons.local_hospital;
        iconColor = Colors.red;
        break;
      default:
        iconData = Icons.public;
        iconColor = Colors.green;
        break;
    }

    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: ListTile(
        leading: Icon(iconData, color: iconColor),
        title: Text(
          announcement['message'] ?? "No message",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Group: ${announcement['group'] ?? "All"}",
                style: TextStyle(color: Colors.white)),
            SizedBox(height: 5),
            Text("Date And Time : ${announcement['timestamp'] ?? "Unknown"}",
                style: TextStyle(color: Colors.white)),
          ],
        ),
        trailing: Checkbox(
          value: _selectedAnnouncements.contains(index),
          onChanged: (bool? selected) {
            setState(() {
              if (selected ?? false) {
                _selectedAnnouncements.add(index);
              } else {
                _selectedAnnouncements.remove(index);
              }
            });
          },
        ),
        tileColor: Color(0xffb55f92),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Announcements',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon:
                Icon(_selectAll ? Icons.select_all : Icons.select_all_outlined),
            onPressed: _toggleSelectAll,
          ),
          IconButton(
            icon: Icon(Icons.delete_outline),
            onPressed: _deleteSelected,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xff6a5f6d), Color(0xff42214f)],
          ),
        ),
        child: ListView.builder(
          padding: EdgeInsets.all(10),
          itemCount: _announcements.length,
          itemBuilder: (context, index) {
            return _announcementCard(index);
          },
        ),
      ),
    );
  }
}
