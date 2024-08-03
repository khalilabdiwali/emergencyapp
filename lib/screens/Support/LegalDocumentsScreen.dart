import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

// Detail screen to display legal documents
class DetailScreen extends StatelessWidget {
  final String title;
  final String content;

  DetailScreen({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // To ensure the content is scrollable
          child: Text(content, style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}

class LegalDocumentsScreen extends StatelessWidget {
  // Method to navigate to the detail screen with specific content
  void _navigateToDetail(BuildContext context, String title, String content) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailScreen(title: title, content: content),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Legal & Privacy Documents'.tr()),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.privacy_tip),
            title: Text('Privacy Policy'.tr(),
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            subtitle:
                Text('Click to read more about how we protect your data.'.tr()),
            onTap: () => _navigateToDetail(
                context,
                'Privacy Policy',
                'Our Privacy Policy explains how information about you is collected, used, and disclosed by our emergency response application. Your privacy is critical, and we take stringent measures to protect your personal data and ensure compliance with all applicable privacy laws.'
                    .tr()),
          ),
          Divider(height: 30),
          ListTile(
            leading: Icon(Icons.gavel),
            title: Text('Terms of Use'.tr(),
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            subtitle: Text('Click to read our terms of service.'.tr()),
            onTap: () => _navigateToDetail(
                context,
                'Terms of Use',
                'These Terms of Use govern your access to and use of our emergency response application. By accessing or using the app, you agree to be bound by these terms and understand your rights and obligations.'
                    .tr()),
          ),
          Divider(height: 30),
          ListTile(
            leading: Icon(Icons.warning),
            title: Text('Disclaimer'.tr(),
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            subtitle:
                Text('Click to read the legal limitations of app usage.'.tr()),
            onTap: () => _navigateToDetail(
                context,
                'Disclaimer'.tr(),
                'The information provided through our emergency response application is for informational purposes only. While we strive to provide accurate and up-to-date information, we are not responsible for any inaccuracies that may occur.'
                    .tr()),
          ),
          Divider(height: 30),
          ListTile(
            leading: Icon(Icons.contact_mail),
            title: Text('Contact Us'.tr(),
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            subtitle: Text('Click to learn how to reach us.'.tr()),
            onTap: () => _navigateToDetail(
                context,
                'Contact Us'.tr(),
                'If you have any questions or concerns regarding our app, please feel free to reach out to us. Your feedback is valuable, and we are here to help you with any issues or inquiries.'
                    .tr()),
          ),
        ],
      ),
    );
  }
}
