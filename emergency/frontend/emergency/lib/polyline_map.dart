import 'dart:convert'; // Import for jsonDecode
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:math';

Future<String> shortDistance(String userId) async {
  try {
    final response = await http.get(Uri.parse('${dotenv.env['API_URL']}/api/locations'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      // Fetch user location
      final userLocationResponse = await http.get(Uri.parse('${dotenv.env['API_URL']}/api/user/$userId'));
      if (userLocationResponse.statusCode != 200) return '';

      final userLocation = jsonDecode(userLocationResponse.body);
      double userLat = userLocation['latitude'];
      double userLon = userLocation['longitude'];

      double shortestDistance = double.infinity;
      String closestAmbulanceDriverId = '';

      for (var location in data) {
        double lat = double.parse(location['latitude'].toString());
        double lon = double.parse(location['longitude'].toString());
        String ambulanceDriverId = location['user'];

        bool isAmbulanceDriver = await _fetchAmbulanceDriverStatus(ambulanceDriverId);
        if (isAmbulanceDriver) {
          double distance = _calculateDistance(userLat, userLon, lat, lon);
          if (distance < shortestDistance) {
            shortestDistance = distance;
            closestAmbulanceDriverId = ambulanceDriverId;
          }
        }
      }

      return closestAmbulanceDriverId;
    } else {
      return ''; // Handle failed API response
    }
  } catch (e) {
    return ''; // Handle exceptions
  }
}

Future<bool> _fetchAmbulanceDriverStatus(String userId) async {
  try {
    final response = await http.get(Uri.parse('${dotenv.env['API_URL']}/api/user/$userId'));

    if (response.statusCode == 200) {
      final user = jsonDecode(response.body);
      return user['ambulance_Driver'] == true;
    }
  } catch (e) {
    print('Error fetching ambulance driver status: ${e.toString()}');
  }
  return false;
}

double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const double earthRadius = 6371; // Radius of Earth in kilometers

  double dLat = _degreesToRadians(lat2 - lat1);
  double dLon = _degreesToRadians(lon2 - lon1);

  double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
          sin(dLon / 2) * sin(dLon / 2);

  double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return earthRadius * c;
}

double _degreesToRadians(double degrees) {
  return degrees * pi / 180;
}
