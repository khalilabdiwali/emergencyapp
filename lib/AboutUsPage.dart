import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'About Us',
          style: GoogleFonts.openSans(), // Nunito font
        ),
        // centerTitle: true,
        // backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.0),
              child: Text(
                'About Socma Group'.tr(),
                style: GoogleFonts.openSans(
                  textStyle: Theme.of(context).textTheme.headline5?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  customPadding(
                    child: Text(
                      'Socma Group is dedicated to leveraging technology to enhance emergency response efficiency. Our team is composed of experienced professionals in technology, healthcare, and emergency response sectors, driven by the mission to save lives and provide immediate assistance in critical situations.'
                          .tr(),
                      style: GoogleFonts.openSans(
                        textStyle: Theme.of(context).textTheme.bodyText1,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                  // SizedBox(height: 20),
                  // Image.asset(
                  //   'assets/glogo.png',
                  //   fit: BoxFit.cover,
                  // ),
                  SizedBox(height: 20),
                  customPadding(
                    child: Text(
                      'Why We Built This App'.tr(),
                      style: GoogleFonts.openSans(
                        textStyle: Theme.of(context).textTheme.headline6,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  customPadding(
                    child: Text(
                      'The inspiration behind our emergency response app stems from a need to streamline and optimize the way emergency services are dispatched and managed. Recognizing the critical importance of time in emergency situations, our app aims to significantly reduce response times and ensure that help is always just a few taps away.'
                          .tr(),
                      style: GoogleFonts.openSans(
                        textStyle: Theme.of(context).textTheme.bodyText1,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                  SizedBox(height: 20),
                  customPadding(
                    child: Text(
                      'Benefits of the Emergency Response App'.tr(),
                      style: GoogleFonts.openSans(
                        textStyle: Theme.of(context).textTheme.headline6,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  customPadding(
                    child: Text(
                      'Rapid dispatch of emergency services\n- Real-time tracking of emergency response units\n- Direct communication with responders\n- Access to vital health information for effective on-site treatment\n- Community alerts and safety notifications'
                          .tr(),
                      style: GoogleFonts.openSans(
                        textStyle: Theme.of(context).textTheme.bodyText1,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget customPadding({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: child,
    );
  }
}
