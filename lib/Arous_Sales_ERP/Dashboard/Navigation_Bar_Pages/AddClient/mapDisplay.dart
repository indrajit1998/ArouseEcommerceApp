import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;

class Mapdisplay extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String vendorName;
  final double userLatitude;
  final double userLongitude;
  final String userName;

  const Mapdisplay({
    Key? key,
    required this.latitude,
    required this.longitude,
    required this.vendorName,
    required this.userLatitude,
    required this.userLongitude,
    required this.userName,
  }) : super(key: key);

  @override
  _MapdisplayState createState() => _MapdisplayState();
}

class _MapdisplayState extends State<Mapdisplay> {
  final MapController _mapController = MapController();
  List<LatLng> _routePoints = [];
  bool _isLoadingDirections = false;
  double _initialZoom = 7.0;

  @override
  void initState() {
    super.initState();
    _initialZoom = _calculateZoomLevel();
    Future.microtask(() {
      _fitBounds();
    });
  }

  @override
  void didUpdateWidget(Mapdisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.latitude != widget.latitude ||
        oldWidget.longitude != widget.longitude ||
        oldWidget.userLatitude != widget.userLatitude ||
        oldWidget.userLongitude != widget.userLongitude) {
      setState(() {
        _initialZoom = _calculateZoomLevel();
      });
      Future.microtask(() {
        _fitBounds();
      });
    }
  }

  double _calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371;
    final double lat1 = point1.latitude * math.pi / 180;
    final double lat2 = point2.latitude * math.pi / 180;
    final double deltaLat = (point2.latitude - point1.latitude) * math.pi / 180;
    final double deltaLon = (point2.longitude - point1.longitude) * math.pi / 180;

    final double a = math.sin(deltaLat / 2) * math.sin(deltaLat / 2) +
        math.cos(lat1) * math.cos(lat2) * math.sin(deltaLon / 2) * math.sin(deltaLon / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    final double distance = earthRadius * c;

    return distance;
  }

  double _calculateZoomLevel() {
    final vendorLocation = LatLng(widget.latitude, widget.longitude);
    final userLocation = LatLng(widget.userLatitude, widget.userLongitude);

    if (!isValidLatLng(vendorLocation) || !isValidLatLng(userLocation) || vendorLocation == userLocation) {
      return 12.0;
    }

    final distance = _calculateDistance(vendorLocation, userLocation);
    print('Distance between points: $distance km');

    if (distance < 1) {
      return 15.0;
    } else if (distance < 10) {
      return 13.0;
    } else if (distance < 50) {
      return 11.0;
    } else if (distance < 200) {
      return 9.0;
    } else if (distance < 1000) {
      return 7.0;
    } else {
      return 5.0;
    }
  }

  void _fitBounds() {
    final vendorLocation = LatLng(widget.latitude, widget.longitude);
    final userLocation = LatLng(widget.userLatitude, widget.userLongitude);

    if (vendorLocation == userLocation ||
        !isValidLatLng(vendorLocation) ||
        !isValidLatLng(userLocation)) {
      final fallbackLocation = LatLng(
        isValidLatLng(vendorLocation) ? widget.latitude : 19.0760,
        isValidLatLng(vendorLocation) ? widget.longitude : 72.8777,
      );
      _mapController.move(fallbackLocation, _initialZoom);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Locations are identical or invalid. Showing fallback location.'),
          backgroundColor: Colors.orange,
        ),
      );
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) setState(() {});
      });
      return;
    }

    final bounds = LatLngBounds.fromPoints([vendorLocation, userLocation]);

    try {
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(50.0),
        ),
      );
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) setState(() {});
      });
    } catch (e) {
      print('Error fitting bounds: $e');
      final center = LatLng(
        (widget.latitude + widget.userLatitude) / 2,
        (widget.longitude + widget.userLongitude) / 2,
      );
      _mapController.move(center, _initialZoom);
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) setState(() {});
      });
    }
  }

  bool isValidLatLng(LatLng point) {
    return point.latitude >= -90 &&
        point.latitude <= 90 &&
        point.longitude >= -180 &&
        point.longitude <= 180 &&
        !point.latitude.isNaN &&
        !point.longitude.isNaN;
  }

  Future<void> _fetchRoute() async {
    setState(() {
      _isLoadingDirections = true;
    });

    const apiKey = 'AIzaSyA9ieViIp5PX0aKITTZgPfGPNCovp6O0Og';
    final url = 'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=${widget.userLatitude},${widget.userLongitude}'
        '&destination=${widget.latitude},${widget.longitude}'
        '&mode=driving'
        '&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      print('Google Maps API Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK') {
          final polyline = data['routes'][0]['overview_polyline']['points'];
          final points = _decodePolyline(polyline);
          setState(() {
            _routePoints = points;
          });
          _fitBoundsWithRoute(points);
        } else {
          _showError('Failed to fetch directions: ${data['status']} - ${data['error_message'] ?? 'No error message'}');
        }
      } else {
        _showError('Failed to fetch directions: HTTP Status ${response.statusCode}');
      }
    } catch (e) {
      _showError('Error fetching directions: $e');
    } finally {
      setState(() {
        _isLoadingDirections = false;
      });
    }
  }

  void _fitBoundsWithRoute(List<LatLng> routePoints) {
    final points = [
      LatLng(widget.latitude, widget.longitude),
      LatLng(widget.userLatitude, widget.userLongitude),
      ...routePoints,
    ];
    if (points.length < 2) {
      _fitBounds();
      return;
    }

    final bounds = LatLngBounds.fromPoints(points);
    try {
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(50.0),
        ),
      );
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) setState(() {});
      });
    } catch (e) {
      print('Error fitting route bounds: $e');
      final center = LatLng(
        (widget.latitude + widget.userLatitude) / 2,
        (widget.longitude + widget.userLongitude) / 2,
      );
      _mapController.move(center, _initialZoom);
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) setState(() {});
      });
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final vendorLocation = LatLng(widget.latitude, widget.longitude);
    final userLocation = LatLng(widget.userLatitude, widget.userLongitude);

    return Scaffold(
      appBar: AppBar(
        title: Text('Route to ${widget.vendorName}'),
        backgroundColor: const Color.fromRGBO(254, 254, 254, 1),
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(
                  isValidLatLng(vendorLocation) ? (widget.latitude + widget.userLatitude) / 2 : 19.0760,
                  isValidLatLng(vendorLocation) ? (widget.longitude + widget.userLongitude) / 2 : 72.8777,
                ),
                initialZoom: _initialZoom.clamp(5.0, 18.0),
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                  userAgentPackageName: 'com.example.app',
                  tileBuilder: (context, tileWidget, tile) {
                    if (tile == null) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return tileWidget;
                  },
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: vendorLocation,
                      width: 100,
                      height: 100,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 40,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            color: Colors.white.withOpacity(0.7),
                            child: Text(
                              widget.vendorName,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: width * 0.03,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Marker(
                      point: userLocation,
                      width: 100,
                      height: 100,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.location_pin,
                            color: Colors.blue,
                            size: 40,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            color: Colors.white.withOpacity(0.7),
                            child: Text(
                              widget.userName,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: width * 0.03,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints.isNotEmpty
                          ? _routePoints
                          : [userLocation, vendorLocation],
                      strokeWidth: 5.0,
                      color: Colors.red,
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              top: 20,
              right: 20,
              child: Column(
                children: [
                  FloatingActionButton(
                    heroTag: 'zoom_in',
                    mini: true,
                    onPressed: () {
                      _mapController.move(
                        _mapController.camera.center,
                        _mapController.camera.zoom + 1,
                      );
                    },
                    child: const Text(
                      '+',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  FloatingActionButton(
                    heroTag: 'zoom_out',
                    mini: true,
                    onPressed: () {
                      _mapController.move(
                        _mapController.camera.center,
                        _mapController.camera.zoom - 1,
                      );
                    },
                    child: const Text(
                      '−',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 20,
              left: 20,
              child: FloatingActionButton(
                heroTag: 'directions',
                onPressed: _isLoadingDirections ? null : _fetchRoute,
                child: _isLoadingDirections
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Icon(Icons.directions),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Route Details',
                      style: TextStyle(
                        fontSize: width * 0.045,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Inter",
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'From: ${widget.userName}',
                      style: TextStyle(
                        fontSize: width * 0.04,
                        fontFamily: "Inter",
                      ),
                    ),
                    Text(
                      'To: ${widget.vendorName}',
                      style: TextStyle(
                        fontSize: width * 0.04,
                        fontFamily: "Inter",
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}