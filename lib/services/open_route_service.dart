import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class OpenRouteService {
  Future<List<LatLng>> getRoutePolyline(
      double startLat, double startLng, double endLat, double endLng) async {
    await dotenv.load();
    String apiKey = dotenv.env['ORS']!; // Remplacez par votre propre clé API

    String url =
        "https://api.openrouteservice.org/v2/directions/driving-car?api_key=$apiKey&start=$startLng,$startLat&end=$endLng,$endLat";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      List<dynamic> coordinates =
          data['features'][0]['geometry']['coordinates'];
      return coordinates
          .map((coord) => LatLng(
                coord[1],
                coord[0],
              )) // Inversion de l'ordre : lat,lng
          .toList();
    } else {
      throw Exception('Échec de la requête pour l\'itinéraire');
    }
  }
}
