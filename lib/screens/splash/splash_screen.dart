import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:xseven_presensi/screens/dashboard/dashboard_screen.dart';
import 'package:xseven_presensi/screens/login/login_screen.dart';
import 'package:xseven_presensi/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _auth = AuthService();

  StreamSubscription<User?>? _subscription;
  Timer? _timer;

  bool _minDelayDone = false;
  bool _authResolved = false;
  bool _navigated = false;
  User? _user;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1500), () {
      _minDelayDone = true;
      _go();
    });
    _subscription = _auth.authStateChanges.listen(
      (user) {
        _user = user;
        _authResolved = true;
        _go();
      },
      onError: (_) {
        _user = null;
        _authResolved = true;
        _go();
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _subscription?.cancel();
    super.dispose();
  }

  void _go() {
    if (!mounted || _navigated || !_minDelayDone || !_authResolved) return;
    _navigated = true;
    final target = _user == null ? const LoginScreen() : const DashboardScreen();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => target),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Center(
                child: Text(
                  'X7',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'XSEVEN PRESENSI',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sistem Presensi Pegawai',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 40),
            const SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(strokeWidth: 2.6),
            ),
          ],
        ),
      ),
    );
  }
}