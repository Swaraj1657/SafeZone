import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../services/emergency_service.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  List<String> contacts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    setState(() => isLoading = true);
    final loadedContacts = await EmergencyService.instance.getEmergencyContacts();
    setState(() {
      contacts = loadedContacts;
      isLoading = false;
    });
  }

  Future<void> _addContact() async {
    final contact = await _showContactDialog();
    if (contact != null) {
      final prefs = await SharedPreferences.getInstance();
      contacts.add(contact);
      await prefs.setStringList('emergency_contacts', contacts);
      setState(() {});
    }
  }

  Future<void> _editContact(int index) async {
    final contact = await _showContactDialog(initialValue: contacts[index]);
    if (contact != null) {
      final prefs = await SharedPreferences.getInstance();
      contacts[index] = contact;
      await prefs.setStringList('emergency_contacts', contacts);
      setState(() {});
    }
  }

  Future<void> _deleteContact(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Contact'),
        content: const Text('Are you sure you want to delete this contact?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      contacts.removeAt(index);
      await prefs.setStringList('emergency_contacts', contacts);
      setState(() {});
    }
  }

  Future<String?> _showContactDialog({String? initialValue}) async {
    final controller = TextEditingController(text: initialValue);
    
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(initialValue == null ? 'Add Contact' : 'Edit Contact'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            hintText: 'Enter phone number',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final number = controller.text.trim();
              if (number.isNotEmpty) {
                Navigator.pop(context, number);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        title: Text('Emergency Contacts', style: AppTextStyles.heading),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    'Add emergency contacts who will be notified when you press the SOS button.',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: contacts.isEmpty
                      ? Center(
                          child: Text(
                            'No emergency contacts added yet',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          itemCount: contacts.length,
                          itemBuilder: (context, index) {
                            return Card(
                              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                              child: ListTile(
                                leading: const Icon(Icons.phone),
                                title: Text(
                                  contacts[index],
                                  style: AppTextStyles.body,
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () => _editContact(index),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      color: Colors.red,
                                      onPressed: () => _deleteContact(index),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addContact,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }
} 