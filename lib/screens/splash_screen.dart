import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import '../providers/auth_provider.dart';
import '../providers/menu_provider.dart';
import '../config/routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Load menu items first
      final menuProvider = Provider.of<MenuProvider>(context, listen: false);
      await menuProvider.fetchMenuItems();
      
      // Wait for splash duration
      await Future<void>.delayed(const Duration(seconds: 2));
      
      if (!mounted) return;
      
      // Check authentication
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      if (authProvider.isLoggedIn) {
        if (authProvider.isAdmin) {
          Get.offAllNamed<dynamic>(AppRoutes.adminDashboard);
        } else {
          Get.offAllNamed<dynamic>(AppRoutes.home);
        }
      } else {
        Get.offAllNamed<dynamic>(AppRoutes.login);
      }
    } catch (e) {
      debugPrint('Splash error: $e');
      // On error, go to login
      if (mounted) {
        Get.offAllNamed<dynamic>(AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade700,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo with simple animation
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  size: 80,
                  color: Colors.orange,
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // App Name
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: const Text(
                'Rajeev Chowmin Center',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Tagline
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: child,
                );
              },
              child: const Text(
                'Delicious Chowmin Delivered',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Loading Indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
