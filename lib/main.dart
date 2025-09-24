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
  late AnimatedGunComponent gun;
  int score = 0;
  late TextComponent scoreText;
  late TextComponent instructionText;
  BulletType currentBulletType = BulletType.noun;

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
    WordType.noun: Colors.blue,
    WordType.pronoun: Colors.green,
    WordType.verb: Colors.red,
  };

  final Map<BulletType, Color> bulletTypeColors = {
    BulletType.noun: Colors.blue,
    BulletType.pronoun: Colors.green,
    BulletType.verb: Colors.red,
  };

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Add animated gun at the bottom center
    gun = AnimatedGunComponent(
      position: Vector2(size.x / 2 - 30, size.y - 100),
      onBulletTypeChanged: (newType) {
        currentBulletType = newType;
      },
    );
    add(gun);

    // Add score display
    scoreText = TextComponent(
      text: 'Score: $score',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(20, 50),
    );
    add(scoreText);

    // Add instruction text
    instructionText = TextComponent(
      text: 'Current Bullet: NOUN',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.yellow,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(20, 80),
    );
    add(instructionText);

    // Set up balloon spawning timer
    balloonSpawnTimer = Timer(
      2.0, // Spawn every 2 seconds
      onTick: spawnBalloon,
      repeat: true,
    );
    balloonSpawnTimer.start();
  }

  @override
  void update(double dt) {
    super.update(dt);
    balloonSpawnTimer.update(dt);

    // Update instruction text
    instructionText.text =
        'Current Bullet: ${currentBulletType.name.toUpperCase()}';

    // Remove balloons that have fallen off screen
    final balloonsToRemove = <WordBalloonComponent>[];
    for (final component in children) {
      if (component is WordBalloonComponent &&
          component.position.y > size.y + 100) {
        balloonsToRemove.add(component);
      }
    }

    for (final balloon in balloonsToRemove) {
      balloon.removeFromParent();
    }

    // Remove bullets that have gone off screen
    final bulletsToRemove = <TypedBulletComponent>[];
    for (final component in children) {
      if (component is TypedBulletComponent && component.position.y < -50) {
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
    final bullets = children.whereType<TypedBulletComponent>().toList();
    final balloons = children.whereType<WordBalloonComponent>().toList();

    for (final bullet in bullets) {
      for (final balloon in balloons) {
        if (bullet.toRect().overlaps(balloon.toRect())) {
          // Collision detected
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
            // Correct match - increase score
            score += 20;
            addExplosion(balloon.position, Colors.green);
          } else {
            // Wrong match - decrease score
            score -= 10;
            if (score < 0) score = 0; // Don't go below 0
            addExplosion(balloon.position, Colors.red);
          }

          scoreText.text = 'Score: $score';
          break;
        }
      }
    }
  }

  void addExplosion(Vector2 position, Color color) {
    final explosion = ExplosionComponent(
      position: position,
      explosionColor: color,
    );
    add(explosion);
  }

  void spawnBalloon() {
    final random = Random();
    final x = random.nextDouble() * (size.x - 100) + 50;

    // Randomly select word type
    final wordType = WordType.values[random.nextInt(WordType.values.length)];
    final words = wordsByType[wordType]!;
    final word = words[random.nextInt(words.length)];
    final color = wordTypeColors[wordType]!;

    final balloon = WordBalloonComponent(
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

    // Fire bullet towards tap position
    fireBullet(tapPosition);
    return true;
  }

  void fireBullet(Vector2 targetPosition) {
    final gunPosition = gun.position + Vector2(30, 10); // Center of gun
    final direction = (targetPosition - gunPosition).normalized();

    final bullet = TypedBulletComponent(
      position: gunPosition.clone(),
      direction: direction,
      bulletType: currentBulletType,
    );

    add(bullet);
  }
}

class AnimatedGunComponent extends PositionComponent {
  final Function(BulletType) onBulletTypeChanged;
  late Timer rotationTimer;
  BulletType currentType = BulletType.noun;
  double rotationAngle = 0;
  late RectangleComponent gunBarrel;
  late CircleComponent bulletIndicator;

  AnimatedGunComponent({
    required Vector2 position,
    required this.onBulletTypeChanged,
  }) : super(position: position, size: Vector2(60, 80));

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Gun base
    final gunBase = RectangleComponent(
      size: Vector2(40, 25),
      position: Vector2(10, 50),
      paint: Paint()..color = Colors.brown[800]!,
    );

    // Gun barrel (will be rotated)
    gunBarrel = RectangleComponent(
      size: Vector2(10, 40),
      position: Vector2(25, 10),
      paint: Paint()..color = Colors.grey[700]!,
      anchor: Anchor.center,
    );

    // Bullet type indicator
    bulletIndicator = CircleComponent(
      radius: 8,
      position: Vector2(30, 60),
      paint: Paint()..color = Colors.blue, // Start with noun (blue)
    );

    add(gunBase);
    add(gunBarrel);
    add(bulletIndicator);

    // Set up rotation timer to change bullet types
    rotationTimer = Timer(
      3.0, // Change bullet type every 3 seconds
      onTick: changeBulletType,
      repeat: true,
    );
    rotationTimer.start();
  }

  @override
  void update(double dt) {
    super.update(dt);
    rotationTimer.update(dt);

    // Animate gun barrel rotation
    rotationAngle += dt * 2; // Slow rotation
    gunBarrel.angle = sin(rotationAngle) * 0.3; // Slight swaying motion
  }

  void changeBulletType() {
    // Cycle through bullet types
    switch (currentType) {
      case BulletType.noun:
        currentType = BulletType.pronoun;
        bulletIndicator.paint.color = Colors.green;
        break;
      case BulletType.pronoun:
        currentType = BulletType.verb;
        bulletIndicator.paint.color = Colors.red;
        break;
      case BulletType.verb:
        currentType = BulletType.noun;
        bulletIndicator.paint.color = Colors.blue;
        break;
    }

    onBulletTypeChanged(currentType);
  }
}

class TypedBulletComponent extends PositionComponent {
  final Vector2 direction;
  final BulletType bulletType;
  final double speed = 350.0;

  TypedBulletComponent({
    required Vector2 position,
    required this.direction,
    required this.bulletType,
  }) : super(position: position, size: Vector2(6, 10));

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final bulletColors = {
      BulletType.noun: Colors.blue,
      BulletType.pronoun: Colors.green,
      BulletType.verb: Colors.red,
    };

    final bullet = CircleComponent(
      radius: 3,
      position: Vector2(0, 0),
      paint: Paint()..color = bulletColors[bulletType]!,
    );

    add(bullet);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += direction * speed * dt;
  }
}

class ExplosionComponent extends PositionComponent {
  late Timer explosionTimer;
  final List<CircleComponent> particles = [];
  final Color explosionColor;

  ExplosionComponent({required Vector2 position, required this.explosionColor})
    : super(position: position, size: Vector2(60, 60));

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Create explosion particles
    final random = Random();
    for (int i = 0; i < 10; i++) {
      final particle = CircleComponent(
        radius: random.nextDouble() * 4 + 2,
        position: Vector2(
          random.nextDouble() * 60 - 30,
          random.nextDouble() * 60 - 30,
        ),
        paint: Paint()..color = explosionColor.withOpacity(0.8),
      );
      particles.add(particle);
      add(particle);
    }

    // Remove explosion after short time
    explosionTimer = Timer(0.6, onTick: () => removeFromParent());
    explosionTimer.start();
  }

  @override
  void update(double dt) {
    super.update(dt);
    explosionTimer.update(dt);

    // Animate particles
    for (final particle in particles) {
      particle.scale = Vector2.all(particle.scale.x * 0.94);
      if (particle.scale.x < 0.1) {
        particle.removeFromParent();
      }
    }
  }
}

class WordBalloonComponent extends PositionComponent {
  final String word;
  final WordType wordType;
  final Color color;
  late TextComponent textComponent;
  final double fallSpeed = 60.0;

  WordBalloonComponent({
    required Vector2 position,
    required this.word,
    required this.wordType,
    required this.color,
  }) : super(position: position, size: Vector2(90, 110));

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Create the balloon shape with word type color
    final balloonBody = CircleComponent(
      radius: 40,
      position: Vector2(5, 10),
      paint: Paint()..color = color,
    );

    // Balloon string
    final balloonString = RectangleComponent(
      size: Vector2(2, 35),
      position: Vector2(44, 85),
      paint: Paint()..color = Colors.black,
    );

    // Word label on balloon
    textComponent = TextComponent(
      text: word,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    // Word type label (small)
    final typeLabel = TextComponent(
      text: wordType.name.toUpperCase(),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.yellow,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    add(balloonBody);
    add(balloonString);
    add(textComponent);
    add(typeLabel);

    // Position text after adding to get proper size
    await textComponent.loaded;
    await typeLabel.loaded;

    textComponent.position = Vector2(
      45 - textComponent.size.x / 2,
      40 - textComponent.size.y / 2,
    );

    typeLabel.position = Vector2(45 - typeLabel.size.x / 2, 55);
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Make balloon fall down
    position.y += fallSpeed * dt;

    // Add slight horizontal wobble
    final wobble = sin(position.y * 0.008) * 0.8;
    position.x += wobble;
  }
}

// Alternative main function with proper Flutter app structure
class BalloonGameApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Word Type Balloon Shooter',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(body: GameWidget(game: FallingBalloonsGame())),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Use this main function for a complete Flutter app
// void main() {
//   runApp(BalloonGameApp());
// }
