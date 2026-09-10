import 'package:flutter/material.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';

/// Named routes for the whole app. Add one line per new screen as you
/// build features — keeps navigation centralized instead of scattered
/// Navigator.push calls with inline widget builders.
class AppRoutes {
  static const login = '/login';
  static const dashboard = '/dashboard';

  static Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginScreen(),
    dashboard: (context) => const DashboardScreen(),
    // faith: (context) => const EventListScreen(),
    // library: (context) => const CatalogScreen(),
    // finance: (context) => const TransactionsScreen(),
  };
}
