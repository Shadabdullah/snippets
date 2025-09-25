import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'dart:math';

void main() {
  runApp(GameWidget(game: FallingBalloonsGame()));
}

enum WordType { noun, pronoun, verb }

enum BulletType { noun, pronoun, verb }

class FallingBalloonsGame extends FlameGame with TapDetector {
  late Timer balloonSpawnTimer;
  late ModernGunComponent nounGun;
  late ModernGunComponent pronounGun;
  late ModernGunComponent verbGun;
  int score = 0;
  int lives = 5;
  late TextComponent scoreText;
  late TextComponent livesText;
  late RectangleComponent gameBackground;

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
    ],
  };

  final Map<WordType, Color> wordTypeColors = {
    WordType.noun: const Color(0xFF4A90E2), // Modern blue
    WordType.pronoun: const Color(0xFF7ED321), // Modern green
    WordType.verb: const Color(0xFFD0021B), // Modern red
  };

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Modern gradient background
    gameBackground = RectangleComponent(
      size: size,
      paint: Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
        ).createShader(Rect.fromLTWH(0, 0, size.x, size.y)),
    );
    add(gameBackground);

    // Position three guns at the bottom
    final gunSpacing = size.x / 4;

    // Noun Gun (Blue)
    nounGun = ModernGunComponent(
      position: Vector2(gunSpacing - 30, size.y - 120),
      bulletType: BulletType.noun,
      label: 'NOUN',
      primaryColor: const Color(0xFF4A90E2),
      secondaryColor: const Color(0xFF357ABD),
    );
    add(nounGun);

    // Pronoun Gun (Green)
    pronounGun = ModernGunComponent(
      position: Vector2(gunSpacing * 2 - 30, size.y - 120),
      bulletType: BulletType.pronoun,
      label: 'PRONOUN',
      primaryColor: const Color(0xFF7ED321),
      secondaryColor: const Color(0xFF5BA91A),
    );
    add(pronounGun);

    // Verb Gun (Red)
    verbGun = ModernGunComponent(
      position: Vector2(gunSpacing * 3 - 30, size.y - 120),
      bulletType: BulletType.verb,
      label: 'VERB',
      primaryColor: const Color(0xFFD0021B),
      secondaryColor: const Color(0xFFA00015),
    );
    add(verbGun);

    // Modern UI elements
    final uiBackground = RectangleComponent(
      size: Vector2(size.x, 100),
      paint: Paint()..color = const Color(0xFF1a1a2e).withOpacity(0.9),
    );
    add(uiBackground);

    // Score display with modern styling
    scoreText = TextComponent(
      text: 'SCORE: $score',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
        ),
      ),
      position: Vector2(30, 35),
    );
    add(scoreText);

    // Lives display
    livesText = TextComponent(
      text: '❤️ $lives',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
      ),
      position: Vector2(size.x - 100, 35),
    );
    add(livesText);

    // Set up balloon spawning timer
    balloonSpawnTimer = Timer(
      1.8, // Spawn every 1.8 seconds
      onTick: spawnBalloon,
      repeat: true,
    );
    balloonSpawnTimer.start();
  }

  @override
  void update(double dt) {
    super.update(dt);
    balloonSpawnTimer.update(dt);

    // Check for balloons that reached gun level (auto-burst and lose life)
    final balloonsToRemove = <CleanBalloonComponent>[];
    for (final component in children) {
      if (component is CleanBalloonComponent) {
        if (component.position.y > size.y - 200) {
          // Balloon reached gun level - auto burst and lose life
          balloonsToRemove.add(component);
          lives--;
          livesText.text = '❤️ $lives';
          addExplosion(component.position, Colors.orange, isAutoBurst: true);

          if (lives <= 0) {
            // Game over logic could be added here
          }
        }
      }
    }

    for (final balloon in balloonsToRemove) {
      balloon.removeFromParent();
    }

    // Remove bullets that have gone off screen
    final bulletsToRemove = <ModernBulletComponent>[];
    for (final component in children) {
      if (component is ModernBulletComponent && component.position.y < -50) {
        bulletsToRemove.add(component);
      }
    }

    for (final bullet in bulletsToRemove) {
      bullet.removeFromParent();
    }

    // Check bullet-balloon collisions
    checkCollisions();
  }

  void checkCollisions() {
    final bullets = children.whereType<ModernBulletComponent>().toList();
    final balloons = children.whereType<CleanBalloonComponent>().toList();

    for (final bullet in bullets) {
      for (final balloon in balloons) {
        if (bullet.toRect().overlaps(balloon.toRect())) {
          bullet.removeFromParent();
          balloon.removeFromParent();

          // Check if bullet type matches balloon word type
          final bulletType = bullet.bulletType;
          final wordType = balloon.wordType;

          bool isCorrect =
              (bulletType == BulletType.noun && wordType == WordType.noun) ||
              (bulletType == BulletType.pronoun &&
                  wordType == WordType.pronoun) ||
              (bulletType == BulletType.verb && wordType == WordType.verb);

          if (isCorrect) {
            score += 25;
            addExplosion(balloon.position, const Color(0xFF00FF88));
          } else {
            score -= 15;
            if (score < 0) score = 0;
            addExplosion(balloon.position, const Color(0xFFFF4444));
          }

          scoreText.text = 'SCORE: $score';
          break;
        }
      }
    }
  }

  void addExplosion(Vector2 position, Color color, {bool isAutoBurst = false}) {
    final explosion = ModernExplosionComponent(
      position: position,
      explosionColor: color,
      isAutoBurst: isAutoBurst,
    );
    add(explosion);
  }

  void spawnBalloon() {
    final random = Random();
    final x = random.nextDouble() * (size.x - 80) + 40;

    final wordType = WordType.values[random.nextInt(WordType.values.length)];
    final words = wordsByType[wordType]!;
    final word = words[random.nextInt(words.length)];
    final color = wordTypeColors[wordType]!;

    final balloon = CleanBalloonComponent(
      position: Vector2(x, -100),
      word: word,
      wordType: wordType,
      color: color,
    );

    add(balloon);
  }

  @override
  bool onTapDown(TapDownInfo info) {
    final tapPosition = info.eventPosition.global;

    // Check which gun was tapped
    if (nounGun.containsPoint(tapPosition)) {
      fireFromGun(nounGun, tapPosition);
    } else if (pronounGun.containsPoint(tapPosition)) {
      fireFromGun(pronounGun, tapPosition);
    } else if (verbGun.containsPoint(tapPosition)) {
      fireFromGun(verbGun, tapPosition);
    }

    return true;
  }

  void fireFromGun(ModernGunComponent gun, Vector2 targetPosition) {
    gun.triggerFireAnimation();

    final gunCenter = gun.position + Vector2(30, 20);
    final direction = Vector2(0, -1); // Shoot straight up

    final bullet = ModernBulletComponent(
      position: gunCenter.clone(),
      direction: direction,
      bulletType: gun.bulletType,
      color: gun.primaryColor,
    );

    add(bullet);
  }
}

class ModernGunComponent extends PositionComponent {
  final BulletType bulletType;
  final String label;
  final Color primaryColor;
  final Color secondaryColor;
  late TextComponent labelComponent;
  late RectangleComponent gunBody;
  late RectangleComponent gunBarrel;
  late CircleComponent gunBase;
  double fireAnimationScale = 1.0;
  bool isAnimating = false;

  ModernGunComponent({
    required Vector2 position,
    required this.bulletType,
    required this.label,
    required this.primaryColor,
    required this.secondaryColor,
  }) : super(position: position, size: Vector2(60, 100));

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Gun base (circular)
    gunBase = CircleComponent(
      radius: 25,
      position: Vector2(30, 70),
      paint: Paint()
        ..shader = RadialGradient(
          colors: [primaryColor, secondaryColor],
        ).createShader(const Rect.fromLTWH(0, 0, 50, 50)),
      anchor: Anchor.center,
    );

    // Gun body (main part)
    gunBody = RectangleComponent(
      size: Vector2(20, 35),
      position: Vector2(20, 35),
      paint: Paint()
        ..shader = LinearGradient(
          colors: [primaryColor.withOpacity(0.9), secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(const Rect.fromLTWH(0, 0, 20, 35)),
    );

    // Gun barrel
    gunBarrel = RectangleComponent(
      size: Vector2(8, 25),
      position: Vector2(26, 10),
      paint: Paint()..color = const Color(0xFF2C2C2C),
    );

    // Label
    labelComponent = TextComponent(
      text: label,
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: primaryColor.withOpacity(0.8),
              offset: const Offset(0, 1),
              blurRadius: 2,
            ),
          ],
        ),
      ),
      anchor: Anchor.center,
    );

    add(gunBase);
    add(gunBody);
    add(gunBarrel);
    add(labelComponent);

    await labelComponent.loaded;
    labelComponent.position = Vector2(30, 85);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Fire animation
    if (isAnimating) {
      fireAnimationScale += dt * 15;
      if (fireAnimationScale > 1.2) {
        fireAnimationScale = 1.0;
        isAnimating = false;
      }
      scale = Vector2.all(fireAnimationScale);
    }
  }

  void triggerFireAnimation() {
    isAnimating = true;
    fireAnimationScale = 1.0;
  }
}

class ModernBulletComponent extends PositionComponent {
  final Vector2 direction;
  final BulletType bulletType;
  final Color color;
  final double speed = 400.0;
  late CircleComponent glowEffect;

  ModernBulletComponent({
    required Vector2 position,
    required this.direction,
    required this.bulletType,
    required this.color,
  }) : super(position: position, size: Vector2(8, 12));

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Glow effect
    glowEffect = CircleComponent(
      radius: 6,
      position: Vector2(4, 6),
      paint: Paint()..color = color.withOpacity(0.3),
      anchor: Anchor.center,
    );

    // Main bullet
    final bullet = CircleComponent(
      radius: 4,
      position: Vector2(4, 6),
      paint: Paint()
        ..shader = RadialGradient(
          colors: [Colors.white, color],
        ).createShader(const Rect.fromLTWH(0, 0, 8, 8)),
      anchor: Anchor.center,
    );

    add(glowEffect);
    add(bullet);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += direction * speed * dt;

    // Animate glow
    final pulse = sin(DateTime.now().millisecondsSinceEpoch * 0.01) * 0.5 + 0.5;
    glowEffect.scale = Vector2.all(1.0 + pulse * 0.3);
  }
}

class ModernExplosionComponent extends PositionComponent {
  late Timer explosionTimer;
  final List<Component> particles = [];
  final Color explosionColor;
  final bool isAutoBurst;

  ModernExplosionComponent({
    required Vector2 position,
    required this.explosionColor,
    this.isAutoBurst = false,
  }) : super(position: position, size: Vector2(80, 80));

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final random = Random();
    final particleCount = isAutoBurst ? 15 : 12;

    for (int i = 0; i < particleCount; i++) {
      final particle = CircleComponent(
        radius: random.nextDouble() * 5 + 3,
        position: Vector2(
          random.nextDouble() * 80 - 40,
          random.nextDouble() * 80 - 40,
        ),
        paint: Paint()
          ..shader = RadialGradient(
            colors: [explosionColor, explosionColor.withOpacity(0.3)],
          ).createShader(const Rect.fromLTWH(0, 0, 10, 10)),
      );
      particles.add(particle);
      add(particle);
    }

    explosionTimer = Timer(0.8, onTick: () => removeFromParent());
    explosionTimer.start();
  }

  @override
  void update(double dt) {
    super.update(dt);
    explosionTimer.update(dt);

    for (final particle in particles) {
      if (particle is CircleComponent) {
        particle.scale = Vector2.all(particle.scale.x * 0.92);
        if (particle.scale.x < 0.1) {
          particle.removeFromParent();
        }
      }
    }
  }
}

class CleanBalloonComponent extends PositionComponent {
  final String word;
  final WordType wordType;
  final Color color;
  late TextComponent textComponent;
  final double fallSpeed = 70.0;

  CleanBalloonComponent({
    required Vector2 position,
    required this.word,
    required this.wordType,
    required this.color,
  }) : super(position: position, size: Vector2(70, 90));

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Modern balloon with gradient
    final balloonBody = CircleComponent(
      radius: 32,
      position: Vector2(35, 35),
      paint: Paint()
        ..shader = RadialGradient(
          colors: [color.withOpacity(0.9), color, color.withOpacity(0.7)],
        ).createShader(const Rect.fromLTWH(0, 0, 64, 64)),
      anchor: Anchor.center,
    );

    // Subtle balloon string
    final balloonString = RectangleComponent(
      size: Vector2(1, 25),
      position: Vector2(34, 65),
      paint: Paint()..color = Colors.white.withOpacity(0.6),
    );

    // Word text (clean, no type label)
    textComponent = TextComponent(
      text: word,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          shadows: [
            Shadow(color: Colors.black26, offset: Offset(1, 1), blurRadius: 2),
          ],
        ),
      ),
      anchor: Anchor.center,
    );

    add(balloonBody);
    add(balloonString);
    add(textComponent);

    await textComponent.loaded;
    textComponent.position = Vector2(35, 35);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += fallSpeed * dt;

    // Gentle floating animation
    final float = sin(position.y * 0.005) * 1.2;
    position.x += float * dt;
  }
}

class BalloonGameApp extends StatelessWidget {
  const BalloonGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Modern Word Shooter',
      theme: ThemeData.dark().copyWith(primaryColor: const Color(0xFF4A90E2)),
      home: Scaffold(body: GameWidget(game: FallingBalloonsGame())),
      debugShowCheckedModeBanner: false,
    );
  }
}
