import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'loader_page.dart';
import './utils/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart'; // For calling functionality

class CallingAb extends StatefulWidget {
  final String ambulanceDriverId;

  const CallingAb({Key? key, required this.ambulanceDriverId}) : super(key: key);

  @override
  _CallingAbState createState() => _CallingAbState();
}

class _CallingAbState extends State<CallingAb> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String errorMessage = '';
  String? userId;
  String? id; // Holds the modified ID after removing 'user_' prefix

  @override
  void initState() {
    super.initState();
    _loadEnvAndFetchUser(); // Load environment variables and fetch user data
  }

  // Function to load environment variables and modify the ID, then fetch user data
  Future<void> _loadEnvAndFetchUser() async {
    await dotenv.load(); // Load environment variables

    // Modify the ID by removing 'user_' prefix (if present)
    id = widget.ambulanceDriverId.startsWith('user_')
        ? widget.ambulanceDriverId.substring(5)
        : widget.ambulanceDriverId;

    // Fetch the userId from SharedPreferences (if needed)
    String? fetchedUserId = await getUserId();

    setState(() {
      userId = fetchedUserId;
    });

    if (userId != null) {
      _fetchUserData(id!); // Fetch user data using the modified ID
    } else {
      setState(() {
        errorMessage = 'No user ID found';
        isLoading = false;
      });
    }
  }

  // Fetch user data using the API
  Future<void> _fetchUserData(String id) async {
    try {
      final userResponse = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/api/user/$id'),
      );

      if (userResponse.statusCode == 200) {
        setState(() {
          userData = jsonDecode(userResponse.body);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to fetch user data';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching user data: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  // Function to make the call
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunch(launchUri.toString())) {
      await launch(launchUri.toString());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch call')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return LoaderPage(); // Loading page
    }

    if (errorMessage.isNotEmpty) {
      return Scaffold(
        body: Center(child: Text(errorMessage)),
      );
    }

    if (userData != null && userData!['ambulance_Driver'] == true) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade900, Colors.black],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade900, Colors.black],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                CircleAvatar(
                  child: Icon(Icons.person_outline, size: 50),
                  radius: 55,
                ),
                SizedBox(height: 10),
                Text(
                  userData!['username'] ?? 'Name not available',
                  style: TextStyle(fontSize: 30, color: Colors.white),
                ),
                Text(
                  'Ambulance Driver',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: [
                            Icon(Icons.call),
                            SizedBox(width: 10),
                            Text(
                              'Phone no: ${userData!['phone'] ?? 'N/A'}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.location_city),
                            SizedBox(width: 10),
                            Text(
                              'City: ${userData!['city'] ?? 'N/A'}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Trigger the call
            String phoneNumber = userData!['phone'] ?? 'N/A';
            if (phoneNumber != 'N/A') {
              _makePhoneCall(phoneNumber);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Phone number not available')),
              );
            }
          },
          backgroundColor: Colors.green,
          child: Icon(
            Icons.call,
            color: Colors.white,
            size: 30,
          ),
        ),
      );
    } else {
      return Scaffold(
        body: Center(
          child: Text(
            'This profile is only available for ambulance drivers.',
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
        ),
      );
    }
  }
}
