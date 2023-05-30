import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_app2/screens/main/dashboard_screen.dart';
import 'package:new_app2/screens/main/datalogging_screen.dart';
import 'package:new_app2/screens/main/settings_screen.dart';
import 'package:new_app2/utils/color_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class NavigationDrawerWidget extends StatelessWidget {
  const NavigationDrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = FirebaseAuth.instance.currentUser;
    final String email = user?.email ?? "guest@example.com";
    return Drawer(
      backgroundColor: const Color.fromARGB(255, 177, 177, 177),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  Wrap(
                    runSpacing: 8,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.account_box_rounded),
                        title: Text(email),
                      ),
                      ListTile(
                        leading: const Icon(Icons.home),
                        title: const Text('Dashboard'),
                        onTap: () {
                          // back to home screen
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const HomeScreen()));
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.list),
                        title: const Text('Data logged'),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const DataLogScreen()));
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.settings),
                        title: const Text('Settings'),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const SettingsScreen()));
                        },
                      ),
                      const Divider(color: Palette.blueGrayDark),
                    ],
                  )
                ],
              ),
            ),
            Align(
                alignment: FractionalOffset.bottomCenter,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const Divider(color: Palette.blueGrayDark),
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('Logout'),
                      onTap: () async {
                        if (auth.currentUser != null) {
                          await auth
                              .signOut()
                              .then((value) => Navigator.pop(context));
                        }
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.person_rounded),
                      title: const Text('Facebook'),
                      onTap: () async {
                        Uri url = Uri.parse(
                            'https://www.facebook.com/lamquangtri.01/');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        } else {
                          throw 'Could not launch $url';
                        }
                      },
                    ),
                    const ListTile(
                        title: Text(
                      'Des by LAM QUANG TRI | K19 | HCMUTE',
                      style: TextStyle(
                          fontStyle: FontStyle.italic, color: Colors.black38),
                    )),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
