import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/services/auth_service.dart';
import '../core/services/firestore_service.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import 'theme.dart';
import 'routes.dart';

/// Root widget of ChurchMate. Wires up theme + named routes, plus the
/// app-wide backend services (Firebase Auth + Firestore) via Provider so
/// any screen can reach them with `context.read<AuthService>()`.
class ChurchMateApp extends StatelessWidget {
  const ChurchMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        Provider(create: (_) => FirestoreService()),
      ],
      child: MaterialApp(
        title: 'ChurchMate',
        debugShowCheckedModeBanner: false,
        theme: appTheme,
        home: const AuthGate(),
        routes: AppRoutes.routes,
      ),
    );
  }
}

/// Checks Firebase Authentication when the app starts: if a session is
/// already persisted, go straight to the Home page; otherwise show Login.
/// Also reacts live to sign-in/sign-out anywhere else in the app.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          // While a sign-in is still being verified (role check), stay on the
          // login screen so a wrong-role account never flashes the dashboard.
          if (auth.isPendingAuth) return const LoginScreen();
          // Existing session after an app restart: wait for the profile so
          // the correct (member/leader) dashboard is shown.
          if (!auth.profileResolved) {
            return const Scaffold(
              backgroundColor: AppColors.background,
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (auth.currentUser == null) return const LoginScreen();
          return const DashboardScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
