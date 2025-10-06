// ==================== MODELS ====================

// ==================== MODELS ====================

import 'package:flutter/material.dart';

class StoredHabit {
  final String id;
  final String name;
  final String trackingType; // 'task', 'amount', 'time'
  final Color color;
  final String icon;
  final int? targetCount;
  final int? timeValue;
  final String? counterValue;
  final int? timerElapsed;
  final bool isTimerRunning;
  final List<String> selectedDays;
  final String? startDate;
  final String? endDate;
  final String? repeatability;
  final int? repeatInterval;

  StoredHabit({
    required this.id,
    required this.name,
    required this.trackingType,
    required this.color,
    required this.icon,
    this.targetCount,
    this.timeValue,
    this.counterValue,
    this.timerElapsed,
    this.isTimerRunning = false,
    this.selectedDays = const [],
    this.startDate,
    this.endDate,
    this.repeatability,
    this.repeatInterval,
  });
}

// ==================== TASK BUTTON WIDGET ====================

class TaskButton extends StatefulWidget {
  final StoredHabit task;
  final int progress;
  final VoidCallback? onTaskDone;
  final VoidCallback? onIncrement;
  final VoidCallback? onToggleTimer;
  final VoidCallback? onResetTimer;

  const TaskButton({
    Key? key,
    required this.task,
    required this.progress,
    this.onTaskDone,
    this.onIncrement,
    this.onToggleTimer,
    this.onResetTimer,
  }) : super(key: key);

  @override
  State<TaskButton> createState() => _TaskButtonState();
}

class _TaskButtonState extends State<TaskButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _scaleController.reverse();
  }

  void _onTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    // Task-based (boolean checkbox)
    if (widget.task.trackingType == 'task') {
      return GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.onTaskDone,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: widget.task.color,
              shape: BoxShape.circle,
              border: Border.all(color: widget.task.color, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      );
    }

    // Amount-based (counter with progress)
    if (widget.task.trackingType == 'amount') {
      final progressPercent =
          ((widget.progress / (widget.task.targetCount ?? 1)) * 100).clamp(
            0.0,
            100.0,
          );

      return GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.onIncrement,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(56, 56),
                  painter: _ProgressRingPainter(
                    progress: progressPercent,
                    color: widget.task.color,
                    backgroundColor: const Color(0xFFE5E7EB),
                  ),
                ),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: widget.task.color.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.task.counterValue ?? '0',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: widget.task.color,
                          height: 1.2,
                        ),
                      ),
                      Icon(
                        Icons.add,
                        size: 12,
                        color: widget.task.color,
                        weight: 700,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Time-based (timer with progress)
    if (widget.task.trackingType == 'time') {
      final progressPercent =
          ((widget.progress / (widget.task.timeValue ?? 1)) * 100).clamp(
            0.0,
            100.0,
          );

      return SizedBox(
        width: 56,
        height: 56,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Transform.rotate(
              angle: -1.5708,
              child: CustomPaint(
                size: const Size(56, 56),
                painter: _ProgressRingPainter(
                  progress: progressPercent,
                  color: widget.task.color,
                  backgroundColor: const Color(0xFFF3F4F6),
                ),
              ),
            ),
            GestureDetector(
              onTapDown: _onTapDown,
              onTapUp: _onTapUp,
              onTapCancel: _onTapCancel,
              onTap: widget.onToggleTimer,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: widget.task.color.withOpacity(
                      widget.task.isTimerRunning ? 0.15 : 0.08,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.task.isTimerRunning ? Icons.pause : Icons.play_arrow,
                    size: 14,
                    color: widget.task.color,
                  ),
                ),
              ),
            ),
            if ((widget.task.timerElapsed ?? 0) > 0 &&
                !widget.task.isTimerRunning)
              Positioned(
                top: -4,
                right: -4,
                child: GestureDetector(
                  onTap: widget.onResetTimer,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.refresh,
                      size: 12,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  _ProgressRingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = 22.0;
    final strokeWidth = 3.0;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, bgPaint);

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = (progress / 100) * 2 * 3.14159;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}

// ==================== UNDO BUTTON WIDGET ====================

class UndoButton extends StatelessWidget {
  final VoidCallback? onUndo;

  const UndoButton({Key? key, this.onUndo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onUndo,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.green[500],
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(Icons.check, color: Colors.white, size: 24),
      ),
    );
  }
}

// ==================== TASK CARD WIDGET ====================

class TaskCard extends StatefulWidget {
  final StoredHabit task;
  final bool isCompleted;
  final int progress;
  final VoidCallback? onTaskDone;
  final VoidCallback? onIncrement;
  final VoidCallback? onToggleTimer;
  final VoidCallback? onResetTimer;
  final VoidCallback? onUndo;

  const TaskCard({
    Key? key,
    required this.task,
    required this.isCompleted,
    required this.progress,
    this.onTaskDone,
    this.onIncrement,
    this.onToggleTimer,
    this.onResetTimer,
    this.onUndo,
  }) : super(key: key);

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _blinkController;
  late Animation<double> _blinkAnimation;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _blinkAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.7), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.7, end: 1.0), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.9), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 25),
    ]).animate(_blinkController);

    if (_shouldBlink()) {
      _blinkController.repeat();
    }
  }

  @override
  void didUpdateWidget(TaskCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_shouldBlink() && !_blinkController.isAnimating) {
      _blinkController.repeat();
    } else if (!_shouldBlink() && _blinkController.isAnimating) {
      _blinkController.stop();
      _blinkController.reset();
    }
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  bool _shouldBlink() {
    if (widget.task.trackingType != 'time' || widget.isCompleted) return false;
    final remaining = (widget.task.timeValue ?? 0) - widget.progress;
    return remaining <= 5 && remaining > 0;
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  Widget? _getProgressInfo() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shouldBlink = _shouldBlink();

    if (widget.task.trackingType == 'amount') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: shouldBlink
              ? (isDark ? Colors.red[900] : Colors.red[100])
              : (isDark ? Colors.grey[700] : Colors.grey[100]),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.progress.toString(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: shouldBlink
                    ? (isDark ? Colors.red[300] : Colors.red[600])
                    : (isDark ? Colors.grey[300] : Colors.grey[600]),
              ),
            ),
            Text(
              ' / ',
              style: TextStyle(
                fontSize: 13,
                color: shouldBlink
                    ? (isDark ? Colors.red[500] : Colors.red[400])
                    : (isDark ? Colors.grey[500] : Colors.grey[400]),
              ),
            ),
            Text(
              (widget.task.targetCount ?? 0).toString(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: shouldBlink
                    ? (isDark ? Colors.red[300] : Colors.red[600])
                    : (isDark ? Colors.grey[300] : Colors.grey[600]),
              ),
            ),
          ],
        ),
      );
    }

    if (widget.task.trackingType == 'time') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: shouldBlink
              ? (isDark ? Colors.red[900] : Colors.red[100])
              : (isDark ? Colors.grey[700] : Colors.grey[100]),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _formatTime(widget.progress),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: shouldBlink
                    ? (isDark ? Colors.red[300] : Colors.red[600])
                    : (isDark ? Colors.grey[300] : Colors.grey[600]),
              ),
            ),
            Text(
              ' — ',
              style: TextStyle(
                fontSize: 13,
                color: shouldBlink
                    ? (isDark ? Colors.red[500] : Colors.red[400])
                    : (isDark ? Colors.grey[500] : Colors.grey[400]),
              ),
            ),
            Text(
              _formatTime(widget.task.timeValue ?? 0),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: shouldBlink
                    ? (isDark ? Colors.red[300] : Colors.red[600])
                    : (isDark ? Colors.grey[300] : Colors.grey[600]),
              ),
            ),
          ],
        ),
      );
    }

    return null;
  }

  double _getProgressPercentage() {
    if (widget.task.trackingType == 'amount') {
      return ((widget.progress / (widget.task.targetCount ?? 1)) * 100).clamp(
        0.0,
        100.0,
      );
    }
    if (widget.task.trackingType == 'time') {
      return ((widget.progress / (widget.task.timeValue ?? 1)) * 100).clamp(
        0.0,
        100.0,
      );
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shouldBlink = _shouldBlink();

    return AnimatedBuilder(
      animation: _blinkAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: shouldBlink ? _blinkAnimation.value : 1.0,
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.grey[700]! : Colors.grey[100]!,
              ),
              boxShadow: shouldBlink
                  ? [
                      BoxShadow(
                        color: widget.task.color.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
            ),
            child: Stack(
              children: [
                // Subtle top highlight
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          isDark
                              ? Colors.grey[600]!.withOpacity(0.3)
                              : Colors.white.withOpacity(0.6),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Main content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Icon
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: widget.task.color,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: widget.task.color.withOpacity(0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          _getIconData(widget.task.icon),
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              widget.task.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: shouldBlink
                                    ? (isDark
                                          ? Colors.red[400]
                                          : Colors.red[600])
                                    : (isDark
                                          ? Colors.white
                                          : Colors.grey[900]),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),

                            // Days
                            if (widget.task.selectedDays.isNotEmpty)
                              Wrap(
                                spacing: 4,
                                children: widget.task.selectedDays.map((day) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.grey[700]
                                          : Colors.grey[100],
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      day.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? Colors.grey[400]
                                            : Colors.grey[500],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),

                            // Progress bar
                            if (widget.task.trackingType == 'amount' ||
                                widget.task.trackingType == 'time') ...[
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: Container(
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.grey[700]
                                        : Colors.grey[100],
                                  ),
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: _getProgressPercentage() / 100,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: shouldBlink
                                            ? Colors.red[400]
                                            : widget.task.color,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Right side buttons
                      const SizedBox(width: 12),
                      Row(
                        children: [
                          if (!widget.isCompleted && _getProgressInfo() != null)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: _getProgressInfo(),
                            ),
                          if (!widget.isCompleted)
                            TaskButton(
                              task: widget.task,
                              progress: widget.progress,
                              onTaskDone: widget.onTaskDone,
                              onIncrement: widget.onIncrement,
                              onToggleTimer: widget.onToggleTimer,
                              onResetTimer: widget.onResetTimer,
                            ),
                          if (widget.isCompleted)
                            UndoButton(onUndo: widget.onUndo),
                        ],
                      ),
                    ],
                  ),
                ),

                // Bottom separator
                Positioned(
                  bottom: 0,
                  left: 16,
                  right: 16,
                  child: Container(
                    height: 1,
                    color: isDark ? Colors.grey[700] : Colors.grey[100],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getIconData(String iconName) {
    final iconMap = {
      'Smile': Icons.sentiment_satisfied,
      'Heart': Icons.favorite,
      'Star': Icons.star,
      'Target': Icons.track_changes,
      'Book': Icons.menu_book,
      'Dumbbell': Icons.fitness_center,
      'Coffee': Icons.local_cafe,
      'Moon': Icons.nightlight_round,
      'Sun': Icons.wb_sunny,
      'Water': Icons.water_drop,
    };
    return iconMap[iconName] ?? Icons.circle;
  }
}

// ==================== DEMO APP ====================

class HabitTrackerDemo extends StatefulWidget {
  const HabitTrackerDemo({Key? key}) : super(key: key);

  @override
  State<HabitTrackerDemo> createState() => _HabitTrackerDemoState();
}

class _HabitTrackerDemoState extends State<HabitTrackerDemo> {
  final List<StoredHabit> habits = [
    StoredHabit(
      id: '1',
      name: 'Morning Meditation',
      trackingType: 'time',
      color: const Color(0xFF8B5CF6),
      icon: 'Moon',
      timeValue: 10,
      timerElapsed: 0,
      isTimerRunning: false,
      selectedDays: ['MON', 'WED', 'FRI'],
    ),
    StoredHabit(
      id: '2',
      name: 'Drink Water',
      trackingType: 'amount',
      color: const Color(0xFF3B82F6),
      icon: 'Water',
      targetCount: 8,
      counterValue: '0',
      selectedDays: ['MON', 'TUE', 'WED', 'THU', 'FRI'],
    ),
    StoredHabit(
      id: '3',
      name: 'Read Books',
      trackingType: 'task',
      color: const Color(0xFF10B981),
      icon: 'Book',
      selectedDays: ['SAT', 'SUN'],
    ),
  ];

  Map<String, int> progress = {'1': 0, '2': 0, '3': 0};

  Map<String, bool> completed = {'1': false, '2': false, '3': false};

  Timer? _timer;

  void _incrementHabit(String id) {
    setState(() {
      final habit = habits.firstWhere((h) => h.id == id);
      progress[id] = (progress[id] ?? 0) + 1;

      // Check if completed
      if (progress[id]! >= (habit.targetCount ?? 0)) {
        completed[id] = true;
      }

      final index = habits.indexWhere((h) => h.id == id);
      habits[index] = StoredHabit(
        id: habit.id,
        name: habit.name,
        trackingType: habit.trackingType,
        color: habit.color,
        icon: habit.icon,
        targetCount: habit.targetCount,
        counterValue: progress[id].toString(),
        selectedDays: habit.selectedDays,
      );
    });
  }

  void _toggleTimer(String id) {
    setState(() {
      final habit = habits.firstWhere((h) => h.id == id);
      final isRunning = !(habit.isTimerRunning);

      final index = habits.indexWhere((h) => h.id == id);
      habits[index] = StoredHabit(
        id: habit.id,
        name: habit.name,
        trackingType: habit.trackingType,
        color: habit.color,
        icon: habit.icon,
        timeValue: habit.timeValue,
        timerElapsed: habit.timerElapsed,
        isTimerRunning: isRunning,
        selectedDays: habit.selectedDays,
      );

      if (isRunning) {
        _startTimer(id);
      } else {
        _timer?.cancel();
      }
    });
  }

  void _startTimer(String id) {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        final habit = habits.firstWhere((h) => h.id == id);
        if (habit.isTimerRunning) {
          setState(() {
            progress[id] = (progress[id] ?? 0) + 1;

            // Check if completed
            if (progress[id]! >= (habit.timeValue ?? 0)) {
              completed[id] = true;
              _toggleTimer(id); // Stop timer
            }

            final index = habits.indexWhere((h) => h.id == id);
            habits[index] = StoredHabit(
              id: habit.id,
              name: habit.name,
              trackingType: habit.trackingType,
              color: habit.color,
              icon: habit.icon,
              timeValue: habit.timeValue,
              timerElapsed: progress[id],
              isTimerRunning: habit.isTimerRunning,
              selectedDays: habit.selectedDays,
            );
          });
        } else {
          timer.cancel();
        }
      }
    });
  }

  void _resetTimer(String id) {
    setState(() {
      progress[id] = 0;
      final habit = habits.firstWhere((h) => h.id == id);
      final index = habits.indexWhere((h) => h.id == id);
      habits[index] = StoredHabit(
        id: habit.id,
        name: habit.name,
        trackingType: habit.trackingType,
        color: habit.color,
        icon: habit.icon,
        timeValue: habit.timeValue,
        timerElapsed: 0,
        isTimerRunning: false,
        selectedDays: habit.selectedDays,
      );
    });
  }

  void _taskDone(String id) {
    setState(() {
      completed[id] = true;
    });
  }

  void _undoTask(String id) {
    setState(() {
      completed[id] = false;
      progress[id] = 0;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Today\'s Habits',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: false,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: habits.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final habit = habits[index];
          return TaskCard(
            task: habit,
            progress: progress[habit.id] ?? 0,
            isCompleted: completed[habit.id] ?? false,
            onTaskDone: () => _taskDone(habit.id),
            onIncrement: () => _incrementHabit(habit.id),
            onToggleTimer: () => _toggleTimer(habit.id),
            onResetTimer: () => _resetTimer(habit.id),
            onUndo: () => _undoTask(habit.id),
          );
        },
      ),
    );
  }
}
