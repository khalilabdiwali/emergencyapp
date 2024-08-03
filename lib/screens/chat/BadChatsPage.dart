import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';

class BadChatsPage extends StatefulWidget {
  @override
  _BadChatsPageState createState() => _BadChatsPageState();
}

class _BadChatsPageState extends State<BadChatsPage> {
  final DatabaseReference _messagesRef =
      FirebaseDatabase.instance.reference().child('messages');
  List<DataSnapshot> _badMessages = [];
  final List<String> _badWords = [
    "abuse",
    "asshole",
    "bastard",
    "bitch",
    "bollocks",
    "bullshit",
    "crap",
    "cunt",
    "damn",
    "dick",
    "douche",
    "fag",
    "fuck",
    "motherfucker",
    "nigger",
    "piss",
    "prick",
    "shit",
    "slut",
    "whore"
  ];

  @override
  void initState() {
    super.initState();
    _fetchBadMessages();
  }

  void _fetchBadMessages() {
    _messagesRef.once().then((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;
      List<DataSnapshot> messages = [];
      if (snapshot.value != null) {
        Map<dynamic, dynamic> messagesMap =
            snapshot.value as Map<dynamic, dynamic>;
        messagesMap.forEach((key, value) {
          if (value != null && value['text'] is String) {
            String text = value['text'];
            if (_badWords.any((badWord) => text.contains(badWord))) {
              messages.add(snapshot.child(key));
            }
          }
        });
      }
      setState(() {
        _badMessages = messages;
      });
    });
  }

  void _deleteMessage(String messageId) {
    _messagesRef.child(messageId).remove().then((_) {
      setState(() {
        _badMessages.removeWhere((message) => message.key == messageId);
      });
    });
  }

  Future<void> _confirmDeleteMessage(String messageId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this message?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                _deleteMessage(messageId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bad Chats'),
        centerTitle: true,
        //backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: _badMessages.length,
          itemBuilder: (context, index) {
            var message = _badMessages[index].value as Map?;
            String text = message?['text'] as String? ?? 'No text available';
            String messageId = _badMessages[index].key!;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purpleAccent, Colors.deepPurpleAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              text,
                              style: GoogleFonts.openSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete_forever,
                          color: Colors.white,
                        ),
                        tooltip: 'Delete Message',
                        onPressed: () => _confirmDeleteMessage(messageId),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
