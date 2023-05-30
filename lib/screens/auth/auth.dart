import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_app2/screens/main/dashboard_screen.dart';
import 'auth_select.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (userSnapshot.connectionState == ConnectionState.active) {
            if (userSnapshot.hasData) {
              return const HomeScreen();
            } else {
              return const AuthSelection();
            }
          } else if (userSnapshot.hasError) {
            return const Center(
              child: Text('Error occured'),
            );
          }
          return const Center(
            child: Text('Error occured'),
          );
        });
  }
}
    //return Scaffold(
    //   body: StreamBuilder<User?>(
    //     stream: FirebaseAuth.instance.authStateChanges(),
    //     builder: (context, snapshot) {
    //       if (snapshot.hasData) {
    //         // if user is logged in
    //         return const HomeScreen();
    //       } else {
    //         // if user is not logged in
    //         return const AuthSelection();
    //       }
    //     },
    //   ),
    // );