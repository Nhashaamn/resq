import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:resq/core/theme/app_theme.dart';
import 'package:resq/features/func/presentation/widgets/appbar.dart';

class TsunamiGuide extends StatefulWidget {
  const TsunamiGuide({super.key});

  @override
  State<TsunamiGuide> createState() => _TsunamiGuideState();
}

class _TsunamiGuideState extends State<TsunamiGuide> {
  int? selectedAnswerIndex;
  int currentQuestionIndex = 0;
  int correctAnswers = 0;
  bool showResult = false;
  bool quizStarted = false;

  final List<QuizQuestion> questions = [
    QuizQuestion(
      question: 'If you are near the coast and feel a strong earthquake, you should:',
      options: [
        'Wait to see if a tsunami warning is issued',
        'Move immediately to higher ground or inland',
        'Go to the beach to watch',
        'Stay where you are',
      ],
      correctAnswer: 1,
      explanation: 'If you feel a strong earthquake near the coast, move immediately to higher ground. Do not wait for official warnings.',
    ),
    QuizQuestion(
      question: 'What is a natural warning sign of an approaching tsunami?',
      options: [
        'Clear skies',
        'The ocean receding unusually far, exposing the seafloor',
        'Calm water',
        'Birds flying away',
      ],
      correctAnswer: 1,
      explanation: 'If the ocean recedes unusually far, exposing the seafloor, a tsunami may be approaching. Move to higher ground immediately.',
    ),
    QuizQuestion(
      question: 'If you are in a boat when a tsunami warning is issued, you should:',
      options: [
        'Head toward the shore',
        'Move to deeper water if time permits',
        'Anchor near the coast',
        'Stay in shallow water',
      ],
      correctAnswer: 1,
      explanation: 'If you are in a boat and have time, move to deeper water (at least 100 fathoms). Do not return to port.',
    ),
    QuizQuestion(
      question: 'How far inland should you go to escape a tsunami?',
      options: [
        '100 feet',
        'At least 2 miles or 100 feet above sea level',
        '500 feet',
        'Just away from the beach',
      ],
      correctAnswer: 1,
      explanation: 'Move at least 2 miles inland or to an elevation of at least 100 feet above sea level. Higher is better.',
    ),
    QuizQuestion(
      question: 'After the first wave of a tsunami, you should:',
      options: [
        'Return to the coast immediately',
        'Stay away - more waves may follow',
        'Go to the beach to help',
        'Check on your property',
      ],
      correctAnswer: 1,
      explanation: 'Tsunamis consist of multiple waves. Stay away from the coast until authorities declare it safe. The first wave is often not the largest.',
    ),
    QuizQuestion(
      question: 'If you cannot escape to higher ground during a tsunami, you should:',
      options: [
        'Climb a tree',
        'Go to the upper floors of a sturdy building',
        'Swim toward deeper water',
        'Hide in a basement',
      ],
      correctAnswer: 1,
      explanation: 'If you cannot reach higher ground, go to the upper floors of a sturdy building. Avoid trees and weak structures.',
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
        title: 'Tsunami Guide',
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
                          Icons.waves_rounded,
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
                              'Tsunami Safety Guide',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Learn how to stay safe during a tsunami',
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
            
            // Natural Warning Signs Section
            _buildSectionCard(
              icon: Icons.warning_amber_rounded,
              iconColor: AppTheme.errorRed,
              title: 'Natural Warning Signs',
              gradient: LinearGradient(
                colors: [
                  AppTheme.errorRed.withOpacity(0.1),
                  AppTheme.errorRed.withOpacity(0.05),
                ],
              ),
              children: [
                _buildBulletPoint('Strong earthquake that lasts 20 seconds or more near the coast.'),
                _buildBulletPoint('Unusual ocean behavior - water receding or rising rapidly.'),
                _buildBulletPoint('A loud roar coming from the ocean.'),
                _buildBulletPoint('If you see any of these signs, move to higher ground immediately.'),
                _buildBulletPoint('Do not wait for official warnings if you observe these signs.'),
              ],
            ),
            const SizedBox(height: 16),
            
            // If You Feel an Earthquake Section
            _buildSectionCard(
              icon: Icons.emergency_rounded,
              iconColor: AppTheme.errorRed,
              title: 'If You Feel an Earthquake',
              gradient: LinearGradient(
                colors: [
                  AppTheme.errorRed.withOpacity(0.1),
                  AppTheme.errorRed.withOpacity(0.05),
                ],
              ),
              children: [
                _buildStepItem(
                  number: '1',
                  title: 'DROP, COVER, HOLD',
                  description: 'During the earthquake, drop, cover, and hold on.',
                ),
                const SizedBox(height: 12),
                _buildStepItem(
                  number: '2',
                  title: 'EVACUATE IMMEDIATELY',
                  description: 'As soon as shaking stops, move to higher ground or inland immediately.',
                ),
                const SizedBox(height: 12),
                _buildStepItem(
                  number: '3',
                  title: 'GO HIGH AND INLAND',
                  description: 'Move at least 2 miles inland or 100 feet above sea level.',
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Evacuation Section
            _buildSectionCard(
              icon: Icons.directions_run_rounded,
              iconColor: AppTheme.primary,
              title: 'Evacuation',
              gradient: LinearGradient(
                colors: [
                  AppTheme.primary.withOpacity(0.1),
                  AppTheme.primary.withOpacity(0.05),
                ],
              ),
              children: [
                _buildBulletPoint('Know your evacuation route and practice it.'),
                _buildBulletPoint('Move on foot if possible - roads may be damaged or congested.'),
                _buildBulletPoint('Go to high ground or inland - at least 2 miles or 100 feet elevation.'),
                _buildBulletPoint('If you cannot reach higher ground, go to upper floors of a sturdy building.'),
                _buildBulletPoint('Do not return to the coast until authorities declare it safe.'),
                _buildBulletPoint('Follow evacuation routes and signs.'),
              ],
            ),
            const SizedBox(height: 16),
            
            // If You Are in a Boat Section
            _buildSectionCard(
              icon: Icons.directions_boat_rounded,
              iconColor: AppTheme.primary,
              title: 'If You Are in a Boat',
              gradient: LinearGradient(
                colors: [
                  AppTheme.primary.withOpacity(0.1),
                  AppTheme.secendory.withOpacity(0.05),
                ],
              ),
              children: [
                _buildBulletPoint('If you have time, move to deeper water (at least 100 fathoms).'),
                _buildBulletPoint('Do not return to port if a tsunami warning has been issued.'),
                _buildBulletPoint('Tsunamis can cause dangerous currents in harbors and ports.'),
                _buildBulletPoint('Stay in deeper water until authorities declare it safe.'),
                _buildBulletPoint('Listen to marine radio for updates.'),
              ],
            ),
            const SizedBox(height: 16),
            
            // After a Tsunami Section
            _buildSectionCard(
              icon: Icons.check_circle_rounded,
              iconColor: AppTheme.successGreen,
              title: 'After a Tsunami',
              gradient: LinearGradient(
                colors: [
                  AppTheme.successGreen.withOpacity(0.1),
                  AppTheme.successGreen.withOpacity(0.05),
                ],
              ),
              children: [
                _buildBulletPoint('Stay away from the coast until authorities declare it safe.'),
                _buildBulletPoint('Tsunamis consist of multiple waves - the first may not be the largest.'),
                _buildBulletPoint('Avoid damaged areas and downed power lines.'),
                _buildBulletPoint('Listen to authorities for information about safe areas.'),
                _buildBulletPoint('Help others if you can do so safely.'),
                _buildBulletPoint('Be aware of aftershocks that may cause additional tsunamis.'),
              ],
            ),
            const SizedBox(height: 16),
            
            // Before a Tsunami Section
            _buildSectionCard(
              icon: Icons.shield_rounded,
              iconColor: AppTheme.primary,
              title: 'Before a Tsunami',
              gradient: LinearGradient(
                colors: [
                  AppTheme.primary.withOpacity(0.1),
                  AppTheme.secendory.withOpacity(0.05),
                ],
              ),
              children: [
                _buildBulletPoint('Know if you live, work, or visit tsunami-prone areas.'),
                _buildBulletPoint('Learn the natural warning signs of a tsunami.'),
                _buildBulletPoint('Plan and practice your evacuation route.'),
                _buildBulletPoint('Have an emergency kit ready.'),
                _buildBulletPoint('Know the location of high ground and how to get there.'),
                _buildBulletPoint('Stay informed about tsunami risks in your area.'),
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
                      'Remember: If you feel a strong earthquake near the coast, move to higher ground immediately. Do not wait for official warnings. Every second counts during a tsunami.',
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
                      '${questions.length} questions to check your tsunami safety knowledge',
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
                    'Answer questions correctly to test your understanding of tsunami safety procedures.',
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
