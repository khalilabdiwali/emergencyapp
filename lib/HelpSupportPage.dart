import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class HelpSupportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help & Support'),
        // backgroundColor:
        //     Color(0xff3f134e), // Uncomment to apply background color
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildSectionTitle(context, "FAQs"),
              _buildFAQ(
                  context,
                  'How do I register for the app?'.tr(),
                  'To register, download the app and follow the on-screen instructions to create an account.'
                      .tr()),
              _buildFAQ(
                  context,
                  'How do I report an emergency?'.tr(),
                  'In the event of an emergency, open the app, tap the "Report" button, and follow the prompts to detail the situation.'
                      .tr()),
              _buildFAQ(
                  context,
                  'How can I update my personal information?'.tr(),
                  'Go to the Settings section of the app, and you will find options to update your personal information.'
                      .tr()),
              _buildFAQ(
                  context,
                  'How is my privacy protected?'.tr(),
                  'Your privacy is our priority. We use state-of-the-art encryption and comply with local regulations to ensure your data is secure.'
                      .tr()),
              _buildFAQ(
                  context,
                  'What are the typical response times?'.tr(),
                  'Response times can vary, but typically, local authorities are alerted within 1-2 minutes of your report.'
                      .tr()),
              _buildFAQ(
                  context,
                  'Where is the service available?'.tr(),
                  'Our service is currently available in major cities across the country. Check our website for a list of supported regions.'
                      .tr()),
              _buildFAQ(
                  context,
                  'What should I do if the app crashes?'.tr(),
                  'If the app crashes, try restarting your device. If the problem persists, please contact our support team.'
                      .tr()),
              _buildSectionTitle(context, "Contact Us".tr()),
              Text("For immediate assistance, please contact us:".tr(),
                  style: Theme.of(context).textTheme.subtitle1),
              _buildContactInfo(Icons.email, 'Email', 'socmabot@gmail.com'),
              _buildContactInfo(Icons.phone, 'Phone', '+252617179442'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.0),
      child:
          Text(title, style: Theme.of(context).textTheme.headline6!.copyWith()),
    );
  }

  Widget _buildFAQ(BuildContext context, String question, String answer) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      child: ExpansionTile(
        title: Text(question,
            style: Theme.of(context).textTheme.subtitle1!.copyWith()),
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(answer, style: Theme.of(context).textTheme.bodyText2),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(IconData icon, String type, String contact) {
    return ListTile(
      leading: Icon(
        icon,
      ),
      title: Text(type),
      subtitle: Text(contact, style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
