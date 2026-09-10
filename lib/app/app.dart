import 'package:flutter/material.dart';
import 'theme.dart';
import 'routes.dart';

/// Root widget of ChurchMate. Wires up theme + named routes.
/// Wrap this in your Provider(s) once auth/state services are built, e.g.:
///
/// MultiProvider(
///   providers: [ChangeNotifierProvider(create: (_) => AuthService())],
///   child: const ChurchMateApp(),
/// )
class ChurchMateApp extends StatelessWidget {
  const ChurchMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChurchMate',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      initialRoute: AppRoutes.login,
      routes: AppRoutes.routes,
    );
  }
}
