import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:http/http.dart' as http;
import '../models/event.dart';

class MapService {
  final MapController _mapController;

  MapService(this._mapController);

  Future<GeoPoint> getUserLocation() async {
    return await _mapController.myLocation();
  }

  Future<void> addEventMarkers(List<Event> events) async {
    for (var event in events) {
      final GeoPoint point = GeoPoint(latitude: event.latitude, longitude: event.longitude);
      await _mapController.addMarker(
        point,
        markerIcon: const MarkerIcon(
          icon: Icon(
            Icons.location_on,
            color: Colors.red,
            size: 30,
          ),
        ),
      );
    }
  }

  Future<void> calculateRoute(GeoPoint userLocation, GeoPoint destination) async {
    const apiKey = '5b3ce3597851110001cf62483cebf855baaa41de9d372f99a4031dbd';
    final url = Uri.parse(
        'https://api.openrouteservice.org/v2/directions/foot-walking?api_key=$apiKey&start=${userLocation.longitude},${userLocation.latitude}&end=${destination.longitude},${destination.latitude}');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final coordinates = data['features'][0]['geometry']['coordinates'];

      List<GeoPoint> routePoints = [];
      for (var coord in coordinates) {
        routePoints.add(GeoPoint(latitude: coord[1], longitude: coord[0]));
      }

      await _mapController.drawRoad(
        routePoints.first,
        routePoints.last,
        roadType: RoadType.car,
        roadOption: const RoadOption(
          roadColor: Colors.blueAccent,
          roadWidth: 10,
        ),
      );
    } else {
      debugPrint('Failed to fetch route: ${response.statusCode}');
    }
  }

  Future<void> calculateRoutesToEvents(List<Event> events, GeoPoint userLocation) async {
    for (var event in events) {
      final destination = GeoPoint(latitude: event.latitude, longitude: event.longitude);
      await calculateRoute(userLocation, destination);
    }
  }
}
