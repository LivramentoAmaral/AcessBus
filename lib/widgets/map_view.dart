import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:latlong2/latlong.dart';
import 'package:acesstrans/Constants/coordinates.dart';
import 'package:location/location.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class MapView extends StatefulWidget {
  final LatLng busLocation;
  final List<List<LatLng>> allRoutes;
  final Function(LatLng, String, String) onMarkerTapped;

  // ignore: use_super_parameters
  const MapView({
    Key? key,
    required this.busLocation,
    required this.allRoutes,
    required this.onMarkerTapped,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final MapController _mapController = MapController();
  final FlutterTts _flutterTts = FlutterTts();
  final Distance _distanceCalculator = const Distance();
  final Location _location = Location();
  final stt.SpeechToText _speechToText = stt.SpeechToText();

  LocationData? _currentLocation;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initLocationService();
    _initSpeechRecognition();
  }

  Future<void> _initLocationService() async {
    if (!await _ensureLocationServiceEnabled()) return;
    if (!await _ensureLocationPermissionGranted()) return;

    try {
      final location = await _location.getLocation();
      setState(() {
        _currentLocation = location;
      });
    } catch (e) {
      // ignore: avoid_print
      print("Erro ao obter localização: $e");
    }
  }

  Future<bool> _ensureLocationServiceEnabled() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
    }
    // ignore: avoid_print
    if (!serviceEnabled) print("Serviço de localização desabilitado.");
    return serviceEnabled;
  }

  Future<bool> _ensureLocationPermissionGranted() async {
    PermissionStatus permission = await _location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await _location.requestPermission();
    }
    if (permission != PermissionStatus.granted) {
      // ignore: avoid_print
      print("Permissão de localização negada.");
      return false;
    }
    return true;
  }

  Future<void> _initSpeechRecognition() async {
    bool available = await _speechToText.initialize(
      // ignore: avoid_print
      onStatus: (status) => print("Status: $status"),
      // ignore: avoid_print
      onError: (error) => print("Erro: $error"),
    );

    if (!available) {
      // ignore: avoid_print
      print("Reconhecimento de voz não disponível.");
    }
  }

  void _startListening() async {
    if (!_isListening && await _speechToText.initialize()) {
      setState(() => _isListening = true);

      _speechToText.listen(onResult: (result) {
        if (result.recognizedWords.toLowerCase().contains("busão")) {
          _speakTimeToArrival();
        }
      });
    }
  }

  void _stopListening() async {
    if (_isListening) {
      await _speechToText.stop();
      setState(() => _isListening = false);
    }
  }

  void _speakNearestStop() async {
    if (_currentLocation == null) {
      await _speakMessage("Não foi possível determinar sua localização.");
      return;
    }

    final nearestStop = _findNearestStop();
    if (nearestStop == null) {
      await _speakMessage("Não foi possível determinar a parada mais próxima.");
      return;
    }

    final stopName = nearestStop['tooltip'];
    final stopLocation = nearestStop['location'];
    final distance = _calculateDistance(
      LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
      stopLocation,
    );

    final message =
        "Você está a aproximadamente ${distance.toStringAsFixed(2)} quilômetros da parada $stopName.";
    await _speakMessage(message);
  }

  void _speakTimeToArrival() async {
    if (_currentLocation == null) {
      await _speakMessage("Não foi possível determinar sua localização.");
      return;
    }

    final nearestStop = _findNearestStop();
    if (nearestStop == null) {
      await _speakMessage("Não foi possível determinar a parada mais próxima.");
      return;
    }

    final stopLocation = nearestStop['location'];
    final busDistance = _calculateDistance(widget.busLocation, stopLocation);
    const busSpeedKmPerHour = 40; // Velocidade média do ônibus em km/h
    final timeToArrival =
        (busDistance / busSpeedKmPerHour) * 60; // Tempo em minutos

    final message =
        "O ônibus chegará à parada mais próxima em aproximadamente ${timeToArrival.toStringAsFixed(1)} minutos.";
    await _speakMessage(message);
  }

  Future<void> _speakMessage(String message) async {
    await _flutterTts.setLanguage("pt-BR");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.speak(message);
  }

  double _calculateDistance(LatLng point1, LatLng point2) {
    return _distanceCalculator.as(LengthUnit.Kilometer, point1, point2);
  }

  Map<String, dynamic>? _findNearestStop() {
    if (_currentLocation == null) return null;

    LatLng userLocation =
        LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!);
    double? smallestDistance;
    Map<String, dynamic>? nearestStop;

    for (var stop in coordinates) {
      final stopLocation = stop['location'] as LatLng;
      final distance = _calculateDistance(userLocation, stopLocation);

      if (smallestDistance == null || distance < smallestDistance) {
        smallestDistance = distance;
        nearestStop = stop;
      }
    }

    return nearestStop;
  }

  void _centerMapOnBus() {
    _mapController.move(widget.busLocation, 16.0);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: widget.busLocation,
            initialZoom: 14.0,
            maxZoom: 18.0, // Zoom máximo
          ),
          children: [
            TileLayer(
              urlTemplate:
                  "https://a.tile.openstreetmap.fr/osmfr/{z}/{x}/{y}.png",
              subdomains: const ['a', 'b', 'c'],
            ),
            PolylineLayer(
              polylines: widget.allRoutes.asMap().entries.map((entry) {
                final index = entry.key;
                final route = entry.value;

                final isReturnRoute = index >= 6;
                return Polyline(
                  points: route,
                  color: isReturnRoute
                      ? const Color.fromARGB(255, 54, 244, 86)
                      : Colors.blueAccent,
                  strokeWidth: 6.0,
                  borderColor: Colors.white,
                  borderStrokeWidth: 2.0, // Borda suave nas rotas
                );
              }).toList(),
            ),
            MarkerLayer(
              markers: coordinates.where((coord) {
                return coord['tooltip'] != '9ª Parada' &&
                    coord['tooltip'] != '11ª Parada';
              }).map((coord) {
                return Marker(
                  point: coord['location'],
                  child: GestureDetector(
                    onTap: () {
                      widget.onMarkerTapped(
                          coord['location'], coord['tooltip'], coord['popup']);
                    },
                    child: Container(
                      width: 100, // Largura do marcador
                      height: 100, // Altura do marcador
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blueAccent.withOpacity(0.0),
                      ),
                      child: const Center(
                        // Garante que o ícone fique centralizado
                        child: Icon(
                          Icons.location_on,
                          size: 50, // Tamanho do ícone
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: widget.busLocation,
                  child: Semantics(
                    label: "Localização atual do ônibus",
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color.fromARGB(255, 40, 41, 40)
                            .withOpacity(0.0),
                      ),
                      child: const Icon(
                        Icons.directions_bus,
                        size: 50,
                        color: Color.fromARGB(255, 44, 43, 43),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FloatingActionButton(
                onPressed: _centerMapOnBus,
                backgroundColor: Colors.black87,
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.my_location,
                  color: Color.fromARGB(255, 190, 74, 74),
                ),
              ),
              const SizedBox(height: 10),
              FloatingActionButton(
                onPressed: _speakNearestStop,
                backgroundColor: Colors.blueAccent,
                // ignore: sort_child_properties_last
                child: const Icon(
                  Icons.record_voice_over,
                  color: Colors.white,
                ),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              const SizedBox(height: 10),
              FloatingActionButton(
                onPressed: _speakTimeToArrival,
                backgroundColor: Colors.orangeAccent,
                // ignore: sort_child_properties_last
                child: const Icon(
                  Icons.directions_bus,
                  color: Colors.white,
                ),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 40,
          right: 20,
          child: FloatingActionButton(
            onPressed: _isListening ? _stopListening : _startListening,
            backgroundColor: Colors.redAccent,
            child: Icon(_isListening ? Icons.mic_off : Icons.mic),
          ),
        ),
      ],
    );
  }
}
