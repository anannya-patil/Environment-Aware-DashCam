import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../ui/emergency_alert_page.dart';
import 'location_service.dart';
import '../utils/storage_service.dart';
import '../models/contact.dart';

class EmergencyService {

  static const bool debugMode = false;

  static void trigger(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EmergencyAlertPage(
          onTimeout: () {
            _handleEmergency(context);
          },
        ),
      ),
    );
  }

  static Future<void> _handleEmergency(BuildContext context) async {
    Navigator.pop(context);

    print("EMERGENCY TRIGGERED");

    String? locationLink = await LocationService.getLocationLink();

    String message = "Possible accident detected.";
    if (locationLink != null) {
      message += "\nLocation: $locationLink";
    }

    List<ContactModel> savedContacts =
        await StorageService.getContacts();

    List<String> contacts =
        savedContacts.map((c) => c.phone).toList();

    if (contacts.isEmpty) {
      print("No emergency contacts found");
      return;
    }

    if (debugMode) {
      print("Contacts: $contacts");
      print("Message: $message");

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("DEBUG: Emergency Triggered"),
          content: Text(
            "Contacts: $contacts\n\nMessage:\n$message",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );

      return;
    }

    String number = contacts.first;

    try {
      final Uri smsUri = Uri(
        scheme: 'sms',
        path: number,
        queryParameters: {'body': message},
      );

      await launchUrl(smsUri);

      await Future.delayed(const Duration(seconds: 2));

    } catch (e) {
      print("SMS failed: $e");
    }

    await Future.delayed(const Duration(seconds: 2));

    try {
      final Uri callUri = Uri(
        scheme: 'tel',
        path: number,
      );

      await launchUrl(callUri);
    } catch (e) {
      print("Call failed: $e");
    }
  }
}