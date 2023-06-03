import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:new_app2/widgets/drawer_widget.dart';
import 'package:new_app2/utils/color_utils.dart';
import 'package:intl/intl.dart';
import 'package:new_app2/widgets/Chart/chart_widget.dart';

class DashboardScreen extends StatefulWidget {
  final String device;
  const DashboardScreen({super.key, required this.device});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late DatabaseReference refRT;
  double temp = 0.0;
  double humid = 0.0;
  int pm2_5 = 0;
  int timestamp = 0;
  var listdata = [];
  var rawdata = "";

  // Define a function that will be called when the user initiates a refresh
  Future<void> _handleRefresh() async {}

  @override
  void initState() {
    super.initState();
    refRT =
        FirebaseDatabase.instance.ref('dataSensor/${widget.device}/realtime');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Palette.blueGray,
      drawer: NavigationDrawerWidget(device: widget.device),
      appBar: AppBar(
        backgroundColor: Palette.blueGray,
        elevation: 0,
        title: const Text(
          'Air Quality Index',
          style: TextStyle(
            fontSize: 30,
            color: Colors.white,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: Palette.blueGrayDark,
        backgroundColor: Palette.lightGray,
        onRefresh: _handleRefresh,
        child: StreamBuilder(
          stream: refRT.onValue,
          builder: (context, snapshot) {
            if (snapshot.data?.snapshot.value != null) {
              listdata = jsonparse(snapshot);
              pm2_5 = int.tryParse(listdata[0]) ?? 0;
              temp = double.tryParse(listdata[1]) ?? 0.0;
              humid = double.tryParse(listdata[2]) ?? 0;
              timestamp = int.tryParse(listdata[4]) ?? 0;
              return Padding(
                  padding: const EdgeInsets.only(
                    top: 16.0,
                    left: 16.0,
                    right: 16.0,
                  ),
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      Text(
                        'Last update: ${getFormattedDateTime(timestamp)}',
                        style: const TextStyle(
                          color: Palette.redAccent,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w400,
                          letterSpacing: 1,
                          fontSize: 16.0,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: statusColor(pm2_5).withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Status',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w500,
                                              letterSpacing: 1,
                                              fontSize: 24.0,
                                            ),
                                          ),
                                          Text(
                                            statusEmoji(pm2_5),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'Montserrat',
                                              letterSpacing: 1,
                                              fontSize: 28.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8.0),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.info,
                                            size: 26.0,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 4.0),
                                          Expanded(
                                            child: Text(
                                              'The Air quality is ${getStatus(pm2_5)}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'Montserrat',
                                                fontWeight: FontWeight.w500,
                                                letterSpacing: 1,
                                                fontSize: 14.0,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              const Text(
                                'Temperature',
                                style: TextStyle(
                                  color: Palette.blueAccent,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1,
                                  fontSize: 30.0,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                '${temp.toStringAsFixed(1)} °C',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1,
                                  fontSize: 48.0,
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              const Text(
                                'Humidity',
                                style: TextStyle(
                                  color: Palette.blueAccent,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1,
                                  fontSize: 30.0,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                '${humid.toStringAsFixed(1)} %',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1,
                                  fontSize: 48.0,
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              const Text(
                                'PM2.5',
                                style: TextStyle(
                                  color: Palette.blueAccent,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1,
                                  fontSize: 30.0,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                '$pm2_5 ug/m³',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1,
                                  fontSize: 48.0,
                                ),
                              ),
                            ],
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 54.0),
                              child: Image.asset(
                                'assets/images/plant_shadow.png',
                                height: 420,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24.0),
                      SizedBox(
                          width: screenWidth,
                          height: screenWidth / 1.3,
                          child: ChartWidget(
                              chartType: 'temperature', device: widget.device)),
                      const SizedBox(height: 24.0),
                      SizedBox(
                          width: screenWidth,
                          height: screenWidth / 1.3,
                          child: ChartWidget(
                              chartType: 'humidity', device: widget.device)),
                      const SizedBox(height: 24.0),
                      SizedBox(
                          width: screenWidth,
                          height: screenWidth / 1.3,
                          child: ChartWidget(
                              chartType: 'dust', device: widget.device)),
                      const SizedBox(height: 24.0),
                    ],
                  ));
            } else if (snapshot.hasError) {
              return Center(
                child: Text('${snapshot.error}'),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }

  List<String> jsonparse(var snapshot) {
    // Declare local variables
    var jsondata = "";
    var rawdata = "";
    List<String> listdata;

    // Assign the value of the snapshot to jsondata
    jsondata = snapshot.data!.snapshot.value.toString();
    // Replace the unwanted characters in jsondata with empty strings
    rawdata = jsondata
        .replaceAll(
            RegExp(
                r"{|} |PM2_5: |Temperature: |Humidity: |PM10: |Timestamp: |PM1_0: "),
            "")
        .replaceAll('}', '');
    // Trim any leading or trailing whitespace in rawdata
    rawdata.trim();
    // Split rawdata by commas and assign the result to listdata
    listdata = rawdata.split(',');
    // Return listdata
    return listdata;
  }

  String getFormattedDateTime(int timestamp) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }

  String getStatus(int dust) {
    if (dust < 35) {
      return 'Great';
    } else if (dust >= 35 && dust < 75) {
      return 'Good';
    } else if (dust >= 75 && dust < 115) {
      return 'Middly Polluted';
    } else if (dust >= 115 && dust < 150) {
      return 'Moderately Polluted';
    } else if (dust >= 150 && dust < 250) {
      return 'Seriously Polluted';
    } else if (dust >= 250) {
      return 'Serverely Polluted';
    } else {
      return 'Error';
    }
  }

  Color statusColor(int dust) {
    if (dust < 35) {
      return Palette.greenAccent;
    } else if (dust >= 35 && dust < 75) {
      return Palette.yellowAccent;
    } else if (dust >= 75 && dust < 115) {
      return Palette.orangeAccent;
    } else if (dust >= 115 && dust < 150) {
      return Palette.redAccent;
    } else if (dust >= 150 && dust < 250) {
      return Palette.purpleAccent;
    } else if (dust >= 250) {
      return Palette.maroonAccent;
    } else {
      return Palette.blueAccent;
    }
  }

  String statusEmoji(int dust) {
    if (dust < 35) {
      return '😊';
    } else if (dust >= 35 && dust < 75) {
      return '😀';
    } else if (dust >= 75 && dust < 115) {
      return '😐';
    } else if (dust >= 115 && dust < 150) {
      return '😷';
    } else if (dust >= 150 && dust < 250) {
      return '🤢';
    } else if (dust >= 250) {
      return '💀';
    } else {
      return '🤔';
    }
  }
}
