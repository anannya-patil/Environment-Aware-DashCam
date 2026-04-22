import 'package:flutter/material.dart';
import '../ui/emergency_alert_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:telephony/telephony.dart';
import 'location_service.dart';

class EmergencyService {
  static final Telephony telephony = Telephony.instance;

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

    // 2. Send SMS (TEMP NUMBERS — replace later with Person 2 data)
    List<String> contacts = [
      "1234567890",
      "9876543210"
    ];

    for (String number in contacts) {
      try {
        await telephony.sendSms(
          to: number,
          message: message,
        );
      } catch (e) {
        print("SMS failed to $number: $e");
      }
    }

    // 3. Call primary contact (first number)
    try {
      final Uri callUri = Uri(scheme: 'tel', path: contacts.first);
      await launchUrl(callUri);
    } catch (e) {
      print("Call failed: $e");
    }
  }
}