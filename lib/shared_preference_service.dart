import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:live_location_tracking_app/user_location.dart';
import 'package:shared_preferences/shared_preferences.dart';


enum SPKeys {
  islocationtrackeractive,
  location
}

class SharedPreferenceService {

  static Future<SharedPreferences> getInstance() async {
    return await SharedPreferences.getInstance();
  }

  static Future<bool> isLocationTrackerActive() async {
    return (await getInstance())
      .getBool(SPKeys.islocationtrackeractive.name) ?? false;
  }

  static Future setLocationTrackerStatus(bool status) async {
    (await getInstance())
      .setBool(SPKeys.islocationtrackeractive.name, status);
  }

  static Future getLocationDetails() async {
    return (await getInstance())
    .getStringList(SPKeys.location.name) ?? false;
  }
  
  static Future setLocationDetails(List<String> locationDetails) async {
    (await getInstance())
    .setStringList(SPKeys.location.name, locationDetails);
  }

  static Future<List<UserLocation>?> readLocationDetails() async{
    var instance = await getInstance();
    String locationDetailsString = instance.getString(SPKeys.location.name) ?? '[]';
    List<dynamic>? items = jsonDecode(locationDetailsString);
    if(items == null){
      return null;
    }
    return items
      .map((e) => UserLocation.fromMap(e as Map<String, dynamic>))
      .toList();
  }

  static Future writeLocationDetail(UserLocation userLocation) async {
    List<UserLocation>? existingLocations = await readLocationDetails();
    existingLocations ??= [];
    existingLocations.add(userLocation);
    List<Map<String, dynamic>> locationsToWrite = existingLocations
      .map((e) => UserLocation.toMap(e))
      .toList();
    
    String stringToWrite = jsonEncode(locationsToWrite);
    var instance = await getInstance();
    instance.setString(SPKeys.location.name, stringToWrite);
  }

  static Future clearAllLocationDetails() async {
    var instance = await getInstance();
    await instance.remove(SPKeys.location.name);
  }
}