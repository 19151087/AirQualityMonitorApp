import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:new_app2/screens/auth/auth.dart';
import 'package:new_app2/utils/color_utils.dart';

import 'dashboard_screen.dart';

class SelectDevices extends StatefulWidget {
  const SelectDevices({super.key});

  @override
  State<SelectDevices> createState() => _SelectDevicesState();
}

class _SelectDevicesState extends State<SelectDevices> {
  // Get a database reference to the data path
  final DatabaseReference _databaseRef =
      FirebaseDatabase.instance.ref("dataSensor");

  // Create a list to store the snapshots of devices
  final List<DataSnapshot> _deviceList = [];

  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    // Listen for child events on the database reference
    _databaseRef.onChildAdded.listen((event) {
      // Add the new device snapshot to the list
      setState(() {
        _deviceList.add(event.snapshot);
      });
    });
    _databaseRef.onChildChanged.listen((event) {
      // Update the device snapshot in the list
      setState(() {
        int index = _deviceList
            .indexWhere((snapshot) => snapshot.key == event.snapshot.key);
        if (index != -1) {
          _deviceList[index] = event.snapshot;
        }
      });
    });
    _databaseRef.onChildRemoved.listen((event) {
      // Remove the device snapshot from the list
      setState(() {
        _deviceList
            .removeWhere((snapshot) => snapshot.key == event.snapshot.key);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Palette.blueGray,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              onPressed: () async {
                if (auth.currentUser != null) {
                  await auth.signOut().then((value) => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AuthScreen())));
                }
              },
              icon: const Icon(Icons.logout_rounded),
            ),
          ),
        ],
      ),
      backgroundColor: Palette.lightGray,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Text(
                'Choose your device',
                style: TextStyle(fontSize: 36),
              ),
            ),
            ListView.builder(
              // physics: const ScrollPhysics(parent: null),
              shrinkWrap: true,
              itemCount: _deviceList.length,
              itemBuilder: (context, index) {
                // Get the device snapshot from the list
                DataSnapshot device = _deviceList[index];
                // Create a custom list item widget
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Card(
                    color: Palette.lightGray,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.devices_rounded),
                      title: Text(
                        device.key.toString(),
                        style: const TextStyle(fontSize: 20),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded),
                      onTap: () {
                        Navigator.of(context)
                            .push(_createRoute(device.key.toString()));
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Route _createRoute(String key) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          DashboardScreen(device: key),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}
