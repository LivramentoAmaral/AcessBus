import 'package:acesstrans/service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:acesstrans/utils/helpers.dart';
import 'package:acesstrans/widgets/map_view.dart';
import 'package:acesstrans/Constants/coordinates.dart';
import 'package:acesstrans/core/theme/app_themes.dart'; // Importando a classe de temas

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();
  List<List<LatLng>> _allRoutes = [];
  LatLng _busLocation = const LatLng(-10.43029, -45.174006);

  @override
  void initState() {
    super.initState();
    _loadInitialRoutes();
    _apiService.startLocationUpdates(onLocationUpdate: (newLocation) {
      setState(() {
        _busLocation = newLocation;
      });
    });
  }

  @override
  void dispose() {
    _apiService.stopLocationUpdates();
    super.dispose();
  }

  Future<void> _loadInitialRoutes() async {
    try {
      final routes = await _apiService.fetchMultipleRoutes(coordinates);
      setState(() {
        _allRoutes = routes;
      });
    } catch (e) {
      Helpers.speak("Erro ao carregar as rotas iniciais.");
    }
  }

  void _showTimeToArrivalModal(
      LatLng stopLocation, String stopName, String popupDescription) {
    final timeToArrival = Helpers.calculateTimeToArrival(
        _busLocation, stopLocation, averageSpeed: 40.0);

    Helpers.speak(
        "Faltam $timeToArrival minutos para o ônibus chegar a $stopName, $popupDescription");

   showDialog(
  context: context,
  builder: (BuildContext context) {
    return AlertDialog(
      backgroundColor: AppThemes.lightTheme.scaffoldBackgroundColor, // Usando o fundo claro para o diálogo
      title: Text(
        'Tempo até $stopName',
        style: TextStyle(
          color: AppThemes.lightTheme.primaryColor, // Usando o verde mais vibrante para o título
          fontSize: 22, // Aumentando o tamanho da fonte para maior legibilidade
          fontWeight: FontWeight.bold, // Deixando o título mais grosso para destacar ainda mais
        ),
      ),
      content: Text(
        '$timeToArrival minutos restantes até a parada.\n\n$popupDescription',
        style: TextStyle(
          color: AppThemes.lightTheme.textTheme.bodyLarge?.color ?? Colors.black, // Cor do texto, preto ou a do tema
          fontSize: 20, // Aumentando o tamanho da fonte
          fontWeight: FontWeight.bold, // Deixando o texto mais legível
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            'Fechar',
            style: TextStyle(
              color: AppThemes.lightTheme.buttonTheme.colorScheme?.primary ?? Colors.green, // Usando o verde vibrante para o botão
              fontSize: 22, // Aumentando o tamanho da fonte para o botão
              fontWeight: FontWeight.bold, // Garantindo que o botão se destaque
            ),
          ),
        ),
      ],
    );
  },
);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mapa do Trajeto',
          style: TextStyle(
            fontSize: 24,
            color: AppThemes.lightTheme.appBarTheme.titleTextStyle?.color ?? Colors.white, // Cor do texto do título
          ),
        ),
        backgroundColor: AppThemes.lightTheme.appBarTheme.backgroundColor, // Cor do AppBar
      ),
      body: MapView(
        busLocation: _busLocation,
        allRoutes: _allRoutes,
        onMarkerTapped: _showTimeToArrivalModal,
      ),
    );
  }
}
