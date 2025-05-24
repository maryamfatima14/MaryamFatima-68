import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:lottie/lottie.dart';
import 'login_screen.dart';
import 'dart:developer' as developer;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Animation setup for Lottie scaling
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();

    // Navigate to AdminLoginScreen after 5 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo[700]!, Colors.indigo[300]!],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Semantics(
                      label: 'Student Task Tracker Animation',
                      child: Lottie.asset(
                        'assets/images/login.json', // Path to your Lottie file
                        width: size.width * 0.7, // Increased from 0.5 to 0.7
                        height: size.width * 0.7, // Increased proportionally
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                        repeat: true,
                        animate: true,
                        errorBuilder: (context, error, stackTrace) {
                          developer.log('Lottie Error: $error', stackTrace: stackTrace);
                          return const Icon(
                            Icons.error,
                            size: 80,
                            color: Colors.white,
                          );
                        },
                        frameRate: FrameRate.max,
                        onLoaded: (composition) {
                          developer.log('Lottie Loaded: ${composition.duration.inMilliseconds}ms');
                        },
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    'Student Portal',
                    textStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                    speed: const Duration(milliseconds: 100),
                  ),
                ],
                totalRepeatCount: 1,
              ),
              const SizedBox(height: 8),
              AnimatedTextKit(
                animatedTexts: [
                  FadeAnimatedText(
                    'Admin Panel',
                    textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white70,
                    ),
                    duration: const Duration(milliseconds: 1500),
                  ),
                ],
                totalRepeatCount: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}