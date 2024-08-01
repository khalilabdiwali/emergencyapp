import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';

class AnnouncementSend extends StatefulWidget {
  @override
  AnnouncementSendState createState() => AnnouncementSendState();
}

class AnnouncementSendState extends State<AnnouncementSend> {
  final DatabaseReference _usersRef =
      FirebaseDatabase.instance.ref().child('Users');
  final DatabaseReference _announcementsRef =
      FirebaseDatabase.instance.ref().child('Announcements');
  final TextEditingController _broadcastMessageController =
      TextEditingController();
  String _selectedGroup = 'all';

  // Dropdown menu items
  final List<DropdownMenuItem<String>> _groupDropdownItems = [
    DropdownMenuItem(
        value: 'all',
        child: Text('All Users', style: TextStyle(color: Colors.white))),
    DropdownMenuItem(
        value: 'regular',
        child: Text('Regular Users', style: TextStyle(color: Colors.white))),
    DropdownMenuItem(
        value: 'responders',
        child: Text('Responders (Police, Fire, Traffic, Medical)',
            style: TextStyle(color: Colors.white))),
  ];

  Future<void> sendMessageToGroup(String message, String group) async {
    final announcementKey = _announcementsRef.push().key;
    final DateTime now = DateTime.now();
    final String timestamp =
        '${now.year}-${now.month}-${now.day} ${now.hour}:${now.minute}:${now.second}';

    if (group == 'all') {
      await _announcementsRef.child(announcementKey!).set({
        'message': message,
        'targetGroup': group,
        'timestamp': timestamp,
      });
    } else {
      final usersSnapshot = await _usersRef.get();
      final Map<dynamic, dynamic> users =
          usersSnapshot.value as Map<dynamic, dynamic>;
      final Map<String, dynamic> targetedUsers = {};
      users.forEach((uid, userData) {
        if (group == 'regular' && userData['role'] == 'regular') {
          targetedUsers[uid] = true;
        } else if (group == 'responders' &&
            (userData['role'] == 'police' ||
                userData['role'] == 'fire' ||
                userData['role'] == 'traffic' ||
                userData['role'] == 'medical')) {
          targetedUsers[uid] = true;
        }
      });
      if (targetedUsers.isNotEmpty) {
        await _announcementsRef.child(announcementKey!).set({
          'message': message,
          'targetGroup': group,
          'targetedUsers': targetedUsers,
          'timestamp': timestamp,
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Admin Panel',
              style: GoogleFonts.openSans(color: Colors.white)),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xff3d184c), Color(0xff5e4c64)],
              ),
            ),
          ),
        ),
        body: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xff3d184c), Color(0xff5e4c64)],
            ),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  'Send Announcement',
                  style: GoogleFonts.openSans(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                SizedBox(height: 20),
                DropdownButtonFormField(
                  decoration: InputDecoration(
                    labelText: 'Select User Group',
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  dropdownColor: Color(0xff42275a),
                  value: _selectedGroup,
                  style: TextStyle(color: Colors.white),
                  items: _groupDropdownItems,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedGroup = newValue!;
                    });
                  },
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _broadcastMessageController,
                  maxLines: 3,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Enter your message here",
                    hintStyle: TextStyle(color: Colors.white70),
                    labelText: "Message",
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xff3f134e),
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  onPressed: () {
                    sendMessageToGroup(
                        _broadcastMessageController.text, _selectedGroup);
                    _broadcastMessageController.clear();
                  },
                  child: Text('Send Announcement',
                      style: GoogleFonts.openSans(
                          fontSize: 18, color: Colors.white)),
                ),
              ],
            ),
          ),
        ));
  }
}
