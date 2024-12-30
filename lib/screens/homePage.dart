import 'dart:convert';
import 'package:http/http.dart' as http; // Importando para fazer requisições HTTP
import 'package:acesstrans/core/theme/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:acesstrans/Constants/coordinates.dart'; // Importando as coordenadas

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isListening = false;
  bool _speechEnabled = false;
  String _lastWords = '';
  LatLng _busLocation = LatLng(-10.43029, -45.174006); // Localização inicial do ônibus

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  // Função para pegar a localização do ônibus via API
  Future<void> _fetchBusLocation() async {
  final response = await http.get(Uri.parse('https://api-location-teal.vercel.app/api/location'));
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);  // Deserializa o JSON
    print('Localização do ônibus recebida: $data');
    
    // Acessa a latitude e longitude dentro da chave 'location'
    double latitude = data["location"]['latitude'];
    double longitude = data["location"]['longitude'];
    
    // Atualiza a localização do ônibus no mapa
    setState(() {
      _busLocation = LatLng(latitude, longitude);  // Atualiza a posição no mapa
    });
  } else {
    print('Falha ao carregar a localização do ônibus');
  }
}


  void _initSpeech() async {
    await _requestMicrophonePermission();

    _speechEnabled = await _speechToText.initialize(
      onError: (val) => print('Erro: $val'),
      onStatus: (val) => print('Status: $val'),
    );

    if (_speechEnabled) {
      setState(() {
        _isListening = false;
      });
    } else {
      print("O reconhecimento de fala não está disponível.");
    }
  }

  Future<void> _requestMicrophonePermission() async {
    var status = await Permission.microphone.request();
    if (status.isDenied) {
      print("Permissão para usar o microfone negada.");
    }
  }

  void _startListening() async {
    if (_speechEnabled) {
      await _speechToText.listen(onResult: _onSpeechResult);
      setState(() {
        _isListening = true;
      });
    } else {
      print("Speech recognition não está disponível.");
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords.toLowerCase();
    });

    if (_lastWords.contains("busão")) {
      _speak("Estou ouvindo, diga o nome da parada.");
      _stopListening();
      _startListening();
    } else {
      _respondToUser();
    }
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });
  }

  Future<void> _speak(String text) async {
    await flutterTts.setLanguage("pt-BR");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(text);
  }

  void _respondToUser() {
    String response;
    var match = coordinates.firstWhere(
      (coord) => _lastWords.contains(coord['tooltip'].toLowerCase()),
      orElse: () => {},
    );

    if (match.isNotEmpty) {
      int estimatedMinutes = 5; // Estimativa fixa, pode ser melhorada
      response = "${match['tooltip']} está a $estimatedMinutes minutos.";
      _speak(response);
    } else if (_lastWords.isNotEmpty) {
      _speak("Não entendi o destino. Tente novamente.");
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    _speechToText.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppThemes.lightTheme.primaryColor,
        title: Text('Mapa do Trajeto'),
        actions: [
          IconButton(
            color: AppThemes.lightTheme.hintColor,
            icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
            onPressed: _isListening ? _stopListening : _startListening,
          ),
        ],
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: _busLocation,
          initialZoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: coordinates.map((coord) {
              return Marker(
                point: coord['location'],
                width: 50.0,
                height: 50.0,
                child: IconButton(
                  icon: Image.network(
                    'https://cdn-icons-png.flaticon.com/512/3448/3448339.png',
                    width: 40,
                    height: 40,
                  ),
                  onPressed: () {
                    _speak("${coord['tooltip']}, ${coord['popup']}");
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          title: Text(
                            coord['tooltip'],
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          content: Text(
                            coord['popup'],
                            style: TextStyle(
                              fontSize: 20,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          actions: [
                            Center(
                              child: ElevatedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: const Text(
                                  "Fechar",
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              );
            }).toList()
              ..add(
                Marker(
                  point: _busLocation,
                  width: 50.0,
                  height: 50.0,
                  child: IconButton(
                    icon: Image.network(
                      'https://cdn-icons-png.flaticon.com/512/3448/3448339.png',
                      width: 40,
                      height: 40,
                    ),
                    onPressed: () {
                      _speak("A localização do ônibus foi atualizada.");
                    },
                  ),
                ),
              ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _fetchBusLocation(); // Atualiza a localização do ônibus
        },
        child: Icon(Icons.location_on),
        backgroundColor: AppThemes.lightTheme.primaryColor,
      ),
    );
  }
}
