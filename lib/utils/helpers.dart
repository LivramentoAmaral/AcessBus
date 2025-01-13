import 'package:flutter_tts/flutter_tts.dart';
import 'package:latlong2/latlong.dart';

class Helpers {
  static final FlutterTts _flutterTts = FlutterTts();

  /// Fala um texto com configurações de idioma e velocidade.
  static Future<void> speak(String text) async {
    try {
      await _flutterTts.setLanguage("pt-BR");
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.speak(text);
    } catch (e) {
      print("Erro ao tentar falar o texto: $e");
    }
  }

  /// Calcula a distância entre dois pontos em quilômetros.
  static double calculateDistance(LatLng start, LatLng end) {
    try {
      final Distance distance = Distance();
      return distance.as(LengthUnit.Kilometer, start, end);
    } catch (e) {
      print("Erro ao calcular distância: $e");
      return 0.0;
    }
  }

  /// Calcula o tempo estimado de chegada em minutos.
  /// [averageSpeed] é a velocidade média em km/h.
  static int calculateTimeToArrival(
    LatLng start,
    LatLng end, {
    required double averageSpeed,
  }) {
    // Validação: Velocidade média não pode ser zero ou negativa.
    if (averageSpeed <= 0) {
      print("Velocidade média inválida: $averageSpeed km/h");
      return -1; // Indica erro no cálculo.
    }

    try {
      final double distance = calculateDistance(start, end);
      final double timeInHours = distance / averageSpeed;
      final int timeInMinutes = (timeInHours * 60).ceil();

      return timeInMinutes;
    } catch (e) {
      print("Erro ao calcular o tempo de chegada: $e");
      return -1; // Indica erro no cálculo.
    }
  }
}
