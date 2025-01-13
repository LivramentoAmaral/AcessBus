import 'dart:async';
import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class ApiService {
  Timer? _locationUpdateTimer;

  Future<List<List<LatLng>>> fetchMultipleRoutes(
      List<Map<String, dynamic>> coordinates) async {
    List<List<LatLng>> allRoutes = [];

    for (int i = 0; i < coordinates.length - 1; i++) {
      final start = coordinates[i]['location'];
      final end = coordinates[i + 1]['location'];
      try {
        final route = await fetchRoute(start, end);
        allRoutes.add(route);
      } catch (e) {
        print("Erro ao buscar rota: $e");
      }
    }

    return allRoutes;
  }

  Future<List<LatLng>> fetchRoute(LatLng start, LatLng end) async {
    const apiKey = '5b3ce3597851110001cf6248362750b06b11431595a04b0687baea5a';
    final url =
        'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$apiKey&start=${start.longitude},${start.latitude}&end=${end.longitude},${end.latitude}';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['features'][0]['geometry']['coordinates'] as List)
          .map((coord) => LatLng(coord[1], coord[0]))
          .toList();
    } else {
      throw Exception('Erro ao obter rota: ${response.statusCode}');
    }
  }

  Future<void> startLocationUpdates(
      {required Function(LatLng) onLocationUpdate}) async {
    _locationUpdateTimer =
        Timer.periodic(const Duration(seconds: 1), (timer) async {
      final location = await _fetchBusLocation();
      onLocationUpdate(location);
    });
  }

  void stopLocationUpdates() {
    _locationUpdateTimer?.cancel();
  }

  Future<LatLng> _fetchBusLocation() async {
    const url = 'https://api-location-teal.vercel.app/api/location';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return LatLng(
        data["location"]['latitude'],
        data["location"]['longitude'],
      );
    } else {
      throw Exception('Erro ao buscar localização do ônibus');
    }
  }
}
