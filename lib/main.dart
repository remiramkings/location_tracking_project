import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:live_location_tracking_app/user_location.dart';
import 'package:live_location_tracking_app/work_manager_service.dart';
import 'package:live_location_tracking_app/shared_preference_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'location_listing.dart';
import 'location_service.dart';

void main() {
  // WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    print('Debug: Background location tracking is active');

    bool canContinue = true;
    while (canContinue) {
      Position position = await LocationService.getCurrentLocation();

      print('Debug: Tracking user location: ${position.toString()}');
      UserLocation userLocation = UserLocation(latitude: position.latitude, longitude: position.longitude, timeStamp: position.timestamp ?? DateTime.now());
      await SharedPreferenceService.writeLocationDetail(userLocation);
      sleep(Duration(seconds: 3));
      canContinue = await SharedPreferenceService.isLocationTrackerActive();
      print("Debug: Can continue $canContinue");
    }

    return Future.value(true);
  });
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<UserLocation>? userLocations;

  @override
  void initState() {
    super.initState();
    getWorkerStatus();
    getUserLocations(); 
  }

  Future getUserLocations() async{
    var locations = await SharedPreferenceService.readLocationDetails();
    setState(() {
      userLocations = locations;
    });
  }

  Future getWorkerStatus() async {
    bool isWorkerActive =
        await SharedPreferenceService.isLocationTrackerActive();
    setState(() {
      on = isWorkerActive;
    });
  }

  Position? userPosition;
  bool on = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          padding: EdgeInsets.only(top: 100),
          alignment: Alignment.center,
          child: Column(
            
            children: [
              ElevatedButton(
                onPressed: () async {
                  Position position = await LocationService.getCurrentLocation();

                  setState(() {
                    userPosition = position;
                    print(userPosition);
                  });
                },
                child: Text('Track location'),
              ),
              userPosition == null ? Text('') : Text(userPosition.toString()),
              const Text('Turn on/off location tracker background service'),
              Switch(
                  value: on,
                  onChanged: (bool value) async {
                    setState(() {
                      on = value;
                    });
                    await LocationService.checkAndRequestPermissions();
                    if (value) {
                      await SharedPreferenceService.setLocationTrackerStatus(
                          true);
                      Workmanager()
                          .initialize(callbackDispatcher, isInDebugMode: true);
                      Workmanager().registerOneOffTask(
                          'live-location-tracking', 'Tracking-task');

                    } else {
                      await SharedPreferenceService.setLocationTrackerStatus(
                          false);
                      Workmanager().cancelByUniqueName('live-location-tracking');
                    }
                  }),
                  Row(
                    children: [
                      TextButton(onPressed: (){
                        getUserLocations();
                      }, child: const Text("Refresh")),
                      TextButton(onPressed: () async {
                        await SharedPreferenceService.clearAllLocationDetails();
                        await getUserLocations();
                      }, child: const Text("Delete all"))
                    ],
                  ),
                  Expanded(
                    flex: 1,
                    child:userLocations!=null? ListView.builder( 
                      itemCount: userLocations?.length,
                      itemBuilder: (BuildContext context, int index) {
                              return LocationListingTile(userLocation: userLocations![index]);
                            },
                    ):Text('No locations yet'),
                  )
            ],
          ),
        ) //
        );
  }
}
