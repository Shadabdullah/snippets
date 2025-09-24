import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'dart:math';

void main() {
  runApp(const BalloonGameApp());
}

enum WordType { noun, pronoun, verb }

enum BulletType { noun, pronoun, verb }

class FallingBalloonsGame extends FlameGame
    with TapDetector, HasCollisionDetection {
  late Timer balloonSpawnTimer;
  late ModernCannonComponent nounCannon;
  late ModernCannonComponent pronounCannon;
  late ModernCannonComponent verbCannon;

  int score = 0;
  int lives = 5;
  int level = 1;
  late TextComponent scoreText;
  late TextComponent livesText;
  late TextComponent levelText;
  late RectangleComponent gameBackground;
  late PositionComponent uiLayer;

  // Enhanced visual effects
  List<FloatingParticleComponent> backgroundParticles = [];

  // Word collections by type
  final Map<WordType, List<String>> wordsByType = {
    WordType.noun: [
      'Cat',
      'Dog',
      'House',
      'Book',
      'Car',
      'Tree',
      'Phone',
      'Apple',
      'Ball',
      'Chair',
      'Ocean',
      'Mountain',
      'Star',
      'Cloud',
      'River',
      'Castle',
      'Dragon',
      'Flower',
    ],
    WordType.pronoun: [
      'I',
      'You',
      'He',
      'She',
      'We',
      'They',
      'It',
      'Me',
      'Him',
      'Her',
      'Us',
      'Them',
      'Myself',
      'Yourself',
      'Himself',
      'Herself',
    ],
    WordType.verb: [
      'Run',
      'Jump',
      'Sing',
      'Dance',
      'Read',
      'Write',
      'Swim',
      'Fly',
      'Cook',
      'Play',
      'Create',
      'Explore',
      'Discover',
      'Build',
      'Paint',
      'Laugh',
      'Dream',
      'Soar',
    ],
  };

  final Map<WordType, Color> wordTypeColors = {
    WordType.noun: const Color(0xFF00D4FF), // Cyan blue
    WordType.pronoun: const Color(0xFF00FF88), // Neon green
    WordType.verb: const Color(0xFFFF6B6B), // Coral red
  };

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Ultra-modern gradient background
    gameBackground = RectangleComponent(
      size: size,
      paint: Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0D1B2A), // Deep navy
            Color(0xFF1B263B), // Darker blue
            Color(0xFF2D3748), // Slate
            Color(0xFF1A1A2E), // Deep purple
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.x, size.y)),
    );
    add(gameBackground);

    // Add floating background particles
    _createBackgroundParticles();

    // Position cannons with better spacing
    final cannonY = size.y - 140;
    final cannonSpacing = size.x / 4;

    // Enhanced Cannons
    nounCannon = ModernCannonComponent(
      position: Vector2(cannonSpacing - 40, cannonY),
      bulletType: BulletType.noun,
      label: 'NOUN',
      primaryColor: const Color(0xFF00D4FF),
      secondaryColor: const Color(0xFF0099CC),
      accentColor: const Color(0xFF66E5FF),
      game: this,
    );
    add(nounCannon);

    pronounCannon = ModernCannonComponent(
      position: Vector2(cannonSpacing * 2 - 40, cannonY),
      bulletType: BulletType.pronoun,
      label: 'PRONOUN',
      primaryColor: const Color(0xFF00FF88),
      secondaryColor: const Color(0xFF00CC66),
      accentColor: const Color(0xFF66FFAA),
      game: this,
    );
    add(pronounCannon);

    verbCannon = ModernCannonComponent(
      position: Vector2(cannonSpacing * 3 - 40, cannonY),
      bulletType: BulletType.verb,
      label: 'VERB',
      primaryColor: const Color(0xFFFF6B6B),
      secondaryColor: const Color(0xFFCC5555),
      accentColor: const Color(0xFFFF9999),
      game: this,
    );
    add(verbCannon);

    // Create modern UI overlay
    _createModernUI();

    // Enhanced balloon spawning
    balloonSpawnTimer = Timer(
      max(0.8, 2.5 - (level * 0.2)), // Adaptive spawn rate
      onTick: spawnBalloon,
      repeat: true,
    );
    balloonSpawnTimer.start();
  }

  void _createBackgroundParticles() {
    final random = Random();
    for (int i = 0; i < 30; i++) {
      final particle = FloatingParticleComponent(
        position: Vector2(
          random.nextDouble() * size.x,
          random.nextDouble() * size.y,
        ),
      );
      add(particle);
    }
  }

  void _createModernUI() {
    // Modern UI background with glassmorphism effect
    uiLayer = PositionComponent();

    final uiBackground = RectangleComponent(
      size: Vector2(size.x, 120),
      paint: Paint()..color = const Color(0xFF1A1A2E).withOpacity(0.95),
    );
    uiLayer.add(uiBackground);

    // Neon-style score display
    scoreText = TextComponent(
      text: 'SCORE: $score',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFF00FF88),
          fontSize: 28,
          fontWeight: FontWeight.w900,
          letterSpacing: 3,
          shadows: [
            Shadow(
              color: Color(0x8000FF88),
              offset: Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
      ),
      position: Vector2(30, 30),
    );
    uiLayer.add(scoreText);

    // Enhanced lives display
    livesText = TextComponent(
      text: '♥ $lives LIVES',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFFF6B6B),
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
          shadows: [
            Shadow(
              color: Color(0x80FF6B6B),
              offset: Offset(0, 2),
              blurRadius: 6,
            ),
          ],
        ),
      ),
      position: Vector2(size.x - 180, 30),
    );
    uiLayer.add(livesText);

    // Level indicator
    levelText = TextComponent(
      text: 'LEVEL $level',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFF00D4FF),
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 2,
          shadows: [
            Shadow(
              color: Color(0x8000D4FF),
              offset: Offset(0, 2),
              blurRadius: 6,
            ),
          ],
        ),
      ),
      position: Vector2(30, 70),
    );
    uiLayer.add(levelText);

    add(uiLayer);
  }

  @override
  void update(double dt) {
    super.update(dt);
    balloonSpawnTimer.update(dt);

    // Level progression
    if (score > 0 && score % 200 == 0 && score != 0) {
      if (level < score ~/ 200 + 1) {
        level = score ~/ 200 + 1;
        levelText.text = 'LEVEL $level';
        // Update spawn timer with new difficulty
        balloonSpawnTimer = Timer(
          max(0.5, 2.5 - (level * 0.3)),
          onTick: spawnBalloon,
          repeat: true,
        );
        balloonSpawnTimer.start();
      }
    }

    // Enhanced balloon cleanup and collision
    _updateBalloons(dt);
    _updateBullets(dt);
    checkCollisions();
  }

  void _updateBalloons(double dt) {
    final balloonsToRemove = <EnhancedBalloonComponent>[];

    for (final component in children) {
      if (component is EnhancedBalloonComponent) {
        if (component.position.y > size.y - 180) {
          balloonsToRemove.add(component);
          lives--;
          livesText.text = '♥ $lives LIVES';
          addExplosion(component.position, Colors.orange, isAutoBurst: true);

          if (lives <= 0) {
            _gameOver();
          }
        }
      }
    }

    for (final balloon in balloonsToRemove) {
      balloon.removeFromParent();
    }
  }

  void _updateBullets(double dt) {
    final bulletsToRemove = <EnhancedBulletComponent>[];

    for (final component in children) {
      if (component is EnhancedBulletComponent && component.position.y < -50) {
        bulletsToRemove.add(component);
      }
    }

    for (final bullet in bulletsToRemove) {
      bullet.removeFromParent();
    }
  }

  void checkCollisions() {
    final bullets = children.whereType<EnhancedBulletComponent>().toList();
    final balloons = children.whereType<EnhancedBalloonComponent>().toList();

    for (final bullet in bullets) {
      for (final balloon in balloons) {
        if (bullet.toRect().overlaps(balloon.toRect())) {
          bullet.removeFromParent();
          balloon.removeFromParent();

          final bulletType = bullet.bulletType;
          final wordType = balloon.wordType;

          bool isCorrect =
              (bulletType == BulletType.noun && wordType == WordType.noun) ||
              (bulletType == BulletType.pronoun &&
                  wordType == WordType.pronoun) ||
              (bulletType == BulletType.verb && wordType == WordType.verb);

          if (isCorrect) {
            score += 25 + (level * 5); // Bonus points for higher levels
            addExplosion(balloon.position, const Color(0xFF00FF88));
            addScorePopup(balloon.position, '+${25 + (level * 5)}');
          } else {
            score -= 15;
            if (score < 0) score = 0;
            addExplosion(balloon.position, const Color(0xFFFF4444));
            addScorePopup(balloon.position, '-15');
          }

          scoreText.text = 'SCORE: $score';
          break;
        }
      }
    }
  }

  void addExplosion(Vector2 position, Color color, {bool isAutoBurst = false}) {
    final explosion = EnhancedExplosionComponent(
      position: position,
      explosionColor: color,
      isAutoBurst: isAutoBurst,
    );
    add(explosion);
  }

  void addScorePopup(Vector2 position, String text) {
    final popup = ScorePopupComponent(position: position, text: text);
    add(popup);
  }

  void spawnBalloon() {
    final random = Random();
    final x = random.nextDouble() * (size.x - 100) + 50;

    final wordType = WordType.values[random.nextInt(WordType.values.length)];
    final words = wordsByType[wordType]!;
    final word = words[random.nextInt(words.length)];
    final color = wordTypeColors[wordType]!;

    final balloon = EnhancedBalloonComponent(
      position: Vector2(x, -120),
      word: word,
      wordType: wordType,
      color: color,
      level: level,
    );

    add(balloon);
  }

  @override
  bool onTapDown(TapDownInfo info) {
    final tapPosition = info.eventPosition.global;

    // Fixed: Check which cannon area was tapped based on screen position
    final screenWidth = size.x;
    final tapX = tapPosition.x;

    // Define tap zones more clearly - each cannon gets 1/3 of the screen width
    if (tapX < screenWidth / 3) {
      // Left third - noun cannon
      fireFromCannon(nounCannon, tapPosition);
    } else if (tapX < (screenWidth * 2) / 3) {
      // Middle third - pronoun cannon
      fireFromCannon(pronounCannon, tapPosition);
    } else {
      // Right third - verb cannon
      fireFromCannon(verbCannon, tapPosition);
    }

    return true;
  }

  void fireFromCannon(ModernCannonComponent cannon, Vector2 targetPosition) {
    // Fixed: Calculate proper cannon center position
    final cannonCenter = cannon.position + Vector2(40, 60);

    // Aim the cannon at the tap position
    cannon.aimAt(targetPosition);
    cannon.triggerFireAnimation();

    // Calculate direction from cannon to tap position
    final direction = (targetPosition - cannonCenter).normalized();

    // Create bullet at cannon position
    final bullet = EnhancedBulletComponent(
      position: cannonCenter.clone(),
      direction: direction,
      bulletType: cannon.bulletType,
      color: cannon.primaryColor,
    );

    add(bullet);
  }

  void _gameOver() {
    // Add game over logic here
    // For now, just reset
    lives = 5;
    score = 0;
    level = 1;
    scoreText.text = 'SCORE: $score';
    livesText.text = '♥ $lives LIVES';
    levelText.text = 'LEVEL $level';
  }
}

class ModernCannonComponent extends PositionComponent {
  final BulletType bulletType;
  final String label;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final FallingBalloonsGame game;

  late TextComponent labelComponent;
  late RectangleComponent cannonBody;
  late PositionComponent cannonBarrel;
  late CircleComponent cannonBase;

  double fireAnimationScale = 1.0;
  bool isAnimating = false;
  double barrelAngle = -pi / 2; // Start pointing up
  double targetAngle = -pi / 2; // Target angle to rotate towards
  final double rotationSpeed = 3.0; // Increased rotation speed
  bool isRotating = false; // Track if currently rotating

  ModernCannonComponent({
    required Vector2 position,
    required this.bulletType,
    required this.label,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.game,
  }) : super(position: position, size: Vector2(80, 120));

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Enhanced cannon base with glow effect
    final glowCircle = CircleComponent(
      radius: 38,
      position: Vector2(40, 80),
      paint: Paint()..color = primaryColor.withOpacity(0.3),
      anchor: Anchor.center,
    );

    // Main base
    cannonBase = CircleComponent(
      radius: 30,
      position: Vector2(40, 80),
      paint: Paint()
        ..shader = RadialGradient(
          colors: [accentColor, primaryColor, secondaryColor],
          stops: const [0.0, 0.7, 1.0],
        ).createShader(const Rect.fromLTWH(0, 0, 60, 60)),
      anchor: Anchor.center,
    );

    add(glowCircle);
    add(cannonBase);

    // Modern cannon body (thicker)
    cannonBody = RectangleComponent(
      size: Vector2(35, 45), // Made thicker
      position: Vector2(22.5, 35), // Adjusted position for centering
      paint: Paint()
        ..shader = LinearGradient(
          colors: [accentColor, primaryColor, secondaryColor],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(const Rect.fromLTWH(0, 0, 35, 45)),
    );
    add(cannonBody);

    // THICK cannon barrel that rotates
    cannonBarrel = PositionComponent();

    // Much thicker barrel
    final barrel = RectangleComponent(
      size: Vector2(20, 50), // Much thicker and longer
      position: Vector2(-10, -50), // Centered for rotation
      paint: Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0xFF34495E),
            Color(0xFF2C3E50),
            Color(0xFF1A252F),
            Color(0xFF2C3E50),
            Color(0xFF34495E),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(const Rect.fromLTWH(0, 0, 20, 50)),
    );

    // Barrel reinforcement rings (gear-like details)
    final ring1 = RectangleComponent(
      size: Vector2(22, 4),
      position: Vector2(-11, -35),
      paint: Paint()..color = const Color(0xFF1A252F),
    );

    final ring2 = RectangleComponent(
      size: Vector2(22, 4),
      position: Vector2(-11, -20),
      paint: Paint()..color = const Color(0xFF1A252F),
    );

    // Thicker barrel tip with glow
    final barrelTip = CircleComponent(
      radius: 12, // Bigger tip
      position: Vector2(0, -50),
      paint: Paint()
        ..shader = RadialGradient(
          colors: [accentColor.withOpacity(0.9), const Color(0xFF2C3E50)],
        ).createShader(const Rect.fromLTWH(0, 0, 24, 24)),
      anchor: Anchor.center,
    );

    // Inner barrel opening
    final barrelOpening = CircleComponent(
      radius: 8,
      position: Vector2(0, -50),
      paint: Paint()..color = const Color(0xFF0D1117),
      anchor: Anchor.center,
    );

    cannonBarrel.add(barrel);
    cannonBarrel.add(ring1);
    cannonBarrel.add(ring2);
    cannonBarrel.add(barrelTip);
    cannonBarrel.add(barrelOpening);
    cannonBarrel.position = Vector2(40, 60); // Pivot point
    cannonBarrel.angle = barrelAngle;
    add(cannonBarrel);

    // Enhanced label with glow
    labelComponent = TextComponent(
      text: label,
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
          shadows: [
            Shadow(
              color: primaryColor,
              offset: const Offset(0, 1),
              blurRadius: 4,
            ),
          ],
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(40, 100),
    );
    add(labelComponent);
  }

  void aimAt(Vector2 targetPosition) {
    final cannonCenter = position + Vector2(40, 60);
    final direction = targetPosition - cannonCenter;
    double newTargetAngle = atan2(direction.y, direction.x) - pi / 2;

    // Fixed: Better angle constraints
    // Clamp angles to reasonable firing range
    if (newTargetAngle > pi * 0.3) {
      newTargetAngle = pi * 0.3; // Don't aim too far down
    }
    if (newTargetAngle < -pi * 0.8) {
      newTargetAngle = -pi * 0.8; // Don't aim too far back
    }

    // Normalize angle to avoid unnecessary rotation
    while (newTargetAngle - barrelAngle > pi) {
      newTargetAngle -= 2 * pi;
    }
    while (barrelAngle - newTargetAngle > pi) {
      newTargetAngle += 2 * pi;
    }

    // Only update if there's a significant difference
    if ((newTargetAngle - barrelAngle).abs() > 0.1) {
      targetAngle = newTargetAngle;
      isRotating = true;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Fixed: Improved rotation logic
    if (isRotating) {
      double angleDiff = targetAngle - barrelAngle;

      // Smooth rotation
      if (angleDiff.abs() > 0.05) {
        double rotationStep = rotationSpeed * dt;
        if (angleDiff.abs() < rotationStep) {
          barrelAngle = targetAngle;
          isRotating = false;
        } else {
          barrelAngle += angleDiff > 0 ? rotationStep : -rotationStep;
        }
        cannonBarrel.angle = barrelAngle;
      } else {
        isRotating = false;
      }
    }

    // Fire animation with enhanced effects
    if (isAnimating) {
      fireAnimationScale += dt * 15;
      if (fireAnimationScale > 1.2) {
        fireAnimationScale = 1.0;
        isAnimating = false;
      }
      scale = Vector2.all(fireAnimationScale);

      // Fixed: Better screen shake effect
      if (fireAnimationScale > 1.05) {
        final shakeIntensity = (fireAnimationScale - 1.0) * 10;
        final time = DateTime.now().millisecondsSinceEpoch * 0.01;
        game.camera.viewfinder.position = Vector2(
          sin(time) * shakeIntensity,
          cos(time * 1.3) * shakeIntensity,
        );
      } else {
        game.camera.viewfinder.position = Vector2.zero();
      }
    } else {
      game.camera.viewfinder.position = Vector2.zero();
    }
  }

  void triggerFireAnimation() {
    isAnimating = true;
    fireAnimationScale = 1.0;
  }
}

class EnhancedBulletComponent extends PositionComponent {
  final Vector2 direction;
  final BulletType bulletType;
  final Color color;
  final double speed = 500.0;
  late PositionComponent bulletVisuals;

  EnhancedBulletComponent({
    required Vector2 position,
    required this.direction,
    required this.bulletType,
    required this.color,
  }) : super(position: position, size: Vector2(12, 12));

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    bulletVisuals = PositionComponent();

    // Enhanced bullet with energy trail
    final energyField = CircleComponent(
      radius: 8,
      position: Vector2(6, 6),
      paint: Paint()..color = color.withOpacity(0.4),
      anchor: Anchor.center,
    );

    final coreEnergy = CircleComponent(
      radius: 5,
      position: Vector2(6, 6),
      paint: Paint()
        ..shader = RadialGradient(
          colors: [Colors.white, color, color.withOpacity(0.8)],
        ).createShader(const Rect.fromLTWH(0, 0, 10, 10)),
      anchor: Anchor.center,
    );

    bulletVisuals.add(energyField);
    bulletVisuals.add(coreEnergy);
    add(bulletVisuals);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += direction * speed * dt;

    // Animated energy effects
    final pulse = sin(DateTime.now().millisecondsSinceEpoch * 0.02) * 0.3 + 0.7;
    bulletVisuals.scale = Vector2.all(pulse);

    // Rotation for energy effect
    bulletVisuals.angle += dt * 5;
  }
}

class EnhancedBalloonComponent extends PositionComponent {
  final String word;
  final WordType wordType;
  final Color color;
  final int level;

  late TextComponent textComponent;
  late PositionComponent balloonVisuals;
  final double baseFallSpeed = 80.0;
  double floatOffset = 0.0;

  EnhancedBalloonComponent({
    required Vector2 position,
    required this.word,
    required this.wordType,
    required this.color,
    required this.level,
  }) : super(position: position, size: Vector2(80, 100));

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    balloonVisuals = PositionComponent();

    // Enhanced balloon with glow and modern design
    final balloonGlow = CircleComponent(
      radius: 38,
      position: Vector2(40, 40),
      paint: Paint()..color = color.withOpacity(0.3),
      anchor: Anchor.center,
    );

    final balloonBody = CircleComponent(
      radius: 32,
      position: Vector2(40, 40),
      paint: Paint()
        ..shader = RadialGradient(
          center: Alignment.topLeft,
          colors: [
            Colors.white.withOpacity(0.8),
            color,
            color.withOpacity(0.9),
            color.withOpacity(0.7),
          ],
          stops: const [0.0, 0.3, 0.8, 1.0],
        ).createShader(const Rect.fromLTWH(0, 0, 64, 64)),
      anchor: Anchor.center,
    );

    // Modern balloon string with gradient
    final balloonString = RectangleComponent(
      size: Vector2(2, 30),
      position: Vector2(39, 70),
      paint: Paint()
        ..shader = const LinearGradient(
          colors: [Colors.white70, Colors.transparent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(const Rect.fromLTWH(0, 0, 2, 30)),
    );

    // Enhanced word text with glow effect
    textComponent = TextComponent(
      text: word,
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
          shadows: [
            const Shadow(
              color: Color(0xCC000000),
              offset: Offset(1, 1),
              blurRadius: 3,
            ),
            Shadow(color: color, offset: const Offset(0, 0), blurRadius: 8),
          ],
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(40, 40),
    );

    balloonVisuals.add(balloonGlow);
    balloonVisuals.add(balloonBody);
    balloonVisuals.add(balloonString);
    add(balloonVisuals);
    add(textComponent);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Adaptive fall speed based on level
    final fallSpeed = baseFallSpeed + (level * 10);
    position.y += fallSpeed * dt;

    // Enhanced floating animation
    floatOffset += dt * 2;
    final floatX = sin(floatOffset) * 1.5;
    final floatScale = sin(floatOffset * 0.5) * 0.05 + 1.0;

    position.x += floatX * dt * 10;
    balloonVisuals.scale = Vector2.all(floatScale);

    // Subtle rotation
    balloonVisuals.angle = sin(floatOffset * 0.3) * 0.1;
  }
}

class EnhancedExplosionComponent extends PositionComponent {
  late Timer explosionTimer;
  final List<CircleComponent> particles = [];
  final Color explosionColor;
  final bool isAutoBurst;

  EnhancedExplosionComponent({
    required Vector2 position,
    required this.explosionColor,
    this.isAutoBurst = false,
  }) : super(position: position, size: Vector2(120, 120));

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final random = Random();
    final particleCount = isAutoBurst ? 20 : 15;

    // Create enhanced explosion particles
    for (int i = 0; i < particleCount; i++) {
      final angle = (i / particleCount) * 2 * pi;
      final distance = random.nextDouble() * 40 + 20;

      final particle = CircleComponent(
        radius: random.nextDouble() * 6 + 4,
        position: Vector2(cos(angle) * distance, sin(angle) * distance),
        paint: Paint()
          ..shader = RadialGradient(
            colors: [
              Colors.white,
              explosionColor,
              explosionColor.withOpacity(0.5),
              Colors.transparent,
            ],
          ).createShader(const Rect.fromLTWH(0, 0, 20, 20)),
      );

      particles.add(particle);
      add(particle);
    }

    explosionTimer = Timer(1.2, onTick: () => removeFromParent());
    explosionTimer.start();
  }

  @override
  void update(double dt) {
    super.update(dt);
    explosionTimer.update(dt);

    for (final particle in particles) {
      // Enhanced particle animation
      final scaleReduction = dt * 2;
      final currentScale = particle.scale.x - scaleReduction;
      particle.scale = Vector2.all(max(0.0, currentScale));

      // Particle movement
      final currentPos = particle.position;
      particle.position = currentPos + (currentPos.normalized() * dt * 50);

      if (particle.scale.x <= 0.1) {
        particle.removeFromParent();
      }
    }
  }
}

class ScorePopupComponent extends PositionComponent {
  final String text;
  late TextComponent textComponent;
  late Timer lifeTimer;
  double opacity = 1.0;

  ScorePopupComponent({required Vector2 position, required this.text})
    : super(position: position, size: Vector2(100, 50));

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final isPositive = text.startsWith('+');
    final color = isPositive
        ? const Color(0xFF00FF88)
        : const Color(0xFFFF4444);

    textComponent = TextComponent(
      text: text,
      textRenderer: TextPaint(
        style: TextStyle(
          color: color,
          fontSize: 20,
          fontWeight: FontWeight.w900,
          shadows: [
            Shadow(
              color: color.withOpacity(0.5),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
      ),
      anchor: Anchor.center,
    );

    add(textComponent);

    lifeTimer = Timer(1.5, onTick: () => removeFromParent());
    lifeTimer.start();
  }

  @override
  void update(double dt) {
    super.update(dt);
    lifeTimer.update(dt);

    // Float upward and fade
    position.y -= dt * 50;
    opacity -= dt * 0.8;

    if (opacity > 0) {
      textComponent.textRenderer = TextPaint(
        style: TextStyle(
          color: (textComponent.textRenderer as TextPaint).style.color!
              .withOpacity(opacity),
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
      );
    }
  }
}

class FloatingParticleComponent extends PositionComponent {
  late CircleComponent particle;
  double floatSpeed = 20.0;
  double floatOffset = 0.0;

  FloatingParticleComponent({required Vector2 position})
    : super(position: position, size: Vector2(4, 4));

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final random = Random();
    floatSpeed = random.nextDouble() * 30 + 10;
    floatOffset = random.nextDouble() * 2 * pi;

    particle = CircleComponent(
      radius: random.nextDouble() * 2 + 1,
      position: Vector2(2, 2),
      paint: Paint()..color = Colors.white.withOpacity(0.3),
      anchor: Anchor.center,
    );

    add(particle);
  }

  @override
  void update(double dt) {
    super.update(dt);

    floatOffset += dt;

    // Gentle floating movement
    position.y -= floatSpeed * dt;
    position.x += sin(floatOffset) * 20 * dt;

    // Pulse effect
    final pulse = sin(floatOffset * 2) * 0.3 + 0.7;
    particle.scale = Vector2.all(pulse);

    // Reset position when off screen
    if (position.y < -10) {
      final game = findGame();
      if (game != null) {
        position.y = game.size.y + 10;
        position.x = Random().nextDouble() * game.size.x;
      }
    }
  }
}

class BalloonGameApp extends StatelessWidget {
  const BalloonGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Modern Word Shooter',
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF00D4FF),
        scaffoldBackgroundColor: const Color(0xFF0D1B2A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1A2E),
          elevation: 0,
        ),
      ),
      home: const GameScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _showInstructions = true;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _fadeController.forward();

    // Hide instructions after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showInstructions = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Game Widget
          FadeTransition(
            opacity: _fadeAnimation,
            child: GameWidget(game: FallingBalloonsGame()),
          ),

          // Instructions Overlay
          if (_showInstructions)
            AnimatedOpacity(
              opacity: _showInstructions ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black.withOpacity(0.7),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF1A1A2E),
                          Color(0xFF16213E),
                          Color(0xFF0F3460),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF00D4FF).withOpacity(0.5),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00D4FF).withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '🎯 MODERN WORD SHOOTER',
                          style: TextStyle(
                            color: Color(0xFF00D4FF),
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            shadows: [
                              Shadow(
                                color: Color(0x8000D4FF),
                                offset: Offset(0, 2),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),

                        _buildInstruction(
                          '🔵 TAP LEFT THIRD OF SCREEN',
                          'To shoot NOUNS',
                          const Color(0xFF00D4FF),
                        ),
                        const SizedBox(height: 15),

                        _buildInstruction(
                          '🟢 TAP MIDDLE THIRD OF SCREEN',
                          'To shoot PRONOUNS',
                          const Color(0xFF00FF88),
                        ),
                        const SizedBox(height: 15),

                        _buildInstruction(
                          '🔴 TAP RIGHT THIRD OF SCREEN',
                          'To shoot VERBS',
                          const Color(0xFFFF6B6B),
                        ),
                        const SizedBox(height: 30),

                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          child: const Text(
                            '💡 AIM YOUR CANNONS!\nTap anywhere on screen - cannons will aim and fire towards your tap location!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _showInstructions = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00D4FF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 5,
                          ),
                          child: const Text(
                            'START GAME',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
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
    );
  }

  Widget _buildInstruction(String title, String subtitle, Color color) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
