import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:acesstrans/Constants/coordinates.dart';
import 'package:acesstrans/core/theme/app_themes.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FlutterTts flutterTts = FlutterTts();
  LatLng _busLocation = LatLng(-10.43029, -45.174006);
  List<List<LatLng>> _allRoutes =
      []; // Lista contendo todas as rotas consecutivas

  @override
  void initState() {
    super.initState();
    _loadInitialRoutes(); // Carrega as rotas ao iniciar
  }

  Future<void> _loadInitialRoutes() async {
    try {
      final routes = await fetchMultipleRoutes(coordinates);
      setState(() {
        _allRoutes = routes; // Atualiza todas as rotas consecutivas
      });
    } catch (e) {
      print("Erro ao carregar rotas iniciais: $e");
      _speak("Erro ao carregar as rotas iniciais.");
    }
  }

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
        print(
            "Erro ao buscar rota de ${coordinates[i]['tooltip']} para ${coordinates[i + 1]['tooltip']}: $e");
      }
    }

    return allRoutes;
  }

  Future<List<LatLng>> fetchRoute(LatLng start, LatLng end) async {
    final apiKey = '5b3ce3597851110001cf6248362750b06b11431595a04b0687baea5a';
    final url =
        'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$apiKey&start=${start.longitude},${start.latitude}&end=${end.longitude},${end.latitude}';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<LatLng> route =
          (data['features'][0]['geometry']['coordinates'] as List)
              .map((coord) => LatLng(coord[1], coord[0]))
              .toList();

      if (route.isEmpty) {
        throw Exception('Nenhuma rota encontrada.');
      }

      return route;
    } else {
      throw Exception('Erro ao obter rota: ${response.statusCode}');
    }
  }

  Future<void> _speak(String text) async {
    await flutterTts.setLanguage("pt-BR");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppThemes.lightTheme.primaryColor,
        title: const Text(
          'Mapa do Trajeto',
          style: TextStyle(fontSize: 24),
        ),
      ),
      body: MapView(
        busLocation: _busLocation,
        allRoutes: _allRoutes, // Passa todas as rotas
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadInitialRoutes, // Recarregar as rotas
        tooltip: "Recarregar rotas",
        backgroundColor: AppThemes.lightTheme.primaryColor,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

class MapView extends StatelessWidget {
  final LatLng busLocation;
  final List<List<LatLng>> allRoutes; // Lista de todas as rotas

  const MapView({
    Key? key,
    required this.busLocation,
    required this.allRoutes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: busLocation,
        initialZoom: 13.0,
      ),
      children: [
        TileLayer(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: ['a', 'b', 'c'],
          additionalOptions: const {
            'attribution': '© OpenStreetMap',
          },
        ),
        // Desenhando todas as rotas no mapa
        PolylineLayer(
          polylines: allRoutes.asMap().entries.map((entry) {
            final index = entry.key;
            final route = entry.value;

            // Se for rota de retorno (após a Parada 7), desenhar em vermelho
            final isReturnRoute = index >= 6; // Parada 7 tem índice 6
            return Polyline(
              points: route,
              color: isReturnRoute
                  ? const Color.fromARGB(255, 54, 244, 86)
                  : Colors.blueAccent,
              strokeWidth: 4.0,
            );
          }).toList(),
        ),
        MarkerLayer(
          markers: coordinates.where((coord) {
            // Remove as paradas 8 e 10
            return coord['tooltip'] != '9ª Parada' &&
                coord['tooltip'] != '11ª Parada';
          }).map((coord) {
            return Marker(
              point: coord['location'],
              child: IconButton(
                icon:
                    const Icon(Icons.location_on, size: 40, color: Colors.red),
                onPressed: () {
                  // Ação para cada marcador
                },
                tooltip: coord['tooltip'],
              ),
            );
          }).toList()
            ..add(
              Marker(
                point: busLocation,
                child: IconButton(
                  icon: const Icon(Icons.directions_bus,
                      size: 40, color: Color.fromARGB(255, 2, 45, 80)),
                  onPressed: () {
                    // Ação ao clicar no ônibus
                  },
                  tooltip: "Localização do ônibus",
                ),
              ),
            ),
        ),
      ],
    );
  }
}
