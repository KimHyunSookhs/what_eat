import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
 GoogleMapController? mapController;
 final LatLng _center = const LatLng(37.5665, 126.9780);

 void _onMapCreated(GoogleMapController controller){
   mapController = controller;
 }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Map'),
      ),body:  GoogleMap(initialCameraPosition: CameraPosition(target: _center, zoom: 11.0),onMapCreated: _onMapCreated,),
    );
  }
}
