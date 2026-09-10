import 'package:flutter/material.dart';

/// The Unified Dashboard: attendance summary, library activity, and
/// financial overview at a glance, per the professor's required feature.
/// Show/hide management widgets (approve expense, create event, etc.)
/// based on the current user's role.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Unified dashboard — build me in Week 3')),
    );
  }
}
