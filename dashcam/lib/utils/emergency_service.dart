import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../ui/emergency_alert_page.dart';
import 'location_service.dart';
import '../utils/storage_service.dart';
import '../models/contact.dart';

class EmergencyService {

  static const bool debugMode = false;

  static void trigger({BuildContext? context}) {
    if (context != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EmergencyAlertPage(
            onTimeout: () {
              _handleEmergency(context: context);
            },
          ),
        ),
      );
    } else {
      triggerWithoutUI();
    }
  }

  static Future<void> triggerWithoutUI() async {
    await Future.delayed(const Duration(seconds: 5));
    await _handleEmergency();
  }

  static Future<void> _handleEmergency({BuildContext? context}) async {

    if (context != null) {
      Navigator.pop(context);
    }

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
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No emergency contacts added")),
        );
      }
      return;
    }

    if (debugMode) return;

    for (String number in contacts) {
      try {
        final Uri smsUri = Uri(
          scheme: 'sms',
          path: number,
          queryParameters: {'body': message},
        );

        await launchUrl(smsUri);
        await Future.delayed(const Duration(seconds: 2));

      } catch (e) {
        print("SMS failed for $number: $e");
      }
    }

    await Future.delayed(const Duration(seconds: 2));

    for (String number in contacts) {
      try {
        final Uri callUri = Uri(
          scheme: 'tel',
          path: number,
        );

        await launchUrl(callUri);
        await Future.delayed(const Duration(seconds: 3));

      } catch (e) {
        print("Call failed for $number: $e");
      }
    }
  }
}