import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/community_post_card.dart';
import '../widgets/report_safety_dialog.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/community_safety_service.dart';
import 'package:geolocator/geolocator.dart';
import '../models/safety_report.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// CommunityScreen shows safety alerts and community posts
class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final CommunitySafetyService _safetyService = CommunitySafetyService.instance;
  GoogleMapController? _mapController;
  Set<Circle> _safetyCircles = {};
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _getCurrentLocation();
    _loadSafetyData();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();
        if (requested == LocationPermission.denied) {
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLocation!, 15),
      );
    } catch (e) {
      // Handle location error
      print('Error getting location: $e');
    }
  }

  Future<void> _loadSafetyData() async {
    final reports = await _safetyService.getSafetyReports();
    setState(() {
      _safetyCircles = reports.map((report) {
        final severityColor = report.severity.color;
        return Circle(
          circleId: CircleId(report.id),
          center: report.latLng,
          radius: report.radius,
          fillColor: Color(severityColor).withOpacity(0.3),
          strokeColor: Color(severityColor),
          strokeWidth: 2,
        );
      }).toSet();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _showReportDialog() {
    if (_currentLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Waiting for location...'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => ReportSafetyDialog(
        initialLocation: _currentLocation!,
        onSubmit: (report) async {
          await _safetyService.createSafetyReport(
            location: GeoPoint(_currentLocation!.latitude, _currentLocation!.longitude),
            type: report.type,
            severity: report.severity,
            description: report.description,
            reporterId: report.reporterId,
            radius: report.radius,
            images: report.images,
          );
          _loadSafetyData();
          Navigator.of(context).pop(report);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        title: Text('Community Safety', style: AppTextStyles.heading),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Safety Map'),
            Tab(text: 'Community Posts'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Safety Map Tab
          Column(
            children: [
              Expanded(
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentLocation ?? const LatLng(0, 0),
                    zoom: 15,
                  ),
                  circles: _safetyCircles,
                  onMapCreated: (controller) {
                    _mapController = controller;
                    if (_currentLocation != null) {
                      controller.animateCamera(
                        CameraUpdate.newLatLngZoom(_currentLocation!, 15),
                      );
                    }
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),
              ),
            ],
          ),
          // Community Posts Tab
          _CommunityPostsView(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showReportDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_location_alt),
      ),
    );
  }
}

class _CommunityPostsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search safety alerts...',
              hintStyle: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.5),
              ),
              prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.cardBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            style: TextStyle(color: AppColors.textPrimary),
          ),
        ),

        // Category tabs
        Container(
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _CategoryTab(
                label: 'All Posts',
                isSelected: true,
                onTap: () {},
              ),
              _CategoryTab(
                label: 'Safety Tips',
                onTap: () {},
              ),
              _CategoryTab(
                label: 'Alerts',
                onTap: () {},
              ),
              _CategoryTab(
                label: 'Events',
                onTap: () {},
              ),
            ],
          ),
        ),

        // Posts list
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              CommunityPostCard(
                username: 'Sarah M.',
                timeAgo: '5m ago',
                content:
                    'Street lights are not working on Oak Street. Please be careful if walking alone.',
                category: PostCategory.alert,
                onTap: () {},
              ),
              CommunityPostCard(
                username: 'Safety Officer',
                timeAgo: '30m ago',
                content:
                    'Remember to share your location with trusted contacts when traveling late.',
                category: PostCategory.tip,
                isVerified: true,
                onTap: () {},
              ),
              CommunityPostCard(
                username: 'Community Center',
                timeAgo: '2h ago',
                content:
                    'Self-defense workshop this Saturday at 10 AM. All women welcome!',
                category: PostCategory.event,
                isVerified: true,
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoryTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryTab({
    required this.label,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.textSecondary.withOpacity(0.3),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
