import 'package:flutter/material.dart';
import 'location_page.dart';
import './utils/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'welcome_page.dart';
import 'loader_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    print('Error loading .env file: ${e.toString()}');
  }
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Location App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: isLoading
          ? LoaderPage() // Show loader while checking the userId
          : userId != null
          ? const LocationPage() // Navigate to LocationPage if userId exists
          : WelcomePage(), // Navigate to WelcomePage if userId is null
    );
  }
}
