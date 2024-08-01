import 'dart:async';
import 'dart:io';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:sms/Policeoffline.dart';
import 'package:sms/home.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

enum UserRole { regular, police }

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  late String userId;
  final databaseReference = FirebaseDatabase.instance.reference();
  List<UserData> userList = [];
  late UserRole userRole;

  @override
  void initState() {
    super.initState();
    _getUser();
    _fetchUsers();
  }

  Future<void> _getUser() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
        userRole = user.email == "police@example.com"
            ? UserRole.police
            : UserRole.regular;
      });
    }
  }

  Future<void> _fetchUsers() async {
    try {
      DatabaseEvent snapshot = await databaseReference.child('Users').once();
      if (snapshot.snapshot.value != null && snapshot.snapshot.value is Map) {
        Map<dynamic, dynamic> values =
            Map<dynamic, dynamic>.from(snapshot.snapshot.value as Map);
        setState(() {
          userList.clear();
          values.forEach((key, value) {
            final userData = UserData(
              userId: key,
              name: value['name'],
              profileImageUrl: value['profileImageUrl'],
            );
            if (value['role'] == 'police' && userRole == UserRole.regular) {
              userList.add(userData);
            } else if (value['role'] == 'regular' &&
                userRole == UserRole.police) {
              userList.add(userData);
            }
          });
        });
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
    return Scaffold(
      // backgroundColor: Color(0xff534159),
      appBar: AppBar(
        title: Text('Police Department', style: GoogleFonts.openSans()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Container(
          //color: Color(0xff543152),
          height: 250,
          width: 450,
          decoration: BoxDecoration(
            color: Color(0xff553253), // Use color here inside decoration
            borderRadius:
                BorderRadius.circular(25), // This applies a border radius of 20
            // You can also specify border radius for each corner separately if needed
          ),

          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              children: [
                ListTile(
                  title: Text('Emergency Offline',
                      style: GoogleFonts.openSans(
                          fontSize: 20, color: Colors.white)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PoliceOffline()),
                    );
                  },
                  trailing: Icon(Icons.call_outlined, color: Colors.white),
                ),
                Divider(color: Colors.grey[300]),
                Expanded(
                  child: userList.isEmpty
                      ? Center(
                          child: LoadingAnimationWidget.fourRotatingDots(
                          color: Color.fromARGB(255, 255, 255, 255),
                          size: 50.0,
                        ))
                      : ListView.separated(
                          itemCount: userList.length + 1,
                          separatorBuilder: (context, index) =>
                              Divider(height: 0.5, color: Colors.grey[300]),
                          itemBuilder: (context, index) {
                            if (index == userList.length) {
                              return ListTile(
                                title: Text('Visit  Website ',
                                    style: GoogleFonts.openSans(
                                        fontSize: 20, color: Colors.white)),
                                onTap: () async {
                                  const url =
                                      'https://police.gov.so/'; // Your website URL here
                                  if (await canLaunch(url)) {
                                    await launch(url);
                                  } else {
                                    throw 'Could not launch $url';
                                  }
                                },
                                trailing:
                                    Icon(Icons.public, color: Colors.white),
                              );
                            } else {
                              return ListTile(
                                title: Text(userList[index].name,
                                    style: GoogleFonts.openSans(
                                        fontSize: 20, color: Colors.white)),
                                // leading: CircleAvatar(
                                //     backgroundImage: NetworkImage(
                                //         userList[index].profileImageUrl)),
                                onTap: () =>
                                    _navigateToChatView(userList[index]),
                                trailing: Icon(Icons.chat, color: Colors.white),
                              );
                            }
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
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
  final PlayerController _playerController = PlayerController();

  bool _isRecording = false;
  bool _isPlaying = false;
  String? _durationText;
  String? _currentPlayingVoiceUrl;
  late AudioPlayer _audioPlayer;
  late DatabaseReference _messagesRef;
  Timer? _durationTimer;

  bool _locationSent = false;

  @override
  void initState() {
    super.initState();
    _initRecorder();
    _messagesRef = _database.reference().child('messages');
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    if (_isRecording) {
      _soundRecorder.stopRecorder();
    }
    _textController.dispose();
    _audioPlayer.dispose();
    _durationTimer?.cancel();
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
    if (!_locationSent) {
      await _sendCurrentLocation();
      _locationSent = true;
    }
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
        if (!_locationSent) {
          await _sendCurrentLocation();
          _locationSent = true;
        }
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
        if (!_locationSent) {
          await _sendCurrentLocation();
          _locationSent = true;
        }
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
      _durationTimer?.cancel();
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
      _durationTimer?.cancel();
    });

    Duration duration = await _audioPlayer.getDuration() ?? Duration.zero;
    _durationText = _formatDuration(duration);

    _durationTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (duration.inSeconds > 0) {
        duration = Duration(seconds: duration.inSeconds - 1);
        setState(() {
          _durationText = _formatDuration(duration);
        });
      } else {
        timer.cancel();
      }
    });
  }

  void stopPlaying() async {
    if (_isPlaying) {
      await _audioPlayer.stop();
      _durationTimer?.cancel(); // Cancel the timer if it's running
      setState(() {
        _isPlaying = false;
        _currentPlayingVoiceUrl = null;
        _durationText = null; // Reset the duration text if needed
      });
    }
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
        title: Row(
          children: <Widget>[
            CircleAvatar(
              backgroundImage:
                  NetworkImage(widget.recipientUser.profileImageUrl),
              radius: 20,
            ),
            SizedBox(width: 10),
            Text(widget.recipientUser.name),
          ],
        ),
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
                                  color: message['type'] == 'text'
                                      ? (isSentByMe
                                          ? Color(0xff753b63)
                                          : Color(0xff6a7e7f))
                                      : Colors
                                          .transparent, // Color based on message type and sender
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
                                          color: Colors.white,
                                        ),
                                      ),
                                    if (message['type'] == 'image')
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(context,
                                              MaterialPageRoute(builder: (_) {
                                            return DetailScreen(
                                                url: message['imageUrl']);
                                          }));
                                        },
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                              10), // Specify the radius here
                                          child: Image.network(
                                            message['imageUrl'],
                                            width: 200,
                                            height: 250,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
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
                                    // if (message['type'] == 'location')
                                    //   _buildLocationMessage(
                                    //       message, isSentByMe, theme),
                                    SizedBox(height: 5),
                                    Text(formattedTime,
                                        style: TextStyle(
                                            color: message['type'] == 'text'
                                                ? Colors.white
                                                : Colors
                                                    .black, // Conditional color
                                            fontSize: 12)),
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
              style: textStyle.copyWith(color: Colors.white),
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

  Widget _buildVoiceMessage({
    required String voiceUrl,
    required bool isPlaying,
    required VoidCallback onPlay,
    required String durationText,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(0),
          bottomLeft: Radius.circular(20.0),
          bottomRight: Radius.circular(20.0),
          topLeft: Radius.circular(20.0),
        ),
        color: isPlaying ? Color(0xff753b63) : Colors.grey[400],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Play/Stop Button
            IconButton(
              icon: Icon(
                isPlaying ? Icons.stop : Icons.play_arrow,
                color: Colors.white,
              ),
              onPressed: () {
                if (isPlaying) {
                  stopPlaying();
                } else {
                  onPlay();
                }
              },
            ),
            // Progress Indicator
            Expanded(
              child: LinearProgressIndicator(
                value: isPlaying ? null : 0, // Continuous when playing
                backgroundColor: Colors.deepPurple[
                    300], // Restored background color for visibility
                valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white), // Active color of the progress bar
              ),
            ),
            SizedBox(
                width:
                    10), // Spacing between the progress bar and the duration text
            // Duration Text
            Text(
              durationText,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationMessage(
      Map<dynamic, dynamic> message, bool isSentByMe, ThemeData theme) {
    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(12.0),
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSentByMe ? Colors.blue : Colors.green),
        ),
        child: Column(
          crossAxisAlignment:
              isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              'Location shared',
              style: TextStyle(
                color: isSentByMe ? Colors.blue : Colors.green,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Lat: ${message['latitude']}, Lng: ${message['longitude']}',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () {
                String locationUrl =
                    'https://www.google.com/maps/search/?api=1&query=${message['latitude']},${message['longitude']}';
                _launchURL(locationUrl);
              },
              child: Text(
                'View on map',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('hh:mm a').format(
                DateTime.fromMillisecondsSinceEpoch(
                  message['timestamp'],
                ),
              ),
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
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

  Future<Position> _determinePosition() async {
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

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  String _formatDuration(Duration duration) {
    return '${duration.inMinutes}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}';
  }
}

class UserData {
  final String userId;
  final String name;
  final String profileImageUrl;

  UserData({
    required this.userId,
    required this.name,
    required this.profileImageUrl,
  });
}

class DetailScreen extends StatelessWidget {
  final String url;

  DetailScreen({required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Image'),
      ),
      body: Container(
        child: PhotoView(
          imageProvider: NetworkImage(url),
          backgroundDecoration: BoxDecoration(color: Colors.white),
        ),
      ),
    );
  }
}
