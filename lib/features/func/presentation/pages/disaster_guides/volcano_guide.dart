import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:resq/core/theme/app_theme.dart';
import 'package:resq/features/func/presentation/widgets/appbar.dart';

class VolcanoGuide extends StatefulWidget {
  const VolcanoGuide({super.key});

  @override
  State<VolcanoGuide> createState() => _VolcanoGuideState();
}

class _VolcanoGuideState extends State<VolcanoGuide> {
  int? selectedAnswerIndex;
  int currentQuestionIndex = 0;
  int correctAnswers = 0;
  bool showResult = false;
  bool quizStarted = false;

  final List<QuizQuestion> questions = [
    QuizQuestion(
      question: 'If a volcano erupts near you, you should:',
      options: [
        'Stay indoors and close all windows and doors',
        'Go outside to watch the eruption',
        'Drive toward the volcano',
        'Wait for instructions',
      ],
      correctAnswer: 0,
      explanation: 'Stay indoors and close all windows, doors, and dampers. Turn off fans and air conditioning to avoid bringing ash inside.',
    ),
    QuizQuestion(
      question: 'What should you do if you are caught outside during a volcanic eruption?',
      options: [
        'Run toward higher ground',
        'Seek shelter immediately and protect your head',
        'Continue your activities',
        'Take photos',
      ],
      correctAnswer: 1,
      explanation: 'Seek shelter immediately. If caught outside, protect your head and body from falling ash and debris. Avoid low-lying areas.',
    ),
    QuizQuestion(
      question: 'If you must drive during a volcanic ash fall, you should:',
      options: [
        'Drive as fast as possible',
        'Drive slowly with headlights on',
        'Drive with windows open',
        'Stop in the middle of the road',
      ],
      correctAnswer: 1,
      explanation: 'Drive slowly with headlights on. Ash can reduce visibility and make roads slippery. Avoid driving if possible.',
    ),
    QuizQuestion(
      question: 'What should you do to protect yourself from volcanic ash?',
      options: [
        'Wear a regular cloth mask',
        'Wear goggles and a respirator or N95 mask',
        'Cover your mouth with your hand',
        'Nothing - ash is harmless',
      ],
      correctAnswer: 1,
      explanation: 'Wear goggles to protect your eyes and a respirator or N95 mask to protect your lungs from ash particles.',
    ),
    QuizQuestion(
      question: 'If you are told to evacuate due to a volcanic eruption, you should:',
      options: [
        'Wait and see what happens',
        'Evacuate immediately to a safe location',
        'Stay home and close windows',
        'Go to a nearby hill to watch',
      ],
      correctAnswer: 1,
      explanation: 'If told to evacuate, do so immediately. Follow evacuation routes and go to designated safe areas.',
    ),
    QuizQuestion(
      question: 'After a volcanic eruption, you should:',
      options: [
        'Return home immediately',
        'Wait for authorities to declare the area safe',
        'Start cleaning up right away',
        'Go sightseeing',
      ],
      correctAnswer: 1,
      explanation: 'Wait for authorities to declare the area safe before returning. Volcanic hazards can persist long after the initial eruption.',
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
        title: 'Volcano Guide',
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
                    AppTheme.errorRed.withOpacity(0.15),
                    AppTheme.errorRed.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.errorRed.withOpacity(0.3),
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
                          color: AppTheme.errorRed,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.errorRed.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.landscape_rounded,
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
                              'Volcano Safety Guide',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Learn how to stay safe during a volcanic eruption',
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
            
            // During an Eruption Section
            _buildSectionCard(
              icon: Icons.warning_amber_rounded,
              iconColor: AppTheme.errorRed,
              title: 'During a Volcanic Eruption',
              gradient: LinearGradient(
                colors: [
                  AppTheme.errorRed.withOpacity(0.1),
                  AppTheme.errorRed.withOpacity(0.05),
                ],
              ),
              children: [
                _buildStepItem(
                  number: '1',
                  title: 'STAY INDOORS',
                  description: 'Stay indoors and close all windows, doors, and dampers.',
                ),
                const SizedBox(height: 12),
                _buildStepItem(
                  number: '2',
                  title: 'PROTECT YOURSELF',
                  description: 'Wear long-sleeved shirts, long pants, and goggles. Use a respirator or N95 mask.',
                ),
                const SizedBox(height: 12),
                _buildStepItem(
                  number: '3',
                  title: 'AVOID ASH',
                  description: 'Avoid areas downwind of the volcano. Stay away from low-lying areas.',
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // If You Are Outside Section
            _buildSectionCard(
              icon: Icons.park_rounded,
              iconColor: AppTheme.errorRed,
              title: 'If You Are Outside',
              gradient: LinearGradient(
                colors: [
                  AppTheme.errorRed.withOpacity(0.1),
                  AppTheme.errorRed.withOpacity(0.05),
                ],
              ),
              children: [
                _buildBulletPoint('Seek shelter immediately in a building or vehicle.'),
                _buildBulletPoint('If caught in ash fall, protect your head and body.'),
                _buildBulletPoint('Avoid low-lying areas where ash and gases can accumulate.'),
                _buildBulletPoint('Do not seek shelter in valleys or canyons.'),
                _buildBulletPoint('Cover your mouth and nose with a cloth or mask.'),
                _buildBulletPoint('Protect your eyes with goggles or glasses.'),
              ],
            ),
            const SizedBox(height: 16),
            
            // Volcanic Ash Protection Section
            _buildSectionCard(
              icon: Icons.face_retouching_natural_rounded,
              iconColor: AppTheme.primary,
              title: 'Protecting Yourself from Ash',
              gradient: LinearGradient(
                colors: [
                  AppTheme.primary.withOpacity(0.1),
                  AppTheme.primary.withOpacity(0.05),
                ],
              ),
              children: [
                _buildBulletPoint('Wear goggles to protect your eyes from ash.'),
                _buildBulletPoint('Use a respirator or N95 mask to protect your lungs.'),
                _buildBulletPoint('Wear long-sleeved shirts and long pants.'),
                _buildBulletPoint('Keep skin covered to avoid irritation from ash.'),
                _buildBulletPoint('Avoid contact with ash if you have respiratory problems.'),
                _buildBulletPoint('Stay indoors as much as possible during ash fall.'),
              ],
            ),
            const SizedBox(height: 16),
            
            // Driving Safety Section
            _buildSectionCard(
              icon: Icons.directions_car_rounded,
              iconColor: AppTheme.primary,
              title: 'Driving Safety',
              gradient: LinearGradient(
                colors: [
                  AppTheme.primary.withOpacity(0.1),
                  AppTheme.secendory.withOpacity(0.05),
                ],
              ),
              children: [
                _buildBulletPoint('Avoid driving during heavy ash fall if possible.'),
                _buildBulletPoint('If you must drive, go slowly with headlights on.'),
                _buildBulletPoint('Ash can make roads very slippery - drive with extreme caution.'),
                _buildBulletPoint('Keep windows and vents closed while driving.'),
                _buildBulletPoint('Change air filters in your vehicle after ash exposure.'),
                _buildBulletPoint('Avoid areas with poor visibility due to ash.'),
              ],
            ),
            const SizedBox(height: 16),
            
            // Evacuation Section
            _buildSectionCard(
              icon: Icons.directions_run_rounded,
              iconColor: AppTheme.errorRed,
              title: 'Evacuation',
              gradient: LinearGradient(
                colors: [
                  AppTheme.errorRed.withOpacity(0.1),
                  AppTheme.errorRed.withOpacity(0.05),
                ],
              ),
              children: [
                _buildBulletPoint('If told to evacuate, do so immediately.'),
                _buildBulletPoint('Follow designated evacuation routes.'),
                _buildBulletPoint('Take your emergency kit with you.'),
                _buildBulletPoint('Listen to authorities for safe locations.'),
                _buildBulletPoint('Do not return until authorities declare it safe.'),
                _buildBulletPoint('Be aware that multiple eruptions may occur.'),
              ],
            ),
            const SizedBox(height: 16),
            
            // After an Eruption Section
            _buildSectionCard(
              icon: Icons.check_circle_rounded,
              iconColor: AppTheme.successGreen,
              title: 'After an Eruption',
              gradient: LinearGradient(
                colors: [
                  AppTheme.successGreen.withOpacity(0.1),
                  AppTheme.successGreen.withOpacity(0.05),
                ],
              ),
              children: [
                _buildBulletPoint('Wait for authorities to declare the area safe.'),
                _buildBulletPoint('Continue to protect yourself from ash.'),
                _buildBulletPoint('Clear roofs of heavy ash to prevent collapse.'),
                _buildBulletPoint('Avoid driving on ash-covered roads.'),
                _buildBulletPoint('Be aware of lahars (mudflows) that can occur after eruptions.'),
                _buildBulletPoint('Listen for updates about additional eruptions.'),
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
                      'Remember: Volcanic ash can cause serious health problems and damage. Stay indoors during ash fall, wear proper protection, and follow evacuation orders immediately.',
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

  Widget _buildQuizCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.errorRed.withOpacity(0.15),
            AppTheme.errorRed.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.errorRed.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.errorRed.withOpacity(0.2),
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
                  color: AppTheme.errorRed,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.errorRed.withOpacity(0.4),
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
                      '${questions.length} questions to check your volcano safety knowledge',
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
                    color: AppTheme.errorRed, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Answer questions correctly to test your understanding of volcano safety procedures.',
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
                backgroundColor: AppTheme.errorRed,
                foregroundColor: AppTheme.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                shadowColor: AppTheme.errorRed.withOpacity(0.4),
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
                            color: AppTheme.errorRed,
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
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.errorRed),
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
                backgroundColor: AppTheme.errorRed,
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
      borderColor = AppTheme.errorRed;
      backgroundColor = AppTheme.errorRed.withOpacity(0.1);
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
                    color: AppTheme.errorRed.withOpacity(0.2),
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
                    ? AppTheme.errorRed
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
              colors: [AppTheme.errorRed, AppTheme.errorRed.withOpacity(0.8)],
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: AppTheme.errorRed.withOpacity(0.3),
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
                colors: [AppTheme.errorRed, AppTheme.errorRed.withOpacity(0.7)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.errorRed.withOpacity(0.3),
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
