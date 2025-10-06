import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppColors {
  static const primary = Colors.blue;
  static const primaryDark = Colors.blueAccent;
  static const primaryLight = Colors.blueAccent;
  static const surface = Colors.white;
  static const secondaryLight = Colors.grey;
  static const textPrimary = Colors.black;
  static const textSecondary = Colors.grey;
  static const textOnPrimary = Colors.white;
}

// ============================================================================

class QuickInsightWidgets extends StatelessWidget {
  const QuickInsightWidgets({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quick Insight', style: TextStyle(fontSize: 18.sp)),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'Your Progress',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        fontSize: 18.sp,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Icon(
                      Icons.bar_chart,
                      size: 20.sp,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              // Cards Section → Responsive Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  // Calculate number of columns based on screen width
                  int crossAxisCount;
                  double cardWidth;

                  if (constraints.maxWidth < 600) {
                    // Small phones: 2 columns
                    crossAxisCount = 2;
                    cardWidth = (constraints.maxWidth - 16.w) / 2;
                  } else if (constraints.maxWidth < 900) {
                    // Large phones/small tablets: 3 columns
                    crossAxisCount = 3;
                    cardWidth = (constraints.maxWidth - 32.w) / 3;
                  } else {
                    // Tablets: 4 columns
                    crossAxisCount = 4;
                    cardWidth = (constraints.maxWidth - 48.w) / 4;
                  }

                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 10.h,
                    crossAxisSpacing: 10.w,
                    childAspectRatio: cardWidth / (cardWidth * .9),
                    children: [
                      _buildStreakCard(backgroundColor: AppColors.primaryDark),
                      _buildMotivationCard(backgroundColor: AppColors.primary),
                      _buildProgressCard(backgroundColor: AppColors.surface),
                      _buildEngagementCard(backgroundColor: AppColors.surface),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- Card Wrapper ----------------
  Widget _buildCard({required Widget child, required Color color}) {
    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.secondaryLight),
      ),
      child: child,
    );
  }

  // ---------------- Streak Card ----------------
  Widget _buildStreakCard({required Color backgroundColor}) {
    final currentStreak = 3;
    final bestStreak = 7;
    final targetStreak = 5;

    return _buildCard(
      color: backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _circleIcon(Icons.local_fire_department, AppColors.textOnPrimary),
              const Spacer(),
              _tag("Streak", Colors.orange),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStreakColumn(targetStreak, 'Target'),
              _buildStreakColumn(currentStreak, 'Current'),
              _buildStreakColumn(bestStreak, 'Best'),
            ],
          ),
          Spacer(),
          _buildCurrentStreakProgress(currentStreak, targetStreak),
        ],
      ),
    );
  }

  Widget _buildStreakColumn(int value, String label) {
    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '$value',
              style: TextStyle(
                color: AppColors.textOnPrimary,
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: TextStyle(color: AppColors.textOnPrimary, fontSize: 9.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStreakProgress(int currentStreak, int targetStreak) {
    const displayDays = 7;
    final basicProgress = math.min(currentStreak, displayDays);
    final extraDays = math.max(0, currentStreak - displayDays);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(displayDays, (index) {
            final isCompleted = index < basicProgress;
            final isLastAndHasExtra = index == displayDays - 1 && extraDays > 0;

            return Flexible(
              child: Container(
                width: 14.r,
                height: 14.r,
                margin: EdgeInsets.all(1.r),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? (isLastAndHasExtra ? Colors.orange : AppColors.surface)
                      : AppColors.surface.withOpacity(0.3),
                  shape: BoxShape.circle,
                  border: isLastAndHasExtra
                      ? Border.all(color: Colors.orange, width: 1.5.w)
                      : null,
                ),
                alignment: Alignment.center,
                child: isCompleted
                    ? isLastAndHasExtra
                          ? FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '+$extraDays',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 7.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.check,
                              size: 10.sp,
                              color: AppColors.primary,
                            )
                    : null,
              ),
            );
          }),
        ),
        SizedBox(height: 4.h),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '$currentStreak / $targetStreak days',
            style: TextStyle(
              color: AppColors.textOnPrimary,
              fontSize: 9.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // ---------------- Motivation Card ----------------
  Widget _buildMotivationCard({required Color backgroundColor}) {
    final todayXP = 50;
    final level = 3;
    final currentXP = 120;
    final requiredXP = 200;
    final progress = currentXP / requiredXP;

    return _buildCard(
      color: backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _circleIcon(Icons.emoji_events, AppColors.textOnPrimary),
              _tag('+50 XP', Colors.orange),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'Level ',
                style: TextStyle(
                  color: AppColors.textOnPrimary,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$level',
                style: TextStyle(
                  color: AppColors.textOnPrimary,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: AppColors.textOnPrimary.withOpacity(0.2),
            color: AppColors.surface,
            minHeight: 4.h,
          ),
          SizedBox(height: 4.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '$currentXP / $requiredXP XP',
              style: TextStyle(color: AppColors.textOnPrimary, fontSize: 9.sp),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- Progress Card ----------------
  Widget _buildProgressCard({required Color backgroundColor}) {
    final wordsLearned = 35;
    final goal = 50;
    final progress = wordsLearned / goal;

    return _buildCard(
      color: backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _circleIcon(Icons.bar_chart, AppColors.primary),
              const Spacer(),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '+${(progress * 100).toInt()}%',
                  style: TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '$wordsLearned',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'Words Learned',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11.sp),
            ),
          ),
          SizedBox(height: 8.h),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: AppColors.primaryLight,
            color: AppColors.primaryDark,
            minHeight: 4.h,
          ),
          SizedBox(height: 4.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'Goal: 50',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 9.sp),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- Engagement Card ----------------
  Widget _buildEngagementCard({required Color backgroundColor}) {
    final todayMinutes = 45;
    final dailyGoalMinutes = 60;
    final progress = todayMinutes / dailyGoalMinutes;

    return _buildCard(
      color: backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _circleIcon(Icons.access_time, AppColors.primary),
              const Spacer(),
              _tag("Today", AppColors.secondaryLight),
            ],
          ),
          SizedBox(height: 6.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${todayMinutes}m',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'Study Time',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11.sp),
            ),
          ),
          SizedBox(height: 4.h),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: AppColors.primaryLight,
            color: AppColors.primaryDark,
            minHeight: 4.h,
          ),
          SizedBox(height: 4.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'Goal: $dailyGoalMinutes min (${(progress * 100).toInt()}%)',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 9.sp),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- Helper Widgets ----------------
  Widget _circleIcon(IconData icon, Color color, {double? size}) {
    return Container(
      padding: EdgeInsets.all(5.r),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(icon, color: color, size: size ?? 16.sp),
    );
  }

  Widget _tag(String text, Color bgColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 9.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
