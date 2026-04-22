import 'dart:async';
import 'package:flutter/material.dart';

class EmergencyAlertPage extends StatefulWidget {
  final VoidCallback onTimeout;

  const EmergencyAlertPage({super.key, required this.onTimeout});

  @override
  State<EmergencyAlertPage> createState() => _EmergencyAlertPageState();
}

class _EmergencyAlertPageState extends State<EmergencyAlertPage> {
  int countdown = 10;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startCountdown();
  }

  void startCountdown() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (countdown == 0) {
        t.cancel();
        widget.onTimeout(); // trigger emergency action
      } else {
        setState(() {
          countdown--;
        });
      }
    });
  }

  void cancelEmergency() {
    timer?.cancel();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade900,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning, color: Colors.white, size: 100),

              const SizedBox(height: 20),

              const Text(
                "EMERGENCY ALERT",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                "Sending alert in $countdown sec",
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),

              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: cancelEmergency,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: const Text(
                  "CANCEL",
                  style: TextStyle(color: Colors.red, fontSize: 18),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}