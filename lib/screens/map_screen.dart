import 'package:autostop/layouts/popup_info_point.dart';
import 'package:autostop/layouts/popup_new_point.dart';
import 'package:autostop/services/osm_service.dart';
import 'package:autostop/services/point_service.dart';
import 'package:autostop/shared/search_bar_dialog.dart';
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

  late final SharedPreferences _preferences;

  final double _minZoom = 2.0;
  final double _maxZoom = 18.0;
  final location.Location _location = location.Location();
  location.PermissionStatus? _permissionStatus;

  Marker? _selectedMarker;
  List<Marker> _markers = [];

  final Stream<List<Point>> _streamListPoint =
      PointService().getApprovedPointsStream();

  void _zoomIn() {
    if (_mapController.zoom < _maxZoom) {
      _mapController.move(_mapController.center, _mapController.zoom + 1);
    }
  }

  void _zoomOut() {
    if (_mapController.zoom > _minZoom) {
      _mapController.move(_mapController.center, _mapController.zoom - 1);
    }
  }

  Future<void> _checkPermission() async {
    final status = await _location.hasPermission();
    setState(() {
      _permissionStatus = status;
    });
  }

  Future<void> _requestPermission() async {
    final status = await _location.requestPermission();
    setState(() {
      _permissionStatus = status;
      if (location.PermissionStatus.granted == status) {
        _detectAndZoomToLocation();
      }
    });
  }

  Future<void> _detectAndZoomToLocation() async {
    if (_permissionStatus == location.PermissionStatus.granted) {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _mapController.move(LatLng(position.latitude, position.longitude), 15);
    } else {
      // Demandez la permission si elle n'est pas accordée
      _requestPermission();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadRememberedSelectedMarker();
    _checkPermission();
  }

  @override
  void dispose() {
    _popupLayerController.dispose();
    _mapController.dispose();
    _saveRememberedSelectedMarker(_selectedMarker!.point);
    super.dispose();
  }

  void _loadRememberedSelectedMarker() async {
    _preferences = await SharedPreferences.getInstance();
    setState(() {
      double? lat = _preferences.getDouble('selectedMarkerLat');
      double? lng = _preferences.getDouble('selectedMarkerLng');
      if (lat != null && lng != null) {
        _selectedMarker = _getSelectedMarker(LatLng(lat, lng));
      }
    });
  }

  void _saveRememberedSelectedMarker(LatLng point) {
    _preferences.setDouble('selectedMarkerLat', point.latitude);
    _preferences.setDouble('selectedMarkerLng', point.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildMap(),
          SearchBarDialog(onSelected: _placeFindMarker),
          _buildBottomButtons(),
        ],
      ),
    );
  }

  PopupScope _buildMap() {
    return PopupScope(
      popupController: _popupLayerController,
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: const LatLng(46.59212, 2.46081),
          zoom: 6,
          minZoom: _minZoom,
          maxZoom: _maxZoom,
          rotationWinGestures: MultiFingerGesture.pinchZoom,
          onTap: (_, __) {
            _popupLayerController.hideAllPopups();
            setState(() {
              if (_selectedMarker != null) {
                _markers.remove(_selectedMarker!);
              }
            });
          },
          onLongPress: (tapPosition, point) {
            _popupLayerController.hideAllPopups();
            setState(() {
              if (_selectedMarker != null) {
                _markers.remove(_selectedMarker!);
              }
              _selectedMarker = _getSelectedMarker(point);
              _markers.add(_selectedMarker!);
            });
          },
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
                  if (_markers == [] ||
                      _markers.length - (_selectedMarker == null ? 0 : 1) !=
                          snapshot.data!.length) {
                    _markers = <Marker>[] +
                        snapshot.data!.map((e) => PointMarker(p: e)).toList();
                  }
                  if (_selectedMarker != null &&
                      _markers.contains(_selectedMarker!)) {
                    Future.delayed(
                        const Duration(milliseconds: 100),
                        () => _popupLayerController
                            .showPopupsOnlyFor([_selectedMarker!]));
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

  Positioned _buildBottomButtons() {
    return Positioned(
      bottom: 16,
      right: 16,
      child: Column(
        children: [
          FloatingActionButton(
            heroTag: 'detectLoc',
            onPressed: _detectAndZoomToLocation,
            child: const Icon(Icons.my_location),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'zoomIn',
            onPressed: _zoomIn,
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'zoomOut',
            onPressed: _zoomOut,
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }

  PopupMarkerLayer _buildPopupMarkerLayer() {
    return PopupMarkerLayer(
      options: PopupMarkerLayerOptions(
        markers: _markers,
        popupController: _popupLayerController,
        popupDisplayOptions: PopupDisplayOptions(builder: (_, marker) {
          if (marker is PointMarker) {
            return PopupInfoPoint(point: marker.p);
          }
          return PopupNewPoint(p: marker.point);
        }),
      ),
    );
  }

  void _placeFindMarker(City city) {
    _mapController.move(city.pos, 13);
    setState(() {
      if (_selectedMarker != null) {
        _markers.remove(_selectedMarker);
      }
      _selectedMarker = _getSelectedMarker(city.pos);
      _markers.add(_selectedMarker!);
    });
  }

  Marker _getSelectedMarker(LatLng point) {
    return Marker(
      builder: (context) => const Icon(
        Icons.location_on,
        size: Point.size,
        color: Colors.blue,
      ),
      point: point,
    );
  }
}

class PointMarker extends Marker {
  final Point p;

  PointMarker({required this.p})
      : super(
          anchorPos: AnchorPos.align(AnchorAlign.top),
          height: Point.size,
          width: Point.size,
          point: LatLng(p.latitude, p.longitude),
          builder: (_) => const Icon(Icons.location_on,
              size: Point.size, color: Colors.red),
        );
}
