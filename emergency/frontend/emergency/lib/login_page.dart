import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import './utils/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'location_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  bool _isAmbulanceDriver = false;
  bool isLoading = false;
  String errorMessage = '';
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    dotenv.load(); // Ensure dotenv is loaded
    _checkLoggedInUser();
  }

  Future<void> _checkLoggedInUser() async {
    String? id = await getUserId();
    if (id != null) {
      await _fetchUserData(id);
    }
  }

  Future<void> _fetchUserData(String id) async {
    try {
      final userResponse = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/api/user/$id'),
      );

      if (userResponse.statusCode == 200) {
        if (mounted) { // Check if the widget is still in the tree
          setState(() {
            userData = jsonDecode(userResponse.body);
          });
        }
      }
    } catch (e) {
      if (mounted) { // Check if the widget is still in the tree
        setState(() {
          errorMessage = 'Error fetching user data: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _login() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
      userData = null;
    });

    final String username = _usernameController.text;
    final String phone = _phoneController.text;
    final String city = _cityController.text;
    final bool ambulanceDriver = _isAmbulanceDriver;

    if (username.isEmpty || phone.isEmpty || city.isEmpty) {
      setState(() {
        isLoading = false;
        errorMessage = 'All fields are required.';
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('${dotenv.env['API_URL']}/api/user/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'phone': phone,
          'city': city,
          'ambulance_Driver': ambulanceDriver,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['message'] == 'User created successfully') {
          await saveUserId(data['_id']); // Save user ID to SharedPreferences
          // await _fetchUserData(data['_id']);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LocationPage()), // Replace with your desired page
          );
        }
      } else {
        if (mounted) { // Check if the widget is still in the tree
          setState(() {
            errorMessage =
            'Invalid username, phone number, city, or ambulance status.';
          });
        }
      }
    } catch (e) {
      if (mounted) { // Check if the widget is still in the tree
        setState(() {
          errorMessage = 'Error logging in: ${e.toString()}';
        });
      }
    }

    if (mounted) { // Check if the widget is still in the tree
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // Back icon
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (userData == null) ...[
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: _cityController,
                decoration: InputDecoration(labelText: 'City'),
              ),
              Row(
                children: [
                  Checkbox(
                    value: _isAmbulanceDriver,
                    onChanged: (value) {
                      setState(() {
                        _isAmbulanceDriver = value ?? false;
                      });
                    },
                  ),
                  Text('Are you an Ambulance Driver?'),
                ],
              ),
              SizedBox(height: 20),
              isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _login,
                child: Text('Login'),
              ),
              SizedBox(height: 20),
              Text(
                errorMessage,
                style: TextStyle(color: Colors.red),
              ),
            ] else ...[
              Text('Username: ${userData!['username']}'),
              Text('Phone: ${userData!['phone']}'),
              Text('City: ${userData!['city']}'),
              Text(
                  'Ambulance Driver: ${userData!['ambulance_Driver'] ? 'Yes' : 'No'}'),
            ]
          ],
        ),
      ),
    );
  }
}
