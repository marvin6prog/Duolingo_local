import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../providers/user_provider.dart';
import '../models/language_data.dart';
import '../services/language_service.dart';
import '../widgets/question_widget.dart';

class LessonScreen extends StatefulWidget {
  final Subject subject;
  final Language targetLanguage;

  const LessonScreen({
    super.key,
    required this.subject,
    required this.targetLanguage,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  int _correctAnswers = 0;
  int _hearts = 5;
  bool _isLoading = true;
  bool _lessonCompleted = false;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _loadQuestions();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final sourceLang =
          userProvider.userProgress?.sourceLanguage ?? Language.ewondo;
      final sourceLangCode = sourceLang == Language.ewondo ? 'fr' : 'en';
      final targetLangCode = widget.targetLanguage == Language.ewondo
          ? 'ewondo'
          : 'bu';

      final questions = await LanguageService.generateQuestions(
        language: widget.targetLanguage,
        subject: widget.subject,
        sourceLang: sourceLangCode,
        targetLang: targetLangCode,
        questionCount: 10,
      );

      if (mounted) {
        setState(() {
          _questions = questions;
          _hearts = userProvider.userProgress?.hearts ?? 5;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading questions: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de chargement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onAnswerSelected(String selectedAnswer) {
    final correctAnswer = _questions[_currentQuestionIndex].correctAnswer;
    final isCorrect = selectedAnswer == correctAnswer;

    if (isCorrect) {
      setState(() => _correctAnswers++);
      _showFeedback(true);
    } else {
      setState(() => _hearts--);
      _showFeedback(false);

      if (_hearts <= 0) {
        _endLesson(false);
        return;
      }
    }

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        if (_currentQuestionIndex < _questions.length - 1) {
          setState(() => _currentQuestionIndex++);
        } else {
          _endLesson(true);
        }
      }
    });
  }

  void _showFeedback(bool isCorrect) {
    final color = isCorrect ? Colors.green : Colors.red;
    final icon = isCorrect ? Icons.check_circle : Icons.cancel;
    final message = isCorrect ? 'Correct !' : 'Incorrect !';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: color,
        duration: const Duration(milliseconds: 1000),
      ),
    );
  }

  Future<void> _endLesson(bool completed) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (completed) {
      final xp = _correctAnswers * 10;
      await userProvider.addXP(xp);
      await userProvider.completeSubjectLevel(widget.subject, 1);
      await userProvider.updateStreak();

      setState(() => _lessonCompleted = true);
      _confettiController.play();
    } else {
      await userProvider.updateHearts(_hearts);

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Leçon terminée'),
            content: const Text(
              'Vous n\'avez plus de vies. Révisez et réessayez plus tard !',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        appBar: AppBar(
          backgroundColor: const Color(0xFF58CC02),
          elevation: 0,
          title: Text(_getSubjectTitle()),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF58CC02)),
              ),
              SizedBox(height: 20),
              Text(
                'Chargement des questions...',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    if (_lessonCompleted) {
      return Scaffold(
        backgroundColor: const Color(0xFF58CC02),
        body: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.emoji_events,
                    size: 100,
                    color: Colors.white,
                  ).animate().scale(duration: 600.ms),
                  const SizedBox(height: 20),
                  Text(
                    'Leçon terminée !',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ).animate().fadeIn(duration: 800.ms),
                  const SizedBox(height: 10),
                  Text(
                    '$_correctAnswers/${_questions.length} réponses correctes',
                    style: const TextStyle(fontSize: 18, color: Colors.white70),
                  ).animate().fadeIn(duration: 1000.ms),
                  const SizedBox(height: 20),
                  Text(
                    '+${_correctAnswers * 10} XP',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellow,
                    ),
                  ).animate().fadeIn(duration: 1200.ms),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF58CC02),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Continuer',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ).animate().fadeIn(duration: 1400.ms),
                ],
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple,
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF58CC02),
        elevation: 0,
        title: Text(_getSubjectTitle()),
        actions: [
          Row(
            children: [
              ...List.generate(_hearts, (index) {
                return const Padding(
                  padding: EdgeInsets.only(right: 2),
                  child: Icon(Icons.favorite, color: Colors.red, size: 20),
                );
              }),
              const SizedBox(width: 16),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 8,
            color: Colors.grey.withOpacity(0.2),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (_currentQuestionIndex + 1) / _questions.length,
              child: Container(
                decoration: const BoxDecoration(color: Color(0xFF58CC02)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${_currentQuestionIndex + 1}/${_questions.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3C3C3C),
                  ),
                ),
                Text(
                  '$_correctAnswers correctes',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF58CC02),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _currentQuestionIndex < _questions.length
                ? QuestionWidget(
                    question: _questions[_currentQuestionIndex],
                    onAnswerSelected: _onAnswerSelected,
                  ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1)
                : const Center(
                    child: Text(
                      'Aucune question disponible',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  String _getSubjectTitle() {
    switch (widget.subject) {
      case Subject.alphabet:
        return 'Alphabet';
      case Subject.expression:
        return 'Expressions de base';
      case Subject.number:
        return 'Nombres';
      case Subject.conjugation:
        return 'Conjugaison';
      case Subject.pronoun:
        return 'Pronoms';
      case Subject.article:
        return 'Articles';
      case Subject.phrase:
        return 'Phrases';
      case Subject.famille:
        return 'La famille';
      case Subject.animaux:
        return 'Les animaux';
    }
  }
}
