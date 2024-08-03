import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

enum UserRole { regular, traffic }

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  late String userId;
  final databaseReference = FirebaseDatabase.instance.reference();
  Map<String, UserData> userMap = {};
  late UserRole userRole;

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  Future<void> _getUser() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
        userRole = user.email == ''
            ? UserRole.traffic
            : UserRole.regular; // Changed here
      });
      _fetchUsers();
    }
  }

  Future<void> _fetchUsers() async {
    // Find all unique users who have sent a message
    final sentMessagesRef =
        databaseReference.child('messages').orderByChild('senderId');
    final usersRef = databaseReference.child('Users');

    try {
      DatabaseEvent messagesSnapshot = await sentMessagesRef.once();
      Set<String> userIds = {};

      if (messagesSnapshot.snapshot.value != null &&
          messagesSnapshot.snapshot.value is Map) {
        Map<dynamic, dynamic> messages =
            messagesSnapshot.snapshot.value as Map<dynamic, dynamic>;
        messages.forEach((key, value) {
          if (value is Map) {
            String senderId = value['senderId'];
            userIds.add(senderId);
          }
        });

        // For each user who sent a message, check if they are regular
        for (String id in userIds) {
          DatabaseEvent userSnapshot = await usersRef.child(id).once();
          if (userSnapshot.snapshot.value != null &&
              userSnapshot.snapshot.value is Map) {
            final userData =
                userSnapshot.snapshot.value as Map<dynamic, dynamic>;
            // Only add to userMap if the user is a regular
            if (userData['role'] == 'regular') {
              setState(() {
                userMap[id] = UserData(
                  userId: id,
                  name: userData['name'] as String,
                  profileImageUrl: userData['profileImageUrl'] as String,
                );
              });
            }
          }
        }
      }
    } catch (error) {
      print("Error fetching users: $error");
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _navigateToChatView(UserData user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatViewScreen(
          currentUser: userId,
          recipientUser: user,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<UserData> usersList = userMap.values.toList();

    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 20),
          Text(
            'All Messages',
            textAlign: TextAlign.right,
            style: GoogleFonts.nunitoSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          //SizedBox(height: 60),
          usersList.isEmpty
              ? CircularProgressIndicator()
              : Expanded(
                  child: ListView.builder(
                    itemCount: usersList.length,
                    itemBuilder: (context, index) {
                      UserData user = usersList[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(user.profileImageUrl),
                        ),
                        title: Text(user.name),
                        onTap: () => _navigateToChatView(user),
                      );
                    },
                  ),
                ),
          //Divider(height: 1.0),
        ],
      ),
    );
  }
}

class ChatViewScreen extends StatefulWidget {
  final String currentUser;
  final UserData recipientUser;

  ChatViewScreen({required this.currentUser, required this.recipientUser});

  @override
  _ChatViewScreenState createState() => _ChatViewScreenState();
}

class _ChatViewScreenState extends State<ChatViewScreen> {
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FlutterSoundRecorder _soundRecorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _soundPlayer = FlutterSoundPlayer();
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _durationText;
  String? _currentPlayingVoiceUrl;
  late AudioPlayer _audioPlayer;
  late DatabaseReference _messagesRef;

  @override
  void initState() {
    super.initState();
    _initRecorder();
    _messagesRef = _database.reference().child('messages');
    _audioPlayer = AudioPlayer();
    _audioPlayer.onDurationChanged.listen((Duration duration) {
      setState(() {
        _durationText =
            '${duration.inMinutes}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}';
      });
    });
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  @override
  void dispose() {
    if (_isRecording) {
      _soundRecorder.stopRecorder();
    }
    _textController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _initRecorder() async {
    final status = await Permission.microphone.request();
    if (status == PermissionStatus.granted) {
      try {
        await _soundRecorder.openRecorder();
        await _soundRecorder
            .setSubscriptionDuration(Duration(milliseconds: 10));
      } catch (err) {
        print('Error initializing audio recorder: $err');
      }
    } else {
      // Handle microphone permission denied
    }
  }

  Future<void> _sendTextMessage(String text) async {
    if (text.trim().isEmpty) return;
    _messagesRef.push().set({
      'senderId': widget.currentUser,
      'receiverId': widget.recipientUser.userId,
      'timestamp': ServerValue.timestamp,
      'text': text,
      'type': 'text',
    });
    _textController.clear();
  }

  Future<void> _sendImageMessage() async {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      final String fileName =
          'images/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference reference = _storage.ref().child(fileName);
      final UploadTask uploadTask = reference.putFile(File(pickedImage.path));
      await uploadTask.then((TaskSnapshot snapshot) async {
        final String imageUrl = await snapshot.ref.getDownloadURL();
        _messagesRef.push().set({
          'senderId': widget.currentUser,
          'receiverId': widget.recipientUser.userId,
          'timestamp': ServerValue.timestamp,
          'imageUrl': imageUrl,
          'type': 'image',
        });
      }, onError: (e) {
        // Handle errors
      });
    }
  }

  Future<void> _startRecording() async {
    if (_isRecording) return;

    final directory = await getApplicationDocumentsDirectory();
    final filePath =
        '${directory.path}/flutter_sound_${DateTime.now().millisecondsSinceEpoch}.aac';

    try {
      await _soundRecorder.startRecorder(
        toFile: filePath,
        codec: Codec.aacADTS,
        bitRate: 128000,
        numChannels: 1,
        sampleRate: 44100,
      );
      setState(() {
        _isRecording = true;
      });
    } catch (e) {
      print('Error starting recorder: $e');
      // Handle errors here
    }
  }

  Future<void> _stopRecordingAndSend() async {
    if (!_isRecording) return;

    final recordingPath = await _soundRecorder.stopRecorder();
    setState(() {
      _isRecording = false;
    });

    if (recordingPath != null) {
      final String fileName =
          'voices/${DateTime.now().millisecondsSinceEpoch}.aac';
      final Reference reference = _storage.ref().child(fileName);
      final UploadTask uploadTask = reference.putFile(File(recordingPath));
      await uploadTask.then((TaskSnapshot snapshot) async {
        final String voiceUrl = await snapshot.ref.getDownloadURL();
        _messagesRef.push().set({
          'senderId': widget.currentUser,
          'receiverId': widget.recipientUser.userId,
          'timestamp': ServerValue.timestamp,
          'voiceUrl': voiceUrl,
          'type': 'voice',
        });
      }, onError: (e) {
        // Handle errors
      });
    }
  }

  void _playVoiceMessage(String voiceUrl) async {
    if (_isPlaying) {
      await _audioPlayer.stop();
      setState(() {
        _isPlaying = false;
        _currentPlayingVoiceUrl = null;
      });
    }

    setState(() {
      _isPlaying = true;
      _currentPlayingVoiceUrl = voiceUrl;
    });

    await _audioPlayer
        .play(UrlSource(voiceUrl), mode: PlayerMode.mediaPlayer)
        .catchError((error) {
      print('Error during playback: $error');
      setState(() {
        _isPlaying = false;
        _currentPlayingVoiceUrl = null;
      });
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _isPlaying = false;
        _currentPlayingVoiceUrl = null;
      });
    });
  }

  void _deleteMessage(String messageId) {
    _messagesRef.child(messageId).remove();
  }

  Future<void> _sendCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    _messagesRef.push().set({
      'senderId': widget.currentUser,
      'receiverId': widget.recipientUser.userId,
      'timestamp': ServerValue.timestamp,
      'latitude': position.latitude,
      'longitude': position.longitude,
      'type': 'location',
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipientUser.name),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _messagesRef.orderByChild('timestamp').onValue,
              builder: (context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                  return LoadingAnimationWidget.fourRotatingDots(
                    color: theme.colorScheme.secondary,
                    size: 50.0,
                  );
                }

                DataSnapshot dataValues = snapshot.data!.snapshot;
                if (dataValues.value is! Map) {
                  return SizedBox();
                }

                Map<dynamic, dynamic> values =
                    dataValues.value as Map<dynamic, dynamic>;
                List<Map<dynamic, dynamic>> messages = values.entries
                    .map((e) => {...e.value, 'key': e.key})
                    .where((message) =>
                        (message['senderId'] == widget.currentUser &&
                            message['receiverId'] ==
                                widget.recipientUser.userId) ||
                        (message['receiverId'] == widget.currentUser &&
                            message['senderId'] == widget.recipientUser.userId))
                    .toList();

                messages
                    .sort((a, b) => a['timestamp'].compareTo(b['timestamp']));

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    bool isSentByMe = message['senderId'] == widget.currentUser;

                    String formattedTime = DateFormat('hh:mm a').format(
                        DateTime.fromMillisecondsSinceEpoch(
                            message['timestamp']));

                    return Dismissible(
                      key: Key(message['key']),
                      onDismissed: (direction) {
                        _deleteMessage(message['key']);
                      },
                      background: Container(color: Colors.red),
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: Align(
                          alignment: isSentByMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: isSentByMe
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isSentByMe
                                      ? Color.fromARGB(255, 80, 128,
                                          205) // Your custom color
                                      : theme.colorScheme.surface,
                                  borderRadius: BorderRadius.only(
                                    topLeft: isSentByMe
                                        ? Radius.circular(20)
                                        : Radius.circular(0),
                                    topRight: isSentByMe
                                        ? Radius.circular(0)
                                        : Radius.circular(20),
                                    bottomLeft: Radius.circular(20),
                                    bottomRight: Radius.circular(20),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (message['type'] == 'text')
                                      _buildMessageText(
                                        message['text'],
                                        theme.textTheme.bodyText1!.copyWith(
                                          color: isSentByMe
                                              ? Colors.white
                                              : theme.colorScheme.onSurface,
                                        ),
                                      ),
                                    if (message['type'] == 'image')
                                      Image.network(
                                        message['imageUrl'],
                                        width: 200,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      ),
                                    if (message['type'] == 'voice')
                                      _buildVoiceMessage(
                                        voiceUrl: message['voiceUrl'],
                                        isPlaying: _currentPlayingVoiceUrl ==
                                                message['voiceUrl'] &&
                                            _isPlaying,
                                        onPlay: () => _playVoiceMessage(
                                            message['voiceUrl']),
                                        durationText: _currentPlayingVoiceUrl ==
                                                message['voiceUrl']
                                            ? _durationText ?? ''
                                            : '',
                                      ),
                                    if (message['type'] == 'location')
                                      GestureDetector(
                                        onTap: () {
                                          String locationUrl =
                                              'https://www.google.com/maps/search/?api=1&query=${message['latitude']},${message['longitude']}';
                                          _launchURL(locationUrl);
                                        },
                                        child: Text(
                                          'Check out my current location ',
                                          style: TextStyle(
                                            color: Colors
                                                .white, // Change color to white
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    SizedBox(height: 5),
                                    Text(
                                      formattedTime,
                                      style: theme.textTheme.caption!.copyWith(
                                        color: isSentByMe
                                            ? Colors.white.withOpacity(0.6)
                                            : theme.colorScheme.onSurface
                                                .withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Divider(height: 1.0),
          _buildMessageInputBar(context),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
      {required Widget child,
      required Color color,
      required BuildContext context}) {
    return Container(
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  Widget _buildMessageText(String text, TextStyle textStyle) {
    List<String> words = text.split(' ');
    List<Widget> widgets = [];
    for (String word in words) {
      if (word.startsWith('http') || word.startsWith('https')) {
        widgets.add(
          GestureDetector(
            onTap: () {
              _launchURL(word);
            },
            child: Text(
              word,
              style: textStyle.copyWith(color: Colors.blueAccent),
            ),
          ),
        );
      } else {
        widgets.add(Text(word, style: textStyle));
      }
      widgets.add(SizedBox(width: 4));
    }
    return Wrap(children: widgets);
  }

  Widget _buildVoiceMessage(
      {required String voiceUrl,
      required bool isPlaying,
      required VoidCallback onPlay,
      required String durationText}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            isPlaying ? Icons.stop : Icons.play_arrow,
            color: Colors.white,
          ),
          onPressed: onPlay,
        ),
        Text(durationText),
      ],
    );
  }

  Widget _buildMessageInputBar(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(color: theme.colorScheme.background),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.photo, color: theme.iconTheme.color),
            onPressed: _sendImageMessage,
          ),
          if (_isRecording)
            AvatarGlow(
              glowColor: Colors.red,
              child: Material(
                shape: CircleBorder(),
                child: IconButton(
                  icon: Icon(Icons.mic, color: theme.iconTheme.color),
                  onPressed: () {},
                ),
              ),
            ),
          if (!_isRecording)
            IconButton(
              icon: Icon(Icons.mic_none, color: theme.iconTheme.color),
              onPressed: _startRecording,
            ),
          if (_isRecording)
            IconButton(
              icon: Icon(Icons.stop, color: theme.iconTheme.color),
              onPressed: _stopRecordingAndSend,
            ),
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration.collapsed(
                hintText: 'Send a message',
                hintStyle: TextStyle(color: theme.hintColor),
              ),
              style: TextStyle(color: theme.textTheme.bodyText1!.color),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: theme.iconTheme.color),
            onPressed: () => _sendTextMessage(_textController.text),
          ),
          SizedBox(width: 8), // Adjust spacing between buttons
          IconButton(
            icon: Icon(Icons.location_on),
            onPressed: () async {
              Position position = await _determinePosition();
              String locationUrl =
                  'https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}';
              await _sendTextMessage(locationUrl);
            },
          ),
        ],
      ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled.';
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied.';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied, we cannot request permissions.';
    }

    return await Geolocator.getCurrentPosition();
  }
}

class UserData {
  final String userId;
  final String name;
  final String profileImageUrl; // Add this line

  UserData({
    required this.userId,
    required this.name,
    required this.profileImageUrl, // Add this line
  });
}
