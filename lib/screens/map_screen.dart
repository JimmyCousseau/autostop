import 'package:autostop/layouts/popup_info_point.dart';
import 'package:autostop/layouts/popup_new_point.dart';
import 'package:autostop/services/osm_service.dart';
import 'package:autostop/services/point_service.dart';
import 'package:autostop/shared/main_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  List<Marker> _markers = [];
  Marker? _selectedMarker;
  final OsmService _osmService = OsmService();
  final Stream<List<Point>> _streamListPoint =
      PointService().getApprovedPointsStream();

  final PopupController _popupLayerController = PopupController();

  void _zoomIn() {
    _mapController.move(_mapController.center,
        _mapController.zoom < 1000 ? _mapController.zoom + 1 : 0);
  }

  void _zoomOut() {
    _mapController.move(_mapController.center,
        _mapController.zoom > 1 ? _mapController.zoom - 1 : 0);
  }

  void _detectAndZoomToLocation() async {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    _mapController.move(LatLng(position.latitude, position.longitude), 15);
  }

  bool isDrawerVisible = false; // Track if the drawer is visible

  @override
  void dispose() {
    _popupLayerController.dispose();
    _mapController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AutoStop'),
      ),
      drawer:
          FirebaseAuth.instance.currentUser != null ? const MainDrawer() : null,
      body: Stack(
        children: [
          PopupScope(
            popupController: _popupLayerController,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: const LatLng(46.59212, 2.46081),
                zoom: 13,
                minZoom: 1,
                maxZoom: 1000,
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
                    _selectedMarker = Marker(
                      anchorPos: AnchorPos.align(AnchorAlign.top),
                      builder: (_) => const Icon(Icons.location_on,
                          size: Point.size, color: Colors.blue),
                      point: point,
                    );
                    _markers.add(_selectedMarker!);
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
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
                            _markers.length -
                                    (_selectedMarker == null ? 0 : 1) !=
                                snapshot.data!.length) {
                          _markers = <Marker>[] +
                              snapshot.data!
                                  .map((e) => PointMarker(p: e))
                                  .toList();
                        }
                        if (_selectedMarker != null &&
                            _markers.contains(_selectedMarker!)) {
                          Future.delayed(
                              const Duration(milliseconds: 100),
                              () => _popupLayerController
                                  .showPopupsOnlyFor([_selectedMarker!]));
                        }

                        return PopupMarkerLayer(
                          options: PopupMarkerLayerOptions(
                            markers: _markers,
                            popupController: _popupLayerController,
                            popupDisplayOptions:
                                PopupDisplayOptions(builder: (_, marker) {
                              if (marker is PointMarker) {
                                return PopupInfoPoint(point: marker.p);
                              }
                              return PopupNewPoint(p: marker.point);
                            }),
                          ),
                        );
                      } else {
                        return const Text('No data available');
                      }
                    }),
              ],
            ),
          ),
          Positioned(
            top: 16,
            left: MediaQuery.of(context).size.width / 4,
            width: MediaQuery.of(context).size.width / 2,
            child: Column(
              children: [
                Autocomplete<City>(
                  displayStringForOption: (option) => option.displayName,
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return [];
                    }
                    return _osmService.searchCities(textEditingValue.text);
                  },
                  onSelected: (City selectedCity) {
                    _mapController.move(selectedCity.pos, 13);
                  },
                  optionsViewBuilder: (BuildContext context,
                      AutocompleteOnSelected<City> onSelected,
                      Iterable<City> options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width / 2,
                        child: Card(
                          // Wrap the options with a Card widget
                          child: ListView.builder(
                            itemCount: options.length,
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context, int index) {
                              return ListTile(
                                title:
                                    Text(options.elementAt(index).displayName),
                                onTap: () {
                                  onSelected(options.elementAt(index));
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                  fieldViewBuilder: (BuildContext context,
                      TextEditingController textEditingController,
                      FocusNode focusNode,
                      VoidCallback onFieldSubmitted) {
                    return Container(
                      width: MediaQuery.of(context).size.width / 2,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        color: Colors.white,
                      ),
                      child: TextField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        onSubmitted: (selectedCity) async {
                          City city =
                              (await _osmService.searchCities(selectedCity))
                                  .first;
                          _mapController.move(city.pos, 13);
                          // setState(() {
                          //   if (_findMarker != null) {
                          //     _markers.remove(_findMarker);
                          //   }
                          //   _findMarker = Marker(
                          //     builder: (context) => const Icon(
                          //         Icons.location_on,
                          //         size: Point.size,
                          //         color: Colors.blue),
                          //     point: city.pos,
                          //   );
                          //   _markers.add(_findMarker!);
                          // });
                        },
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 12.0),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          Positioned(
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
          ),
        ],
      ),
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
