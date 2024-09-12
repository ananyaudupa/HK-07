import 'package:demo/register.dart';
import 'help_page.dart'; // Import the Help page

import 'package:flutter/material.dart';
import 'profile.dart';

class EmergencyWaveApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.green.shade50, Colors.blue.shade500],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Container( // Reduced margin
                    child: Image.asset(
                      'assets/Logo.png',
                      width: 200,
                      semanticLabel: 'Heart with medical cross',
                    ),
                  ),
                ),
                Text(
                  'Emergency Wave',
                  style: TextStyle(
                    fontSize: 45,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Welcome!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Your lifeline for faster emergency response. Emergency Wave helps ambulances move quickly through traffic by alerting nearby vehicles and traffic officials to clear the way. Input your destination, and\n let us handle the rest!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => profile()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.tealAccent.shade700, // Secondary color
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 32,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Get started',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white, // Secondary foreground color
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Help()), // Navigate to Help page
                    );
                  },
                  child: Text(
                    'Help?',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70, // Muted foreground color
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
