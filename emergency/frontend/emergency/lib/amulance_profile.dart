import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'loader_page.dart';
import './utils/shared_preferences.dart'; // Import your shared preferences utility
import 'package:url_launcher/url_launcher.dart';
import 'polyline_map.dart';
import 'userViewab.dart';

class AmulanceProfile extends StatefulWidget {
  @override
  _AmulanceProfileState createState() => _AmulanceProfileState();
}

class _AmulanceProfileState extends State<AmulanceProfile> {
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

  Future<void> _handleIsactive() async {
    if (userId == null || userData == null) return;

    bool newStatus = !(userData!['isactive'] ?? true); // Toggle status
    try {
      final response = await http.put(
        Uri.parse('${dotenv.env['API_URL']}/api/locations/isactive/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'isactive': newStatus}),
      );

      if (response.statusCode == 200) {
        // Check if the response body contains the expected data
        final responseBody = jsonDecode(response.body);
        if (responseBody['success'] == true) {  // Check if your backend sends a success message
          setState(() {
            userData!['isactive'] = newStatus;
          });
        } else {
          setState(() {
            errorMessage = 'Status update failed: ${responseBody['message']}';
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to update status: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error updating status: ${e.toString()}';
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

  // Function to handle emergency button press
  void _handleEmergency() async {
    if (userId != null) {
      String closestAmbulanceDriverId = await shortDistance(userId!);
      debugPrint(userId);
      if (closestAmbulanceDriverId.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CallingAb(ambulanceDriverId: closestAmbulanceDriverId),
          ),
        );
      } else {
        setState(() {
          errorMessage = 'No nearby ambulance drivers found';
        });
      }
    } else {
      setState(() {
        errorMessage = 'No user ID available for emergency';
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

    if (userData != null && userData!['ambulance_Driver'] == true) {
      // Ambulance Driver Profile Layout
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
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _handleIsactive, // Trigger the _handleIsactive function
                    icon: Icon(
                      userData!['isactive'] == true ? Icons.check_circle : Icons.cancel, // Icon changes based on status
                    ),
                    label: Text(
                      userData!['isactive'] == true ? 'Active' : 'Inactive', // Button text changes based on status
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: userData!['isactive'] == true ? Colors.green : Colors.red, // Button color changes based on status
                    ),
                  ),

                ],
              ),
            ),
          ),
        ),
      );
    } else if (userData != null && userData!['ambulance_Driver'] == false) {
      // Non-Ambulance Driver Profile Layout
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
                  colors: [Colors.orange.shade900, Colors.black],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade900, Colors.black],
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
                    'User',
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
                  // Emergency Button
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _handleEmergency, // Trigger the emergency function
                    icon: Icon(Icons.warning),
                    label: Text('Emergency'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Red button for emergency
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
            'This profile is only available for users.',
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
        ),
      );
    }
  }
}
