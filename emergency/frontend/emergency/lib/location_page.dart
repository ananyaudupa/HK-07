import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'map_page.dart';
import 'package:http/http.dart' as http;
import './utils/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'location_service.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({Key? key}) : super(key: key);

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  String _location = "Unknown";
  Position? _currentUserPosition;
  String? message;
  String? userId;
  late StreamSubscription<Position> positionStream;
  Timer? updateTimer;

  @override
  void initState() {
    super.initState();
    _currentUserId();
    _startLocationTracking();
  }

  Future<void> _currentUserId() async {
    String? userID = await getUserId();
    setState(() {
      userId = userID;
    });
  }

  Future<void> _startLocationTracking() async {
    try {
      // Request the initial position
      Position position = await determinePosition();
      setState(() {
        _location = '${position.latitude}, ${position.longitude}';
        _currentUserPosition = position;
      });

      if (userId != null) {
        await _postOrUpdateLocation(userId!, position.latitude.toString(), position.longitude.toString());
      }

      // Subscribe to position changes and stream them to the server
      positionStream = Geolocator.getPositionStream().listen((Position? position) {
        if (position != null) {
          if (_currentUserPosition == null ||
              _currentUserPosition!.latitude != position.latitude ||
              _currentUserPosition!.longitude != position.longitude) {
            setState(() {
              _location = '${position.latitude}, ${position.longitude}';
              _currentUserPosition = position;
            });

            if (userId != null) {
              _postOrUpdateLocation(userId!, position.latitude.toString(), position.longitude.toString());
            }
          }
        }
      });

      // Set a timer to send the data to the server every few seconds
      _scheduleLocationUpdates();
    } catch (e) {
      setState(() {
        _location = 'Error: ${e.toString()}';
      });
    }
  }

  void _scheduleLocationUpdates() {
    updateTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (_currentUserPosition != null && userId != null) {
        _postOrUpdateLocation(userId!, _currentUserPosition!.latitude.toString(), _currentUserPosition!.longitude.toString());
      }
    });
  }

  Future<void> _postOrUpdateLocation(String userId, String latitude, String longitude) async {
    try {
      final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/api/locations/user/$userId'),
      );

      print("Fetch locations response: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> locations = jsonDecode(response.body);

        if (locations.isNotEmpty) {
          // Update existing location
          final locationId = locations[0]['_id'];
          final updateResponse = await http.put(
            Uri.parse('${dotenv.env['API_URL']}/api/locations/$locationId'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, String>{
              'latitude': latitude,
              'longitude': longitude,
            }),
          );

          print("Update response: ${updateResponse.body}");

          if (updateResponse.statusCode == 200) {
            setState(() {
              message = 'Location updated successfully!';
            });
          } else {
            setState(() {
              message = 'Failed to update location';
            });
          }
        } else {
          // No existing location, create a new one
          await _createLocation(userId, latitude, longitude);
        }
      } else {
        // If fetching existing location fails, create a new one
        await _createLocation(userId, latitude, longitude);
      }
    } catch (e) {
      setState(() {
        message = 'Error: ${e.toString()}';
      });
    }
  }

  Future<void> _createLocation(String userId, String latitude, String longitude) async {
    final createResponse = await http.post(
      Uri.parse('${dotenv.env['API_URL']}/api/locations/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'latitude': latitude,
        'longitude': longitude,
        'user': userId,
      }),
    );

    print("Create response: ${createResponse.body}");

    if (createResponse.statusCode == 201) {
      setState(() {
        message = 'Location added successfully!';
      });
    } else {
      setState(() {
        message = 'Failed to add location';
      });
    }



  }

  @override
  void dispose() {
    positionStream.cancel();
    updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentUserPosition == null || userId == null
          ? const Center(child: Text('Loading initial position...'))
          : MapSample(
        currentUserPosition: _currentUserPosition!,
        currentUserID: userId!,
      ),
    );
  }
}
