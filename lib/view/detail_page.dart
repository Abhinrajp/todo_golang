import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_golang/model/todo_model.dart';
import 'package:todo_golang/provider/todo_provider.dart';

class Detailscreen extends StatefulWidget {
  final int todoid;
  const Detailscreen({super.key, required this.todoid});
  @override
  State<Detailscreen> createState() => _DetailscreenState();
}

class _DetailscreenState extends State<Detailscreen>
    with TickerProviderStateMixin {
  late AnimationController _orbitController;
  late AnimationController _dateScaleController;
  late AnimationController _typewriterController;
  late AnimationController _fadeController;
  late AnimationController _glowController;
  late AnimationController _warpController;

  late Animation<double> _dateScale;
  late Animation<double> _contentFade;
  late Animation<double> _warpScale;

  String _displayTitle = '';
  String _fullTitle = '';
  bool _warping = false;

  @override
  void initState() {
    super.initState();

    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _dateScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _dateScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _dateScaleController, curve: Curves.elasticOut),
    );

    _typewriterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _contentFade = Tween<double>(begin: 0, end: 1).animate(_fadeController);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _warpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _warpScale = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _warpController, curve: Curves.easeIn));

    // Sequence the entry animations
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _dateScaleController.forward();
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _startTypewriter();
    });
  }

  void _startTypewriter() {
    _typewriterController.addListener(() {
      if (!mounted) return;
      final chars = (_typewriterController.value * _fullTitle.length).round();
      setState(() => _displayTitle = _fullTitle.substring(0, chars));
      if (_typewriterController.value >= 1.0) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) _fadeController.forward();
        });
      }
    });
    _typewriterController.forward();
  }

  @override
  void dispose() {
    _orbitController.dispose();
    _dateScaleController.dispose();
    _typewriterController.dispose();
    _fadeController.dispose();
    _glowController.dispose();
    _warpController.dispose();
    super.dispose();
  }

  Future<void> _warpExit(BuildContext context, Todomodel todo) async {
    setState(() => _warping = true);
    await _warpController.forward();
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final todo = context.read<TodoProvider>().todos.firstWhere(
      (e) => e.id == widget.todoid,
      orElse: () => Todomodel(title: '', content: '', enddate: '', id: -1),
    );

    if (_fullTitle.isEmpty && todo.title.isNotEmpty) {
      _fullTitle = todo.title.toUpperCase();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D0221),
      body: Stack(
        children: [
          // Starfield
          AnimatedBuilder(
            animation: _orbitController,
            builder: (_, _) => CustomPaint(
              painter: _StaticStarsPainter(),
              child: const SizedBox.expand(),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Back button
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(
                                0xFF7B61FF,
                              ).withValues(alpha: 0.5),
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Color(0xFF7B61FF),
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'MISSION DETAILS',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                          letterSpacing: 3,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ScaleTransition(
                    scale: _warping
                        ? _warpScale
                        : const AlwaysStoppedAnimation(1.0),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
                      child: Column(
                        children: [
                          // Date countdown
                          ScaleTransition(
                            scale: _dateScale,
                            child: Column(
                              children: [
                                const Text(
                                  'TARGET DATE',
                                  style: TextStyle(
                                    color: Color(0xFF8888AA),
                                    fontSize: 11,
                                    letterSpacing: 3,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  todo.enddate,
                                  style: const TextStyle(
                                    color: Color(0xFFFFD700),
                                    fontSize: 42,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 36),

                          // Orbit ring + card
                          AnimatedBuilder(
                            animation: _orbitController,
                            builder: (_, child) => CustomPaint(
                              painter: _OrbitPainter(_orbitController.value),
                              child: child,
                            ),
                            child: Container(
                              margin: const EdgeInsets.all(24),
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A1040),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: const Color(
                                    0xFF7B61FF,
                                  ).withValues(alpha: 0.4),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF7B61FF,
                                    ).withValues(alpha: 0.2),
                                    blurRadius: 30,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Planet icon
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          Color(0xFF9D4EDD),
                                          Color(0xFF1A1040),
                                        ],
                                        center: Alignment(-0.3, -0.3),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.public,
                                      color: Colors.white70,
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Typewriter title
                                  Text(
                                    _displayTitle.isEmpty ? '' : _displayTitle,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),

                                  // Fade-in content
                                  FadeTransition(
                                    opacity: _contentFade,
                                    child: Text(
                                      todo.content,
                                      style: const TextStyle(
                                        color: Color(0xFF8888AA),
                                        fontSize: 16,
                                        height: 1.6,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Pulsing complete button
                          AnimatedBuilder(
                            animation: _glowController,
                            builder: (_, _) => GestureDetector(
                              onTap: () => _warpExit(context, todo),
                              child: Container(
                                width: double.infinity,
                                height: 56,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFF9D4EDD),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF9D4EDD).withValues(
                                        alpha:
                                            0.2 + _glowController.value * 0.35,
                                      ),
                                      blurRadius:
                                          16 + _glowController.value * 12,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline,
                                      color: Color(0xFF9D4EDD),
                                      size: 22,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'MARK COMPLETE',
                                      style: TextStyle(
                                        color: Color(0xFF9D4EDD),
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 2,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Orbit Painter ─────────────────────────────────────────────────────────────

class _OrbitPainter extends CustomPainter {
  final double t;
  _OrbitPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final rx = size.width / 2 + 10;
    final ry = 18.0;

    final paint = Paint()
      ..color = const Color(0xFF9D4EDD).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2),
      paint,
    );

    // Orbiting dot
    final angle = t * 2 * pi;
    final dx = cx + rx * cos(angle);
    final dy = cy + ry * sin(angle);
    canvas.drawCircle(
      Offset(dx, dy),
      4,
      Paint()
        ..color = const Color(0xFF9D4EDD)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawCircle(Offset(dx, dy), 3, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_) => true;
}

// ── Static Stars Painter ──────────────────────────────────────────────────────

class _StaticStarsPainter extends CustomPainter {
  static final _rand = Random(77);
  static final _stars = List.generate(
    70,
    (_) => Offset(_rand.nextDouble(), _rand.nextDouble()),
  );
  static final _sizes = List.generate(
    70,
    (_) => _rand.nextDouble() * 1.8 + 0.3,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.6);
    for (int i = 0; i < _stars.length; i++) {
      canvas.drawCircle(
        Offset(_stars[i].dx * size.width, _stars[i].dy * size.height),
        _sizes[i],
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
