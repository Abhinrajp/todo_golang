import 'dart:developer';
import 'dart:math' hide log;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_golang/provider/todo_provider.dart';
import 'package:todo_golang/view/addto_todo_page.dart';
import 'package:todo_golang/view/detail_page.dart';
import 'package:todo_golang/view/search_todo_page.dart';
import 'package:todo_golang/widget/custom_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _starController;
  late AnimationController _fabController;
  late AnimationController _searchController;

  @override
  void initState() {
    super.initState();
    _starController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _searchController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<TodoProvider>().fetchTodo();
    });
  }

  @override
  void dispose() {
    _starController.dispose();
    _fabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0221),
      body: Stack(
        children: [
          // Starfield background
          AnimatedBuilder(
            animation: _starController,
            builder: (_, _) => CustomPaint(
              painter: StarfieldPainter(_starController.value),
              child: const SizedBox.expand(),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Custom AppBar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '''YOUR TODO's''',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 4,
                            ),
                          ),
                          Text(
                            'your task log',
                            style: TextStyle(
                              color: Color(0xFF9D4EDD),
                              fontSize: 12,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, a, _) => FadeTransition(
                              opacity: a,
                              child: const Searchscreen(),
                            ),
                            transitionDuration: const Duration(
                              milliseconds: 500,
                            ),
                          ),
                        ),
                        child: RotationTransition(
                          turns: _searchController,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF7B61FF),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF7B61FF,
                                  ).withValues(alpha: 0.4),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.star,
                              color: Color(0xFF7B61FF),
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Body
                Expanded(
                  child: Consumer<TodoProvider>(
                    builder: (context, value, _) {
                      if (value.loading) {
                        return Center(
                          child: ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFF7B61FF), Color(0xFF9D4EDD)],
                            ).createShader(bounds),
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          ),
                        );
                      }

                      if (value.todos.isEmpty) {
                        return const Center(
                          child: Text(
                            'No missions launched yet',
                            style: TextStyle(
                              color: Color(0xFF8888AA),
                              fontSize: 16,
                            ),
                          ),
                        );
                      }

                      return RefreshIndicator(
                        color: const Color(0xFF7B61FF),
                        backgroundColor: const Color(0xFF1A1040),
                        onRefresh: () =>
                            context.read<TodoProvider>().fetchTodo(),
                        child: GridView.builder(
                          padding: const EdgeInsets.all(12),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                          itemCount: value.todos.length,
                          itemBuilder: (context, index) {
                            final todo = value.todos[index];
                            return _PlanetCard(
                              todo: todo,
                              onTap: () => Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (_, a, _) => FadeTransition(
                                    opacity: a,
                                    child: Detailscreen(todoid: todo.id),
                                  ),
                                  transitionDuration: const Duration(
                                    milliseconds: 600,
                                  ),
                                ),
                              ),
                              onEdit: () => Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (_, a, _) => FadeTransition(
                                    opacity: a,
                                    child: Addtodoscreen(todo: todo),
                                  ),
                                  transitionDuration: const Duration(
                                    milliseconds: 600,
                                  ),
                                ),
                              ),
                              onDelete: () =>
                                  _showDeleteDialog(context, value, todo),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Pulsing FAB
          Positioned(
            bottom: 30,
            right: 24,
            child: AnimatedBuilder(
              animation: _fabController,
              builder: (_, child) => Transform.scale(
                scale: 1.0 + (_fabController.value * 0.08),
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, a, _) => FadeTransition(
                        opacity: a,
                        child: Addtodoscreen(todo: null),
                      ),
                      transitionDuration: const Duration(milliseconds: 600),
                    ),
                  ),
                  child: Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7B61FF), Color(0xFF9D4EDD)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF7B61FF,
                          ).withValues(alpha: 0.3 + _fabController.value * 0.4),
                          blurRadius: 20 + _fabController.value * 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 28),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, TodoProvider value, todo) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 350),
      transitionBuilder: (_, a, _, child) => ScaleTransition(
        scale: CurvedAnimation(parent: a, curve: Curves.elasticOut),
        child: child,
      ),
      pageBuilder: (dialogContext, _, _) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1040),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF9D4EDD), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9D4EDD).withValues(alpha: 0.4),
                  blurRadius: 30,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFFFD700),
                  size: 48,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Delete Todo?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This todo will be lost in the void.',
                  style: TextStyle(color: Color(0xFF8888AA), fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          Navigator.of(dialogContext).pop();
                          final response = await value.deleteTodo(todo: todo);
                          log(response);
                          if (response == 'todo deleted successfully') {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                customSnakBar(title: 'Mission Deleted'),
                              );
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF9D4EDD),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Delete',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(dialogContext).pop(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFF7B61FF)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Continue',
                            style: TextStyle(
                              color: Color(0xFF7B61FF),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Planet Card ──────────────────────────────────────────────────────────────

class _PlanetCard extends StatefulWidget {
  final dynamic todo;
  final VoidCallback onTap, onEdit, onDelete;
  const _PlanetCard({
    required this.todo,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });
  @override
  State<_PlanetCard> createState() => _PlanetCardState();
}

class _PlanetCardState extends State<_PlanetCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (_, _) => GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onDelete,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1040),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFF7B61FF).withValues(alpha: 0.6),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFF7B61FF,
                ).withValues(alpha: 0.15 + _glowController.value * 0.2),
                blurRadius: 16 + _glowController.value * 8,
                spreadRadius: 1,
              ),
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Color(0xFF9D4EDD), Color(0xFF1A1040)],
                  ),
                ),
                child: const Icon(
                  Icons.rocket_launch,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.todo.enddate,
                style: const TextStyle(
                  color: Color(0xFFFFD700),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.todo.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
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
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: widget.onEdit,
                    child: const Icon(
                      Icons.edit,
                      color: Color(0xFF7B61FF),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: widget.onDelete,
                    child: const Icon(
                      Icons.delete_outline,
                      color: Color(0xFF9D4EDD),
                      size: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Starfield Painter ─────────────────────────────────────────────────────────

class StarfieldPainter extends CustomPainter {
  final double t;
  StarfieldPainter(this.t);

  static final _rand = Random(42);
  static final _stars = List.generate(
    90,
    (_) => Offset(_rand.nextDouble(), _rand.nextDouble()),
  );
  static final _sizes = List.generate(
    90,
    (_) => _rand.nextDouble() * 2.2 + 0.4,
  );
  static final _speeds = List.generate(
    90,
    (_) => _rand.nextDouble() * 0.3 + 0.1,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (int i = 0; i < _stars.length; i++) {
      final opacity = (sin((t + _speeds[i]) * 2 * pi) * 0.5 + 0.5).clamp(
        0.2,
        1.0,
      );
      paint.color = Colors.white.withValues(alpha: opacity * 0.9);
      canvas.drawCircle(
        Offset(_stars[i].dx * size.width, _stars[i].dy * size.height),
        _sizes[i],
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_) => true;
}
