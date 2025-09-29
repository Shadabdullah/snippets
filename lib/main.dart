import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lesson Path',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF7F7F7),
      ),
      home: const LessonPathScreen(),
    );
  }
}

class Lesson {
  final int number;
  final String title;
  final LessonType type;
  final LessonStatus status;
  final int stars;

  Lesson({
    required this.number,
    required this.title,
    required this.type,
    required this.status,
    this.stars = 0,
  });
}

enum LessonType { lesson, story, practice, review, treasure, unit }

enum LessonStatus { locked, unlocked, inProgress, completed }

class LessonPathScreen extends StatefulWidget {
  const LessonPathScreen({Key? key}) : super(key: key);

  @override
  State<LessonPathScreen> createState() => _LessonPathScreenState();
}

class _LessonPathScreenState extends State<LessonPathScreen>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late List<Lesson> lessons;
  final Map<int, GlobalKey> _lessonKeys = {};
  late AnimationController _floatingController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    // Generate lessons from bottom to top
    lessons = _generateLessons();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentLesson();
    });
  }

  List<Lesson> _generateLessons() {
    final List<LessonType> typePattern = [
      LessonType.lesson,
      LessonType.lesson,
      LessonType.practice,
      LessonType.lesson,
      LessonType.story,
      LessonType.lesson,
      LessonType.review,
      LessonType.lesson,
      LessonType.treasure,
      LessonType.unit,
    ];

    return List.generate(50, (index) {
      final lessonNumber = 50 - index;
      _lessonKeys[index] = GlobalKey();

      LessonStatus status;
      int stars = 0;

      if (lessonNumber <= 8) {
        status = LessonStatus.completed;
        stars = 3;
      } else if (lessonNumber == 9) {
        status = LessonStatus.inProgress;
        stars = 2;
      } else if (lessonNumber == 10) {
        status = LessonStatus.unlocked;
      } else {
        status = LessonStatus.locked;
      }

      return Lesson(
        number: lessonNumber,
        title: 'Lesson $lessonNumber',
        type: typePattern[lessonNumber % typePattern.length],
        status: status,
        stars: stars,
      );
    });
  }

  void _scrollToCurrentLesson() {
    int currentIndex = lessons.indexWhere(
      (lesson) =>
          lesson.status == LessonStatus.inProgress ||
          lesson.status == LessonStatus.unlocked,
    );

    if (currentIndex != -1 &&
        _lessonKeys[currentIndex]?.currentContext != null) {
      final context = _lessonKeys[currentIndex]!.currentContext!;
      Future.delayed(const Duration(milliseconds: 300), () {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeInOutCubic,
          alignment: 0.3,
        );
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F5E9), Color(0xFFF7F7F7), Color(0xFFFFF9E6)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50, bottom: 100),
                    child: Column(
                      children: lessons.asMap().entries.map((entry) {
                        return _buildLessonNode(entry.key, entry.value);
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    int completed = lessons
        .where((l) => l.status == LessonStatus.completed)
        .length;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF58CC02), Color(0xFF78D118)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF58CC02).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'SECTION 1, UNIT 1',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.menu_book,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Use basic phrases',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: completed / lessons.length,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonNode(int index, Lesson lesson) {
    final screenWidth = MediaQuery.of(context).size.width;
    final rowIndex = (index / 4).floor();
    final positionInRow = index % 4;

    final isLeftToRight = rowIndex % 2 == 0;
    final position = isLeftToRight ? positionInRow : 3 - positionInRow;

    final centerOffset = (position - 1.5) * (screenWidth * 0.2);

    return Container(
      key: _lessonKeys[index],
      margin: EdgeInsets.only(
        left: screenWidth / 2 + centerOffset - 60,
        top: positionInRow == 0 ? 40 : 12,
        bottom: 12,
      ),
      child: LessonNode(
        lesson: lesson,
        floatingAnimation: _floatingController,
        onTap: () => _handleLessonTap(lesson),
      ),
    );
  }

  void _handleLessonTap(Lesson lesson) {
    if (lesson.status != LessonStatus.locked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Starting ${lesson.title}!'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF58CC02),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }
}

class PathPainter extends CustomPainter {
  final List<Lesson> lessons;

  PathPainter({required this.lessons});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < lessons.length - 1; i++) {
      final rowIndex = (i / 4).floor();
      final nextRowIndex = ((i + 1) / 4).floor();
      final positionInRow = i % 4;
      final nextPositionInRow = (i + 1) % 4;

      final isLeftToRight = rowIndex % 2 == 0;
      final position = isLeftToRight ? positionInRow : 3 - positionInRow;

      final isNextLeftToRight = nextRowIndex % 2 == 0;
      final nextPosition = isNextLeftToRight
          ? nextPositionInRow
          : 3 - nextPositionInRow;

      final centerOffset = (position - 1.5) * (size.width * 0.2);
      final nextCenterOffset = (nextPosition - 1.5) * (size.width * 0.2);

      final startX = size.width / 2 + centerOffset;
      final startY =
          i * 92.0 + (positionInRow == 0 ? 40 : 12) * (rowIndex + 1) + 40;

      final endX = size.width / 2 + nextCenterOffset;
      final endY =
          (i + 1) * 92.0 +
          (nextPositionInRow == 0 ? 40 : 12) * (nextRowIndex + 1) +
          40;

      Color lineColor;
      if (lessons[i].status == LessonStatus.completed) {
        lineColor = const Color(0xFF58CC02);
      } else if (lessons[i].status == LessonStatus.inProgress) {
        lineColor = const Color(0xFFCCCCCC);
      } else {
        lineColor = const Color(0xFFE5E5E5);
      }

      paint.color = lineColor;

      final path = Path();
      path.moveTo(startX, startY);

      final controlX = (startX + endX) / 2;
      final controlY = (startY + endY) / 2;
      path.quadraticBezierTo(controlX, controlY, endX, endY);

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LessonNode extends StatefulWidget {
  final Lesson lesson;
  final AnimationController floatingAnimation;
  final VoidCallback onTap;

  const LessonNode({
    Key? key,
    required this.lesson,
    required this.floatingAnimation,
    required this.onTap,
  }) : super(key: key);

  @override
  State<LessonNode> createState() => _LessonNodeState();
}

class _LessonNodeState extends State<LessonNode>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    _floatAnimation =
        Tween<Offset>(
          begin: const Offset(0, -5),
          end: const Offset(0, 5),
        ).animate(
          CurvedAnimation(
            parent: widget.floatingAnimation,
            curve: Curves.easeInOut,
          ),
        );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  Color _getMainColor() {
    if (widget.lesson.status == LessonStatus.locked) {
      return const Color(0xFFE5E5E5);
    }

    switch (widget.lesson.type) {
      case LessonType.story:
        return const Color(0xFFFF9600);
      case LessonType.practice:
        return const Color(0xFF1CB0F6);
      case LessonType.review:
        return const Color(0xFFCE82FF);
      case LessonType.treasure:
        return const Color(0xFFFFD700);
      case LessonType.unit:
        return const Color(0xFFFF4B4B);
      default:
        return widget.lesson.status == LessonStatus.completed
            ? const Color(0xFF58CC02)
            : const Color(0xFF1CB0F6);
    }
  }

  Widget _getLessonIcon() {
    if (widget.lesson.status == LessonStatus.locked) {
      return const Icon(Icons.lock, color: Color(0xFFAFAFAF), size: 30);
    }

    if (widget.lesson.status == LessonStatus.completed) {
      return const Icon(Icons.star, color: Colors.white, size: 35);
    }

    switch (widget.lesson.type) {
      case LessonType.story:
        return const Icon(Icons.menu_book, color: Colors.white, size: 30);
      case LessonType.practice:
        return const Icon(Icons.fitness_center, color: Colors.white, size: 28);
      case LessonType.review:
        return const Icon(Icons.quiz, color: Colors.white, size: 30);
      case LessonType.treasure:
        return const Icon(Icons.card_giftcard, color: Colors.white, size: 30);
      case LessonType.unit:
        return const Icon(Icons.emoji_events, color: Colors.white, size: 32);
      default:
        return const Icon(Icons.school, color: Colors.white, size: 30);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isActive =
        widget.lesson.status == LessonStatus.unlocked ||
        widget.lesson.status == LessonStatus.inProgress;

    return GestureDetector(
      onTapDown: (_) {
        if (widget.lesson.status != LessonStatus.locked) {
          _bounceController.forward();
        }
      },
      onTapUp: (_) {
        if (widget.lesson.status != LessonStatus.locked) {
          _bounceController.reverse();
          widget.onTap();
        }
      },
      onTapCancel: () => _bounceController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedBuilder(
          animation: widget.floatingAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: isActive ? _floatAnimation.value : Offset.zero,
              child: child,
            );
          },
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // Shadow
                  if (widget.lesson.status != LessonStatus.locked)
                    Positioned(
                      bottom: -8,
                      child: Container(
                        width: 70,
                        height: 15,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Main Circle
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: widget.lesson.status != LessonStatus.locked
                          ? LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                _getMainColor(),
                                _getMainColor().withOpacity(0.8),
                              ],
                            )
                          : null,
                      color: widget.lesson.status == LessonStatus.locked
                          ? const Color(0xFFE5E5E5)
                          : null,
                      border: Border.all(
                        color: widget.lesson.status != LessonStatus.locked
                            ? Colors.white
                            : const Color(0xFFD0D0D0),
                        width: 5,
                      ),
                      boxShadow: widget.lesson.status != LessonStatus.locked
                          ? [
                              BoxShadow(
                                color: _getMainColor().withOpacity(0.4),
                                blurRadius: 20,
                                spreadRadius: 2,
                                offset: const Offset(0, 5),
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                    ),
                    child: _getLessonIcon(),
                  ),
                  // Stars for completed
                  if (widget.lesson.status == LessonStatus.completed &&
                      widget.lesson.stars > 0)
                    Positioned(
                      bottom: -5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            widget.lesson.stars,
                            (index) => const Icon(
                              Icons.star,
                              color: Color(0xFFFFD700),
                              size: 14,
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
    );
  }
}
