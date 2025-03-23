import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';

enum ReportType {
  harassment,
  theft,
  assault,
  suspicious,
  lighting,
  other
}

enum ReportSeverity {
  low,    // Minor concerns
  medium, // Concerning but not immediate danger
  high    // Immediate safety concern
}

extension ReportSeverityColor on ReportSeverity {
  Color get colorValue {
    switch (this) {
      case ReportSeverity.low:
        return Colors.green;
      case ReportSeverity.medium:
        return Colors.orange;
      case ReportSeverity.high:
        return Colors.red;
    }
  }

  int get color => colorValue.value;
}

class SafetyReport {
  final String id;
  final GeoPoint location;
  final ReportType type;
  final ReportSeverity severity;
  final String description;
  final double radius;
  final String reporterId;
  final DateTime timestamp;
  final int verificationCount; // Number of other users who verified this report
  final bool isActive; // Whether this report is still relevant
  final List<String> images; // Optional image URLs

  SafetyReport._({
    required this.id,
    required this.location,
    required this.type,
    required this.severity,
    required this.description,
    required this.radius,
    required this.reporterId,
    required this.timestamp,
    this.verificationCount = 0,
    this.isActive = true,
    this.images = const [],
  });

  factory SafetyReport({
    String? id,
    required LatLng location,
    required ReportType type,
    required ReportSeverity severity,
    required String description,
    required double radius,
    required String reporterId,
    DateTime? timestamp,
    int verificationCount = 0,
    bool isActive = true,
    List<String> images = const [],
  }) {
    return SafetyReport._(
      id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      location: GeoPoint(location.latitude, location.longitude),
      type: type,
      severity: severity,
      description: description,
      radius: radius,
      reporterId: reporterId,
      timestamp: timestamp ?? DateTime.now(),
      verificationCount: verificationCount,
      isActive: isActive,
      images: images,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'location': location,
      'type': type.toString(),
      'severity': severity.toString(),
      'description': description,
      'radius': radius,
      'reporterId': reporterId,
      'timestamp': Timestamp.fromDate(timestamp),
      'verificationCount': verificationCount,
      'isActive': isActive,
      'images': images,
    };
  }

  // Create from Firestore document
  factory SafetyReport.fromMap(Map<String, dynamic> map, String id) {
    return SafetyReport._(
      id: id,
      location: map['location'] as GeoPoint,
      type: ReportType.values.firstWhere(
        (t) => t.toString() == map['type'],
        orElse: () => ReportType.other,
      ),
      severity: ReportSeverity.values.firstWhere(
        (s) => s.toString() == map['severity'],
        orElse: () => ReportSeverity.medium,
      ),
      description: map['description'] as String,
      radius: (map['radius'] as num).toDouble(),
      reporterId: map['reporterId'] as String,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      verificationCount: map['verificationCount'] as int? ?? 0,
      isActive: map['isActive'] as bool? ?? true,
      images: List<String>.from(map['images'] ?? []),
    );
  }

  LatLng get latLng => LatLng(location.latitude, location.longitude);
}   