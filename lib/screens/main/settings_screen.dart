import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:new_app2/utils/color_utils.dart';
import 'package:new_app2/widgets/drawer_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Create a reference to the firebase database
  final ref = FirebaseDatabase.instance
      .ref()
      .child('dataSensor/d4:d4:da:45:89:3c/settings');

  // A boolean variable to store the light status
  bool sdEnable = false;

  // A function to toggle the light status and update the database
  void enableSDcard(bool value) {
    setState(() {
      sdEnable = value;
    });
    ref.child('SD_enable').set(sdEnable ? true : false);
  }

  // A controller for the text field
  final TextEditingController loggingPeriodController = TextEditingController();
  final TextEditingController chartRangeController = TextEditingController();

  // A function to validate the input and update the database
  void submitLoggingPeriod(String input) {
    // Try to parse the input as an integer
    try {
      int number = int.parse(input);
      // If successful, update the database with the number
      ref.child('logging_period').set(number);
      // Clear the text field
      loggingPeriodController.clear();
    } catch (e) {
      // If not successful, show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid integer'),
        ),
      );
    }
  }

  void submitChartRange(String input) {
    // Try to parse the input as an integer
    try {
      int number = int.parse(input);
      // If successful, update the database with the number
      ref.child('chart_range').set(number);
      // Clear the text field
      chartRangeController.clear();
    } catch (e) {
      // If not successful, show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid integer'),
        ),
      );
    }
  }

  // ASync SDenable state with firebase
  void readSDenableState() async {
    final event = await ref.child('SD_enable').once(DatabaseEventType.value);
    if (mounted) {
      setState(() {
        sdEnable = event.snapshot.value == true;
      });
    }
  }

  // Async logging period with firebase
  void readLoggingPeriod() async {
    final event =
        await ref.child('logging_period').once(DatabaseEventType.value);
    if (mounted) {
      setState(() {
        loggingPeriodController.text = event.snapshot.value?.toString() ?? '';
      });
    }
  }

  // Async chart range with firebase
  void readChartRange() async {
    final event = await ref.child('chart_range').once(DatabaseEventType.value);
    if (mounted) {
      setState(() {
        chartRangeController.text = event.snapshot.value?.toString() ?? '';
      });
    }
  }

  late StreamSubscription<DatabaseEvent> listener;
  @override
  void initState() {
    super.initState();
    // Add a listener to the database reference when the app starts
    listener = ref.onValue.listen((event) {
      readSDenableState();
      readLoggingPeriod();
      readChartRange();
    });
  }

  @override
  void dispose() {
    super.dispose();
    // Dispose the controller and cancel the listener when the widget is disposed
    loggingPeriodController.dispose();
    chartRangeController.dispose();
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
      drawer: const NavigationDrawerWidget(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  const Expanded(
                    flex: 2,
                    child: Text(
                      'Set chart range: ',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Expanded(
                      flex: 1,
                      child: TextField(
                        textAlign: TextAlign.center,
                        controller: chartRangeController,
                        keyboardType: TextInputType.number,
                        onSubmitted: submitChartRange,
                        style: const TextStyle(fontSize: 20),
                      ))
                ],
              ),
              Row(
                children: [
                  const Expanded(
                    flex: 2,
                    child: Text(
                      'Set the logging period (second): ',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Expanded(
                      flex: 1,
                      child: TextField(
                        textAlign: TextAlign.center,
                        controller: loggingPeriodController,
                        keyboardType: TextInputType.number,
                        onSubmitted: submitLoggingPeriod,
                        style: const TextStyle(fontSize: 20),
                      ))
                ],
              ),
              Row(
                children: [
                  const Expanded(
                    flex: 2,
                    child: Text(
                      'Enable SD card logging: ',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: CupertinoSwitch(
                      // This bool value toggles the switch.
                      value: sdEnable,
                      onChanged: enableSDcard,
                      activeColor: Colors.green,
                      trackColor: Colors.grey[300],
                      // inactiveThumbColor: Colors.red,
                      // inactiveTrackColor: Colors.red[200],
                    ),
                  )
                ],
              ),
              Row(
                children: [
                  const Expanded(
                    flex: 2,
                    child: Text(
                      'Delete SD card data: ',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
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
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text('Cancel')),
                                            TextButton(
                                              child: const Text(
                                                'DELETE',
                                                style: TextStyle(
                                                    color: Colors.redAccent),
                                              ),
                                              onPressed: () {
                                                ref
                                                    .child('SD_delete')
                                                    .set(true);
                                              },
                                            )
                                          ],
                                        ),
                                        Center(
                                          child: StreamBuilder(
                                            stream:
                                                ref.child('SD_delete').onValue,
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
                                              return const SizedBox.shrink();
                                            },
                                          ),
                                        ),
                                      ],
                                    );
                                  });
                            },
                            icon: const Icon(Icons.delete))),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
