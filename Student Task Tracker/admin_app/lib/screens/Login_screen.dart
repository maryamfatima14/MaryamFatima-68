import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/supabase_service.dart';
import 'home_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  _AdminLoginScreenState createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> with SingleTickerProviderStateMixin {
  final SupabaseService _supabaseService = SupabaseService();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isHovered = false;
  bool _hasInteracted = false;

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    )..addListener(() {
      setState(() {});
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedCredentials() async {
    if (_hasInteracted) {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('admin_email');
      final savedPassword = prefs.getString('admin_password');

      if (savedEmail != null && savedPassword != null) {
        setState(() {
          _usernameController.text = savedEmail; // Using username field for email
          _passwordController.text = savedPassword;
        });
      }
    }
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final success = await _supabaseService.loginAdmin(
          _usernameController.text.trim(),
          _passwordController.text.trim(),
        );
        if (success) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('admin_email', _usernameController.text.trim());
          await prefs.setString('admin_password', _passwordController.text.trim());
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login successful'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid credentials'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
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
            colors: [Colors.deepPurple[800]!, Colors.deepPurple[400]!],
          ),
        ),
        child: Stack(
          children: [
            // Background decorations (planets with increased sizes)
            Positioned(
              top: 50,
              left: 20,
              child: Image.asset(
                'assets/planets/planet1.png',
                width: 150,
                height: 150,
              ),
            ),
            Positioned(
              top: 150,
              right: 30,
              child: Image.asset(
                'assets/planets/planet2.png',
                width: 120,
                height: 120,
              ),
            ),
            Positioned(
              bottom: 100,
              left: 40,
              child: Image.asset(
                'assets/planets/planet3.png',
                width: 90,
                height: 90,
              ),
            ),
            // Center content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText(
                        'Welcome',
                        textStyle: GoogleFonts.poppins(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        speed: const Duration(milliseconds: 100),
                      ),
                    ],
                    totalRepeatCount: 1,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please log in',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(16),
                    width: size.width * 0.85,
                    constraints: const BoxConstraints(maxWidth: 400),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: _usernameController,
                            onChanged: (value) {
                              if (!_hasInteracted) {
                                setState(() => _hasInteracted = true);
                                _loadSavedCredentials();
                              }
                            },
                            style: GoogleFonts.poppins(
                              fontSize: 16, // Increased font size for entered text
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Username',
                              labelStyle: GoogleFonts.poppins(
                                fontSize: 18, // Increased font size for label
                                color: Colors.black,
                              ),
                              prefixIcon: const Icon(Icons.person, color: Colors.black),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.8),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your username';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            onChanged: (value) {
                              if (!_hasInteracted) {
                                setState(() => _hasInteracted = true);
                                _loadSavedCredentials();
                              }
                            },
                            style: GoogleFonts.poppins(
                              fontSize: 16, // Increased font size for entered text
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: GoogleFonts.poppins(
                                fontSize: 18, // Increased font size for label
                                color: Colors.black,
                              ),
                              prefixIcon: const Icon(Icons.lock, color: Colors.black),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.8),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          MouseRegion(
                            onEnter: (_) {
                              setState(() => _isHovered = true);
                              _controller.forward(from: 0);
                            },
                            onExit: (_) {
                              setState(() => _isHovered = false);
                              _controller.reverse();
                            },
                            child: AnimatedBuilder(
                              animation: _animation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _animation.value,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _login,
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(double.infinity, 50),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                      padding: EdgeInsets.zero,
                                      foregroundColor: Colors.white,
                                      backgroundColor: Colors.transparent,
                                      elevation: 0,
                                    ).copyWith(
                                      overlayColor: WidgetStateProperty.all(Colors.transparent),
                                      backgroundColor: WidgetStateProperty.all(Colors.transparent),
                                    ),
                                    child: Ink(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: _isHovered
                                              ? [Colors.deepPurple[900]!, Colors.deepPurple[500]!]
                                              : [Colors.deepPurple[800]!, Colors.deepPurple[400]!],
                                        ),
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: Container(
                                        alignment: Alignment.center,
                                        constraints: const BoxConstraints(minHeight: 50),
                                        child: _isLoading
                                            ? const CircularProgressIndicator(color: Colors.white)
                                            : Text(
                                          'Sign In',
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}