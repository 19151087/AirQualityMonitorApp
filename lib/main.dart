import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:new_app2/screens/auth/auth.dart';
import 'package:new_app2/screens/main/test.dart';
import 'screens/main/datalogging_screen.dart';
import 'screens/main/settings_screen.dart';
import 'screens/main/test2.dart';
import 'utils/color_utils.dart';
import 'widgets/Chart/chart_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Air Quality Monitor',
      theme: ThemeData(
        primaryColor: Palette.blueGray,
        fontFamily: 'Montserrat',
      ),
      home: const AuthScreen(),
    );
  }
}
