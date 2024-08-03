import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:url_launcher/url_launcher.dart';

class FireOffline extends StatelessWidget {
  final String phoneNumber =
      "888"; // Replace with your local police phone number
  final String policeWebsite =
      "https://police.gov.so/"; // Replace with your local police website URL

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Emergency Contacts'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _actionCard(
              context,
              icon: Icons.call,
              color: Colors.green,
              text: 'Call Fire',
              onTap: () => _makePhoneCall(context),
              isDarkMode: isDarkMode,
            ),
            SizedBox(height: 20),
            _actionCard(
              context,
              icon: Icons.message,
              color: Colors.orange,
              text: 'Send SMS',
              onTap: () => _sendSMS(context),
              isDarkMode: isDarkMode,
            ),
            // SizedBox(height: 20),
            // _actionCard(
            //   context,
            //   icon: Icons.web,
            //   color: Colors.blue,
            //   text: 'Visit Website',
            //   onTap: () => _openWebsite(context),
            //   isDarkMode: isDarkMode,
            // ),
          ],
        ),
      ),
    );
  }

  Widget _actionCard(BuildContext context,
      {required IconData icon,
      required Color color,
      required String text,
      required VoidCallback onTap,
      required bool isDarkMode}) {
    return InkWell(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: ListTile(
          leading: Icon(icon, size: 40.0, color: color),
          title: Text(
            text,
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          trailing: Icon(Icons.chevron_right, color: Colors.grey),
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(BuildContext context) async {
    try {
      bool? result = await FlutterPhoneDirectCaller.callNumber(phoneNumber);
      if (!result!) {
        _showErrorDialog(context, "Failed to make a call");
      }
    } catch (e) {
      _showErrorDialog(context, "Failed to make a call");
    }
  }

  Future<void> _sendSMS(BuildContext context) async {
    final Uri smsUri = Uri(scheme: 'sms', path: phoneNumber);
    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      _showErrorDialog(context, "Failed to send SMS");
    }
  }

  Future<void> _openWebsite(BuildContext context) async {
    final Uri webUri = Uri.parse(policeWebsite);
    if (await canLaunchUrl(webUri)) {
      await launchUrl(webUri);
    } else {
      _showErrorDialog(context, "Failed to open website");
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
