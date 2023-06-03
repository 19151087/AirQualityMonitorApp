import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:new_app2/screens/main/selectdevices_screen.dart';
import 'package:new_app2/utils/color_utils.dart';
import 'package:new_app2/widgets/drawer_widget.dart';

class SettingsScreen extends StatefulWidget {
  final String device;
  const SettingsScreen({super.key, required this.device});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

const List<int> chartRangeList = <int>[5, 10, 15, 20];
const List<int> loggingPeriodList = <int>[15, 30, 45, 60];

class _SettingsScreenState extends State<SettingsScreen> {
  int chartRangeValue = chartRangeList.first;
  int loggingPeriodValue = loggingPeriodList.first;
  String wifiSSID = 'No connection';
  // Create a settingsReference to the firebase database
  late DatabaseReference settingsRef;
  late DatabaseReference realtimeRef;

  // A boolean variable to store the light status
  bool sdEnable = false;

  // A function to toggle the SDcard logging status
  void enableSDcard(bool value) {
    setState(() {
      sdEnable = value;
    });
    settingsRef.child('SD_enable').set(sdEnable ? true : false);
  }

  // A function to validate the input and update the database
  void submitLoggingPeriod(int? input) {
    int number = input ?? 0;
    settingsRef.child('logging_period').set(number);
  }

  void submitChartRange(int? input) {
    int number = input ?? 0;
    settingsRef.child('chart_range').set(number);
    setState(() {
      chartRangeValue = number;
    });
  }

  // ASync SDenable state with firebase
  void readSDenableState() async {
    final event =
        await settingsRef.child('SD_enable').once(DatabaseEventType.value);
    if (mounted) {
      setState(() {
        sdEnable = event.snapshot.value == true;
      });
    }
  }

  // Async logging period with firebase
  void readLoggingPeriod() async {
    final event =
        await settingsRef.child('logging_period').once(DatabaseEventType.value);
    if (mounted) {
      setState(() {
        loggingPeriodValue = int.tryParse(event.snapshot.value.toString()) ?? 0;
      });
    }
  }

  // Async chart range with firebase
  void readChartRange() async {
    final event =
        await settingsRef.child('chart_range').once(DatabaseEventType.value);
    if (mounted) {
      setState(() {
        chartRangeValue = int.tryParse(event.snapshot.value.toString()) ?? 0;
      });
    }
  }

  void readSSID() async {
    final event =
        await settingsRef.child('wifi_ssid').once(DatabaseEventType.value);
    if (mounted) {
      setState(() {
        wifiSSID = event.snapshot.value.toString();
      });
    }
  }

  late StreamSubscription<DatabaseEvent> listener;
  late StreamSubscription<DatabaseEvent> connectListener;
  late int _timeCheck;
  late bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    settingsRef = FirebaseDatabase.instance
        .ref()
        .child('dataSensor/${widget.device}/settings');
    realtimeRef = FirebaseDatabase.instance
        .ref()
        .child('dataSensor/${widget.device}/realtime');
    // Add a listener to the database settingsReference when the app starts
    listener = settingsRef.onValue.listen((event) {
      readSDenableState();
      readLoggingPeriod();
      readChartRange();
      readSSID();
    });

    connectListener = realtimeRef.child('Timestamp').onValue.listen((event) {
      if (mounted) {
        setState(() {
          _timeCheck = int.tryParse(event.snapshot.value.toString()) ?? 0;
        });
      }

      // Check if the timestamp stops updating.
      Timer.periodic(const Duration(seconds: 5), (timer) {
        if (_timeCheck == event.snapshot.value) {
          // The ESP32 has disconnected.
          timer.cancel();
          setState(() {
            _isConnected = false;
          });
        } else {
          _isConnected = true;
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    // cancel the listener when the widget is disposed
    listener.cancel();
  }

  @override
  Widget build(BuildContext context) {
    late int firstPress = 0;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Palette.blueGray,
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 30,
            color: Colors.white,
          ),
        ),
      ),
      backgroundColor: Palette.lightGray,
      drawer: NavigationDrawerWidget(device: widget.device),
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 8.0),
          Card(
            color: Palette.lightGray,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: ListTile(
              title: const Text(
                'Select other devices',
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded),
              onTap: () => Navigator.of(context).push(_createRoute()),
            ),
          ),
          const SizedBox(height: 8.0),
          Card(
            color: Palette.lightGray,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: ListTile(
              title: const Text('Device MAC address'),
              subtitle: Text(_isConnected ? widget.device : 'No connection'),
              // style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(height: 8.0),
          Card(
            color: Palette.lightGray,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: ListTile(
              title: const Text('Wifi SSID'),
              subtitle: Text(_isConnected ? wifiSSID : 'No connection'),
              // style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(height: 8.0),
          Card(
            color: Palette.lightGray,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: ListTile(
              title: const Text('Set chart range'),
              subtitle: const Text('Set number of data show on chart frame'),
              trailing: DropdownButton(
                value: chartRangeValue,
                // icon: const Icon(Icons.arrow_downward),
                elevation: 16,
                style: const TextStyle(fontSize: 20, color: Colors.black),
                onChanged: submitChartRange,
                items: chartRangeList.map<DropdownMenuItem<int>>((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(value.toString()),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Card(
            color: Palette.lightGray,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: ListTile(
              title: const Text('Logging period'),
              subtitle:
                  const Text('Set data logging period of device in second'),
              trailing: DropdownButton(
                value: loggingPeriodValue,
                // icon: const Icon(Icons.arrow_downward),
                elevation: 16,
                style: const TextStyle(fontSize: 20, color: Colors.black),
                onChanged: submitLoggingPeriod,
                items:
                    loggingPeriodList.map<DropdownMenuItem<int>>((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(value.toString()),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Card(
            color: Palette.lightGray,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(28)),
            ),
            child: Column(
              children: [
                ListTile(
                  title: const Text(
                    'SD card logging',
                  ),
                  subtitle:
                      const Text('Enable SD card data logging of the device'),
                  trailing: CupertinoSwitch(
                    // This bool value toggles the switch.
                    value: sdEnable,
                    onChanged: enableSDcard,
                    activeColor: Colors.green,
                    trackColor: Colors.grey[300],
                    // inactiveThumbColor: Colors.red,
                    // inactiveTrackColor: Colors.red[200],
                  ),
                ),
                Visibility(
                  visible: sdEnable,
                  child: Column(
                    children: [
                      const SizedBox(height: 8.0),
                      ListTile(
                        title: const Text(
                          'Delete SD card data',
                        ),
                        subtitle: const Text(
                            'Delete all data in SD card, connect to device first!'),
                        trailing: Container(
                            padding: const EdgeInsets.all(0),
                            margin: const EdgeInsets.symmetric(vertical: 12),
                            height: 35,
                            width: 35,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: IconButton(
                                color: Colors.white,
                                iconSize: 18,
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Stack(
                                          children: [
                                            AlertDialog(
                                              title: const Text("Delete Data"),
                                              content: const Text(
                                                  "Are you sure you want to delete data?"),
                                              actions: [
                                                TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child:
                                                        const Text('Cancel')),
                                                TextButton(
                                                  child: const Text(
                                                    'DELETE',
                                                    style: TextStyle(
                                                        color:
                                                            Colors.redAccent),
                                                  ),
                                                  onPressed: () {
                                                    settingsRef
                                                        .child('SD_delete')
                                                        .set(true);
                                                  },
                                                )
                                              ],
                                            ),
                                            Center(
                                              child: StreamBuilder(
                                                stream: settingsRef
                                                    .child('SD_delete')
                                                    .onValue,
                                                builder: (context, snapshot) {
                                                  // Check if the variable is true
                                                  if (snapshot.hasData &&
                                                      snapshot.data!.snapshot
                                                              .value ==
                                                          true) {
                                                    firstPress++;
                                                    // Show a loading circle
                                                    return const CircularProgressIndicator();
                                                  }
                                                  if (firstPress != 0) {
                                                    // Not the first time press
                                                    Navigator.of(context).pop();
                                                    firstPress = 0;
                                                  }
                                                  return const SizedBox
                                                      .shrink();
                                                },
                                              ),
                                            ),
                                          ],
                                        );
                                      });
                                },
                                icon: const Icon(Icons.delete))),
                      ),
                      const SizedBox(height: 8.0),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const SelectDevices(),
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
