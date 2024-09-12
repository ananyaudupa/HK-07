// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'location_page.dart';
import 'package:http/http.dart' as http;
import './utils/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';


class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _vechileNoController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  bool _isAmbulanceDriver = false;
  bool isLoading = false;
  String errorMessage = '';
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    dotenv.load(); // Ensure dotenv is loaded
    // _checkLoggedInUser();
  }

  Future<void> _login() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
      userData = null;
    });

    final String username = _usernameController.text;
    final String phone = _phoneController.text;
    final String vechileNo = _vechileNoController.text;
    final String city = _cityController.text;

    if (username.isEmpty || phone.isEmpty || vechileNo.isEmpty || city.isEmpty) {
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
          'vechileNo': vechileNo,
          'city': city,
          'ambulance_Driver': _isAmbulanceDriver,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['message'] == 'User created successfully') {
          await saveUserId(data['_id']); // Save user ID to SharedPreferences
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LocationPage()),
          );
        }
      } else {
        setState(() {
          errorMessage = 'Invalid username, phone number, city, or ambulance status.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error logging in: ${e.toString()}';
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade50, Colors.blue.shade500],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/Logo.png',
                      width: 200,
                      semanticLabel: 'Heart with medical cross',
                    ),
                  ),
                  Text(
                    'Emergency Wave',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Register',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white,
                          blurRadius: 0.0,
                          spreadRadius: 2.0,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            labelText: 'Phone',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: _vechileNoController,
                          decoration: InputDecoration(
                            labelText: 'Vehicle No',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: _cityController,
                          decoration: InputDecoration(
                            labelText: 'City',
                            border: OutlineInputBorder(),
                          ),
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
                        SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.tealAccent.shade700,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading
                              ? CircularProgressIndicator(
                            color: Colors.white,
                          )
                              : Text(
                            "Let's go!",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        if (errorMessage.isNotEmpty)
                          Text(
                            errorMessage,
                            style: TextStyle(color: Colors.red),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
