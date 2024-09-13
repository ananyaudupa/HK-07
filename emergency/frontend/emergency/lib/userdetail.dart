import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'loader_page.dart';
import './utils/shared_preferences.dart'; // Import your shared preferences utility
import 'package:url_launcher/url_launcher.dart';

class UserProfile extends StatefulWidget {
  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String errorMessage = '';
  String? userId;

  TextEditingController phoneController = TextEditingController();
  TextEditingController cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    dotenv.load(); // Load environment variables
    _currentUserId(); // Fetch the current userId from SharedPreferences
  }

  @override
  void dispose() {
    phoneController.dispose();
    cityController.dispose();
    super.dispose();
  }

  // Function to fetch the userId from SharedPreferences
  Future<void> _currentUserId() async {
    String? fetchedUserId = await getUserId(); // Fetch userId from SharedPreferences
    setState(() {
      userId = fetchedUserId;
    });
    if (userId != null) {
      _fetchUserData(userId!); // Fetch user data only if userId is available
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
          phoneController.text = userData!['phone'] ?? 'N/A';
          cityController.text = userData!['city'] ?? 'N/A';
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return LoaderPage();
    }

    if (errorMessage.isNotEmpty) {
      return Scaffold(
        body: Center(child: Text(errorMessage)),
      );
    }

    if (userData != null && userData!['ambulance_Driver'] == false) {
      return MaterialApp(
        home: Scaffold(
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
                          ListTile(
                            leading: Icon(Icons.call),
                            title: Text('Phone no:'),
                            subtitle: Text(userData!['phone'] ?? 'N/A'),
                          ),
                          ListTile(
                            leading: Icon(Icons.location_city),
                            title: Text('City:'),
                            subtitle: Text(userData!['city'] ?? 'N/A'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
        body: Center(
          child: Text(
            'This profile is only available for User',
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
        ),
      );
    }
  }
}
