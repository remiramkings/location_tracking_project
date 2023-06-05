import 'package:flutter/material.dart';
import 'package:live_location_tracking_app/shared_preference_service.dart';
import 'package:live_location_tracking_app/user_location.dart';


class LocationListingTile extends StatefulWidget {
  UserLocation userLocation;
   LocationListingTile({super.key, required this.userLocation});

  @override
  State<LocationListingTile> createState() => LocationListingTileState();
}
 
class LocationListingTileState extends State<LocationListingTile> {
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey,
      width: 1))),
      padding: EdgeInsets.all(15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [Text('${widget.userLocation.latitude}|(${widget.userLocation.longitude})')],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [Text('${widget.userLocation.timeStamp}')],
          )
        ],
      ),
    );
  }
}
