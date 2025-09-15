import 'dart:convert';
import 'dart:math';

import 'package:autostop/layouts/popup_info_point.dart';
import 'package:autostop/layouts/popup_new_point.dart';
import 'package:autostop/models/map_preferences.dart';
import 'package:autostop/services/point_service.dart';
import 'package:autostop/shared/btn_icon_txt.dart';
import 'package:autostop/shared/map_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' as location;
import 'package:shared_preferences/shared_preferences.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final PopupController _popupLayerController = PopupController();

  late MapPreferences _mapPreferences;

  final double _minZoom = 2.0;
  final double _maxZoom = 18.0;
  final location.Location _location = location.Location();

  PointMarker? _selectedMarker;
  PointMarker? _currentPosition;
  List<PointMarker> _markers = [];
  List<PointMarker> _showedMarkers = [];
  SearchArea? _searchArea;

  final Stream<List<Point>> _streamListPoint = PointService().getApproved();

  void _zoomIn() {
    if (_mapController.camera.zoom < _maxZoom) {
      _mapController.move(
          _mapController.camera.center, _mapController.camera.zoom + 1);
    }
  }

  void _zoomOut() {
    if (_mapController.camera.zoom > _minZoom) {
      _mapController.move(
          _mapController.camera.center, _mapController.camera.zoom - 1);
    }
  }

  Future<bool> _requestPermission() async {
    final scaffold = ScaffoldMessenger.of(context);
    bool hasPermission = location.PermissionStatus.granted ==
        (await _location.requestPermission());
    if (hasPermission) {
      scaffold.showSnackBar(const SnackBar(
          content: Text(
              "Réeffectuez votre action, vous pouvez désormais le faire !")));
    }
    return hasPermission;
  }

  void _setSearchArea(bool clear) {
    setState(() {
      _searchArea = clear
          ? null
          : SearchArea(_mapPreferences.currentPositionZoom!,
              _mapPreferences.currentPosition!);
    });
  }

  Future<bool> _hasLocationPermission() async {
    return (await _location.hasPermission()) ==
        location.PermissionStatus.granted;
  }

  Future<LatLng> _getLocation() async {
    if (await _hasLocationPermission()) {
      final position = await Geolocator.getCurrentPosition();
      final pos = LatLng(position.latitude, position.longitude);
      _currentPosition = PointMarker.constructor(
          PointType.currentPosition, Point.fromLatLng(pos));
      Future.delayed(const Duration(seconds: 10), _getLocation);
      _showedMarkers.remove(_currentPosition);
      _showedMarkers.add(_currentPosition!);
      return pos;
    } else {
      _requestPermission();
      throw ("Doesn't have the required permission: Location\nWhen getting location");
    }
  }

  Future<void> _zoomToLocation(LatLng position) async {
    _mapController.move(position, 15);
    _placeMarker(position);
  }

  @override
  void initState() {
    super.initState();
    _mapPreferences = MapPreferences();
    _loadMapLastState().then((_) => setState(() {}));
  }

  @override
  void dispose() {
    _popupLayerController.dispose();
    _mapController.dispose();
    _saveMapState();
    super.dispose();
  }

  Future<void> _loadMapLastState() async {
    final preferences = await SharedPreferences.getInstance();
    final preferencesJson = preferences.getString('mapPreferences');
    if (preferencesJson != null) {
      final jsonPreferences = jsonDecode(preferencesJson);
      if (jsonPreferences != null) {
        setState(() {
          _mapPreferences = MapPreferences.fromJson(jsonPreferences);
          if (_mapPreferences.selectedMarker != null) {
            _selectedMarker = PointMarker.constructor(
                PointType.searchedOrSelected,
                Point.fromLatLng(_mapPreferences.selectedMarker!));
          }
        });
      }
    }
  }

  void _saveMapState() async {
    _mapPreferences = MapPreferences(
      selectedMarker: _selectedMarker!.p.toLatLng(),
      currentPosition: _mapController.camera.center,
      currentPositionZoom: _mapController.camera.zoom,
    );

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
        'mapPreferences', json.encode(_mapPreferences.toJson()));
  }

  void _removePlacedMarker() {
    setState(() {
      _showedMarkers.remove(_selectedMarker);
    });
  }

  void _placeMarker(LatLng point) {
    setState(() {
      _showedMarkers.remove(_selectedMarker);
      _selectedMarker = PointMarker.constructor(
          PointType.searchedOrSelected, Point.fromLatLng(point));
      _showedMarkers.add(_selectedMarker!);
      _popupLayerController.showPopupsOnlyFor([_selectedMarker!]);
    });
  }

  @override
  Widget build(BuildContext context) {
    const int radiusSearch = 5;
    return Scaffold(
      body: Stack(
        children: [
          _buildMap(),
          MapSearchBar(
            onSelected: (city) {
              if (city != null) {
                if (_currentPosition != null) {
                  setState(() {
                    _setSearchArea(false);
                    _showedMarkers = _markers
                        .where((e) =>
                            e.pointType == PointType.spot &&
                            _getDistanceHaversine(_searchArea!.pos, e.point) <
                                radiusSearch &&
                            _isP3BetweenP2P1(city.pos, _searchArea!.pos,
                                LatLng(e.p.destLat, e.p.destLng), 10))
                        .toList();
                  });
                } else {
                  _getLocation();
                }
              } else {
                setState(() {
                  _searchArea = null;
                  _showedMarkers = _markers;
                });
              }
            },
            onClear: () => _setSearchArea(true),
          ),
          _buildRightBottomButtons(),
          _buildCenterBottomButtons(),
        ],
      ),
    );
  }

  double _getDistanceHaversine(LatLng p1, LatLng p2) {
    const earthRadius = 6371; // In km

    final double dLat = degToRadian(p2.latitude - p1.latitude);
    final double dLng = degToRadian(p2.longitude - p1.longitude);

    final a = pow(sin(dLat / 2), 2) +
        cos(p1.latitude) * cos(p2.latitude) * pow(sin(dLng / 2), 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  bool _isP3BetweenP2P1(LatLng p1, LatLng p2, LatLng p3, double offset) {
    double m = (p2.latitude - p1.latitude) / (p2.longitude - p1.longitude);
    double b = p1.latitude - m * p1.longitude;
    double a = -m;
    double c = 1;
    return _shortestDistFromStraightLigne(
            a, b, c, p3.longitude, p3.longitude) <=
        offset;
  }

  double _shortestDistFromStraightLigne(
      double a, double b, double c, double x, double y) {
    return (a * x + b * y + c).abs() / sqrt(a * a + b * b);
  }

  PopupScope _buildMap() {
    return PopupScope(
      popupController: _popupLayerController,
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _mapPreferences.currentPosition ??
              const LatLng(46.59212, 2.46081),
          initialZoom: _mapPreferences.currentPositionZoom ?? 6,
          interactionOptions: const InteractionOptions(
            enableMultiFingerGestureRace: true,
            rotationWinGestures: MultiFingerGesture.none,
            pinchMoveWinGestures: MultiFingerGesture.pinchZoom,
          ),
          minZoom: _minZoom,
          maxZoom: _maxZoom,
          onTap: (_, __) => _removePlacedMarker(),
          onLongPress: (tapPosition, point) => _placeMarker(point),
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: const ['a', 'b', 'c'],
          ),
          StreamBuilder(
              stream: _streamListPoint,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(); // Show a loading indicator while fetching data
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  if (_markers.isEmpty && snapshot.data != null) {
                    _markers = snapshot.data!
                        .map((e) => PointMarker.constructor(PointType.spot, e))
                        .toList();
                    _showedMarkers = _markers;
                  }
                  return _buildPopupMarkerLayer();
                } else {
                  return const Text('No data available');
                }
              }),
        ],
      ),
    );
  }

  Positioned _buildRightBottomButtons() {
    return Positioned(
      bottom: 16,
      right: 16,
      child: Column(
        children: [
          FloatingActionButton(
            heroTag: 'detectLoc',
            onPressed: () async {
              if (await _hasLocationPermission()) {
                await _zoomToLocation(await _getLocation());
              } else {
                await _requestPermission();
              }
            },
            tooltip: 'Détecter ma position',
            child: const Icon(Icons.my_location),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'zoomIn',
            onPressed: _zoomIn,
            tooltip: 'Zoom avant',
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'zoomOut',
            onPressed: _zoomOut,
            tooltip: 'Zoom arrière',
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }

  Positioned _buildCenterBottomButtons() {
    return Positioned(
        bottom: 16,
        right: 16,
        child: BtnIconText(
            icon: Icons.refresh,
            text: "Chercher dans cette zone",
            onPressed: () {
              _setSearchArea(false);
            }));
  }

  PopupMarkerLayer _buildPopupMarkerLayer() {
    return PopupMarkerLayer(
      options: PopupMarkerLayerOptions(
        markers: _showedMarkers,
        popupController: _popupLayerController,
        popupDisplayOptions: PopupDisplayOptions(builder: (_, marker) {
          if (marker is PointMarker) {
            if (marker.pointType == PointType.spot) {
              return PopupInfoPoint(point: marker.p);
            } else if (marker.pointType == PointType.searchedOrSelected) {
              return PopupNewPoint(point: marker.p);
            } else {
              throw ("Point type not define when building popup marker layer");
            }
          } else {
            throw ("A marker is not a point marker");
          }
        }),
      ),
    );
  }
}

class PointMarker extends Marker {
  final Point p;
  final PointType pointType;
  final Icon icon;

  PointMarker._(this.pointType, this.p, this.icon)
      : super(
          alignment: Alignment.topCenter,
          height: Point.size,
          width: Point.size,
          point: LatLng(p.latitude, p.longitude),
          child: icon,
        );

  static PointMarker constructor(PointType pointType, Point p) {
    switch (pointType) {
      case PointType.spot:
        return PointMarker._(
          pointType,
          p,
          const Icon(Icons.location_on, size: Point.size, color: Colors.blue),
        );
      case PointType.searchedOrSelected:
        return PointMarker._(
          pointType,
          p,
          const Icon(Icons.location_on, size: Point.size, color: Colors.red),
        );
      case PointType.currentPosition:
        return PointMarker._(
          pointType,
          p,
          const Icon(Icons.person_pin_circle_rounded,
              size: Point.size, color: Colors.red),
        );
      default:
        throw ("Point type not defined when constructing");
    }
  }
}

class SearchArea {
  final double zoom;
  final LatLng pos;

  SearchArea(this.zoom, this.pos);
}

enum PointType {
  spot,
  searchedOrSelected,
  currentPosition,
}
