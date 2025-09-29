import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'XP Collection Animation',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const XPCollectionScreen(),
    );
  }
}

class XPCollectionScreen extends StatefulWidget {
  const XPCollectionScreen({super.key});

  @override
  State<XPCollectionScreen> createState() => _XPCollectionScreenState();
}

class _XPCollectionScreenState extends State<XPCollectionScreen>
    with TickerProviderStateMixin {
  int xpCount = 0;
  List<StarAnimation> activeStars = [];
  late AnimationController _counterController;
  late Animation<double> _counterAnimation;
  final GlobalKey _buttonKey = GlobalKey();
  final GlobalKey _starIconKey = GlobalKey();

  IconData customIcon = Icons.diamond;

  @override
  void initState() {
    super.initState();
    _counterController = AnimationController(
      duration: const Duration(milliseconds: 400),
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
    RenderBox? buttonBox =
        _buttonKey.currentContext?.findRenderObject() as RenderBox?;
    RenderBox? starIconBox =
        _starIconKey.currentContext?.findRenderObject() as RenderBox?;
    RenderBox? stackBox =
        context.findRenderObject() as RenderBox?; // root Stack box

    if (buttonBox != null && starIconBox != null && stackBox != null) {
      // global positions
      Offset buttonPosition = buttonBox.localToGlobal(Offset.zero);
      Offset starIconPosition = starIconBox.localToGlobal(Offset.zero);

      // convert to stack-local positions
      Offset buttonCenter = stackBox.globalToLocal(
        buttonPosition +
            Offset(buttonBox.size.width / 2, buttonBox.size.height / 2),
      );
      Offset starIconCenter = stackBox.globalToLocal(
        starIconPosition +
            Offset(starIconBox.size.width / 2, starIconBox.size.height / 2),
      );

      int starCount = 4 + math.Random().nextInt(3);
      for (int i = 0; i < starCount; i++) {
        _createStar(buttonCenter, starIconCenter, i);
      }

      setState(() => xpCount += starCount);

      _counterController.forward().then((_) => _counterController.reverse());
    }
  }

  void _createStar(Offset startPosition, Offset endPosition, int index) {
    AnimationController controller = AnimationController(
      duration: Duration(milliseconds: 1000 + index * 120),
      vsync: this,
    );

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

    Future.delayed(Duration(milliseconds: index * 80), () {
      if (controller.isDismissed) {
        controller.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFF1a0d2e),
          appBar: AppBar(
            backgroundColor: const Color(0xFF2d1b69),
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
                margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 16 : 12,
                  vertical: isTablet ? 10 : 8,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8e2de2), Color(0xFF4a00e0)],
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star,
                      key: _starIconKey,
                      color: Colors.white,
                      size: isTablet ? 24 : 20,
                    ),
                    const SizedBox(width: 6),
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
          body: SafeArea(
            child: Center(
              child: GestureDetector(
                key: _buttonKey,
                onTap: _collectXP,
                child: Container(
                  width: isTablet ? 150 : 120,
                  height: isTablet ? 150 : 120,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Color(0xFF8e2de2),
                        Color(0xFF4a00e0),
                        Color(0xFF2d1b69),
                      ],
                      stops: [0.0, 0.7, 1.0],
                    ),
                  ),
                  child: Icon(
                    customIcon,
                    size: isTablet ? 50 : 40,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),

        // ⭐ flying stars overlay
        ...activeStars.map((star) => StarWidget(star: star)),
      ],
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
    positionAnimation = TweenSequence<Offset>([
      TweenSequenceItem(
        weight: 0.6,
        tween: Tween<Offset>(
          begin: startPosition,
          end: Offset(
            startPosition.dx + (endPosition.dx - startPosition.dx) * 0.3,
            startPosition.dy - 100,
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

    scaleAnimation = Tween<double>(
      begin: 1.2,
      end: 0.6,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.8, 1.0, curve: Curves.easeOut),
      ),
    );

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
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Color(0xFF8e2de2), Color(0xFF4a00e0)],
                    ),
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



import 'package:arabicvocab/core/constants/app_theme.dart';
import 'package:arabicvocab/features/vocabulary/verbs/presentation/controllers/quiz_controller.dart';
import 'package:arabicvocab/features/vocabulary/verbs/presentation/controllers/timer_controller.dart';
import 'package:arabicvocab/features/vocabulary/verbs/presentation/pages/quiz/widgets/quiz_container.dart';
import 'package:arabicvocab/injection/verbs_injections.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class VerbsQuizScreen extends StatefulWidget {
  final int progressIndex;

  const VerbsQuizScreen({super.key, required this.progressIndex});

  @override
  State<VerbsQuizScreen> createState() => _VerbsQuizScreenState();
}

class _VerbsQuizScreenState extends State<VerbsQuizScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _questionController;
  late AnimationController _progressController;

  late Animation<double> _headerAnimation;
  late Animation<Offset> _questionSlideAnimation;
  late Animation<double> _questionFadeAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _questionController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _headerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutBack,
    ));

    _questionSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _questionController,
      curve: Curves.elasticOut,
    ));

    _questionFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _questionController,
      curve: Curves.easeIn,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _questionController.forward();
        _progressController.forward();
      }
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _questionController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _animateQuestionTransition() {
    _questionController.reset();
    _questionController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final quizController = Get.find<QuizController>(tag: VerbTags.verb);
    final timeController = Get.find<TimeController>(tag: VerbTags.verb);

    return PopScope(
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        _cancelTest(didPop);
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: AnimatedBuilder(
            animation: _headerAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _headerAnimation.value,
                child: _buildModernAppBar(context, quizController),
              );
            },
          ),
        ),
        body: Obx(() {
          final currentQuestion = quizController
              .quizQuestions[quizController.currentQuestionIndex.value];

          return Column(
            children: [
              const SizedBox(height: 140), // Space for app bar
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        _buildQuestionCard(
                            context, currentQuestion, quizController),
                        const SizedBox(height: 32),
                        _buildAnswerOptions(currentQuestion, quizController),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
              _buildBottomAction(context, quizController),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildModernAppBar(
      BuildContext context, QuizController quizController) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.primaryContainer.withOpacity(0.8),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            children: [
              // Header with question counter
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  Obx(() {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${quizController.currentQuestionIndex.value + 1} / ${quizController.quizQuestions.length}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                      ),
                    );
                  }),
                  const SizedBox(width: 48), // Balance for back button
                ],
              ),

              const SizedBox(height: 16),

              // Animated Progress Bar
              Obx(() {
                final progress =
                    (quizController.currentQuestionIndex.value + 1) /
                        quizController.quizQuestions.length;

                return AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Stack(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                            width: MediaQuery.of(context).size.width *
                                0.8 *
                                progress *
                                _progressAnimation.value,
                            height: 8,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.surface,
                                  AppColors.surface.withOpacity(0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.surface.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(BuildContext context, var currentQuestion,
      QuizController quizController) {
    return SlideTransition(
      position: _questionSlideAnimation,
      child: FadeTransition(
        opacity: _questionFadeAnimation,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            children: [
              // Question type indicator
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Obx(() {
                  return Text(
                    quizController.optionType.value == "english"
                        ? "Choose Arabic"
                        : "Choose English",
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                  );
                }),
              ),

              const SizedBox(height: 20),

              // Question text
              Obx(() {
                return Directionality(
                  textDirection:
                      _getTextDirection(currentQuestion.questionWord),
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: quizController.optionType.value == "english"
                        ? Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: AppColors.primaryDark,
                                  fontWeight: FontWeight.bold,
                                  height: 1.3,
                                ) ??
                            TextStyle(color: AppColors.primaryDark)
                        : Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: AppColors.primaryDark,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 28,
                                  height: 1.4,
                                ) ??
                            TextStyle(color: AppColors.primaryDark),
                    child: Text(
                      currentQuestion.questionWord,
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerOptions(
      var currentQuestion, QuizController quizController) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: currentQuestion.answerOptions.length,
      itemBuilder: (context, index) {
        return TestContainerWidget(
          optionType: quizController.optionType.value,
          questionId: currentQuestion.questionId,
          currentIndex: index,
          correctAnswer: currentQuestion.correctAnswer,
          answerOption: currentQuestion.answerOptions[index],
        );
      },
    );
  }

  Widget _buildBottomAction(
      BuildContext context, QuizController quizController) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Add haptic feedback
              HapticFeedback.mediumImpact();

              // Restart functionality
              quizController.resetQuiz();
              Get.find<TimeController>(tag: VerbTags.verb).startTimer();

              // Restart animations
              _questionController.reset();
              _questionController.forward();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 8,
              shadowColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 18),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.refresh_rounded,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'RESTART QUIZ',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: Colors.white,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextDirection _getTextDirection(String text) {
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    return arabicRegex.hasMatch(text) ? TextDirection.rtl : TextDirection.ltr;
  }

  void _cancelTest(bool didPop) {
    final timeController = Get.find<TimeController>(tag: VerbTags.verb);
    timeController.stopTimer();
  }
}
