import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../models/user.dart';
import '../services/supabase_services.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _idController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isHovered = false;
  String? _error;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _idController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedCard({required Widget child}) {
    return MouseRegion(
      onEnter: (_) => _animationController.forward(),
      onExit: (_) => _animationController.reverse(),
      child: GestureDetector(
        onTapDown: (_) => _animationController.forward(),
        onTapUp: (_) => _animationController.reverse(),
        onTapCancel: () => _animationController.reverse(),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Card(
                elevation: 6 * _scaleAnimation.value,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Colors.white.withOpacity(0.8), // Match reference transparency
                child: child,
              ),
            );
          },
          child: child,
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = await SupabaseService().validateStudentId(_idController.text.trim());
      if (user == null) {
        setState(() {
          _error = 'Invalid student ID';
          _isLoading = false;
        });
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardScreen(student: user),
        ),
      );
    } catch (e) {
      setState(() {
        _error = 'Login failed: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.purple[900]!, Colors.purple[300]!],
            stops: const [0.0, 0.8], // Match reference gradient
          ),
        ),
        child: SafeArea(
          top: true,
          bottom: true,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildAnimatedCard(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 24),
                        Text(
                          'Student Login',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Enter Your Student ID',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _idController,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            labelText: 'Student ID',
                            hintText: 'Enter your UUID',
                            labelStyle: const TextStyle(color: Colors.black),
                            prefixIcon: const Icon(Icons.person, color: Colors.black),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.8),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your student ID';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        if (_error != null)
                          Text(
                            _error!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        const SizedBox(height: 24),
                        MouseRegion(
                          onEnter: (_) => setState(() => _isHovered = true),
                          onExit: (_) => setState(() => _isHovered = false),
                          child: AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _scaleAnimation.value,
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
                                            ? [Colors.purple[900]!, Colors.purple[500]!] // Hover effect
                                            : [Colors.purple[800]!, Colors.purple[400]!], // Match reference
                                      ),
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: Container(
                                      alignment: Alignment.center,
                                      constraints: const BoxConstraints(minHeight: 50),
                                      child: _isLoading
                                          ? const CircularProgressIndicator(color: Colors.white)
                                          : const Text(
                                        'Sign In',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}