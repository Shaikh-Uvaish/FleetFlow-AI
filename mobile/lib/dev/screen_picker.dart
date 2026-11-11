import 'package:flutter/material.dart';

import '../features/authentication/presentation/screens/login_screen.dart';
import '../features/authentication/presentation/screens/otp_verification_screen.dart';

// A simple list of all finished screens, so you can open any one with a tap.
// Every day, add one import and one line in the list below.
class ScreenPicker extends StatelessWidget {
  const ScreenPicker({super.key});

  @override
  Widget build(BuildContext context) {
    // Name shown in the list : the screen it opens
    final screens = <String, Widget>{
      'Login': const LoginScreen(),
      'OTP Verification': const OtpVerificationScreen(
        maskedPhone: '+1 (555) •••-2834',
        assignedUnit: 'Driver Ray Morales (#DRV-904)',
      ),
    };

    return Scaffold(
      appBar: AppBar(title: const Text('All Screens')),
      body: ListView(
        children: [
          for (final entry in screens.entries)
            ListTile(
              title: Text(entry.key),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => entry.value),
                );
              },
            ),
        ],
      ),
    );
  }
}