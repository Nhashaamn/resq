import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:resq/core/theme/app_theme.dart';
import 'package:resq/features/func/presentation/widgets/appbar.dart';

class EarthQuackGuide extends StatefulWidget {
  const EarthQuackGuide({super.key});

  @override
  State<EarthQuackGuide> createState() => _EarthQuackGuideState();
}

class _EarthQuackGuideState extends State<EarthQuackGuide> {
  int? selectedAnswerIndex;
  int currentQuestionIndex = 0;
  int correctAnswers = 0;
  bool showResult = false;
  bool quizStarted = false;

  final List<QuizQuestion> questions = [
    QuizQuestion(
      question: 'What is the first thing you should do when an earthquake starts?',
      options: [
        'Run outside immediately',
        'Drop, Cover, and Hold On',
        'Stand in a doorway',
        'Call emergency services',
      ],
      correctAnswer: 1,
      explanation: 'The "Drop, Cover, and Hold On" technique is the recommended safety procedure during an earthquake.',
    ),
    QuizQuestion(
      question: 'If you are indoors during an earthquake, you should:',
      options: [
        'Run outside as fast as possible',
        'Stay inside and get under a sturdy desk or table',
        'Stand near windows to see what\'s happening',
        'Use the elevator to get to the ground floor',
      ],
      correctAnswer: 1,
      explanation: 'Stay inside and take cover under sturdy furniture. Running outside can expose you to falling debris.',
    ),
    QuizQuestion(
      question: 'What should you do if you are in a vehicle during an earthquake?',
      options: [
        'Drive quickly to find a safe place',
        'Pull over, stop, and stay in the vehicle',
        'Get out and run to a building',
        'Drive under a bridge for protection',
      ],
      correctAnswer: 1,
      explanation: 'Pull over to a safe location, stop the vehicle, and stay inside until the shaking stops.',
    ),
    QuizQuestion(
      question: 'After an earthquake, you should immediately:',
      options: [
        'Use your phone to call everyone you know',
        'Check for gas leaks and turn off utilities if needed',
        'Enter damaged buildings to retrieve belongings',
        'Drive around to assess the damage',
      ],
      correctAnswer: 1,
      explanation: 'Check for gas leaks and turn off utilities if damaged. Use phones only for emergencies.',
    ),
    QuizQuestion(
      question: 'What should you do if you smell gas after an earthquake?',
      options: [
        'Light a match to check if it\'s really gas',
        'Turn off the main gas valve and leave immediately',
        'Open all windows and stay inside',
        'Call a plumber',
      ],
      correctAnswer: 1,
      explanation: 'If you smell gas, turn off the main valve and evacuate immediately. Do not use any electrical switches or flames.',
    ),
    QuizQuestion(
      question: 'The safest place to be during an earthquake if you are outdoors is:',
      options: [
        'Near tall buildings',
        'Under a tree',
        'In an open area away from buildings and power lines',
        'Next to a streetlight',
      ],
      correctAnswer: 2,
      explanation: 'Move to an open area away from buildings, trees, streetlights, and utility wires.',
    ),
  ];

  void _startQuiz() {
    setState(() {
      quizStarted = true;
      currentQuestionIndex = 0;
      correctAnswers = 0;
      selectedAnswerIndex = null;
      showResult = false;
    });
  }

  void _selectAnswer(int index) {
    if (showResult) return;
    setState(() {
      selectedAnswerIndex = index;
    });
  }

  void _submitAnswer() {
    if (selectedAnswerIndex == null) return;
    
    setState(() {
      showResult = true;
      if (selectedAnswerIndex == questions[currentQuestionIndex].correctAnswer) {
        correctAnswers++;
      }
    });
  }

  void _nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedAnswerIndex = null;
        showResult = false;
      });
    } else {
      _showFinalScore();
    }
  }

  void _showFinalScore() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              correctAnswers == questions.length
                  ? Icons.celebration_rounded
                  : correctAnswers >= questions.length / 2
                      ? Icons.check_circle_rounded
                      : Icons.school_rounded,
              color: correctAnswers == questions.length
                  ? AppTheme.successGreen
                  : AppTheme.primary,
              size: 32,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Quiz Complete!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You got $correctAnswers out of ${questions.length} correct!',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              correctAnswers == questions.length
                  ? 'Perfect! You\'re well prepared! 🎉'
                  : correctAnswers >= questions.length / 2
                      ? 'Good job! Keep learning! 👍'
                      : 'Keep studying the guide to stay safe! 📚',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startQuiz();
            },
            child: const Text('Retake Quiz'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                quizStarted = false;
                currentQuestionIndex = 0;
                correctAnswers = 0;
                selectedAnswerIndex = null;
                showResult = false;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: AppTheme.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppbarWidget(
        title: 'Earthquake Guide',
        leadingIcon: Icons.arrow_back_ios_new_rounded,
        onLeadingTap: () => context.go('/home'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with gradient effect
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primary.withOpacity(0.1),
                    AppTheme.secendory.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.warning_amber_rounded,
                          color: AppTheme.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
            Text(
              'Earthquake Safety Guide',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Learn how to protect yourself and your loved ones',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Quiz Section
            if (!quizStarted)
              _buildQuizCard()
            else
              _buildQuizInterface(),
            
            if (!quizStarted) const SizedBox(height: 24),
            
            // During an Earthquake Section
            _buildSectionCard(
              icon: Icons.warning_amber_rounded,
              iconColor: AppTheme.errorRed,
              title: 'During an Earthquake',
              gradient: LinearGradient(
                colors: [
                  AppTheme.errorRed.withOpacity(0.1),
                  AppTheme.errorRed.withOpacity(0.05),
                ],
              ),
              children: [
                _buildStepItem(
                  number: '1',
                  title: 'DROP',
                  description: 'Drop down to your hands and knees immediately.',
                ),
                const SizedBox(height: 12),
                _buildStepItem(
                  number: '2',
                  title: 'COVER',
                  description: 'Cover your head and neck with your arms. If possible, crawl under a sturdy desk or table.',
                ),
                const SizedBox(height: 12),
                _buildStepItem(
                  number: '3',
                  title: 'HOLD ON',
                  description: 'Hold on to your shelter until the shaking stops. Be prepared to move with it if it shifts.',
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // If Indoors Section
            _buildSectionCard(
              icon: Icons.home_rounded,
              iconColor: AppTheme.primary,
              title: 'If You Are Indoors',
              gradient: LinearGradient(
                colors: [
                  AppTheme.primary.withOpacity(0.1),
                  AppTheme.primary.withOpacity(0.05),
                ],
              ),
              children: [
                _buildBulletPoint('Stay inside. Do not run outside during shaking.'),
                _buildBulletPoint('Stay away from windows, glass, and exterior walls.'),
                _buildBulletPoint('Get under a sturdy desk, table, or bed.'),
                _buildBulletPoint('If no shelter is available, crouch in an inside corner of the building.'),
                _buildBulletPoint('Do not use elevators.'),
                _buildBulletPoint('If you are in bed, stay there and protect your head with a pillow.'),
              ],
            ),
            const SizedBox(height: 16),
            
            // If Outdoors Section
            _buildSectionCard(
              icon: Icons.park_rounded,
              iconColor: AppTheme.successGreen,
              title: 'If You Are Outdoors',
              gradient: LinearGradient(
                colors: [
                  AppTheme.successGreen.withOpacity(0.1),
                  AppTheme.successGreen.withOpacity(0.05),
                ],
              ),
              children: [
                _buildBulletPoint('Move away from buildings, streetlights, and utility wires.'),
                _buildBulletPoint('Find an open area and stay there until shaking stops.'),
                _buildBulletPoint('Avoid areas near cliffs, slopes, or unstable ground.'),
                _buildBulletPoint('If you are near a tall building, get away from it immediately.'),
                _buildBulletPoint('Do not enter damaged buildings.'),
              ],
            ),
            const SizedBox(height: 16),
            
            // If in Vehicle Section
            _buildSectionCard(
              icon: Icons.directions_car_rounded,
              iconColor: AppTheme.primary,
              title: 'If You Are in a Vehicle',
              gradient: LinearGradient(
                colors: [
                  AppTheme.primary.withOpacity(0.1),
                  AppTheme.secendory.withOpacity(0.05),
                ],
              ),
              children: [
                _buildBulletPoint('Pull over to a safe location away from overpasses, bridges, and power lines.'),
                _buildBulletPoint('Stay inside the vehicle until shaking stops.'),
                _buildBulletPoint('Set the parking brake.'),
                _buildBulletPoint('Avoid stopping near or under buildings, trees, or utility wires.'),
                _buildBulletPoint('Once shaking stops, proceed cautiously and watch for road damage.'),
              ],
            ),
            const SizedBox(height: 16),
            
            // After the Earthquake Section
            _buildSectionCard(
              icon: Icons.check_circle_rounded,
              iconColor: AppTheme.successGreen,
              title: 'After the Earthquake',
              gradient: LinearGradient(
                colors: [
                  AppTheme.successGreen.withOpacity(0.1),
                  AppTheme.successGreen.withOpacity(0.05),
                ],
              ),
              children: [
                _buildBulletPoint('Check yourself and others for injuries. Provide first aid if needed.'),
                _buildBulletPoint('Check for gas leaks. If you smell gas, turn off the main valve and leave immediately.'),
                _buildBulletPoint('Check for electrical damage. Turn off electricity at the main fuse box if you see sparks.'),
                _buildBulletPoint('Check water lines. Turn off water supply if pipes are damaged.'),
                _buildBulletPoint('Use the phone only for emergencies.'),
                _buildBulletPoint('Stay away from damaged areas and buildings.'),
                _buildBulletPoint('Be prepared for aftershocks. They can occur minutes, hours, or days later.'),
                _buildBulletPoint('Listen to a battery-operated radio for emergency information.'),
              ],
            ),
            const SizedBox(height: 16),
            
            // Emergency Kit Section
            _buildSectionCard(
              icon: Icons.emergency_rounded,
              iconColor: AppTheme.primary,
              title: 'Prepare an Emergency Kit',
              gradient: LinearGradient(
                colors: [
                  AppTheme.primary.withOpacity(0.1),
                  AppTheme.secendory.withOpacity(0.05),
                ],
              ),
              children: [
                _buildBulletPoint('Water: At least 1 gallon per person per day for 3 days'),
                _buildBulletPoint('Non-perishable food: 3-day supply'),
                _buildBulletPoint('Flashlight with extra batteries'),
                _buildBulletPoint('First aid kit'),
                _buildBulletPoint('Whistle to signal for help'),
                _buildBulletPoint('Dust masks and plastic sheeting'),
                _buildBulletPoint('Wrench or pliers to turn off utilities'),
                _buildBulletPoint('Battery-powered or hand-crank radio'),
                _buildBulletPoint('Important documents in a waterproof container'),
              ],
            ),
            const SizedBox(height: 24),
            
            // Important Reminder
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.warningYellow.withOpacity(0.4),
                    AppTheme.warningYellow.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.warningYellow.withOpacity(0.6),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.warningYellow.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, color: AppTheme.textPrimary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Remember: Most earthquake-related injuries occur from falling objects and debris, not from building collapse. Protect your head and stay away from windows and heavy furniture.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required List<Widget> children,
    Gradient? gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? AppTheme.backgroundWhite : null,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.borderLight.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: iconColor.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required String number,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.8)],
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: AppTheme.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 4),
            Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 7, right: 14),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.7)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withOpacity(0.15),
            AppTheme.secendory.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primary.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.2),
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
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.quiz_rounded,
                  color: AppTheme.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Test Your Knowledge',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${questions.length} questions to check your earthquake safety knowledge',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.backgroundWhite.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    color: AppTheme.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Answer questions correctly to test your understanding of earthquake safety procedures.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _startQuiz,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                shadowColor: AppTheme.primary.withOpacity(0.4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Start Quiz',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizInterface() {
    final currentQuestion = questions[currentQuestionIndex];
    final isCorrect = selectedAnswerIndex != null &&
        selectedAnswerIndex == currentQuestion.correctAnswer;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.backgroundWhite,
            AppTheme.backgroundLight,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.borderLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress indicator
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Question ${currentQuestionIndex + 1} of ${questions.length}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        Text(
                          'Score: $correctAnswers/${currentQuestionIndex}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (currentQuestionIndex + 1) / questions.length,
                        backgroundColor: AppTheme.borderLight,
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Question
          Text(
            currentQuestion.question,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          
          // Options
          ...List.generate(
            currentQuestion.options.length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildOptionButton(
                index: index,
                option: currentQuestion.options[index],
                isSelected: selectedAnswerIndex == index,
                isCorrect: showResult && index == currentQuestion.correctAnswer,
                isWrong: showResult &&
                    selectedAnswerIndex == index &&
                    index != currentQuestion.correctAnswer,
              ),
            ),
          ),
          
          // Explanation (shown after answer)
          if (showResult) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (isCorrect
                        ? AppTheme.successGreen
                        : AppTheme.errorRed)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (isCorrect
                          ? AppTheme.successGreen
                          : AppTheme.errorRed)
                      .withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                    color: isCorrect ? AppTheme.successGreen : AppTheme.errorRed,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isCorrect ? 'Correct!' : 'Incorrect',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isCorrect
                                ? AppTheme.successGreen
                                : AppTheme.errorRed,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currentQuestion.explanation,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Action button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: selectedAnswerIndex == null
                  ? null
                  : showResult
                      ? _nextQuestion
                      : _submitAnswer,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.white,
                disabledBackgroundColor: AppTheme.borderLight,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: Text(
                showResult
                    ? currentQuestionIndex < questions.length - 1
                        ? 'Next Question'
                        : 'View Results'
                    : 'Submit Answer',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton({
    required int index,
    required String option,
    required bool isSelected,
    required bool isCorrect,
    required bool isWrong,
  }) {
    Color borderColor = AppTheme.borderLight;
    Color backgroundColor = AppTheme.backgroundWhite;
    IconData? icon;
    Color? iconColor;

    if (showResult) {
      if (isCorrect) {
        borderColor = AppTheme.successGreen;
        backgroundColor = AppTheme.successGreen.withOpacity(0.1);
        icon = Icons.check_circle_rounded;
        iconColor = AppTheme.successGreen;
      } else if (isWrong) {
        borderColor = AppTheme.errorRed;
        backgroundColor = AppTheme.errorRed.withOpacity(0.1);
        icon = Icons.cancel_rounded;
        iconColor = AppTheme.errorRed;
      }
    } else if (isSelected) {
      borderColor = AppTheme.primary;
      backgroundColor = AppTheme.primary.withOpacity(0.1);
    }

    return InkWell(
      onTap: () => _selectAnswer(index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: isSelected || showResult ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primary
                    : AppTheme.borderLight,
                shape: BoxShape.circle,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: AppTheme.white,
                      size: 16,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: AppTheme.textPrimary,
                  height: 1.4,
                ),
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 12),
              Icon(icon, color: iconColor, size: 24),
            ],
          ],
        ),
      ),
    );
  }
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String explanation;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });
}

