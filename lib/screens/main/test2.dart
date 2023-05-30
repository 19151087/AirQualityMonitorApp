import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_app2/utils/color_utils.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Test2Widget extends StatefulWidget {
  final String chartType;
  const Test2Widget({super.key, required this.chartType});

  @override
  State<Test2Widget> createState() => _Test2WidgetState();
}

class _Test2WidgetState extends State<Test2Widget> {
  late int chartRange = 2;
  final List<ChartData> chartDataList = [];
  final dbRef =
      FirebaseDatabase.instance.ref('dataSensor/d4:d4:da:45:89:3c/dataLog');
  final settingsRef = FirebaseDatabase.instance
      .ref()
      .child('dataSensor/d4:d4:da:45:89:3c/settings');

  List<String> jsonParse(dynamic value) {
    // Declare local variables
    String jsondata = "";
    String stringdata = "";
    List<String> listdata;

    // Assign the value of the snapshot to jsondata
    jsondata = value.toString();
    // Replace the unwanted characters in jsondata with empty strings
    stringdata = jsondata
        .replaceAll(
            RegExp(
                r"{|} |PM2_5: |Temperature: |Humidity: |PM10: |Timestamp: |PM1_0: "),
            "")
        .replaceAll('}', '')
        .trim();
    // Split rawdata by commas and assign the result to listdata
    listdata = stringdata.split(',');
    // Return listdata
    return listdata;
  }

  Future<void> _fetchData() async {
    await _fetchChartRange();
  }

  Future<void> _fetchChartRange() async {
    final v = await settingsRef.child('chart_range').once();
    if (v.snapshot.value != null) {
      chartRange = int.tryParse(v.snapshot.value.toString()) ?? 0;
    }
  }

  @override
  void initState() {
    super.initState();
    settingsRef.child('chart_range').onValue.listen((DatabaseEvent event) {
      final v = event.snapshot.value;
      if (v != null) {
        if (mounted) {
          if (mounted) {
            setState(() {
              chartRange = int.tryParse(v.toString()) ?? 0;
            });
            _fetchData();
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: dbRef.orderByKey().limitToLast(chartRange).onValue,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null && data.isNotEmpty) {
            final chartDataList = data.entries.map((entry) {
              final key = entry.key;
              final value = entry.value;
              List<String> listdata = jsonParse(value);

              int time = int.tryParse(key) ?? 0;
              // Temperature data
              double temp = double.tryParse(listdata[1]) ?? 0.0;
              temp = double.parse(temp.toStringAsFixed(1));
              // Humidity data
              double humid = double.tryParse(listdata[2]) ?? 0.0;
              humid = double.parse(humid.toStringAsFixed(2));
              // Dust data
              int pm2_5 = int.tryParse(listdata[0]) ?? 0;
              int pm10 = int.tryParse(listdata[3]) ?? 0;
              int pm1_0 = int.tryParse(listdata[5]) ?? 0;

              return ChartData(DateTime.fromMillisecondsSinceEpoch(time * 1000),
                  temp, humid, pm2_5, pm10, pm1_0);
            }).toList();
            chartDataList.sort((a, b) => a.timestamp.compareTo(b.timestamp));
            return _buildChart(chartDataList);
          } else {
            return const Text('No data available');
          }
        } else if (snapshot.hasError) {
          return const Text('Something went wrong');
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  Widget _buildChart(List<ChartData> list) {
    switch (widget.chartType) {
      case 'temperature':
        return Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(16),
            ),
            color: Palette.blueGrayDark,
          ),
          child: Padding(
            padding: const EdgeInsets.only(
              right: 24.0,
              left: 0.0,
              top: 24,
              bottom: 12,
            ),
            child: temperatureChart(list),
          ),
        );
      case 'humidity':
        return Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(16),
            ),
            color: Palette.blueGrayDark,
          ),
          child: Padding(
            padding: const EdgeInsets.only(
              right: 24.0,
              left: 0.0,
              top: 24,
              bottom: 12,
            ),
            child: humidityChart(list),
          ),
        );
      case 'dust':
        return Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(16),
            ),
            color: Palette.blueGrayDark,
          ),
          child: Padding(
            padding: const EdgeInsets.only(
              right: 24.0,
              left: 0.0,
              top: 24,
              bottom: 12,
            ),
            child: dustChart(list),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

SfCartesianChart temperatureChart(List<ChartData> datalist) {
  LinearGradient gradientColors = LinearGradient(
      // begin: Alignment.topCenter,
      // end: Alignment.bottomCenter,
      colors: [
        Palette.redAccent.withOpacity(0.3),
        Palette.orangeAccent.withOpacity(0.3)
      ]);
  return SfCartesianChart(
    title: ChartTitle(
        text: 'Temperature (°C)',
        textStyle: const TextStyle(
          fontSize: 20.0,
          fontFamily: 'Montserrat',
          color: Palette.neonRed,
        ),
        alignment: ChartAlignment.center),
    primaryXAxis: DateTimeAxis(
      edgeLabelPlacement: EdgeLabelPlacement.shift,
      interval: null,
      dateFormat: DateFormat.Hms(),
      majorGridLines: const MajorGridLines(width: 0),
    ),
    primaryYAxis: NumericAxis(
      labelFormat: '{value}',
      axisLine: const AxisLine(width: 0),
      majorTickLines: const MajorTickLines(size: 0, color: Colors.transparent),
      minimum: 15, // Set the minimum value of the Y-axis
      maximum: 40, // Set the maximum value of the Y-axis
    ),
    series: <ChartSeries<ChartData, DateTime>>[
      SplineAreaSeries<ChartData, DateTime>(
        // onRendererCreated: (controller) {},
        dataSource: datalist,
        gradient: gradientColors,
        color: const Color(0xff37434d),
        borderColor: Palette.neonRed,
        borderWidth: 2,
        xValueMapper: (ChartData data, _) => data.timestamp,
        yValueMapper: (ChartData data, _) => data.temperature,
        name: 'Temp',
        // markerSettings: const MarkerSettings(isVisible: false)
      )
    ],
    tooltipBehavior: TooltipBehavior(enable: true, canShowMarker: true),
  );
}

SfCartesianChart humidityChart(List<ChartData> datalist) {
  final LinearGradient gradientColors = LinearGradient(
      // begin: Alignment.topCenter,
      // end: Alignment.bottomCenter,
      colors: [
        Palette.blueAccent.withOpacity(0.3),
        Palette.greenAccent.withOpacity(0.3)
      ]);

  return SfCartesianChart(
    title: ChartTitle(
        text: 'Humidity (%)',
        textStyle: const TextStyle(
          fontSize: 20.0,
          fontFamily: 'Montserrat',
          color: Palette.neonBlue,
        )),
    primaryXAxis: DateTimeAxis(
      edgeLabelPlacement: EdgeLabelPlacement.shift,
      interval: null,
      dateFormat: DateFormat.Hms(),
      majorGridLines: const MajorGridLines(width: 0),
    ),
    primaryYAxis: NumericAxis(
      labelFormat: '{value} ',
      axisLine: const AxisLine(width: 0),
      majorTickLines: const MajorTickLines(size: 0, color: Colors.transparent),
      minimum: 100, // Set the minimum value of the Y-axis
      maximum: 40, // Set the maximum value of the Y-axis
    ),
    series: <ChartSeries<ChartData, DateTime>>[
      SplineAreaSeries<ChartData, DateTime>(
        // onRendererCreated: (controller) {},
        dataSource: datalist,
        gradient: gradientColors,
        borderColor: Palette.neonBlue,
        borderWidth: 2,
        xValueMapper: (ChartData data, _) => data.timestamp,
        yValueMapper: (ChartData data, _) => data.humidity,
        name: 'Humid',
        markerSettings: const MarkerSettings(isVisible: false),
      ),
    ],
    tooltipBehavior: TooltipBehavior(enable: true),
  );
}

SfCartesianChart dustChart(List<ChartData> datalist) {
  final LinearGradient gradCol2_5 = LinearGradient(
      // begin: Alignment.topCenter,
      // end: Alignment.bottomCenter,
      colors: [
        Palette.middleBlue.withOpacity(0.3),
        Palette.greenLandGreen.withOpacity(0.3)
      ]);
  final LinearGradient gradCol10 = LinearGradient(
      // begin: Alignment.topCenter,
      // end: Alignment.bottomCenter,
      colors: [
        Palette.helioTrope.withOpacity(0.3),
        Palette.steelPink.withOpacity(0.3)
      ]);
  final LinearGradient gradCol1_0 = LinearGradient(
      // begin: Alignment.topCenter,
      // end: Alignment.bottomCenter,
      colors: [
        Palette.quinceJelly.withOpacity(0.3),
        Palette.carminePink.withOpacity(0.3)
      ]);
  return SfCartesianChart(
    title: ChartTitle(
        text: 'Dust (ug/m³)',
        textStyle: const TextStyle(
          fontSize: 20.0,
          fontFamily: 'Montserrat',
          color: Palette.neonPurple,
        ),
        alignment: ChartAlignment.center),
    primaryXAxis: DateTimeAxis(
      edgeLabelPlacement: EdgeLabelPlacement.shift,
      interval: null,
      dateFormat: DateFormat.Hms(),
      majorGridLines: const MajorGridLines(width: 0),
    ),
    primaryYAxis: NumericAxis(
      // labelFormat: '{value}',
      axisLine: const AxisLine(width: 0),
      majorTickLines: const MajorTickLines(size: 0, color: Colors.transparent),
      // minimum: 15, // Set the minimum value of the Y-axis
      // maximum: 40, // Set the maximum value of the Y-axis
    ),
    legend: Legend(
        isVisible: true,
        position: LegendPosition.top,
        textStyle: const TextStyle(
          fontSize: 12.0,
          fontFamily: 'Montserrat',
          color: Colors.white38,
        )),
    series: <ChartSeries<ChartData, DateTime>>[
      SplineAreaSeries<ChartData, DateTime>(
        // onRendererCreated: (controller) {},
        dataSource: datalist,
        gradient: gradCol10,
        borderColor: Palette.neonPurple,
        borderWidth: 2,
        xValueMapper: (ChartData data, _) => data.timestamp,
        yValueMapper: (ChartData data, _) => data.pm10,
        name: 'PM10',
        // markerSettings: const MarkerSettings(isVisible: true),
      ),
      SplineAreaSeries<ChartData, DateTime>(
        // onRendererCreated: (controller) {},
        dataSource: datalist,
        gradient: gradCol1_0,
        borderColor: Palette.neonRed,
        borderWidth: 2,
        xValueMapper: (ChartData data, _) => data.timestamp,
        yValueMapper: (ChartData data, _) => data.pm1_0,
        name: 'PM1.0',
        // markerSettings: const MarkerSettings(isVisible: true),
      ),
      SplineAreaSeries<ChartData, DateTime>(
        // onRendererCreated: (controller) {},
        dataSource: datalist,
        gradient: gradCol2_5,
        borderColor: Palette.neonGreen,
        borderWidth: 2,
        xValueMapper: (ChartData data, _) => data.timestamp,
        yValueMapper: (ChartData data, _) => data.pm2_5,
        name: 'PM2.5',
        // markerSettings: const MarkerSettings(isVisible: true),
      ),
    ],
    tooltipBehavior: TooltipBehavior(enable: true, canShowMarker: true),
  );
}

class ChartData {
  final DateTime timestamp;
  final double temperature;
  final double humidity;
  final int pm2_5;
  final int pm10;
  final int pm1_0;

  ChartData(this.timestamp, this.temperature, this.humidity, this.pm2_5,
      this.pm10, this.pm1_0);
}
