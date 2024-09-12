import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserDetailsPage extends StatelessWidget {
  final String userId;

  const UserDetailsPage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
      ),
      body: FutureBuilder(
        future: _fetchUserDetails(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading user data'));
          } else if (snapshot.hasData) {
            final user = snapshot.data as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Username: ${user['username']}', style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 10),
                  Text('Email: ${user['email']}', style: const TextStyle(fontSize: 18)),
                  // Add other user details as needed
                ],
              ),
            );
          } else {
            return const Center(child: Text('No user data found'));
          }
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _fetchUserDetails(String userId) async {
    final apiUrl = dotenv.env['API_URL'] ?? '';
    final response = await http.get(Uri.parse('$apiUrl/api/user/$userId'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load user data');
    }
  }
}
