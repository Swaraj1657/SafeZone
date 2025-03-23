import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../utils/constants.dart';
import '../services/emergency_service.dart';

/// SOSButton is a custom widget that handles emergency alerts
/// It toggles emergency mode on/off with a single tap
class SOSButton extends StatefulWidget {
  const SOSButton({super.key});

  @override
  State<SOSButton> createState() => _SOSButtonState();
}

class _SOSButtonState extends State<SOSButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 5),
        action: isError ? SnackBarAction(
          label: kIsWeb ? 'Add Contacts' : 'Settings',
          textColor: Colors.white,
          onPressed: () {
            Navigator.pushNamed(context, '/emergency-contacts');
          },
        ) : null,
      ),
    );
  }

  Future<void> _handleSOSPress() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final emergencyService = EmergencyService.instance;
      
      if (emergencyService.isEmergencyActive()) {
        await emergencyService.stopEmergencyProcess();
        _showMessage(
          kIsWeb 
              ? 'Emergency tracking stopped'
              : 'Emergency mode deactivated'
        );
      } else {
        await emergencyService.startEmergencyProcess();
        _showMessage(
          kIsWeb 
              ? 'Emergency tracking started'
              : 'Emergency mode activated - Tap again to deactivate'
        );
      }
    } catch (e) {
      String errorMessage = 'An error occurred';
      
      if (e.toString().contains('No emergency contacts')) {
        errorMessage = 'Please add emergency contacts first';
      } else if (e.toString().contains('permission')) {
        errorMessage = kIsWeb
            ? 'Please allow location access in your browser settings'
            : 'Required permissions are not granted. Please check settings.';
      } else if (e.toString().contains('location services')) {
        errorMessage = kIsWeb
            ? 'Please enable location services in your browser'
            : 'Please enable location services to use emergency features';
      }
      
      _showMessage(errorMessage, isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final emergencyService = EmergencyService.instance;
    final isActive = emergencyService.isEmergencyActive();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (kIsWeb) ...[
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Web Version: Limited to location tracking only',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
        ],
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final scale = 1.0 + (_animationController.value * 0.1);
            final color = isActive
                ? Colors.red
                : Colors.red.withOpacity(0.8);

            return Transform.scale(
              scale: isActive ? scale : 1.0,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSOSPress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(24),
                  elevation: isActive ? 8.0 : 4.0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(
                        isActive ? Icons.close : Icons.warning_rounded,
                        size: 48,
                        color: Colors.white,
                      ),
              ),
            );
          },
        ),
      ],
    );
  }
}
