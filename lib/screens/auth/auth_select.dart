import 'package:flutter/material.dart';
import 'signin_screen.dart';
import 'signup_screen.dart';

class AuthSelection extends StatefulWidget {
  const AuthSelection({super.key});

  @override
  State<AuthSelection> createState() => _AuthSelectionState();
}

class _AuthSelectionState extends State<AuthSelection> {
  bool showLoginPage = true;

  void togglePage() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return SignInScreen(onTap: togglePage);
    } else {
      return SignUpScreen(onTap: togglePage);
    }
  }
}
