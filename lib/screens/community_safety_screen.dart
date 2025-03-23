import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../models/safety_report.dart';
import '../widgets/report_safety_dialog.dart';

class CommunitySafetyScreen extends StatefulWidget {
  const CommunitySafetyScreen({super.key});

  @override
  State<CommunitySafetyScreen> createState() => _CommunitySafetyScreenState();
}

class _CommunitySafetyScreenState extends State<CommunitySafetyScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  Set<Circle> _safetyCircles = {};
  List<SafetyReport> _nearbyReports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    setState(() => _isLoading = true);
    try {
      print('Starting map initialization...');
      
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current location
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      print('Current position obtained: ${_currentPosition?.latitude}, ${_currentPosition?.longitude}');

      // Load nearby reports
      await _loadNearbyReports();
      print('Nearby reports loaded');
    } catch (e) {
      print('Error initializing map: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error initializing map: $e'),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _initializeMap,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadNearbyReports() async {
    if (_currentPosition == null) {
      print('No current position available');
      return;
    }

    try {
      print('Loading nearby reports...');
      // For now, we'll use an empty list since we don't have a backend
      final reports = <SafetyReport>[];
      print('Found ${reports.length} nearby reports');

      if (mounted) {
        setState(() {
          _nearbyReports = reports;
          _updateHeatmap();
        });
      }
    } catch (e) {
      print('Error loading reports: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading reports: $e')),
        );
      }
    }
  }

  void _updateHeatmap() {
    final circles = _nearbyReports.map((report) {
      // Calculate circle color based on severity and verification count
      Color color;
      switch (report.severity) {
        case ReportSeverity.high:
          color = Colors.red.withOpacity(0.3);
          break;
        case ReportSeverity.medium:
          color = Colors.orange.withOpacity(0.3);
          break;
        case ReportSeverity.low:
          color = Colors.yellow.withOpacity(0.3);
          break;
      }

      return Circle(
        circleId: CircleId(report.id),
        center: LatLng(
          report.location.latitude,
          report.location.longitude,
        ),
        radius: report.radius,
        fillColor: color,
        strokeColor: color.withOpacity(0.8),
        strokeWidth: 2,
      );
    }).toSet();

    setState(() {
      _safetyCircles = circles;
    });
  }

  void _showReportDialog() async {
    if (_currentPosition == null) return;

    final result = await showDialog<SafetyReport>(
      context: context,
      builder: (context) => ReportSafetyDialog(
        initialLocation: LatLng(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        ),
        onSubmit: (report) async {
          // For now, we'll just return the report without saving it
          return report;
        },
      ),
    );

    if (result != null) {
      await _loadNearbyReports();
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _currentPosition == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(
                _currentPosition!.latitude,
                _currentPosition!.longitude,
              ),
              zoom: 15,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            circles: _safetyCircles,
            onMapCreated: (controller) {
              _mapController = controller;
            },
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Safety Heatmap',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_nearbyReports.length} reports in your area',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _LegendItem(
                          color: Colors.red.withOpacity(0.3),
                          label: 'High Risk',
                        ),
                        const SizedBox(width: 8),
                        _LegendItem(
                          color: Colors.orange.withOpacity(0.3),
                          label: 'Medium Risk',
                        ),
                        const SizedBox(width: 8),
                        _LegendItem(
                          color: Colors.yellow.withOpacity(0.3),
                          label: 'Low Risk',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showReportDialog,
        icon: const Icon(Icons.warning_amber_rounded),
        label: const Text('Report Safety Concern'),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
} 