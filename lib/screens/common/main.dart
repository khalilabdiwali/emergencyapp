import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:sms/forms/IntroScreen.dart';
import 'package:sms/forms/LoginPage.dart';
import 'package:sms/screens/Theme/ThemeProvider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await EasyLocalization.ensureInitialized();
  var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
  var initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  runApp(
    EasyLocalization(
      supportedLocales: [
        Locale('en'),
        // Locale('fr'),
        Locale('ar'),
        // Locale('sw'),
        Locale('af')
      ],
      path: 'assets/translations', // Ensure this is the correct path
      fallbackLocale: Locale('en'),
      child: ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      themeMode:
          themeProvider.themeMode, // Use the theme mode from the ThemeProvider
      theme: themeProvider
          .lightTheme, // Use the light theme from the ThemeProvider
      darkTheme: themeProvider.darkTheme,
      home: IntroScreen(),
    );
  }
}
