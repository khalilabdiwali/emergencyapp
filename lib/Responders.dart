import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sms/AddUserPage.dart'; // Ensure this page is implemented for adding users
import 'package:sms/customPadding.dart';

class AppUser {
  final String uid;
  final String name;
  final String email;
  final String phoneNumber;
  final String dateOfBirth;
  final String homeAddress;
  final String personToContact;
  final String contactPersonPhone;
  final String profileImageUrl;
  final String role;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.dateOfBirth,
    required this.homeAddress,
    required this.personToContact,
    required this.contactPersonPhone,
    required this.profileImageUrl,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth,
      'homeAddress': homeAddress,
      'personToContact': personToContact,
      'contactPersonPhone': contactPersonPhone,
      'profileImageUrl': profileImageUrl,
      'role': role,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      dateOfBirth: map['dateOfBirth'] ?? '',
      homeAddress: map['homeAddress'] ?? '',
      personToContact: map['personToContact'] ?? '',
      contactPersonPhone: map['contactPersonPhone'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
      role: map['role'] ?? '',
    );
  }
}

class RespondersPage extends StatefulWidget {
  @override
  _RespondersPageState createState() => _RespondersPageState();
}

class _RespondersPageState extends State<RespondersPage> {
  final DatabaseReference _usersRef =
      FirebaseDatabase.instance.ref().child('Users');
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Future<void> deleteUser(String userId) async {
    try {
      await _usersRef.child(userId).remove();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Responder deleted successfully')));
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete user: $error')));
    }
  }

  Future<void> editUser(String userId, String newName, String newEmail) async {
    print('Call Cloud Function to update user in Firebase Authentication');
    await _usersRef.child(userId).update({'name': newName, 'email': newEmail});
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('User updated successfully')));
  }

  void _displayEditUserDialog(AppUser user) {
    final TextEditingController nameController =
        TextEditingController(text: user.name);
    final TextEditingController emailController =
        TextEditingController(text: user.email);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: "Name")),
              TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: "Email")),
            ],
          ),
          actions: <Widget>[
            TextButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.of(context).pop()),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                editUser(user.uid, nameController.text, emailController.text);
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
        actions: [
          IconButton(
            icon: Icon(Icons.add_outlined),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => RegistrationScreen())),
          ),
        ],
        title: Text('Manage Responders'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xff6a5f6d), Color(0xff42214f)],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search by name or email',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(width: 0, style: BorderStyle.none),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  filled: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 0),
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value.toLowerCase().trim());
                },
              ),
            ),
            Expanded(
              child: customPadding(
                child: StreamBuilder(
                  stream: _usersRef.onValue,
                  builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                    if (snapshot.hasData &&
                        !snapshot.hasError &&
                        snapshot.data!.snapshot.value != null) {
                      final data = snapshot.data!.snapshot.value;
                      if (data is! Map) {
                        return Center(
                            child: Text("Expected user data to be a map."));
                      }

                      Map<String, dynamic> usersMap = {};
                      data.forEach((key, value) {
                        if (key is String && value is Map) {
                          usersMap[key] = Map<String, dynamic>.from(value);
                        }
                      });

                      List<AppUser> users = usersMap.values
                          .where((user) {
                            final String role = user['role'] ?? '';
                            final String name =
                                (user['name'] as String?)?.toLowerCase() ?? '';
                            final String email =
                                (user['email'] as String?)?.toLowerCase() ?? '';
                            return role != 'regular' &&
                                (name.contains(_searchQuery) ||
                                    email.contains(_searchQuery));
                          })
                          .map((user) => AppUser.fromMap(user))
                          .toList();

                      return ListView.separated(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          var user = users[index];
                          return Card(
                            color: Colors.white,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: user.profileImageUrl.isNotEmpty
                                    ? NetworkImage(user.profileImageUrl)
                                    : null,
                                child: user.profileImageUrl.isEmpty
                                    ? Icon(Icons.person_outline)
                                    : null,
                              ),
                              title: Text(
                                user.name,
                                style: TextStyle(color: Color(0xff42214f)),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.email,
                                    style: TextStyle(color: Color(0xff42214f)),
                                  ),
                                  Text(
                                    user.role,
                                    style: TextStyle(color: Color(0xff6a5f6d)),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                      icon: Icon(Icons.edit,
                                          color: Colors.orangeAccent),
                                      onPressed: () =>
                                          _displayEditUserDialog(user)),
                                  IconButton(
                                      icon: Icon(Icons.delete_outline,
                                          color: Colors.redAccent),
                                      onPressed: () => deleteUser(user.uid)),
                                ],
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) => SizedBox(
                          height: 10,
                        ),
                      );
                    } else {
                      return Center(
                          child: LoadingAnimationWidget.fourRotatingDots(
                        color: Color.fromARGB(255, 255, 255, 255),
                        size: 50.0,
                      ));
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
