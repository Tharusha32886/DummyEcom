// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom/view/role_based_login/admin/screens/admin_home_screen.dart';
import 'package:ecom/view/role_based_login/login_screen.dart';
import 'package:ecom/view/role_based_login/User/Screen/user_app_main_screen.dart';
import 'package:ecom/view/role_based_login/forgot_password_screen.dart'; // NEW IMPORT
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // NEW: Initialize dynamic links for password reset handling
  _initDynamicLinks();
  
  runApp(const MyApp());
}

// NEW: Dynamic links initialization for password reset
void _initDynamicLinks() async {
  final initialLink = await FirebaseDynamicLinks.instance.getInitialLink();
  if (initialLink != null) {
    _handlePasswordResetLink(initialLink.link);
  }

  FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
    _handlePasswordResetLink(dynamicLinkData.link);
  });
}

// NEW: Handle password reset links
void _handlePasswordResetLink(Uri link) {
  if (link.queryParameters.containsKey('oobCode')) {
    final resetCode = link.queryParameters['oobCode']!;
    // You might want to store this and handle navigation when app is ready
    // For now, we'll just print it
    debugPrint('Password reset code: $resetCode');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const AuthStateHandler(),
        // NEW: Added routes for navigation
        routes: {
          '/login': (context) => const LoginScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/admin': (context) => const AdminHomeScreen(),
          '/user': (context) => const UserAppMainScreen(),
        },
      ),
    );
  }
}

class AuthStateHandler extends StatefulWidget {
  const AuthStateHandler({super.key});

  @override
  State<AuthStateHandler> createState() => _AuthStateHandlerState();
}

class _AuthStateHandlerState extends State<AuthStateHandler> {
  User? _currentUser;
  String? _userRole;
  
  @override
  void initState() {
    _initializeAuthState();
    super.initState();
  }

  void _initializeAuthState() {
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (!mounted) return; // prevent setState after dispose

      setState(() {
        _currentUser = user;
      });
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (!mounted) return; // prevent setState after dispose
        if (userDoc.exists) {
          setState(() {
            _userRole = userDoc['role'];
          });
        } else {
          setState(() {
            _userRole = null;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const LoginScreen();
    }
    if (_userRole == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return _userRole == "Admin"
        ? const AdminHomeScreen()
        : const UserAppMainScreen();
  }
}