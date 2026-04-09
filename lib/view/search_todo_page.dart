import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_golang/model/todo_model.dart';
import 'package:todo_golang/provider/todo_provider.dart';
import 'package:todo_golang/view/detail_page.dart';

class Searchscreen extends StatefulWidget {
  const Searchscreen({super.key});
  @override
  State<Searchscreen> createState() => _SearchscreenState();
}

class _SearchscreenState extends State<Searchscreen>
    with TickerProviderStateMixin {
  late AnimationController _starController;
  late AnimationController _pulseController;
  final TextEditingController _searchController = TextEditingController();
  bool _hasTyped = false;

  @override
  void initState() {
    super.initState();
    _starController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _starController.dispose();
    _pulseController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0221),
      body: Stack(
        children: [
          // Starfield
          AnimatedBuilder(
            animation: _starController,
            builder: (_, _) => CustomPaint(
              painter: _SearchStarsPainter(_starController.value),
              child: const SizedBox.expand(),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
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
                      const SizedBox(width: 14),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DEEP SCAN',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 4,
                            ),
                          ),
                          Text(
                            'search the todo logs',
                            style: TextStyle(
                              color: Color(0xFF9D4EDD),
                              fontSize: 11,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Search field
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (_, child) => Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7B61FF).withValues(
                              alpha: 0.12 + _pulseController.value * 0.18,
                            ),
                            blurRadius: 14 + _pulseController.value * 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: child,
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                      onChanged: (query) {
                        setState(() => _hasTyped = query.isNotEmpty);
                        context.read<TodoProvider>().searchTodo(query: query);
                      },
                      decoration: InputDecoration(
                        hintText: '''Scan for todo's…''',
                        hintStyle: const TextStyle(
                          color: Color(0xFF8888AA),
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.travel_explore,
                          color: Color(0xFF7B61FF),
                          size: 22,
                        ),
                        suffixIcon: _hasTyped
                            ? GestureDetector(
                                onTap: () {
                                  _searchController.clear();
                                  setState(() => _hasTyped = false);
                                  context.read<TodoProvider>().searchTodo(
                                    query: '',
                                  );
                                },
                                child: const Icon(
                                  Icons.close,
                                  color: Color(0xFF8888AA),
                                  size: 18,
                                ),
                              )
                            : null,
                        filled: true,
                        fillColor: const Color(0xFF1A1040),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFF7B61FF),
                            width: 0.6,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFF9D4EDD),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Results
                Expanded(
                  child: Consumer<TodoProvider>(
                    builder: (context, value, _) {
                      final results = value.searchlist;

                      if (!_hasTyped) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.radar,
                                color: const Color(
                                  0xFF7B61FF,
                                ).withValues(alpha: 0.4),
                                size: 56,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Awaiting scan input…',
                                style: TextStyle(
                                  color: Color(0xFF8888AA),
                                  fontSize: 14,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      if (results.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.search_off,
                                color: const Color(
                                  0xFF9D4EDD,
                                ).withValues(alpha: 0.4),
                                size: 52,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'No missions found in this sector',
                                style: TextStyle(
                                  color: Color(0xFF8888AA),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final todo = results[index];
                          return _SearchResultCard(
                            todo: todo,
                            index: index,
                            onTap: () => Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, a, _) => FadeTransition(
                                  opacity: a,
                                  child: Detailscreen(todoid: todo.id),
                                ),
                                transitionDuration: const Duration(
                                  milliseconds: 500,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
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

// ── Search Result Card ────────────────────────────────────────────────────────

class _SearchResultCard extends StatefulWidget {
  final Todomodel todo;
  final int index;
  final VoidCallback onTap;

  const _SearchResultCard({
    required this.todo,
    required this.index,
    required this.onTap,
  });

  @override
  State<_SearchResultCard> createState() => _SearchResultCardState();
}

class _SearchResultCardState extends State<_SearchResultCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _entryAnim;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    // Staggered entry per card index
    _entryAnim = CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _entryAnim,
      builder: (_, _) => GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1040),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFF7B61FF).withValues(alpha: 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFF7B61FF,
                ).withValues(alpha: 0.1 + _entryAnim.value * 0.2),
                blurRadius: 14 + _entryAnim.value * 8,
                spreadRadius: 1,
              ),
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Color(0xFF9D4EDD), Color(0xFF1A1040)],
                    center: Alignment(-0.3, -0.3),
                  ),
                ),
                child: const Icon(
                  Icons.rocket_launch,
                  color: Colors.white70,
                  size: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.todo.enddate,
                style: const TextStyle(
                  color: Color(0xFFFFD700),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.todo.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                widget.todo.content,
                style: const TextStyle(color: Color(0xFF8888AA), fontSize: 11),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Stars Painter ─────────────────────────────────────────────────────────────

class _SearchStarsPainter extends CustomPainter {
  final double t;
  _SearchStarsPainter(this.t);

  static final _rand = Random(55);
  static final _stars = List.generate(
    65,
    (_) => Offset(_rand.nextDouble(), _rand.nextDouble()),
  );
  static final _sizes = List.generate(
    65,
    (_) => _rand.nextDouble() * 1.8 + 0.3,
  );
  static final _speeds = List.generate(
    65,
    (_) => _rand.nextDouble() * 0.08 + 0.02,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (int i = 0; i < _stars.length; i++) {
      final dy = (_stars[i].dy + t * _speeds[i]) % 1.0;
      final opacity = 0.4 + (sin(t * 2 * pi + i) * 0.3).abs();
      paint.color = Colors.white.withValues(alpha: opacity.clamp(0.2, 0.9));
      canvas.drawCircle(
        Offset(_stars[i].dx * size.width, dy * size.height),
        _sizes[i],
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_) => true;
}
