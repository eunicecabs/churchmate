import 'package:flutter/material.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/faith/screens/qr_display_screen.dart';
import '../features/faith/screens/events_list_screen.dart';

/// Named routes for the whole app. Keeps navigation centralized.
class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String qrDisplay = '/qr-display';
  static const String events = '/events';
  static const String eventDetail = '/event-detail';

  static Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginScreen(),
    dashboard: (context) => const DashboardScreen(),
    qrDisplay: (context) => const QrDisplayScreen(),
    events: (context) => const EventsListScreen(),
    
    // Temporarily point eventDetail to EventsListScreen until EventDetailScreen is created,
    // or point it to a placeholder screen so navigation doesn't fail/crash.
    eventDetail: (context) => const EventsListScreen(),
  };
}