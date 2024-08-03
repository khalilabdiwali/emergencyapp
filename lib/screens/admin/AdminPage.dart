import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sms/forms/AddUserPage.dart';
import 'package:sms/components/customPadding.dart';

class AdminPage extends StatefulWidget {
  @override
  AdminPageState createState() => AdminPageState();
}

class AdminPageState extends State<AdminPage> {
  final DatabaseReference _usersRef =
      FirebaseDatabase.instance.ref().child('Users');
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Future<void> blockUser(String userId) async {
    try {
      await _usersRef.child(userId).update({'isBlocked': true});
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('User blocked successfully')));
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to block user: $error')));
    }
  }

  Future<void> unblockUser(String userId) async {
    try {
      await _usersRef.child(userId).update({'isBlocked': false});
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('User unblocked successfully')));
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to unblock user: $error')));
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _usersRef.child(userId).remove();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('User deleted successfully')));
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete user: $error')));
    }
  }

  Future<void> editUser(String userId, String newName, String newEmail) async {
    await _usersRef.child(userId).update({'name': newName, 'email': newEmail});
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('User updated successfully')));
  }

  void _displayEditUserDialog(Map user) {
    final TextEditingController nameController =
        TextEditingController(text: user['name']);
    final TextEditingController emailController =
        TextEditingController(text: user['email']);

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
                decoration: InputDecoration(labelText: "Name"),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: "Email"),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                editUser(
                    user['uid'], nameController.text, emailController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showUserActionsDialog(Map user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('User Actions'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit User'),
                onTap: () {
                  Navigator.of(context).pop();
                  _displayEditUserDialog(user);
                },
              ),
              ListTile(
                leading: Icon(Icons.block),
                title: Text('Block User'),
                onTap: () {
                  Navigator.of(context).pop();
                  blockUser(user['uid']);
                },
              ),
              ListTile(
                leading: Icon(Icons.lock_open),
                title: Text('Unblock User'),
                onTap: () {
                  Navigator.of(context).pop();
                  unblockUser(user['uid']);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('Delete User'),
                onTap: () {
                  Navigator.of(context).pop();
                  deleteUser(user['uid']);
                },
              ),
            ],
          ),
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
        title: Text('Manage Users '),
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

                      List users = usersMap.values.where((user) {
                        final String name =
                            (user['name'] as String?)?.toLowerCase() ?? '';
                        final String email =
                            (user['email'] as String?)?.toLowerCase() ?? '';
                        final String role =
                            (user['role'] as String?)?.toLowerCase() ?? '';
                        return (name.contains(_searchQuery) ||
                                email.contains(_searchQuery)) &&
                            role == 'regular'; // Filter for regular users only
                      }).toList();

                      return ListView.separated(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          var user = users[index];
                          String? profileImageUrl = user['profileImageUrl'];
                          bool isBlocked = user['isBlocked'] ?? false;

                          return Card(
                            color: isBlocked ? Colors.grey[200] : Colors.white,
                            child: ListTile(
                              onTap: () => _showUserActionsDialog(user),
                              leading: CircleAvatar(
                                backgroundImage: profileImageUrl != null &&
                                        profileImageUrl.isNotEmpty
                                    ? NetworkImage(profileImageUrl)
                                    : null,
                                child: profileImageUrl == null ||
                                        profileImageUrl.isEmpty
                                    ? Icon(Icons.person_outline)
                                    : null,
                              ),
                              title: Text(
                                user['name'] ?? 'N/A',
                                style: TextStyle(
                                  color: isBlocked
                                      ? Colors.red
                                      : Color(0xff42214f),
                                ),
                              ),
                              subtitle: Text(
                                user['email'] ?? 'N/A',
                                style: TextStyle(
                                  color: isBlocked
                                      ? Colors.red
                                      : Color(0xff42214f),
                                ),
                              ),
                              trailing: isBlocked
                                  ? Icon(Icons.block, color: Colors.red)
                                  : null,
                            ),
                          );
                        },
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 10),
                      );
                    } else {
                      return Center(
                        child: LoadingAnimationWidget.fourRotatingDots(
                          color: Color.fromARGB(255, 255, 255, 255),
                          size: 50.0,
                        ),
                      );
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
