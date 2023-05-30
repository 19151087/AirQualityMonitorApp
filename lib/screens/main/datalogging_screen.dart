import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:intl/intl.dart';
import 'package:new_app2/utils/color_utils.dart';
import 'package:new_app2/widgets/drawer_widget.dart';

class DataLogScreen extends StatefulWidget {
  const DataLogScreen({super.key});

  @override
  State<DataLogScreen> createState() => _DataLogScreenState();
}

class _DataLogScreenState extends State<DataLogScreen> {
  final ref = FirebaseDatabase.instance
      .ref()
      .child('dataSensor/d4:d4:da:45:89:3c/dataLog');
  // Create a query to fetch data from firebase realtime database
  final Query query = FirebaseDatabase.instance
      .ref()
      .child('dataSensor/d4:d4:da:45:89:3c/dataLog');

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

  String getFormattedDateTime(int timestamp) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return DateFormat('HH:mm:ss dd-MM-yyyy').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    TextStyle cardTextStyle =
        const TextStyle(color: Colors.white, fontSize: 16);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Palette.blueGray,
        title: const Text(
          'Data logging',
          style: TextStyle(
            fontSize: 30,
            color: Colors.white,
          ),
        ),
      ),
      drawer: const NavigationDrawerWidget(),
      body: Container(
        color: Palette.blueGray,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () {
                      // Handle the 'Delete all' button tap
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Delete All Data"),
                              content: const Text(
                                  "Are you sure you want to delete all data?"),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Cancel')),
                                TextButton(
                                    onPressed: () {
                                      ref.remove();
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text(
                                      'DELETE',
                                      style: TextStyle(color: Colors.redAccent),
                                    ))
                              ],
                            );
                          });
                    },
                    child: const Text('Delete all'),
                  ),
                ),
              ),
              RealtimeDBPagination(
                physics: const ScrollPhysics(parent: null),
                shrinkWrap: true,
                // Use the query to paginate data
                query: query,
                // Add the orderBy parameter to match the query
                orderBy: 'key',
                // Build each item in the list
                itemBuilder: (context, dataSnapshot, index) {
                  // Get the data as a map
                  List<String> listdata = jsonParse(dataSnapshot.value);

                  // Get the key and value of the data
                  double temp = double.parse(listdata[1]);
                  double humid = double.parse(listdata[2]);
                  int pm2_5 = int.parse(listdata[0]);
                  int pm10 = int.parse(listdata[3]);
                  int pm1_0 = int.parse(listdata[5]);
                  int timestamp = int.parse(dataSnapshot.key.toString());
                  // Return a ListTile widget with the key and value
                  return Card(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    color: const Color(0xff3c6382),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Stack(
                        children: [
                          Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text('Time: ', style: cardTextStyle),
                                  ),
                                  Expanded(
                                      flex: 3,
                                      child: Text(
                                          getFormattedDateTime(timestamp),
                                          style: cardTextStyle)),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text('Temperature: ',
                                        style: cardTextStyle),
                                  ),
                                  Expanded(
                                      flex: 3,
                                      child: Text(
                                          '${temp.toStringAsFixed(1)} °C',
                                          style: cardTextStyle)),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text('Humidity: ',
                                        style: cardTextStyle),
                                  ),
                                  Expanded(
                                      flex: 3,
                                      child: Text(
                                          '${humid.toStringAsFixed(1)} %',
                                          style: cardTextStyle)),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child:
                                        Text('PM2.5: ', style: cardTextStyle),
                                  ),
                                  Expanded(
                                      flex: 3,
                                      child: Text('$pm2_5 ug/m3',
                                          style: cardTextStyle)),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text('PM10: ', style: cardTextStyle),
                                  ),
                                  Expanded(
                                      flex: 3,
                                      child: Text('$pm10 ug/m3',
                                          style: cardTextStyle)),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child:
                                        Text('PM1_0: ', style: cardTextStyle),
                                  ),
                                  Expanded(
                                      flex: 3,
                                      child: Text('$pm1_0 ug/m3',
                                          style: cardTextStyle)),
                                ],
                              ),
                            ],
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 24.0),
                              child: Container(
                                  padding: const EdgeInsets.all(0),
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 12),
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
                                              return AlertDialog(
                                                title:
                                                    const Text("Delete Data"),
                                                content: const Text(
                                                    "Are you sure you want to delete this data?"),
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
                                                      ref
                                                          .child(
                                                              dataSnapshot.key!)
                                                          .remove();
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  )
                                                ],
                                              );
                                            });
                                      },
                                      icon: const Icon(Icons.delete))),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                // Set the limit of items per page
                limit: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
