import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/safety_report.dart';
import '../utils/constants.dart';

class ReportSafetyDialog extends StatefulWidget {
  final Function(SafetyReport) onSubmit;
  final LatLng initialLocation;

  const ReportSafetyDialog({
    super.key,
    required this.onSubmit,
    required this.initialLocation,
  });

  @override
  State<ReportSafetyDialog> createState() => _ReportSafetyDialogState();
}

class _ReportSafetyDialogState extends State<ReportSafetyDialog> {
  final _formKey = GlobalKey<FormState>();
  late ReportType _selectedType = ReportType.harassment;
  late ReportSeverity _selectedSeverity = ReportSeverity.medium;
  late double _radius = 100.0;
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitReport() {
    if (_formKey.currentState!.validate()) {
      final report = SafetyReport(
        location: widget.initialLocation,
        type: _selectedType,
        severity: _selectedSeverity,
        description: _descriptionController.text,
        radius: _radius,
        reporterId: 'current_user_id', // TODO: Get from auth service
      );
      widget.onSubmit(report);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Report Safety Concern'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<ReportType>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: 'Type of Concern'),
                items: ReportType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ReportSeverity>(
                value: _selectedSeverity,
                decoration: const InputDecoration(labelText: 'Severity Level'),
                items: ReportSeverity.values.map((severity) {
                  return DropdownMenuItem(
                    value: severity,
                    child: Text(severity.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSeverity = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Provide details about the safety concern',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Affected Radius (meters):'),
                  Expanded(
                    child: Slider(
                      value: _radius,
                      min: 50,
                      max: 500,
                      divisions: 9,
                      label: _radius.round().toString(),
                      onChanged: (value) {
                        setState(() {
                          _radius = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitReport,
          child: const Text('Submit Report'),
        ),
      ],
    );
  }
} 