import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:new_app2/utils/color_utils.dart';

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

  // Create a variable to store the chart range value
  int chartRange = 0;

  // Create a controller for the textfield
  final TextEditingController chartRangeController = TextEditingController();

  // Create a method to update the chart range value in the database
  void updateChartRange(String input) {
    // Try to parse the input as an integer
    try {
      int value = int.parse(input);
      // If successful, update the database with the value
      ref.child('chart_range').set(value);
    } catch (e) {
      // If not successful, show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid integer'),
        ),
      );
    }
  }

  // Create a method to read the chart range value from the database
  void readChartRange() async {
    final event = await ref.child('chart_range').once(DatabaseEventType.value);
    // Check if the widget is still mounted
    if (mounted) {
      setState(() {
        chartRange = int.parse(event.snapshot.value.toString());
        chartRangeController.text = chartRange.toString();
      });
    }
  }

  late StreamSubscription<DatabaseEvent> listener;
  @override
  void initState() {
    super.initState();
    // Add a listener to the database reference when the app starts
    listener = ref.onValue.listen((event) {
      readChartRange();
    });
  }

  @override
  void dispose() {
    super.dispose();
    // Dispose the controller and cancel the listener when the widget is disposed
    chartRangeController.dispose();
    listener.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
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
                onSubmitted: updateChartRange,
                style: const TextStyle(fontSize: 20),
              ))
        ],
      ),
    );
  }
}
