import 'package:flutter/material.dart';
import '../models/language_data.dart';

class QuestionWidget extends StatefulWidget {
  final Question question;
  final Function(String) onAnswerSelected;

  const QuestionWidget({
    super.key,
    required this.question,
    required this.onAnswerSelected,
  });

  @override
  State<QuestionWidget> createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<QuestionWidget> {
  bool _answerSelected = false;
  String? _selectedAnswer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getQuestionTypeColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getQuestionTypeLabel(),
                        style: TextStyle(
                          color: _getQuestionTypeColor(),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    if (widget.question.phoneticHint != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '🔊 ${widget.question.phoneticHint}',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  widget.question.question,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3C3C3C),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.5,
              ),
              itemCount: widget.question.options.length,
              itemBuilder: (context, index) {
                final option = widget.question.options[index];
                final isSelected = _selectedAnswer == option;
                final isCorrect = option == widget.question.correctAnswer;
                
                Color backgroundColor = Colors.white;
                Color borderColor = Colors.grey.withOpacity(0.3);
                Color textColor = const Color(0xFF3C3C3C);
                
                if (_answerSelected) {
                  if (isSelected) {
                    backgroundColor = isCorrect ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1);
                    borderColor = isCorrect ? Colors.green : Colors.red;
                    textColor = isCorrect ? Colors.green : Colors.red;
                  } else if (isCorrect) {
                    backgroundColor = Colors.green.withOpacity(0.1);
                    borderColor = Colors.green;
                    textColor = Colors.green;
                  }
                } else if (isSelected) {
                  backgroundColor = const Color(0xFF58CC02).withOpacity(0.1);
                  borderColor = const Color(0xFF58CC02);
                  textColor = const Color(0xFF58CC02);
                }
                
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    border: Border.all(color: borderColor, width: 2),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: borderColor.withOpacity(0.2),
                        blurRadius: isSelected || _answerSelected ? 8 : 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: _answerSelected ? null : () => _selectAnswer(option),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            option,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _selectAnswer(String answer) {
    setState(() {
      _selectedAnswer = answer;
      _answerSelected = true;
    });
    
    Future.delayed(const Duration(milliseconds: 500), () {
      widget.onAnswerSelected(answer);
    });
  }

  Color _getQuestionTypeColor() {
    switch (widget.question.type) {
      case QuestionType.recognition:
        return Colors.blue;
      case QuestionType.reverseTranslation:
        return Colors.purple;
      case QuestionType.phonetic:
        return Colors.orange;
      case QuestionType.matching:
        return Colors.teal;
    }
  }

  String _getQuestionTypeLabel() {
    switch (widget.question.type) {
      case QuestionType.recognition:
        return 'Reconnaissance';
      case QuestionType.reverseTranslation:
        return 'Traduction inversée';
      case QuestionType.phonetic:
        return 'Défi phonétique';
      case QuestionType.matching:
        return 'Association';
    }
  }
}
