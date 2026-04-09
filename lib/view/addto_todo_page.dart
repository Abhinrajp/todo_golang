import 'dart:developer';
import 'dart:math' hide log;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo_golang/model/todo_model.dart';
import 'package:todo_golang/provider/todo_provider.dart';
import 'package:todo_golang/widget/custom_widget.dart';

class Addtodoscreen extends StatefulWidget {
  final Todomodel? todo;
  const Addtodoscreen({super.key, required this.todo});
  @override
  State<Addtodoscreen> createState() => _AddtodoscreenState();
}

class _AddtodoscreenState extends State<Addtodoscreen>
    with TickerProviderStateMixin {
  final titleController = TextEditingController();
  final dateController = TextEditingController();
  final contentController = TextEditingController();

  late AnimationController _starController;
  late AnimationController _shakeController;
  late AnimationController _launchController;
  late Animation<double> _shakeAnim;
  late Animation<double> _launchAnim;

  bool _launching = false;
  bool _dateVisible = false;

  @override
  void initState() {
    super.initState();

    _starController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    _launchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _launchAnim = Tween<double>(
      begin: 0,
      end: -120,
    ).animate(CurvedAnimation(parent: _launchController, curve: Curves.easeIn));

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (widget.todo != null) {
        titleController.text = widget.todo!.title;
        dateController.text = widget.todo!.enddate;
        contentController.text = widget.todo!.content;
        setState(() => _dateVisible = true);
      }
    });
  }

  @override
  void dispose() {
    _starController.dispose();
    _shakeController.dispose();
    _launchController.dispose();
    titleController.dispose();
    dateController.dispose();
    contentController.dispose();
    super.dispose();
  }

  void _shake() {
    _shakeController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0221),
      body: Stack(
        children: [
          // Drifting starfield
          AnimatedBuilder(
            animation: _starController,
            builder: (_, _) => CustomPaint(
              painter: _DriftingStarsPainter(_starController.value),
              child: const SizedBox.expand(),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
                      const SizedBox(width: 16),
                      Text(
                        widget.todo != null
                            ? 'UPDATE MISSION'
                            : 'LAUNCH MISSION',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: AnimatedBuilder(
                      animation: _shakeAnim,
                      builder: (_, child) => Transform.translate(
                        offset: Offset(
                          sin(_shakeAnim.value * pi * 6) *
                              8 *
                              (1 - _shakeAnim.value),
                          0,
                        ),
                        child: child,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          _CosmicField(
                            controller: titleController,
                            label: 'Mission Title',
                            icon: Icons.rocket_launch,
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                firstDate: DateTime(1900),
                                lastDate: DateTime(2100),
                                builder: (ctx, child) => Theme(
                                  data: ThemeData.dark().copyWith(
                                    colorScheme: const ColorScheme.dark(
                                      primary: Color(0xFF7B61FF),
                                      surface: Color(0xFF1A1040),
                                    ),
                                  ),
                                  child: child!,
                                ),
                              );
                              if (picked != null) {
                                dateController.text = DateFormat(
                                  'yy/MM/dd',
                                ).format(picked);
                                setState(() => _dateVisible = true);
                              }
                            },
                            child: AbsorbPointer(
                              child: AnimatedOpacity(
                                opacity: 1.0,
                                duration: const Duration(milliseconds: 400),
                                child: _CosmicField(
                                  controller: dateController,
                                  label: 'Target Date',
                                  icon: Icons.calendar_today,
                                  readOnly: true,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _CosmicField(
                            controller: contentController,
                            label: 'Mission Briefing',
                            icon: Icons.article_outlined,
                            maxLines: 5,
                          ),
                          const SizedBox(height: 36),

                          // Launch button
                          AnimatedBuilder(
                            animation: _launchAnim,
                            builder: (_, _) => Transform.translate(
                              offset: Offset(
                                0,
                                _launching ? _launchAnim.value : 0,
                              ),
                              child: GestureDetector(
                                onTap: _launching ? null : () => _add(context),
                                child: Container(
                                  width: double.infinity,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF7B61FF),
                                        Color(0xFF9D4EDD),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF7B61FF,
                                        ).withValues(alpha: 0.45),
                                        blurRadius: 20,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (_launching)
                                        const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      else
                                        const Icon(
                                          Icons.rocket,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                      const SizedBox(width: 10),
                                      Text(
                                        _launching
                                            ? 'Launching…'
                                            : widget.todo != null
                                            ? 'Update Mission'
                                            : 'Launch Mission',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
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

  void _add(BuildContext context) async {
    if (titleController.text.isEmpty ||
        dateController.text.isEmpty ||
        contentController.text.isEmpty) {
      _shake();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fill all mission details'),
          backgroundColor: Color(0xFF9D4EDD),
        ),
      );
      return;
    }

    setState(() => _launching = true);
    _launchController.forward();

    if (widget.todo != null) {
      final response = await context.read<TodoProvider>().editTodo(
        id: widget.todo!.id.toString(),
        title: titleController.text,
        content: contentController.text,
        endDate: dateController.text,
      );
      log(response);
      if (response == 'todo updated successfully') {
        titleController.clear();
        contentController.clear();
        dateController.clear();
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(customSnakBar(title: 'Mission updated'));
        }
      } else {
        setState(() => _launching = false);
        _launchController.reset();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Color(0xFFA32D2D),
              content: Text(
                'Unable to update mission',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
      }
    } else {
      final response = await context.read<TodoProvider>().addTodo(
        title: titleController.text,
        content: contentController.text,
        endDate: dateController.text,
      );
      log(response);
      if (response == 'todo added successfully') {
        titleController.clear();
        contentController.clear();
        dateController.clear();
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(customSnakBar(title: 'Mission launched!'));
        }
      } else {
        setState(() => _launching = false);
        _launchController.reset();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Color(0xFFA32D2D),
              content: Text('Launch failed', textAlign: TextAlign.center),
            ),
          );
        }
      }
    }
  }
}

// ── Cosmic Field ──────────────────────────────────────────────────────────────

class _CosmicField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;
  final bool readOnly;

  const _CosmicField({
    required this.controller,
    required this.label,
    required this.icon,
    this.maxLines = 1,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7B61FF).withValues(alpha: 0.15),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        maxLines: maxLines,
        textCapitalization: TextCapitalization.sentences,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF8888AA), fontSize: 14),
          prefixIcon: Icon(icon, color: const Color(0xFF7B61FF), size: 20),
          filled: true,
          fillColor: const Color(0xFF1A1040),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF7B61FF), width: 0.6),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF9D4EDD), width: 1.5),
          ),
        ),
      ),
    );
  }
}

// ── Drifting Stars Painter ────────────────────────────────────────────────────

class _DriftingStarsPainter extends CustomPainter {
  final double t;
  _DriftingStarsPainter(this.t);

  static final _rand = Random(99);
  static final _stars = List.generate(
    55,
    (_) => Offset(_rand.nextDouble(), _rand.nextDouble()),
  );
  static final _speeds = List.generate(
    55,
    (_) => _rand.nextDouble() * 0.12 + 0.04,
  );
  static final _sizes = List.generate(
    55,
    (_) => _rand.nextDouble() * 1.8 + 0.3,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.7);
    for (int i = 0; i < _stars.length; i++) {
      final dy = (_stars[i].dy + t * _speeds[i]) % 1.0;
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
