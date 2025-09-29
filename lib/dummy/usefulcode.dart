import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'XP Collection Animation',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: XPCollectionScreen(),
    );
  }
}

class XPCollectionScreen extends StatefulWidget {
  const XPCollectionScreen({super.key});

  @override
  _XPCollectionScreenState createState() => _XPCollectionScreenState();
}

class _XPCollectionScreenState extends State<XPCollectionScreen>
    with TickerProviderStateMixin {
  int xpCount = 0;
  List<StarAnimation> activeStars = [];
  late AnimationController _counterController;
  late Animation<double> _counterAnimation;
  final GlobalKey _buttonKey = GlobalKey();
  final GlobalKey _badgeKey = GlobalKey();

  // Custom icon options - you can change this to any IconData
  IconData customIcon = Icons.diamond; // Change this to any icon you want

  @override
  void initState() {
    super.initState();
    _counterController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );
    _counterAnimation = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(parent: _counterController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _counterController.dispose();
    for (var star in activeStars) {
      star.dispose();
    }
    super.dispose();
  }

  void _collectXP() {
    // Get button and badge positions
    RenderBox? buttonBox =
        _buttonKey.currentContext?.findRenderObject() as RenderBox?;
    RenderBox? badgeBox =
        _badgeKey.currentContext?.findRenderObject() as RenderBox?;

    if (buttonBox != null && badgeBox != null) {
      Offset buttonPosition = buttonBox.localToGlobal(Offset.zero);
      Size buttonSize = buttonBox.size;
      Offset badgePosition = badgeBox.localToGlobal(Offset.zero);
      Size badgeSize = badgeBox.size;

      // Calculate exact center positions
      Offset buttonCenter = Offset(
        buttonPosition.dx + buttonSize.width / 2,
        buttonPosition.dy + buttonSize.height / 2,
      );

      // Target the star icon in the badge (left side of badge)
      Offset badgeStarPosition = Offset(
        badgePosition.dx + 20, // Position of star icon in badge
        badgePosition.dy + badgeSize.height / 2,
      );

      // Create multiple stars
      int starCount = 14 + math.Random().nextInt(3); // 4-6 stars
      for (int i = 0; i < starCount; i++) {
        _createStar(buttonCenter, badgeStarPosition, i);
      }

      // Update XP count
      setState(() {
        xpCount += starCount;
      });

      // Animate counter
      _counterController.forward().then((_) {
        _counterController.reverse();
      });
    }
  }

  void _createStar(Offset startPosition, Offset endPosition, int index) {
    AnimationController controller = AnimationController(
      duration: Duration(milliseconds: 1000 + index * 120),
      vsync: this,
    );

    // Add randomness to start position for spread effect
    double randomAngle = math.Random().nextDouble() * 2 * math.pi;
    double randomDistance = 20 + math.Random().nextDouble() * 40;
    Offset actualStart = Offset(
      startPosition.dx + math.cos(randomAngle) * randomDistance,
      startPosition.dy + math.sin(randomAngle) * randomDistance,
    );

    StarAnimation star = StarAnimation(
      controller: controller,
      startPosition: actualStart,
      endPosition: endPosition,
      customIcon: customIcon,
      onComplete: () {
        setState(() {
          activeStars.removeWhere((s) => s.controller == controller);
        });
        controller.dispose();
      },
    );

    setState(() {
      activeStars.add(star);
    });

    // Stagger the animation start
    Future.delayed(Duration(milliseconds: index * 80), () {
      if (controller.isCompleted == false && controller.isDismissed) {
        controller.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Color(0xFF1a0d2e),
      appBar: AppBar(
        backgroundColor: Color(0xFF2d1b69),
        elevation: 0,
        title: Text(
          'XP Collector',
          style: TextStyle(
            color: Colors.white,
            fontSize: isTablet ? 24 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Container(
            key: _badgeKey,
            margin: EdgeInsets.only(right: 16, top: 8, bottom: 8),
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 16 : 12,
              vertical: isTablet ? 10 : 8,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF8e2de2), Color(0xFF4a00e0)],
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF8e2de2).withValues(alpha: 0.4),
                  blurRadius: 12,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, color: Colors.white, size: isTablet ? 24 : 20),
                SizedBox(width: 6),
                AnimatedBuilder(
                  animation: _counterAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _counterAnimation.value,
                      child: Text(
                        '$xpCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: isTablet ? 20 : 16,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1a0d2e),
                  Color(0xFF2d1b69),
                  Color(0xFF4a00e0),
                ],
              ),
            ),
          ),

          // Animated background particles
          ...List.generate(
            8,
            (index) => AnimatedPositioned(
              duration: Duration(seconds: 3 + index),
              left: (index * screenWidth / 8) + math.sin(index.toDouble()) * 50,
              top:
                  (index * screenHeight / 8) + math.cos(index.toDouble()) * 100,
              child: Opacity(
                opacity: 0.1,
                child: Icon(
                  customIcon,
                  size: isTablet ? 40 : 30,
                  color: Colors.purple,
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title
                    Text(
                      'Collect XP!',
                      style: TextStyle(
                        fontSize: isTablet ? 42 : 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 15,
                            color: Color(0xFF8e2de2).withValues(alpha: 0.6),
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.05),

                    // XP Info
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 30 : 20,
                        vertical: isTablet ? 15 : 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.purple.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Total XP: $xpCount',
                        style: TextStyle(
                          fontSize: isTablet ? 22 : 18,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.08),

                    // Collect button
                    GestureDetector(
                      key: _buttonKey,
                      onTap: _collectXP,
                      child: Container(
                        width: isTablet ? 150 : 120,
                        height: isTablet ? 150 : 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Color(0xFF8e2de2),
                              Color(0xFF4a00e0),
                              Color(0xFF2d1b69),
                            ],
                            stops: [0.0, 0.7, 1.0],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF8e2de2).withValues(alpha: 0.5),
                              blurRadius: 25,
                              spreadRadius: 8,
                            ),
                            BoxShadow(
                              color: Color(0xFF4a00e0).withValues(alpha: 0.3),
                              blurRadius: 40,
                              spreadRadius: 15,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            customIcon,
                            size: isTablet ? 50 : 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    // Instructions
                    Text(
                      'Tap to collect ${customIcon.codePoint == Icons.diamond.codePoint ? 'diamonds' : 'items'}!',
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        color: Colors.white60,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: screenHeight * 0.05),

                    // Icon selector (you can customize this part)
                    Container(
                      padding: EdgeInsets.all(isTablet ? 20 : 15),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.purple.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Choose Icon:',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: isTablet ? 16 : 14,
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildIconButton(Icons.diamond, isTablet),
                              _buildIconButton(Icons.star, isTablet),
                              _buildIconButton(Icons.favorite, isTablet),
                              _buildIconButton(Icons.flash_on, isTablet),
                              _buildIconButton(Icons.auto_awesome, isTablet),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Flying stars overlay
          ...activeStars.map((star) => StarWidget(star: star)),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, bool isTablet) {
    bool isSelected = customIcon == icon;
    return GestureDetector(
      onTap: () {
        setState(() {
          customIcon = icon;
        });
      },
      child: Container(
        padding: EdgeInsets.all(isTablet ? 12 : 8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? Color(0xFF8e2de2) : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? Colors.white
                : Colors.purple.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Icon(icon, color: Colors.white, size: isTablet ? 28 : 24),
      ),
    );
  }
}

class StarAnimation {
  final AnimationController controller;
  final Offset startPosition;
  final Offset endPosition;
  final IconData customIcon;
  final VoidCallback onComplete;
  late Animation<Offset> positionAnimation;
  late Animation<double> scaleAnimation;
  late Animation<double> opacityAnimation;
  late Animation<double> rotationAnimation;

  StarAnimation({
    required this.controller,
    required this.startPosition,
    required this.endPosition,
    required this.customIcon,
    required this.onComplete,
  }) {
    // Create curved path with control points for smooth arc
    positionAnimation = TweenSequence<Offset>([
      TweenSequenceItem(
        weight: 0.6,
        tween: Tween<Offset>(
          begin: startPosition,
          end: Offset(
            startPosition.dx + (endPosition.dx - startPosition.dx) * 0.3,
            startPosition.dy - 100, // Arc upward
          ),
        ),
      ),
      TweenSequenceItem(
        weight: 0.4,
        tween: Tween<Offset>(
          begin: Offset(
            startPosition.dx + (endPosition.dx - startPosition.dx) * 0.3,
            startPosition.dy - 100,
          ),
          end: endPosition,
        ),
      ),
    ]).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    // Scale animation
    scaleAnimation = Tween<double>(
      begin: 1.2,
      end: 0.6,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    // Opacity animation
    opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.8, 1.0, curve: Curves.easeOut),
      ),
    );

    // Rotation animation for fun effect
    rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.linear));

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        onComplete();
      }
    });
  }

  void dispose() {
    controller.dispose();
  }
}

class StarWidget extends StatelessWidget {
  final StarAnimation star;

  const StarWidget({super.key, required this.star});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: star.controller,
      builder: (context, child) {
        return Positioned(
          left: star.positionAnimation.value.dx - 20,
          top: star.positionAnimation.value.dy - 20,
          child: Transform.scale(
            scale: star.scaleAnimation.value,
            child: Transform.rotate(
              angle: star.rotationAnimation.value,
              child: Opacity(
                opacity: star.opacityAnimation.value,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Color(0xFF8e2de2), Color(0xFF4a00e0)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF8e2de2).withValues(alpha: 0.6),
                        blurRadius: 15,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(star.customIcon, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
