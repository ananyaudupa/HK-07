import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'login_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'userdetail.dart'; // Import UserDetailsPage
import 'userViewab.dart';
import 'polyline_map.dart';

class MapSample extends StatefulWidget {
  final Position currentUserPosition;
  final String currentUserID;

  const MapSample({Key? key, required this.currentUserPosition, required this.currentUserID})
      : super(key: key);

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  Set<Marker> _markers = {};
  Timer? _updateTimer;
  bool _initialZoomDone = false;
  final apiUrl = dotenv.env['API_URL'] ?? '';

  @override
  void initState() {
    super.initState();
    _setCurrentLocationMarker();
    _fetchOtherUsersLocations();
    _startPeriodicUpdates();
  }


  void _setCurrentLocationMarker() {
    setState(() {
      _markers.add(
        Marker(
          markerId: const MarkerId('currentLocation'),
          position: LatLng(widget.currentUserPosition.latitude, widget.currentUserPosition.longitude),
          infoWindow: const InfoWindow(title: 'Your Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    });
  }

  Future<void> _updateCurrentLocationMarker() async {
    setState(() {
      _markers.removeWhere((marker) => marker.markerId.value == 'currentLocation');
      _markers.add(
        Marker(
          markerId: const MarkerId('currentLocation'),
          position: LatLng(widget.currentUserPosition.latitude, widget.currentUserPosition.longitude),
          infoWindow: const InfoWindow(title: 'Your Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    });
    _updateMapCamera();
  }

  Future<String> _fetchUsername(String amulance) async {
    try {
      final userdata = await http.get(Uri.parse('$apiUrl/api/user/$amulance'));
      if (userdata.statusCode == 200) {
        final user = jsonDecode(userdata.body);
        return user['username'] ?? 'Unknown' ; // Handle null case
      }
    } catch (e) {
      print('Error fetching username: $e');
    }
    return 'Unknown'; // Default username in case of failure
  }


    Future<bool> _fetchamulancedriver(String amulance) async {
    try {
      final userdata = await http.get(Uri.parse('$apiUrl/api/user/$amulance'));
      if (userdata.statusCode == 200) {
        final user = jsonDecode(userdata.body);
        return user['ambulance_Driver'] == true; // Handle null case
      }
    } catch (e) {
      print('Error fetching username: $e');
    }
    return false; // Default username in case of failure
  }



  Future<void> _fetchOtherUsersLocations() async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/api/locations/'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('Response Data: ${response.body}');

        final Set<Marker> newMarkers = {};

        for (var userLocation in data) {
          double latitude = double.parse(userLocation['latitude'].toString());
          double longitude = double.parse(userLocation['longitude'].toString());
          String id = userLocation['_id'];
          String amulance = userLocation['user'];
          bool non_amulancedriver = await _fetchamulancedriver(amulance);

          if (widget.currentUserID == amulance || !non_amulancedriver) {
            continue;
          }

          String username = await _fetchUsername(amulance);

          newMarkers.add(
            Marker(
              markerId: MarkerId('user_$id'),
              position: LatLng(latitude, longitude),
              infoWindow: InfoWindow(title: 'User Location: $username'),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CallingAb(ambulanceDriverId: amulance),
                  ),
                );
              },
            ),
          );
        }

        setState(() {
          _markers.removeWhere((marker) => marker.markerId.value.startsWith('user_'));
          _markers.addAll(newMarkers);
        });
      } else {
        print('Failed to load other users\' locations');
      }
    } catch (e) {
      print('Error fetching locations: $e');
    }
  }

  void _updateMapCamera() async {
    final GoogleMapController controller = await _controller.future;

    if (!_initialZoomDone) {
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(widget.currentUserPosition.latitude, widget.currentUserPosition.longitude),
          zoom: 15,
        ),
      ));

      setState(() {
        _initialZoomDone = true;
      });
    }
  }

  void _startPeriodicUpdates() {
    _updateTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _updateCurrentLocationMarker();
      _fetchOtherUsersLocations();
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Map"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.currentUserPosition.latitude, widget.currentUserPosition.longitude),
          zoom: 15,
        ),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
          _updateMapCamera();
        },
        markers: _markers,
      ),

    );
  }
}
