// Import statements
import 'package:chatx/pages/splash_page.dart';
import 'package:chatx/resources/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:responsive_sizer/responsive_sizer.dart';



/// Main function
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

/// MyApp class - the root of the application
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  /// Build method for the application
  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (BuildContext, Orientation, ScreenType) {
        return MaterialApp(
          title: 'ChatX',
          debugShowCheckedModeBanner: false,
          theme: appTheme,
          themeMode: ThemeMode.dark,
          /// Determine the initial screen based on authentication state
          home: SplashPage(),
        );
      },
    );
  }
}

/// Global variable to store username
String UserName = "";