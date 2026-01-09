import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:resq/core/theme/app_theme.dart';
import 'package:resq/features/func/presentation/widgets/appbar.dart';

class StormGuide extends StatefulWidget {
  const StormGuide({super.key});

  @override
  State<StormGuide> createState() => _StormGuideState();
}

class _StormGuideState extends State<StormGuide> {
  int? selectedAnswerIndex;
  int currentQuestionIndex = 0;
  int correctAnswers = 0;
  bool showResult = false;
  bool quizStarted = false;

  final List<QuizQuestion> questions = [
    QuizQuestion(
      question: 'If you are outside during a severe storm, you should:',
      options: [
        'Take shelter under a tree',
        'Seek shelter in a sturdy building immediately',
        'Continue your activities',
        'Stand in an open field',
      ],
      correctAnswer: 1,
      explanation: 'Seek shelter in a sturdy building immediately. Avoid trees, open fields, and isolated structures.',
    ),
    QuizQuestion(
      question: 'If you are in a vehicle during a severe storm, you should:',
      options: [
        'Drive faster to get home',
        'Pull over and stay in the vehicle',
        'Get out and run to a building',
        'Park under a bridge',
      ],
      correctAnswer: 1,
      explanation: 'Pull over to a safe location and stay in your vehicle. Avoid parking under trees or power lines.',
    ),
    QuizQuestion(
      question: 'What should you do if you are caught outside during a thunderstorm?',
      options: [
        'Lie flat on the ground',
        'Crouch low in an open area',
        'Find a low-lying area and lie down',
        'Avoid tall objects and seek low ground',
      ],
      correctAnswer: 3,
      explanation: 'Avoid tall objects like trees and poles. Seek low ground, but avoid areas prone to flooding.',
    ),
    QuizQuestion(
      question: 'During a severe storm warning, you should:',
      options: [
        'Go outside to watch',
        'Stay indoors away from windows',
        'Continue normal activities',
        'Drive to a different location',
      ],
      correctAnswer: 1,
      explanation: 'Stay indoors away from windows. Close curtains and blinds, and stay in an interior room if possible.',
    ),
    QuizQuestion(
      question: 'If you hear thunder, you should:',
      options: [
        'Wait to see lightning first',
        'Seek shelter immediately',
        'Continue outdoor activities',
        'Check the weather forecast',
      ],
      correctAnswer: 1,
      explanation: 'If you can hear thunder, you are close enough to be struck by lightning. Seek shelter immediately.',
    ),
    QuizQuestion(
      question: 'After a severe storm, you should:',
      options: [
        'Go outside immediately',
        'Wait for authorities to declare it safe',
        'Check on neighbors right away',
        'Drive around to assess damage',
      ],
      correctAnswer: 1,
      explanation: 'Wait for authorities to declare the area safe. Watch for downed power lines and damaged structures.',
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
        title: 'Storm Guide',
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
                    AppTheme.primary.withOpacity(0.15),
                    AppTheme.secendory.withOpacity(0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primary.withOpacity(0.3),
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
                          Icons.thunderstorm_rounded,
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
                              'Storm Safety Guide',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Learn how to stay safe during severe storms',
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
            
            // Before a Storm Section
            _buildSectionCard(
              icon: Icons.warning_amber_rounded,
              iconColor: AppTheme.primary,
              title: 'Before a Storm',
              gradient: LinearGradient(
                colors: [
                  AppTheme.primary.withOpacity(0.1),
                  AppTheme.primary.withOpacity(0.05),
                ],
              ),
              children: [
                _buildBulletPoint('Monitor weather forecasts and warnings.'),
                _buildBulletPoint('Secure outdoor furniture and objects that could become projectiles.'),
                _buildBulletPoint('Charge electronic devices and have backup batteries.'),
                _buildBulletPoint('Have an emergency kit ready with food, water, and supplies.'),
                _buildBulletPoint('Know where to take shelter in your home.'),
                _buildBulletPoint('Have a battery-powered or hand-crank radio available.'),
              ],
            ),
            const SizedBox(height: 16),
            
            // During a Storm Section
            _buildSectionCard(
              icon: Icons.emergency_rounded,
              iconColor: AppTheme.errorRed,
              title: 'During a Storm',
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
                  description: 'Stay inside away from windows, skylights, and glass doors.',
                ),
                const SizedBox(height: 12),
                _buildStepItem(
                  number: '2',
                  title: 'AVOID ELECTRICAL',
                  description: 'Avoid using electrical appliances and plumbing during thunderstorms.',
                ),
                const SizedBox(height: 12),
                _buildStepItem(
                  number: '3',
                  title: 'STAY INFORMED',
                  description: 'Listen to weather updates on a battery-powered radio.',
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // If Outside Section
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
                _buildBulletPoint('Seek shelter in a sturdy building immediately.'),
                _buildBulletPoint('Avoid trees, poles, and tall objects.'),
                _buildBulletPoint('If no shelter is available, find a low-lying area and crouch low.'),
                _buildBulletPoint('Stay away from water, metal objects, and electrical equipment.'),
                _buildBulletPoint('Do not lie flat on the ground.'),
                _buildBulletPoint('If in a group, spread out to reduce the risk of multiple injuries.'),
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
                _buildBulletPoint('Pull over to a safe location away from trees and power lines.'),
                _buildBulletPoint('Stay in the vehicle with windows closed.'),
                _buildBulletPoint('Avoid touching metal parts of the vehicle.'),
                _buildBulletPoint('Do not park under bridges or overpasses.'),
                _buildBulletPoint('Wait for the storm to pass before continuing.'),
              ],
            ),
            const SizedBox(height: 16),
            
            // Lightning Safety Section
            _buildSectionCard(
              icon: Icons.flash_on_rounded,
              iconColor: AppTheme.warningYellow,
              title: 'Lightning Safety',
              gradient: LinearGradient(
                colors: [
                  AppTheme.warningYellow.withOpacity(0.15),
                  AppTheme.warningYellow.withOpacity(0.08),
                ],
              ),
              children: [
                _buildBulletPoint('Remember: When thunder roars, go indoors!'),
                _buildBulletPoint('Stay indoors for at least 30 minutes after the last thunder.'),
                _buildBulletPoint('Avoid contact with water during thunderstorms.'),
                _buildBulletPoint('Stay away from windows and doors.'),
                _buildBulletPoint('Do not use corded phones during thunderstorms.'),
                _buildBulletPoint('Unplug electronic equipment before the storm arrives.'),
              ],
            ),
            const SizedBox(height: 16),
            
            // After a Storm Section
            _buildSectionCard(
              icon: Icons.check_circle_rounded,
              iconColor: AppTheme.successGreen,
              title: 'After a Storm',
              gradient: LinearGradient(
                colors: [
                  AppTheme.successGreen.withOpacity(0.1),
                  AppTheme.successGreen.withOpacity(0.05),
                ],
              ),
              children: [
                _buildBulletPoint('Wait for authorities to declare the area safe.'),
                _buildBulletPoint('Watch for downed power lines and report them immediately.'),
                _buildBulletPoint('Avoid walking or driving through floodwaters.'),
                _buildBulletPoint('Check on neighbors, especially the elderly.'),
                _buildBulletPoint('Be cautious of damaged structures and trees.'),
                _buildBulletPoint('Document any damage for insurance purposes.'),
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
                      'Remember: When thunder roars, go indoors! If you can hear thunder, you are close enough to be struck by lightning. No place outside is safe during a thunderstorm.',
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
            AppTheme.primary.withOpacity(0.15),
            AppTheme.primary.withOpacity(0.08),
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
                      '${questions.length} questions to check your storm safety knowledge',
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
                    'Answer questions correctly to test your understanding of storm safety procedures.',
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
