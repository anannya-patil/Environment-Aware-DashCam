import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../ui/emergency_alert_page.dart';
import 'location_service.dart';

class EmergencyService {

  // 🔥 Toggle this (TRUE for emulator testing)
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

    print("🚨 EMERGENCY TRIGGERED 🚨");

    // 1. Get location
    String? locationLink = await LocationService.getLocationLink();

    String message = "Possible accident detected.";
    if (locationLink != null) {
      message += "\nLocation: $locationLink";
    }

    List<String> contacts = [
      "1234567890",
      "9876543210"
    ];

    // 🔥 DEBUG MODE (EMULATOR)
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

    // 🔥 REAL MODE (PHONE)

    // 👉 Send SMS to contacts (one by one)
    for (String number in contacts) {
      try {
        final Uri smsUri = Uri(
          scheme: 'sms',
          path: number,
          queryParameters: {'body': message},
        );

        await launchUrl(smsUri);

        // 🔥 Delay between SMS openings
        await Future.delayed(const Duration(seconds: 2));

      } catch (e) {
        print("SMS failed for $number: $e");
      }
    }

    // 🔥 Delay before calling
    await Future.delayed(const Duration(seconds: 2));

    // 👉 Call primary contact
    try {
      final Uri callUri = Uri(
        scheme: 'tel',
        path: contacts.first,
      );

      await launchUrl(callUri);
    } catch (e) {
      print("Call failed: $e");
    }
  }
}