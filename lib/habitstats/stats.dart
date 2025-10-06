import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StoredHabit {
  final String id;
  final String name;
  final String icon;
  final Color color;
  final String startDate;
  final List<int> scheduledDays; // 0-6 for Sunday-Saturday

  StoredHabit({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.startDate,
    required this.scheduledDays,
  });
}

class AnalyticsData {
  final Map<String, Map<String, ProcessedHabitData>> data;

  AnalyticsData(this.data);

  Map<String, ProcessedHabitData>? operator [](String habitId) => data[habitId];
}

class ProcessedHabitData {
  final StoredHabit habit;
  final dynamic dataPeriod;
  final int completedDays;
  final int totalDays;
  final int percentage;
  final int currentStreak;
  final int longestStreak;

  ProcessedHabitData({
    required this.habit,
    required this.dataPeriod,
    required this.completedDays,
    required this.totalDays,
    required this.percentage,
    required this.currentStreak,
    required this.longestStreak,
  });
}

class MonthlyDataPeriod {
  final List<List<int>> monthlyData;
  MonthlyDataPeriod(this.monthlyData);
}

class OverallDataPeriod {
  final List<int> overallData;
  OverallDataPeriod(this.overallData);
}

class AnalyticsGrid extends StatelessWidget {
  final List<StoredHabit> habits;
  final Map<String, Map<String, ProcessedHabitData>>? analyticsData;
  final String viewType; // "monthly" or "overall"

  const AnalyticsGrid({
    Key? key,
    required this.habits,
    required this.analyticsData,
    required this.viewType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasHabitsWithData = habits.any((habit) {
      final processedData = analyticsData?[habit.id]?[viewType];
      return processedData != null;
    });

    if (habits.isEmpty || !hasHabitsWithData) {
      return const EmptyStateWidget();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        if (viewType == 'monthly') {
          if (constraints.maxWidth > 1024) {
            crossAxisCount = 3;
          } else if (constraints.maxWidth > 768) {
            crossAxisCount = 2;
          } else {
            crossAxisCount = 1;
          }
        } else {
          crossAxisCount = constraints.maxWidth > 768 ? 2 : 1;
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: viewType == 'monthly' ? 0.85 : 1.2,
          ),
          itemCount: habits.length,
          itemBuilder: (context, index) {
            final habit = habits[index];
            final processedData = analyticsData?[habit.id]?[viewType];
            if (processedData == null) return const SizedBox.shrink();

            return HabitAnalyticsCard(
              processedData: processedData,
              viewType: viewType,
            );
          },
        );
      },
    );
  }
}

// Habit Analytics Card
class HabitAnalyticsCard extends StatefulWidget {
  final ProcessedHabitData processedData;
  final String viewType;

  const HabitAnalyticsCard({
    Key? key,
    required this.processedData,
    required this.viewType,
  }) : super(key: key);

  @override
  State<HabitAnalyticsCard> createState() => _HabitAnalyticsCardState();
}

class _HabitAnalyticsCardState extends State<HabitAnalyticsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.grey[900]!.withOpacity(0.95)
                : Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.grey[800]!.withOpacity(0.6)
                  : Colors.grey[200]!.withOpacity(0.6),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isHovered ? 0.1 : 0.06),
                blurRadius: _isHovered ? 20 : 10,
                offset: _isHovered ? const Offset(0, 4) : const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            Colors.grey[800]!.withOpacity(0.4),
                            Colors.transparent,
                            Colors.grey[900]!.withOpacity(0.4),
                          ]
                        : [
                            Colors.white.withOpacity(0.4),
                            Colors.transparent,
                            Colors.grey[50]!.withOpacity(0.4),
                          ],
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: widget.viewType == 'monthly'
                    ? MonthlyHeatmapView(data: widget.processedData)
                    : YearlyHeatmapView(data: widget.processedData),
              ),
              // iOS-style indicator
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        isDark ? Colors.grey[600]! : Colors.grey[200]!,
                        Colors.transparent,
                      ],
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
}

// Monthly Heatmap View
class MonthlyHeatmapView extends StatelessWidget {
  final ProcessedHabitData data;

  const MonthlyHeatmapView({Key? key, required this.data}) : super(key: key);

  String getMonthName(int monthIndex) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[monthIndex];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final monthlyData = (data.dataPeriod as MonthlyDataPeriod).monthlyData;

    final now = DateTime.now();
    final year = now.year;
    final month = now.month - 1;
    final monthName = getMonthName(month);

    final daysInMonth = DateTime(year, month + 2, 0).day;
    final firstDayOfMonth = DateTime(year, month + 1, 1).weekday % 7;

    final calendarDays = <int?>[];

    // Empty cells before month
    for (int i = 0; i < firstDayOfMonth; i++) {
      calendarDays.add(null);
    }

    // Add actual days
    int dayCounter = 0;
    for (var week in monthlyData) {
      for (var day in week) {
        if (day != -1) {
          calendarDays.add(day);
          dayCounter++;
          if (dayCounter >= daysInMonth) break;
        }
      }
      if (dayCounter >= daysInMonth) break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: data.habit.color,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: data.habit.color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(Icons.emoji_emotions, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            // Name and date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.habit.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.grey[100] : Colors.grey[900],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: data.habit.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$monthName $year - ${data.completedDays} of ${data.totalDays} ${data.totalDays == 1 ? 'day' : 'days'}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Progress ring
            ProgressRing(
              percentage: data.percentage,
              color: data.habit.color,
              size: 48,
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Calendar heatmap
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.grey[800]!.withOpacity(0.4)
                : Colors.grey[50]!.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.grey[700]!.withOpacity(0.4)
                  : Colors.grey[200]!.withOpacity(0.4),
            ),
          ),
          child: Column(
            children: [
              // Day labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                    .map(
                      (day) => SizedBox(
                        width: 32,
                        child: Center(
                          child: Text(
                            day,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[500],
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 8),
              // Calendar grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                ),
                itemCount: calendarDays.length,
                itemBuilder: (context, index) {
                  final day = calendarDays[index];
                  final dayNumber = day != null && index >= firstDayOfMonth
                      ? index - firstDayOfMonth + 1
                      : null;

                  return CalendarDayCell(
                    day: day,
                    dayNumber: dayNumber,
                    color: data.habit.color,
                    isDark: isDark,
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Streaks
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            StreakBadge(
              streak: data.currentStreak,
              label: 'CURRENT',
              color: data.habit.color,
              isCurrent: true,
              isDark: isDark,
            ),
            StreakBadge(
              streak: data.longestStreak,
              label: 'BEST',
              color: null,
              isCurrent: false,
              isDark: isDark,
            ),
          ],
        ),
      ],
    );
  }
}

// Yearly Heatmap View with GitHub-style grid
class YearlyHeatmapView extends StatelessWidget {
  final ProcessedHabitData data;

  const YearlyHeatmapView({Key? key, required this.data}) : super(key: key);

  String getMonthName(int monthIndex) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[monthIndex];
  }

  // Group data into weeks (GitHub style)
  List<List<int>> _groupIntoWeeks(List<int> data) {
    final weeks = <List<int>>[];
    final totalDays = data.length;

    // Calculate how many complete weeks we can make
    final totalWeeks = (totalDays / 7).ceil();

    for (int week = 0; week < totalWeeks; week++) {
      final weekData = <int>[];
      for (int day = 0; day < 7; day++) {
        final index = week * 7 + day;
        if (index < totalDays) {
          weekData.add(data[index]);
        } else {
          weekData.add(-4); // Placeholder for empty
        }
      }
      weeks.add(weekData);
    }

    return weeks;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final overallData = (data.dataPeriod as OverallDataPeriod).overallData;

    final now = DateTime.now();
    final year = now.year;
    final month = now.month - 1;
    final monthName = getMonthName(month);

    // Group data into weeks for GitHub-style layout
    final weeklyData = _groupIntoWeeks(overallData);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: data.habit.color,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: data.habit.color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.emoji_emotions,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            // Name
            Expanded(
              child: Text(
                data.habit.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.grey[100] : Colors.grey[900],
                  letterSpacing: 0.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Progress ring
            ProgressRing(
              percentage: data.percentage,
              color: data.habit.color,
              size: 48,
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Date and streaks row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Date info
            Flexible(
              child: Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: data.habit.color),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      '$monthName $year - ${data.completedDays} of ${data.totalDays} ${data.totalDays == 1 ? 'day' : 'days'}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Streaks
            Row(
              children: [
                StreakBadge(
                  streak: data.currentStreak,
                  label: 'CURRENT',
                  color: data.habit.color,
                  isCurrent: true,
                  isDark: isDark,
                  compact: true,
                ),
                const SizedBox(width: 6),
                StreakBadge(
                  streak: data.longestStreak,
                  label: 'BEST',
                  color: null,
                  isCurrent: false,
                  isDark: isDark,
                  compact: true,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        // GitHub-style scrollable heatmap
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.grey[800]!.withOpacity(0.4)
                : Colors.grey[50]!.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.grey[700]!.withOpacity(0.4)
                  : Colors.grey[200]!.withOpacity(0.4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Scrollable GitHub-style grid
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Day labels (Sun-Sat)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const SizedBox(height: 0), // Align with grid
                        ...[
                          'Sun',
                          'Mon',
                          'Tue',
                          'Wed',
                          'Thu',
                          'Fri',
                          'Sat',
                        ].asMap().entries.map((entry) {
                          // Only show Mon, Wed, Fri labels
                          final showLabel = entry.key % 2 == 1;
                          return Container(
                            height: 13,
                            margin: const EdgeInsets.only(bottom: 3),
                            child: showLabel
                                ? Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: Text(
                                      entry.value,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isDark
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  )
                                : const SizedBox(),
                          );
                        }).toList(),
                      ],
                    ),
                    const SizedBox(width: 8),
                    // Weeks grid
                    Row(
                      children: weeklyData.asMap().entries.map((weekEntry) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 3),
                          child: Column(
                            children: weekEntry.value.asMap().entries.map((
                              dayEntry,
                            ) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 3),
                                child: GitHubDayCell(
                                  day: dayEntry.value,
                                  color: data.habit.color,
                                  isDark: isDark,
                                  weekIndex: weekEntry.key,
                                  dayIndex: dayEntry.key,
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Legend
              Row(
                children: [
                  Text(
                    'Less',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GitHubLegendCell(
                    color: isDark ? Colors.grey[800]! : Colors.grey[100]!,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 3),
                  GitHubLegendCell(
                    color: data.habit.color.withOpacity(0.3),
                    isDark: isDark,
                  ),
                  const SizedBox(width: 3),
                  GitHubLegendCell(
                    color: data.habit.color.withOpacity(0.6),
                    isDark: isDark,
                  ),
                  const SizedBox(width: 3),
                  GitHubLegendCell(color: data.habit.color, isDark: isDark),
                  const SizedBox(width: 8),
                  Text(
                    'More',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  // Skipped indicator
                  Container(
                    width: 13,
                    height: 13,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(
                        color: data.habit.color.withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Skipped',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: data.percentage / 100,
            backgroundColor: isDark ? Colors.grey[700] : Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(data.habit.color),
            minHeight: 4,
          ),
        ),
      ],
    );
  }
}

// Supporting Widgets
class ProgressRing extends StatelessWidget {
  final int percentage;
  final Color color;
  final double size;

  const ProgressRing({
    Key? key,
    required this.percentage,
    required this.color,
    this.size = 48,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: ProgressRingPainter(percentage: percentage, color: color),
          ),
          Center(
            child: Text(
              '$percentage%',
              style: TextStyle(
                fontSize: size * 0.25,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProgressRingPainter extends CustomPainter {
  final int percentage;
  final Color color;

  ProgressRingPainter({required this.percentage, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;

    // Background circle
    final bgPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final sweepAngle = (percentage / 100) * 2 * 3.14159;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class CalendarDayCell extends StatelessWidget {
  final int? day;
  final int? dayNumber;
  final Color color;
  final bool isDark;

  const CalendarDayCell({
    Key? key,
    required this.day,
    required this.dayNumber,
    required this.color,
    required this.isDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color? bgColor;
    Color? borderColor;
    Color? textColor;

    if (day == 1) {
      bgColor = color;
      textColor = Colors.white;
    } else if (day == 0) {
      bgColor = isDark ? Colors.grey[700] : Colors.grey[200];
      textColor = isDark ? Colors.white : Colors.black;
    } else if (day == -2) {
      borderColor = color;
      textColor = isDark ? Colors.white : Colors.black;
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: borderColor != null
            ? Border.all(color: borderColor, style: BorderStyle.solid, width: 1)
            : null,
      ),
      child: dayNumber != null
          ? Center(
              child: Text(
                '$dayNumber',
                style: TextStyle(
                  fontSize: 11,
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          : null,
    );
  }
}

class YearDayCell extends StatelessWidget {
  final int day;
  final Color color;
  final bool isDark;

  const YearDayCell({
    Key? key,
    required this.day,
    required this.color,
    required this.isDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color? bgColor;
    Color? borderColor;

    if (day == 1) {
      bgColor = color;
    } else if (day == 0) {
      bgColor = isDark ? Colors.grey[700] : Colors.grey[200];
    } else if (day == -2) {
      borderColor = color;
    }

    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        border: borderColor != null
            ? Border.all(color: borderColor, style: BorderStyle.solid)
            : null,
      ),
    );
  }
}

class StreakBadge extends StatelessWidget {
  final int streak;
  final String label;
  final Color? color;
  final bool isCurrent;
  final bool isDark;
  final bool compact;

  const StreakBadge({
    Key? key,
    required this.streak,
    required this.label,
    required this.color,
    required this.isCurrent,
    required this.isDark,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = isCurrent
        ? color!.withOpacity(0.15)
        : (isDark ? Colors.amber[900]!.withOpacity(0.2) : Colors.amber[50]);

    final borderColor = isCurrent
        ? color!.withOpacity(0.3)
        : (isDark
              ? Colors.amber[700]!.withOpacity(0.4)
              : Colors.amber[200]!.withOpacity(0.6));

    final textColor = isCurrent
        ? color!
        : (isDark ? Colors.amber[300] : Colors.amber[700]);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: textColor, shape: BoxShape.circle),
          ),
          SizedBox(width: compact ? 4 : 6),
          Text(
            '$streak',
            style: TextStyle(
              fontSize: compact ? 12 : 14,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(width: 2),
          Text(
            'days',
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          if (!compact) ...[
            SizedBox(width: compact ? 6 : 8),
            Container(
              width: 1,
              height: 16,
              color: isDark ? Colors.grey[600] : Colors.grey[300],
            ),
            SizedBox(width: compact ? 6 : 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: textColor,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool isDark;
  final Color? borderColor;

  const LegendItem({
    Key? key,
    required this.color,
    required this.label,
    required this.isDark,
    this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: borderColor != null
                ? Border.all(color: borderColor!, style: BorderStyle.solid)
                : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.grey[400] : Colors.grey[500],
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No analytics data available',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class AnalyticsTabs extends StatelessWidget {
  final String activeTab;
  final Function(String) onTabChange;

  const AnalyticsTabs({
    super.key,
    required this.activeTab,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              label: 'Monthly View',
              isActive: activeTab == 'monthly',
              onTap: () => onTabChange('monthly'),
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _TabButton(
              label: 'Overall Progress',
              isActive: activeTab == 'overall',
              onTap: () => onTabChange('overall'),
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatefulWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool isDark;

  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.isDark,
  });

  @override
  State<_TabButton> createState() => _TabButtonState();
}

class _TabButtonState extends State<_TabButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: widget.isActive
                ? Colors.green
                : (widget.isDark ? Colors.grey[800] : Colors.grey[200]),
            borderRadius: BorderRadius.circular(12),
            boxShadow: widget.isActive
                ? [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: widget.isActive
                    ? Colors.white
                    : (widget.isDark ? Colors.grey[400] : Colors.grey[700]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Models for habit stats
class HabitStats {
  final Map<String, Map<String, StatEntry>> data;

  HabitStats(this.data);

  Map<String, StatEntry>? operator [](String habitId) => data[habitId];
}

class StatEntry {
  final bool completed;
  final DateTime date;

  StatEntry({required this.completed, required this.date});
}

class StreakResult {
  final int current;
  final int longest;

  StreakResult({required this.current, required this.longest});
}

class CompletionStats {
  final int completedDays;
  final int totalDays;
  final int percentage;

  CompletionStats({
    required this.completedDays,
    required this.totalDays,
    required this.percentage,
  });
}

// Utility Functions
class AnalyticsUtils {
  /// Format date to YYMMDD string
  static String formatToYYMMDD(DateTime date) {
    return DateFormat('yyMMdd').format(date);
  }

  /// Get today's date as string
  static String getTodayDate() {
    return formatToYYMMDD(DateTime.now());
  }

  /// Check if date1 is strictly greater than date2
  static bool isStrictlyGreaterDateYYMMDD(String date1, String date2) {
    return date1.compareTo(date2) > 0;
  }

  /// Check if habit is scheduled for a specific date
  static bool isHabitScheduledForToday(StoredHabit habit, String dateKey) {
    final date = _parseYYMMDD(dateKey);
    final weekday = date.weekday % 7; // Convert to 0-6 (Sunday-Saturday)
    return habit.scheduledDays.contains(weekday);
  }

  /// Check if habit is completed
  static int isHabitCompleted(StoredHabit habit, StatEntry statEntry) {
    return statEntry.completed ? 1 : 0;
  }

  /// Parse YYMMDD string to DateTime
  static DateTime _parseYYMMDD(String dateKey) {
    final year = 2000 + int.parse(dateKey.substring(0, 2));
    final month = int.parse(dateKey.substring(2, 4));
    final day = int.parse(dateKey.substring(4, 6));
    return DateTime(year, month, day);
  }

  /// Generate monthly calendar data for current month
  static List<List<int>> generateMonthlyRawData(
    StoredHabit habit,
    HabitStats stats,
  ) {
    final currentDate = DateTime.now();
    final year = currentDate.year;
    final month = currentDate.month;

    final daysInMonth = DateTime(year, month + 1, 0).day;
    final firstDayOfMonth = DateTime(year, month, 1).weekday % 7;

    final monthlyData = <List<int>>[];
    int dayIndex = 0;

    // Generate 6 weeks to cover any month layout
    for (int week = 0; week < 6; week++) {
      final weekData = <int>[];

      for (int day = 0; day < 7; day++) {
        if (week == 0 && day < firstDayOfMonth) {
          // Empty cells before month starts
          weekData.add(-1);
        } else if (dayIndex >= daysInMonth) {
          // Empty cells after month ends
          weekData.add(-1);
        } else {
          // Actual day
          final actualDay = dayIndex + 1;
          final dateKey = formatToYYMMDD(DateTime(year, month, actualDay));
          final isSchedule = isHabitScheduledForToday(habit, dateKey);

          if (isSchedule) {
            final habitStats = stats[habit.id];
            final statEntry = habitStats?[dateKey];

            if (statEntry != null) {
              weekData.add(isHabitCompleted(habit, statEntry));
            } else {
              // No data for this date
              final isFuture = isStrictlyGreaterDateYYMMDD(
                dateKey,
                getTodayDate(),
              );
              weekData.add(isFuture ? -3 : 0);
            }
          } else {
            weekData.add(-2); // Not scheduled
          }

          dayIndex++;
        }
      }

      monthlyData.add(weekData);
      if (dayIndex >= daysInMonth) break;
    }

    return monthlyData;
  }

  /// Generate yearly data starting from habit.startDate
  static List<int> generateYearlyRawData(StoredHabit habit, HabitStats? stats) {
    final yearData = <int>[];
    final currentDate = DateTime.now();
    final habitStartDate = _parseYYMMDD(habit.startDate);
    final habitStats = stats?[habit.id];

    // Calculate days since start
    final daysSinceStart = currentDate.difference(habitStartDate).inDays;

    // Ensure minimum 100 grids, maximum 365
    const minGrids = 100;
    const maxGrids = 365;
    final actualDays = daysSinceStart + 1;
    final totalGrids = (actualDays.clamp(minGrids, maxGrids));

    for (int day = 0; day < totalGrids; day++) {
      final date = habitStartDate.add(Duration(days: day));
      final dateKey = formatToYYMMDD(date);
      final statEntry = habitStats?[dateKey];
      final isSchedule = isHabitScheduledForToday(habit, dateKey);

      if (date.isAfter(currentDate)) {
        // Future dates
        yearData.add(-1);
      } else {
        if (isSchedule) {
          if (statEntry != null) {
            yearData.add(isHabitCompleted(habit, statEntry));
          } else {
            yearData.add(0); // Not completed
          }
        } else {
          yearData.add(-2); // Not scheduled
        }
      }
    }

    return yearData;
  }

  /// Calculate completion statistics
  static CompletionStats calculateCompletionStats(List<int> data) {
    int completedDays = 0;
    int totalDays = 0;

    for (final value in data) {
      if (value == 0 || value == 1) {
        totalDays++;
        if (value == 1) {
          completedDays++;
        }
      }
    }

    final percentage = totalDays > 0
        ? ((completedDays / totalDays) * 100).round()
        : 0;

    return CompletionStats(
      completedDays: completedDays,
      totalDays: totalDays,
      percentage: percentage,
    );
  }

  /// Calculate current and longest streaks
  static StreakResult calculateStreaks(List<int> data) {
    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 0;

    // Calculate from end to start for current streak
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 1) {
        currentStreak++;
      } else if (data[i] == 0) {
        break; // Stop at first non-completed day
      }
    }

    // Calculate longest streak
    for (final value in data) {
      if (value == 1) {
        tempStreak++;
        longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;
      } else if (value == 0) {
        tempStreak = 0;
      }
    }

    return StreakResult(current: currentStreak, longest: longestStreak);
  }

  /// Main function to generate analytics data for all habits
  static AnalyticsData generateAnalyticsData(
    List<StoredHabit> habits,
    HabitStats stats,
  ) {
    final data = <String, Map<String, ProcessedHabitData>>{};

    for (final habit in habits) {
      final monthlyRawData = generateMonthlyRawData(habit, stats);
      final overallRawData = generateYearlyRawData(habit, stats);

      // Calculate stats for monthly data
      final monthlyFlatData = monthlyRawData.expand((week) => week).toList();
      final monthlyStats = calculateCompletionStats(monthlyFlatData);
      final monthlyStreaks = calculateStreaks(monthlyFlatData);

      // Calculate stats for overall data
      final overallStats = calculateCompletionStats(overallRawData);
      final overallStreaks = calculateStreaks(overallRawData);

      data[habit.id] = {
        'monthly': ProcessedHabitData(
          habit: habit,
          dataPeriod: MonthlyDataPeriod(monthlyRawData),
          completedDays: monthlyStats.completedDays,
          totalDays: monthlyStats.totalDays,
          percentage: monthlyStats.percentage,
          currentStreak: monthlyStreaks.current,
          longestStreak: monthlyStreaks.longest,
        ),
        'overall': ProcessedHabitData(
          habit: habit,
          dataPeriod: OverallDataPeriod(overallRawData),
          completedDays: overallStats.completedDays,
          totalDays: overallStats.totalDays,
          percentage: overallStats.percentage,
          currentStreak: overallStreaks.current,
          longestStreak: overallStreaks.longest,
        ),
      };
    }

    return AnalyticsData(data);
  }
}

// Import the previous files:
// - analytics_utils.dart
// - analytics_tabs.dart
// - analytics_grid.dart

class MyStats extends StatelessWidget {
  const MyStats({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Analytics',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.grey[900],
      ),
      themeMode: ThemeMode.system,
      home: const AnalyticsPage(),
    );
  }
}

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  String _activeTab = 'monthly';
  late List<StoredHabit> _habits;
  late HabitStats _stats;
  late AnalyticsData _analyticsData;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    // Sample habits
    _habits = [
      StoredHabit(
        id: '1',
        name: 'Morning Exercise',
        icon: 'fitness',
        color: Colors.blue,
        startDate: AnalyticsUtils.formatToYYMMDD(
          DateTime.now().subtract(const Duration(days: 90)),
        ),
        scheduledDays: [1, 2, 3, 4, 5], // Monday to Friday
      ),
      StoredHabit(
        id: '2',
        name: 'Read Books',
        icon: 'book',
        color: Colors.purple,
        startDate: AnalyticsUtils.formatToYYMMDD(
          DateTime.now().subtract(const Duration(days: 60)),
        ),
        scheduledDays: [0, 1, 2, 3, 4, 5, 6], // Every day
      ),
      StoredHabit(
        id: '3',
        name: 'Meditation',
        icon: 'spa',
        color: Colors.teal,
        startDate: AnalyticsUtils.formatToYYMMDD(
          DateTime.now().subtract(const Duration(days: 45)),
        ),
        scheduledDays: [0, 1, 2, 3, 4, 5, 6], // Every day
      ),
      StoredHabit(
        id: '4',
        name: 'Drink Water',
        icon: 'water',
        color: Colors.cyan,
        startDate: AnalyticsUtils.formatToYYMMDD(
          DateTime.now().subtract(const Duration(days: 30)),
        ),
        scheduledDays: [0, 1, 2, 3, 4, 5, 6], // Every day
      ),
    ];

    // Generate sample stats (you would load this from your database)
    _stats = _generateSampleStats(_habits);

    // Generate analytics data
    _analyticsData = AnalyticsUtils.generateAnalyticsData(_habits, _stats);
  }

  HabitStats _generateSampleStats(List<StoredHabit> habits) {
    final data = <String, Map<String, StatEntry>>{};

    for (final habit in habits) {
      final habitStats = <String, StatEntry>{};
      final startDate = AnalyticsUtils._parseYYMMDD(habit.startDate);
      final now = DateTime.now();

      // Generate stats for each day from start to now
      for (int i = 0; i <= now.difference(startDate).inDays; i++) {
        final date = startDate.add(Duration(days: i));
        final dateKey = AnalyticsUtils.formatToYYMMDD(date);

        // Check if habit is scheduled for this day
        if (AnalyticsUtils.isHabitScheduledForToday(habit, dateKey)) {
          // Simulate 75% completion rate with some randomness
          final completed = (i % 4) != 0; // 75% completion
          habitStats[dateKey] = StatEntry(completed: completed, date: date);
        }
      }

      data[habit.id] = habitStats;
    }

    return HabitStats(data);
  }

  void _handleTabChange(String tab) {
    setState(() {
      _activeTab = tab;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Habit Analytics',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              // Toggle theme (implement your theme switching logic)
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Tabs
          AnalyticsTabs(activeTab: _activeTab, onTabChange: _handleTabChange),
          const SizedBox(height: 8),
          // Grid
          Expanded(
            child: AnalyticsGrid(
              habits: _habits,
              analyticsData: _analyticsData,
              viewType: _activeTab,
            ),
          ),
        ],
      ),
    );
  }
}

// Extension to parse YYMMDD (add to AnalyticsUtils class)
extension AnalyticsUtilsExtension on AnalyticsUtils {
  static DateTime _parseYYMMDD(String dateKey) {
    final year = 2000 + int.parse(dateKey.substring(0, 2));
    final month = int.parse(dateKey.substring(2, 4));
    final day = int.parse(dateKey.substring(4, 6));
    return DateTime(year, month, day);
  }
}

// Note: You'll need to add the intl package to your pubspec.yaml:
// dependencies:
//   flutter:
//     sdk: flutter
//   intl: ^0.18.0
