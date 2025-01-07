import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import '../models/event.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'location_radius',
      'Proximity Alerts',
      description: 'Notification when user is close to a marker.',
      importance: Importance.max,
    );

    final androidNotificationPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidNotificationPlugin != null) {
      await androidNotificationPlugin.createNotificationChannel(channel);
    }
  }

  Future<void> requestPermissions() async {
    final androidImplementation = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  Future<void> showNotification(Event event) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      "location_radius",
      "Proximity Alerts",
      channelDescription: 'Notification when user is close to a marker.',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      event.hashCode,
      'Proximity Alert',
      'You are close to ${event.title}',
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  Future<double> calculateDistance(
      double lat1, double lon1, double lat2, double lon2) async {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  Future<void> checkProximity(userLatitude, userLongitude, List<Event> events) async {
    for (var event in events) {
      final distance = await calculateDistance(
        userLatitude,
        userLongitude,
        event.latitude,
        event.longitude,
      );

      if (distance <= 100) {
        await showNotification(event);
      }
    }
  }
}
