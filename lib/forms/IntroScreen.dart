import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:sms/forms/LoginPage.dart';
import 'package:sms/components/customPadding.dart';

class IntroScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      // ),
      body: customPadding(
        child: IntroductionScreen(
          pages: [
            PageViewModel(
              title: "Rapid Emergency Response",
              body:
                  "Receive immediate assistance when it matters most, ensuring your safety during emergencies.",
              image: _buildImage(context, "assets/emergency_response.png"),
              decoration: pageDecoration,
            ),
            PageViewModel(
              title: "Direct Communication",
              body:
                  "Directly connect with emergency responders via chat and voice messages to relay crucial information swiftly.",
              image: _buildImage(context, "assets/com.png"),
              decoration: pageDecoration,
            ),
            PageViewModel(
              title: "Accurate Location Tracking",
              body:
                  "Quickly share your exact location with a simple tap to expedite the arrival of help.",
              image: _buildImage(context, "assets/location_sharing.png"),
              decoration: pageDecoration,
            ),
          ],
          onDone: () => _navigateToLoginPage(context),
          onSkip: () => _navigateToLoginPage(context),
          showSkipButton: true,
          skip: const Text('Skip'),
          next: const Icon(Icons.navigate_next),
          done:
              const Text("Done", style: TextStyle(fontWeight: FontWeight.bold)),
          dotsDecorator: DotsDecorator(
            size: const Size(10.0, 10.0),
            activeSize: const Size(22.0, 10.0),
            activeColor: Colors.orange,
            activeShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25.0)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context, String assetName) {
    return Center(
      child: Image.asset(assetName,
          width: MediaQuery.of(context).size.width * 0.8),
    );
  }

  void _navigateToLoginPage(BuildContext context) {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
  }

  final PageDecoration pageDecoration = const PageDecoration(
    titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
    bodyTextStyle: TextStyle(fontSize: 20.0),
    imagePadding: EdgeInsets.zero,
  );
}
