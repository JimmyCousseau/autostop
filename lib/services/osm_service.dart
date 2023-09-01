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
          'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=$limit&addressdetails=1&extratags=1&countrycodes=fr,it,de,es,gb'));
      if (response.statusCode == 200) {
        final data =
            utf8.decode(response.bodyBytes); // Decode the response body
        final jsonData = json.decode(data);
        final cities =
            (jsonData as List).map<City>((d) => City.fromJson(d)).toList();
        completer.complete(cities);
      } else {
        completer.complete([]);
      }
    });

    return completer.future;
  }
}

class City {
  final LatLng pos;
  final String name;
  final String moreInfo;

  City(this.pos, this.name, this.moreInfo);

  factory City.fromJson(Map<String, dynamic> json) {
    String getDisplayName(dynamic infos) {
      return "${infos['state']}, ${infos['postcode']}, ${infos['country']}";
    }

    return City(
      LatLng(
          double.tryParse(json['lat']) ?? 0, double.tryParse(json['lon']) ?? 0),
      json['name'],
      getDisplayName(json['address']),
    );
  }
}
