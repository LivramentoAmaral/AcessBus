import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:acesstrans/core/theme/app_themes.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> coordinates = [
    {
      "location": const LatLng(-10.43029, -45.174006),
      "tooltip": "TRAJETO SAÍDA DO IFPI",
      "popup": "IFPI - Campus Corrente"
    },
    {
      "location": const LatLng(-10.438866, -45.173230),
      "tooltip": "1ª Parada",
      "popup": "Posto Primavera"
    },
    {
      "location": const LatLng(-10.454374, -45.171460),
      "tooltip": "2ª Parada",
      "popup": "Praça Principal do Vermelhão"
    },
    {
      "location": const LatLng(-10.439672, -45.168913),
      "tooltip": "3ª Parada",
      "popup": "Supermercado Rocha"
    },
    {
      "location": const LatLng(-10.443239, -45.160735),
      "tooltip": "4ª Parada",
      "popup": "Praça da Igreja Batista"
    },
    {
      "location": const LatLng(-10.445506, -45.157068),
      "tooltip": "5ª Parada",
      "popup": "15ª Regional de Educação"
    },
    {
      "location": const LatLng(-10.451376, -45.146146),
      "tooltip": "6ª Parada",
      "popup": "Posto de Combustível do Aeroporto"
    },
    {
      "location": const LatLng(-10.454766, -45.137556),
      "tooltip": "7ª Parada",
      "popup": "Escola Municipal Orley Cavalcante Pacheco"
    },
    {
      "location": const LatLng(-10.442140, -45.158292),
      "tooltip": "8ª Parada",
      "popup": "APAEB Corrente"
    },
    {
      "location": const LatLng(-10.439274, -45.162402),
      "tooltip": "9ª Parada",
      "popup": "SAMU Corrente"
    },
    {
      "location": const LatLng(-10.436220, -45.162002),
      "tooltip": "10ª Parada",
      "popup": "Próximo ao Coronel"
    },
    {
      "location": const LatLng(-10.429860, -45.161559),
      "tooltip": "11ª Parada",
      "popup": "Próximo ao posto Varejão"
    },
    {
      "location": const LatLng(-10.43029, -45.174006),
      "tooltip": "12ª Parada",
      "popup": "Retorno ao IFPI"
    },
  ];

  FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isListening = false;
  bool _speechEnabled = false;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
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
        options: const MapOptions(
          initialCenter: LatLng(-10.43029, -45.174006),
          initialZoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate:
                "https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png",
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
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          content: Text(
                            coord['popup'],
                            style: TextStyle(
                              fontSize: 20,
                              color:
                                  Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          actions: [
                            Center(
                              child: ElevatedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
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
            }).toList(),
          ),
        ],
      ),
    );
  }
}
