import 'dart:async';
import 'dart:convert';

import 'package:autostop/utils/debouncer.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class OsmService {
  final Debouncer _searchDebouncer = Debouncer(milliseconds: 500);

  FutureOr<Iterable<City>> searchCities(String query, {int limit = 5}) async {
    final Completer<Iterable<City>> completer = Completer<Iterable<City>>();

    _searchDebouncer.run(() async {
      final response = await http.get(Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=5'));
      if (response.statusCode == 200) {
        final data =
            utf8.decode(response.bodyBytes); // Decode the response body
        final jsonData = json.decode(data);
        final cities = (jsonData as List)
            .map<City>(
              (d) => City(
                LatLng(double.tryParse(d['lat']) ?? 0,
                    double.tryParse(d['lon']) ?? 0),
                utf8.decode(utf8.encode(d['display_name'])),
              ),
            )
            .toList();
        completer.complete(cities);
      } else {
        completer.complete([City(const LatLng(49, 2.35), "France")]);
      }
    });

    return completer.future;
  }
}

class City {
  final LatLng pos;
  final String displayName;

  City(this.pos, this.displayName);
}
