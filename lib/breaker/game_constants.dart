import 'package:flutter/material.dart';

/// Centralized game constants to avoid magic numbers and hardcoding.
/// Makes tuning gameplay & UI easier.
class GameConstants {
  // 🎨 Colors
  static const Color backGroundColor = Color(0xFF1A1A2E); // dark navy
  static const Color whiteColor = Colors.white;
  static const Color accentColor = Color(
    0xFFE94560,
  ); // for highlights (optional)

  // ⚡ Gameplay Physics
  static const double ballSpeed = 12.0;
  static const double paddleSpeed = 8.0;
  static const double gravity = 9.8; // if you want falling objects
  static const double friction = 0.98; // slowdown factor for movement

  // 🔘 Ball properties
  static const double ballRadius = 8.0;
  static const double ballInitialY = 50.0; // offset from bottom

  // ▭ Paddle / Board
  static const double paddleHeight = 20.0;
  static const double paddleWidthFactor = 0.2; // fraction of screen width
  static const double paddleYOffset = 40.0; // distance from bottom

  // 🧱 Brick settings
  static const int brickRows = 6;
  static const int brickColumns = 8;
  static const double brickWidth = 40.0;
  static const double brickHeight = 16.0;
  static const double brickSpacing = 4.0;

  // ⏱ Timing
  static const Duration powerUpDuration = Duration(seconds: 6);
  static const Duration countdownDuration = Duration(seconds: 3);

  // 🎯 Scoring
  static const int scorePerBrick = 10;
  static const int bonusForLevelClear = 500;

  // 🔊 Audio
  static const String soundBounce = "bounce.wav";
  static const String soundBrickBreak = "brick_break.wav";
  static const String soundLose = "lose.wav";

  // 📱 UI sizes
  static const double scoreFontSize = 26.0;
  static const double bestFontSize = 18.0;
  static const double highScoreFontSize = 22.0;
}
