import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/safety_report.dart';

class CommunitySafetyService {
  static final CommunitySafetyService instance = CommunitySafetyService._internal();
  CommunitySafetyService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Timer? _geofenceTimer;
  Position? _lastKnownPosition;
  final List<StreamSubscription> _activeSubscriptions = [];
  final double _warningRadius = 500; // meters

  // Create a new safety report
  Future<void> createSafetyReport({
    required GeoPoint location,
    required ReportType type,
    required ReportSeverity severity,
    required String description,
    required String reporterId,
    List<String> images = const [],
    double radius = 100,
  }) async {
    final report = SafetyReport(
      location: LatLng(location.latitude, location.longitude),
      type: type,
      severity: severity,
      description: description,
      reporterId: reporterId,
      radius: radius,
      images: images,
    );

    await _firestore.collection('safety_reports').add(report.toMap());
  }

  // Get safety reports
  Future<List<SafetyReport>> getSafetyReports() async {
    final snapshot = await _firestore.collection('safety_reports').get();
    return snapshot.docs.map((doc) => SafetyReport.fromMap(doc.data(), doc.id)).toList();
  }

  // Get heatmap data for a specific area
  Future<List<SafetyReport>> getHeatmapData({
    required GeoPoint center,
    required double radiusInKm,
    DateTime? since,
  }) async {
    final reports = await _firestore
        .collection('safety_reports')
        .where('isActive', isEqualTo: true)
        .get();

    final List<SafetyReport> nearbyReports = [];

    for (var doc in reports.docs) {
      final report = SafetyReport.fromMap(doc.data(), doc.id);
      
      final distance = Geolocator.distanceBetween(
        center.latitude,
        center.longitude,
        report.location.latitude,
        report.location.longitude,
      );

      if (distance <= radiusInKm * 1000 &&
          (since == null || report.timestamp.isAfter(since))) {
        nearbyReports.add(report);
      }
    }

    return nearbyReports;
  }

  // Start monitoring for unsafe areas
  void startGeofenceMonitoring() {
    _geofenceTimer?.cancel();
    _geofenceTimer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      final position = await Geolocator.getCurrentPosition();
      _lastKnownPosition = position;
      
      // Check for nearby safety reports
      final nearbyReports = await getHeatmapData(
        center: GeoPoint(position.latitude, position.longitude),
        radiusInKm: _warningRadius / 1000, // Convert meters to km
        since: DateTime.now().subtract(const Duration(days: 7)), // Reports from last 7 days
      );

      // Calculate risk level based on nearby reports
      if (nearbyReports.isNotEmpty) {
        _processNearbyReports(nearbyReports, position);
      }
    });
  }

  // Stop geofence monitoring
  void stopGeofenceMonitoring() {
    _geofenceTimer?.cancel();
    _geofenceTimer = null;
    for (var subscription in _activeSubscriptions) {
      subscription.cancel();
    }
    _activeSubscriptions.clear();
  }

  // Process nearby reports and trigger warnings if necessary
  void _processNearbyReports(List<SafetyReport> reports, Position currentPosition) {
    for (var report in reports) {
      final distance = Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        report.location.latitude,
        report.location.longitude,
      );

      if (distance <= report.radius) {
        // User is within the report's radius
        _triggerWarning(report);
      }
    }
  }

  // Trigger a warning for a nearby unsafe area
  void _triggerWarning(SafetyReport report) {
    // Implement your warning mechanism here
    print('⚠️ WARNING: You are entering an area with reported safety concerns:');
    print('Type: ${report.type}');
    print('Severity: ${report.severity}');
    print('Description: ${report.description}');
    print('Reported: ${report.timestamp}');
    
    // You can implement more sophisticated warning mechanisms:
    // - Push notifications
    // - In-app alerts
    // - Vibration
    // - Sound alerts
  }

  // Verify a safety report
  Future<void> verifySafetyReport(String reportId) async {
    await _firestore.collection('safety_reports').doc(reportId).update({
      'verificationCount': FieldValue.increment(1),
    });
  }

  // Mark a report as inactive (resolved)
  Future<void> markReportInactive(String reportId) async {
    await _firestore.collection('safety_reports').doc(reportId).update({
      'isActive': false,
    });
  }

  // Get safety tips based on location and recent reports
  Future<List<String>> getSafetyTips(GeoPoint location) async {
    // Implement logic to get relevant safety tips based on:
    // - Nearby reports
    // - Time of day
    // - Area characteristics
    return [
      'Stay aware of your surroundings',
      'Keep your phone charged and easily accessible',
      'Share your location with trusted contacts',
      'Avoid poorly lit areas at night',
      'Trust your instincts - if something feels wrong, leave the area',
    ];
  }

  // Get nearby emergency services
  Future<List<Map<String, dynamic>>> getNearbyEmergencyServices(GeoPoint location) async {
    // Implement logic to fetch nearby:
    // - Police stations
    // - Hospitals
    // - Fire stations
    // - Safe zones
    // This would typically use a places API or your own database
    return [];
  }
} 