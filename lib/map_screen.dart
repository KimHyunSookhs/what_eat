import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  LocationData? _currentLocation;
  Set<Marker> markers = {};

  final Location location = Location();

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    final locationData = await location.getLocation();
    setState(() {
      _currentLocation = locationData;
    });
    if (_currentLocation != null) {
      fetchNearbyRestaurants(
        _currentLocation!.latitude!,
        _currentLocation!.longitude!,
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (_currentLocation != null) {
      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              _currentLocation!.latitude!,
              _currentLocation!.longitude!,
            ),
            zoom: 17.0,
          ),
        ),
      );
    }
  }

  Future<void> fetchNearbyRestaurants(double lat, double lng) async {
    final String apiKey = dotenv.env['Google_Map_API_KEY']!;
    final String url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
        '?location=$lat,$lng'
        '&radius=1000'
        '&type=restaurant'
        '&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];

      for (var place in results) {
        final name = place['name'];
        final lat = place['geometry']['location']['lat'];
        final lng = place['geometry']['location']['lng'];

        // 마커 추가 예시
        markers!.add(
          Marker(
            markerId: MarkerId(name),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(title: name),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
          ),
        );
      }
      setState(() {}); // 마커 반영
    } else {
      throw Exception('Failed to load nearby restaurants');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Google Map')),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: LatLng(
            _currentLocation!.latitude!,
            _currentLocation!.longitude!,
          ),
          zoom: 4.0,
        ),
        onMapCreated: _onMapCreated,
        markers: markers,
        //현재 위치 점으로 표시
        myLocationEnabled: true,
        //현재 위치로 카메라 이동 버튼
        myLocationButtonEnabled: true,
      ),
    );
  }
}
