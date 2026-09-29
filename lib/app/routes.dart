import 'package:flutter/material.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/profile_screen.dart';
import '../features/auth/screens/edit_profile_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/faith/screens/events_list_screen.dart';
import '../features/faith/screens/event_detail_screen.dart';
import '../features/faith/screens/event_form_screen.dart';
import '../features/faith/screens/attendance_scanner_screen.dart';
import '../features/qr/screens/qr_create_screen.dart';
import '../features/qr/screens/qr_management_screen.dart';
import '../features/qr/screens/scan_records_screen.dart';
import '../features/library/screens/library_catalog_screen.dart';
import '../features/library/screens/book_detail_screen.dart';
import '../features/library/screens/book_form_screen.dart';
import '../features/finance/screens/finance_screen.dart';
import '../features/finance/screens/transaction_form_screen.dart';
import '../shared/widgets/leader_only.dart';

class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String events = '/events';
  static const String eventDetail = '/event-detail';
  static const String eventForm = '/event-form';
  static const String attendanceScanner = '/attendance-scanner';
  static const String library = '/library';
  static const String bookDetail = '/book-detail';
  static const String bookForm = '/book-form';
  static const String finance = '/finance';
  static const String transactionForm = '/transaction-form';
  static const String qrCreate = '/qr-create';
  static const String qrManagement = '/qr-management';
  static const String scanRecords = '/scan-records';

  static Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginScreen(),
    dashboard: (context) => const DashboardScreen(),
    profile: (context) => const ProfileScreen(),
    editProfile: (context) => const EditProfileScreen(),
    events: (context) => const EventsListScreen(),
    eventDetail: (context) => const EventDetailScreen(),
    eventForm: (context) => const LeaderOnly(child: EventFormScreen()),
    attendanceScanner: (context) => const AttendanceScannerScreen(),
    library: (context) => const LibraryCatalogScreen(),
    bookDetail: (context) => const BookDetailScreen(),
    bookForm: (context) => const LeaderOnly(child: BookFormScreen()),
    finance: (context) => const LeaderOnly(child: FinanceScreen()),
    transactionForm: (context) => const LeaderOnly(child: TransactionFormScreen()),
    qrCreate: (context) => const LeaderOnly(child: QrCreateScreen()),
    qrManagement: (context) => const LeaderOnly(child: QrManagementScreen()),
    scanRecords: (context) => const LeaderOnly(child: ScanRecordsScreen()),
  };
}
