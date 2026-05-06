import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInCubic),
    );
    _scaleAnimation = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
    });

    final supabase = Supabase.instance.client;
    try {
      final response = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (response.user == null && response.session == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Falha no cadastro. Tente novamente.')),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Conta criada com sucesso!')));
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } on AuthException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha no cadastro: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.secondary.withOpacity(0.12),
                  colorScheme.surface,
                ],
              ),
            ),
          ),
          Positioned(
            top: -50,
            left: -50,
            child: _AnimatedGlowCircle(colorScheme.primary.withOpacity(0.18), 150, _animController),
          ),
          Positioned(
            bottom: -70,
            right: -70,
            child: _AnimatedGlowCircle(colorScheme.secondary.withOpacity(0.16), 200, _animController),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          'Entre para a revolução',
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Crie uma conta e transforme sua organização diária em resultado.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onBackground.withOpacity(0.72),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                            child: Container(
                              decoration: BoxDecoration(
                                color: colorScheme.surface.withOpacity(0.86),
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(
                                  color: colorScheme.secondary.withOpacity(0.18),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: colorScheme.secondary.withOpacity(0.1),
                                    blurRadius: 30,
                                    offset: const Offset(0, 20),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(28),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Bem-vindo(a)!',
                                              style: theme.textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Seu espaço para planejamento produtivo.',
                                              style: theme.textTheme.bodyMedium?.copyWith(
                                                color: colorScheme.onSurface.withOpacity(0.72),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: colorScheme.primary.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        padding: const EdgeInsets.all(14),
                                        child: Icon(
                                          Icons.star_outline,
                                          color: colorScheme.primary,
                                          size: 28,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  TextField(
                                    controller: _emailController,
                                    decoration: InputDecoration(
                                      labelText: 'Email',
                                      prefixIcon: const Icon(Icons.email_outlined),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                  const SizedBox(height: 16),
                                  TextField(
                                    controller: _passwordController,
                                    decoration: InputDecoration(
                                      labelText: 'Senha',
                                      prefixIcon: const Icon(Icons.lock_outline),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    obscureText: true,
                                  ),
                                  const SizedBox(height: 24),
                                  ElevatedButton(
                                    onPressed: _isLoading ? null : _signUp,
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 18),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          )
                                        : const Text(
                                            'Cadastrar',
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                          ),
                                  ),
                                  const SizedBox(height: 24),
                                  Wrap(
                                    spacing: 10,
                                    children: [
                                      _buildFeatureChip('Visual moderno', colorScheme.primary),
                                      _buildFeatureChip('Fácil de usar', colorScheme.secondary),
                                      _buildFeatureChip('Rápido e seguro', colorScheme.primary),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Já tem conta?',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onBackground.withOpacity(0.72),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(context, '/login');
                              },
                              child: const Text('Entrar'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String label, Color color) {
    return Chip(
      label: Text(label),
      labelStyle: TextStyle(color: Colors.white),
      backgroundColor: color,
    );
  }
}

class _AnimatedGlowCircle extends AnimatedWidget {
  final Color color;
  final double size;

  const _AnimatedGlowCircle(this.color, this.size, AnimationController animation)
      : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    final animation = listenable as AnimationController;
    return Opacity(
      opacity: 0.3 + (animation.value * 0.3),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
