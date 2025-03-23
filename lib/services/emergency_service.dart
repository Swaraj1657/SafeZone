import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

/// Service class to handle emergency-related functionality
class EmergencyService {
  // Singleton instance
  static final EmergencyService instance = EmergencyService._internal();
  EmergencyService._internal();

  bool _isEmergencyActive = false;
  Timer? _locationUpdateTimer;
  Position? _lastKnownPosition;
  DateTime? _lastUpdateTime;
  
  // Emergency contacts will be stored in SharedPreferences
  Future<List<String>> getEmergencyContacts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList('emergency_contacts') ?? [];
    } catch (e) {
      print('Error getting emergency contacts: $e');
      return [];
    }
  }

  /// Check and request required permissions
  Future<bool> checkAndRequestPermissions() async {
    if (kIsWeb) {
      // For web, we only check location permission using Geolocator
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      return permission != LocationPermission.denied && 
             permission != LocationPermission.deniedForever;
    } else {
      // For mobile platforms, we check all required permissions
      List<Permission> permissions = [
        Permission.location,
        if (!kIsWeb) Permission.sms,  // SMS only for mobile
        if (!kIsWeb) Permission.phone, // Phone only for mobile
      ];

      // Check permissions
      Map<Permission, PermissionStatus> statuses = await permissions.request();
      
      return statuses.values.every((status) => status.isGranted);
    }
  }

  /// Starts the emergency process
  Future<void> startEmergencyProcess() async {
    if (_isEmergencyActive) return;

    try {
      bool hasPermissions = await checkAndRequestPermissions();
      if (!hasPermissions) {
        throw Exception('Required permissions not granted');
      }

      // Get current location
      _lastKnownPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      _lastUpdateTime = DateTime.now();
      print('Initial location update at ${_lastUpdateTime!.toLocal()}: ${_lastKnownPosition!.latitude}, ${_lastKnownPosition!.longitude}');

      if (!kIsWeb) {
        // SMS and phone calls are only available on mobile platforms
        // Add your SMS and phone call logic here
      } else {
        // Web-specific emergency actions
        print('Emergency location: ${_lastKnownPosition!.latitude}, ${_lastKnownPosition!.longitude}');
      }

      // Get emergency contacts first
      final contacts = await getEmergencyContacts();
      if (contacts.isEmpty) {
        throw 'No emergency contacts found. Please add emergency contacts first.';
      }

      // Send SMS with location to all contacts
      await _sendEmergencySMS(contacts, _lastKnownPosition!);
      
      // Make emergency call to first contact
      await _makeEmergencyCall(contacts.first);
      
      // Start periodic location updates
      _startLocationUpdates(contacts);
      
      _isEmergencyActive = true;
    } catch (e) {
      _isEmergencyActive = false;
      print('Error in emergency process: $e');
      rethrow;
    }
  }

  /// Stops the emergency process
  Future<void> stopEmergencyProcess() async {
    if (!_isEmergencyActive) return;
    _isEmergencyActive = false;

    // Stop location updates
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = null;
    _lastUpdateTime = null;
    print('Emergency tracking stopped. Last known location: ${_lastKnownPosition?.latitude}, ${_lastKnownPosition?.longitude}');

    try {
      // Send safe message to contacts
      final contacts = await getEmergencyContacts();
      if (contacts.isNotEmpty) {
        await _sendSafeMessage(contacts);
      }
    } catch (e) {
      print('Error stopping emergency process: $e');
      rethrow;
    }
  }

  /// Get current location
  Future<Position> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _lastKnownPosition = position;
      _lastUpdateTime = DateTime.now();
      print('Location updated at ${_lastUpdateTime!.toLocal()}: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      print('Error getting location: $e');
      rethrow;
    }
  }

  /// Send emergency SMS with location
  Future<void> _sendEmergencySMS(List<String> contacts, Position position) async {
    final message = 'EMERGENCY: I need help! '
        'My current location: https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}';

    for (final contact in contacts) {
      try {
        final uri = Uri.parse('sms:$contact?body=${Uri.encodeComponent(message)}');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          throw 'Could not send SMS to $contact';
        }
      } catch (e) {
        print('Error sending SMS to $contact: $e');
      }
    }
  }

  /// Make emergency call
  Future<void> _makeEmergencyCall(String contact) async {
    try {
      final uri = Uri.parse('tel:$contact');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Could not make call to $contact';
      }
    } catch (e) {
      print('Error making call: $e');
      rethrow;
    }
  }

  /// Start periodic location updates
  void _startLocationUpdates(List<String> contacts) {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      if (!_isEmergencyActive) {
        timer.cancel();
        return;
      }

      try {
        final position = await _getCurrentLocation();
        await _sendLocationUpdate(contacts, position);
      } catch (e) {
        print('Error updating location: $e');
      }
    });
  }

  /// Send location update
  Future<void> _sendLocationUpdate(List<String> contacts, Position position) async {
    final message = 'Location Update: '
        'https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}';

    for (final contact in contacts) {
      try {
        final uri = Uri.parse('sms:$contact?body=${Uri.encodeComponent(message)}');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        }
      } catch (e) {
        print('Error sending location update to $contact: $e');
      }
    }
  }

  /// Send safe message
  Future<void> _sendSafeMessage(List<String> contacts) async {
    const message = 'I am safe now. Emergency mode deactivated.';
    
    for (final contact in contacts) {
      try {
        final uri = Uri.parse('sms:$contact?body=${Uri.encodeComponent(message)}');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        }
      } catch (e) {
        print('Error sending safe message to $contact: $e');
      }
    }
  }

  /// Checks if an emergency is currently active
  bool isEmergencyActive() => _isEmergencyActive;

  /// Get the last known position
  Position? getLastKnownPosition() => _lastKnownPosition;

  /// Get the last update time
  DateTime? getLastUpdateTime() => _lastUpdateTime;
}
