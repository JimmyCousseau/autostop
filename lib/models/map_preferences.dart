import 'package:latlong2/latlong.dart';

class MapPreferences {
  final LatLng? selectedMarker;
  final LatLng? currentPosition;
  final double? currentPositionZoom;

  MapPreferences({
    this.selectedMarker,
    this.currentPosition,
    this.currentPositionZoom,
  });

  Map<String, dynamic> toJson() {
    return {
      'selectedMarkerLat': selectedMarker?.latitude,
      'selectedMarkerLng': selectedMarker?.longitude,
      'currentPositionLat': currentPosition?.latitude,
      'currentPositionLng': currentPosition?.longitude,
      'currentPositionZoom': currentPositionZoom,
    };
  }

  factory MapPreferences.fromJson(Map<String, dynamic> json) {
    LatLng? selectedMarker;
    LatLng? currentPosition;
    if (json['selectedMarkerLat'] && json['selectedMarkerLng']) {
      selectedMarker =
          LatLng(json['selectedMarkerLat'], json['selectedMarkerLng']);
    }
    if (json['currentPositionLat'] && json['currentPositionLng']) {
      currentPosition =
          LatLng(json['currentPositionLat'], json['currentPositionLng']);
    }
    return MapPreferences(
      selectedMarker: selectedMarker,
      currentPosition: currentPosition,
      currentPositionZoom: json['currentPositionZoom'],
    );
  }
}
