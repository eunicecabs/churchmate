import 'package:flutter/material.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/faith/screens/qr_display_screen.dart';
import '../features/faith/screens/events_list_screen.dart';
import '../features/faith/screens/event_detail_screen.dart';
import '../features/library/screens/library_catalog_screen.dart';
import '../features/library/screens/book_detail_screen.dart';
import '../features/finance/screens/finance_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String qrDisplay = '/qr-display';
  static const String events = '/events';
  static const String eventDetail = '/event-detail';
  static const String library = '/library';
  static const String bookDetail = '/book-detail';
  static const String finance = '/finance';

  static Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginScreen(),
    dashboard: (context) => const DashboardScreen(),
    qrDisplay: (context) => const QrDisplayScreen(),
    events: (context) => const EventsListScreen(),
    eventDetail: (context) => const EventDetailScreen(),
    library: (context) => const LibraryCatalogScreen(),
    bookDetail: (context) => const BookDetailScreen(),
    finance: (context) => const FinanceScreen(),
  };
}