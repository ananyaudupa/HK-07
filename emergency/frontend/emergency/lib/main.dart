import 'package:flutter/material.dart';
import './api/firebase.dart'; // Import your firebase.dart
import 'location_page.dart';
import './utils/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'welcome_page.dart';
import 'loader_page.dart';
import 'amulance_profile.dart'; // Import AmulanceProfile page
import 'help_page.dart'; // Import Help page
import 'location_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    print('Error loading .env file: ${e.toString()}');
  }

  await FirebaseService.initializeFirebase(); // Initialize Firebase

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? userId;
  bool isLoading = true;
  int _selectedIndex = 0; // Selected index for BottomNavigationBar

  @override
  void initState() {
    super.initState();
    _currentUserId();
  }

  Future<void> _currentUserId() async {
    String? userID = await getUserId(); // Fetch userId from SharedPreferences
    setState(() {
      userId = userID;
      isLoading = false; // Stop loading once the userId is fetched
    });
  }

  // Method to switch between different pages
  Widget _getSelectedPage() {
    switch (_selectedIndex) {
      case 0:
        return const LocationPage(); // Replace with your Home/Location page
      case 1:
        return  AmulanceProfile(); // Replace with your Profile page
      case 2:
        return HelpPage(); // Replace with your Help page
      default:
        return const LocationPage(); // Default page is Home
    }
  }

  // Method to handle BottomNavigationBar item taps
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Location App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: isLoading
          ?  LoaderPage(): userId == null ?  WelcomePage(): // Show loader while checking the userId
           Scaffold(
        body: _getSelectedPage(), // Display the selected page
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          elevation: 0, // Removes the shadow for a clean transparent look
          backgroundColor: Colors.black, // Make the bar black
          selectedItemColor: Colors.blue.shade600,
          unselectedItemColor: Colors.white,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.help),
              label: 'Help',
            ),
          ],
        ),
      ),
    );
  }
}
