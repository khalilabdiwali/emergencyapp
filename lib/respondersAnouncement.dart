import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:sms/customPadding.dart';

class RespondersAnnouncementSend extends StatefulWidget {
  @override
  RespondersAnnouncementSendState createState() =>
      RespondersAnnouncementSendState();
}

class RespondersAnnouncementSendState
    extends State<RespondersAnnouncementSend> {
  final DatabaseReference _usersRef =
      FirebaseDatabase.instance.ref().child('Users');
  final DatabaseReference _announcementsRef =
      FirebaseDatabase.instance.ref().child('Announcements');
  final TextEditingController _broadcastMessageController =
      TextEditingController();
  String _selectedGroup = 'regular';

  // Dropdown menu items
  final List<DropdownMenuItem<String>> _groupDropdownItems = [
    DropdownMenuItem(
        value: 'regular',
        child: Text(
          'Regular Users',
          style: TextStyle(color: Colors.white),
        )),
  ];

  Future<void> sendMessageToGroup(String message, String group) async {
    final announcementKey = _announcementsRef.push().key;
    if (group == 'regular') {
      final usersSnapshot = await _usersRef.get();
      final Map<dynamic, dynamic> users =
          usersSnapshot.value as Map<dynamic, dynamic>;
      final Map<String, dynamic> targetedUsers = {};
      users.forEach((uid, userData) {
        if (userData['role'] == 'regular') {
          targetedUsers[uid] = true;
        }
      });
      if (targetedUsers.isNotEmpty) {
        final DateTime now = DateTime.now();
        await _announcementsRef.child(announcementKey!).set({
          'message': message,
          'targetGroup': group,
          'targetedUsers': targetedUsers,
          'timestamp': now.toIso8601String(), // Add timestamp here
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Announcement Sender'),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xff6a5f6d), Color(0xff42214f)],
            ),
          ),
          child: customPadding(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Send Announcement',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                DropdownButtonFormField(
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
                    labelText: 'Select User Group',
                    labelStyle: TextStyle(color: Colors.white),

                    // border: OutlineInputBorder(),
                  ),
                  value: _selectedGroup,
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
                    hintText: "Enter your message here",
                    hintStyle: TextStyle(color: Colors.white),
                    labelText: "Message",
                    labelStyle: TextStyle(color: Colors.white),

                    // border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    sendMessageToGroup(
                        _broadcastMessageController.text, _selectedGroup);
                    _broadcastMessageController.clear();
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xff300030),
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text(
                    'Send Announcement',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
