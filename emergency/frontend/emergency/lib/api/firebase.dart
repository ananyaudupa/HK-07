import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseService {
  // Initialize Firebase in your app
  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
  }

  // Firebase Messaging instance
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Get Firebase Messaging Token
  Future<String?> getFirebaseToken() async {
    try {
      String? token = await _messaging.getToken();
      print('Firebase Messaging Token: $token');
      return token;
    } catch (e) {
      print('Error getting Firebase Messaging Token: $e');
      return null;
    }
  }

  // Subscribe to a topic (for notifications)
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      print('Subscribed to $topic');
    } catch (e) {
      print('Error subscribing to $topic: $e');
    }
  }

  // Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      print('Unsubscribed from $topic');
    } catch (e) {
      print('Error unsubscribing from $topic: $e');
    }
  }

  // Request notification permissions (for iOS)
  Future<void> requestNotificationPermissions() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('Notification permission status: ${settings.authorizationStatus}');
  }

  // Listen to foreground notifications
  void onMessageListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a message in the foreground: ${message.notification?.title} - ${message.notification?.body}');
    });
  }
}
