import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationSenderPage extends StatefulWidget {
  @override
  _NotificationSenderPageState createState() => _NotificationSenderPageState();
}

class _NotificationSenderPageState extends State<NotificationSenderPage> {
  final TextEditingController _ambulanceController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  bool _isLoading = false;

  Future<void> sendNotification(String token, String messageTitle, String messageBody) async {
    const String serverKey = 'firebase-adminsdk-bdiku@emergency-8c549.iam.gserviceaccount.com'; // 🚨 Put your real server key here!
    final url = Uri.parse('https://fcm.googleapis.com/fcm/send');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverKey',
      },
      body: jsonEncode({
        'to': token,
        'notification': {
          'title': messageTitle,
          'body': messageBody,
        },
        'priority': 'high',
      }),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Error sending notification: ${response.statusCode}');
    }
  }

  Future<void> notifyUser() async {
    setState(() {
      _isLoading = true;
    });

    String ambulanceId = _ambulanceController.text.trim();
    String title = _titleController.text.trim();
    String body = _bodyController.text.trim();

    if (ambulanceId.isEmpty || title.isEmpty || body.isEmpty) {
      _showError('All fields are required!');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    String? token = await _getUserFCMToken(ambulanceId);
    if (token != null) {
      await sendNotification(token, title, body);
      _showSuccess('Notification sent to $ambulanceId');
    } else {
      _showError('Failed to fetch token for $ambulanceId');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<String?> _getUserFCMToken(String ambulanceId) async {
    try {
      final userdata = await http.get(Uri.parse('${dotenv.env['API_URL']}/api/user/$ambulanceId'));
      if (userdata.statusCode == 200) {
        final user = jsonDecode(userdata.body);
        return user['fcmToken']; // Assuming the token's in the backend, as you mentioned 😎
      }
    } catch (e) {
      print('Error fetching FCM token: $e');
    }
    return null;
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text('OK'))
        ],
      ),
    );
  }

  void _showSuccess(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Success 🎉'),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text('Awesome!'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Send Notification 🚑'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _ambulanceController,
              decoration: InputDecoration(labelText: 'Ambulance ID'),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Message Title'),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _bodyController,
              decoration: InputDecoration(labelText: 'Message Body'),
            ),
            SizedBox(height: 16),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: notifyUser,
              child: Text('Send Notification 🚀'),
            ),
          ],
        ),
      ),
    );
  }
}
