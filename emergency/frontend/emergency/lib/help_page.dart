import 'package:flutter/material.dart';

class HelpPage extends StatefulWidget {
  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade900, Colors.black],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Healthcare Icon
                Image.asset(
                  'assets/Logo.png',
                  width: 200,
                  semanticLabel: 'Heart with medical cross',
                ),
                const SizedBox(height: 16),

                // Title
                const Text(
                  'Emergency Wave',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle
                const Text(
                  'Contact Us',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),

                // Contact Information Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  width: 300,
                  child: Column(
                    children: [
                      // Phone Number Row
                      Row(
                        children: const [
                          Icon(Icons.phone, color: Colors.grey),
                          SizedBox(width: 8),
                          Text(
                            '987654321',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),

                      // Email Row
                      Row(
                        children: const [
                          Icon(Icons.email, color: Colors.grey),
                          SizedBox(width: 8),
                          Text(
                            'abc@gmail.com',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),

      // Bottom Navigation Bar Placeholder
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent, // Keep background transparent
        child: SizedBox(
          height: 50,
          child: Center(
            child: Text(
              'Footer or Navigation Here',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
