import 'package:flutter/material.dart';

/// Corresponds to the "Log in" box in your account/RBAC flowchart.
/// On success, read the user's role from Firestore and route to
/// AppRoutes.dashboard — the dashboard itself then shows/hides
/// Leader-only actions based on that role.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Login screen — build me first (Week 3)')),
    );
  }
}
