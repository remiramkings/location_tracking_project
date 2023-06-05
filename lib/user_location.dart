import 'dart:convert';

class UserLocation {
  double latitude;
  double longitude;
  DateTime timeStamp;
  UserLocation({required this.latitude, required this.longitude, required this.timeStamp});

  static Map<String, dynamic> toMap(UserLocation userLocation) =>
      {'latitude': userLocation.latitude, 'longitude': userLocation.longitude, 'timeStamp' : userLocation.timeStamp.millisecondsSinceEpoch};

  static UserLocation fromMap(Map<String, dynamic> userLocationMap){
    return UserLocation(latitude: userLocationMap['latitude'], 
     longitude: userLocationMap['longitude'], 
     timeStamp: DateTime.fromMillisecondsSinceEpoch(userLocationMap['timeStamp'])
    );
  }                                                                                                  
}
