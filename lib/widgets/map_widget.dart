import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:lab4_take2/services/notification_service.dart';
import '../models/event.dart';
import '../services/map_service.dart';

class MapWidget extends StatefulWidget {
  final List<Event> events;

  const MapWidget({super.key, required this.events});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  final MapController _mapController = MapController(
    initMapWithUserPosition:
        const UserTrackingOption(enableTracking: true, unFollowUser: true),
  );
  late GeoPoint _userLocation;
  bool _isLocationLoaded = false;
  late MapService _mapService;
  late NotificationService _notificationService;

  @override
  void initState() {
    super.initState();
    _mapService = MapService(_mapController);
    _notificationService = NotificationService();
    _notificationService.initializeNotifications();
    _startProximityCheck();
  }

  void _getUserLocation() async {
    final location = await _mapService.getUserLocation();
    setState(() {
      _userLocation = location;
      _isLocationLoaded = true;
    });
    _mapService.addEventMarkers(widget.events);
    _mapService.calculateRoutesToEvents(widget.events, _userLocation);
  }

  void _startProximityCheck() {
    Timer.periodic(const Duration(seconds: 60), (timer) {
      if (_isLocationLoaded) {
        _notificationService.checkProximity(
          _userLocation.latitude,
          _userLocation.longitude,
          widget.events,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return OSMFlutter(
      controller: _mapController,
      onMapIsReady: (isReady) {
        if (isReady) {
          _getUserLocation();
        }
      },
      osmOption: OSMOption(
        enableRotationByGesture: true,
        zoomOption: const ZoomOption(
          initZoom: 15,
          minZoomLevel: 3,
          maxZoomLevel: 19,
          stepZoom: 1.0,
        ),
        userLocationMarker: UserLocationMaker(
          personMarker: const MarkerIcon(
            icon: Icon(
              Icons.location_history_rounded,
              color: Colors.blue,
              size: 48,
            ),
          ),
          directionArrowMarker: const MarkerIcon(
            icon: Icon(
              Icons.control_point,
              size: 48,
            ),
          ),
        ),
        roadConfiguration: const RoadOption(
          roadColor: Colors.yellowAccent,
        ),
      ),
      mapIsLoading: const Center(child: CircularProgressIndicator()),
    );
  }
}
