import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sms/AdminPage.dart';
import 'package:sms/Announcement.dart';
import 'package:sms/ChatScreen.dart';
import 'package:sms/HospitalToRegular.dart';
import 'package:sms/IncidentList.dart';
import 'package:sms/PoliceDashboard.dart';
import 'package:sms/PolicePage.dart';
import 'package:sms/Policeoffline.dart';
import 'package:sms/Responders.dart';
import 'package:sms/SettingsPage.dart';
import 'package:sms/TrafficScreenChat.dart';
import 'package:sms/customPadding.dart';
import 'package:sms/firstaidpage.dart';
import 'package:sms/respondersAnouncement.dart';

class RespondersDashboardView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
        child: GridView.builder(
          itemCount: 4,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 1.0,
          ),
          itemBuilder: (context, index) {
            switch (index) {
              case 0:
                return _buildServiceItem(
                  context,
                  image: 'assets/chats.gif',
                  label: 'Chats'.tr(),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HospitalToRegular()),
                  ),
                );
              case 1:
                return _buildServiceItem(
                  context,
                  image: 'assets/announcement.gif',
                  label: 'Anoucement'.tr(),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RespondersAnnouncementSend()),
                  ),
                );
              case 2:
                return _buildServiceItem(
                  context,
                  image: 'assets/Reports.gif',
                  label: 'Reports'.tr(),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => IncidentReportView()),
                  ),
                );
              case 3:
                return _buildServiceItem(
                  context,
                  image: 'assets/settings.gif',
                  label: 'Settings'.tr(),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsPage()),
                  ),
                );
              default:
                return Container();
            }
          },
        ),
      ),
    );
  }

  Widget _buildServiceItem(BuildContext context,
      {required String image, required String label, VoidCallback? onTap}) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.secondary,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 24.0), // Adjusted top padding
              child: Image.asset(image, width: 90, height: 75),
            ),
            SizedBox(height: 10),
            Text(label,
                style: GoogleFonts.nunito(
                  fontSize: 18,
                )),
          ],
        ),
      ),
    );
  }
}
