import 'package:flutter/material.dart';
import '../models/language_data.dart';

class SkillTreeWidget extends StatelessWidget {
  final UserProgress userProgress;
  final Function(Subject) onSkillTap;

  const SkillTreeWidget({
    super.key,
    required this.userProgress,
    required this.onSkillTap,
  });

  @override
  Widget build(BuildContext context) {
    final skills = _getSkillsData();
    
    return Container(
      padding: const EdgeInsets.all(16),
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
        children: [
          _buildSkillRow(context, skills.sublist(0, 3), isTopRow: true),
          const SizedBox(height: 20),
          _buildSkillRow(context, skills.sublist(3, 6), isTopRow: false),
          const SizedBox(height: 20),
          _buildSkillRow(context, skills.sublist(6, 9), isTopRow: false),
        ],
      ),
    );
  }

  Widget _buildSkillRow(BuildContext context, List<SkillData> skills, {required bool isTopRow}) {
    return Row(
      children: skills.map((skill) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: skills.last != skill ? 12.0 : 0.0,
            ),
            child: _buildSkillItem(context, skill),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSkillItem(BuildContext context, SkillData skill) {
    final isUnlocked = _isSkillUnlocked(skill);
    final currentLevel = userProgress.completedLevels[skill.subject] ?? 0;
    final maxLevel = 5;
    final progress = currentLevel / maxLevel;
    
    return GestureDetector(
      onTap: isUnlocked ? () => onSkillTap(skill.subject) : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnlocked 
              ? skill.color.withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnlocked 
                ? skill.color.withOpacity(0.3)
                : Colors.grey.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isUnlocked ? skill.color : Colors.grey,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: (isUnlocked ? skill.color : Colors.grey).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                skill.icon,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              skill.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isUnlocked ? const Color(0xFF3C3C3C) : Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            if (isUnlocked) ...[
              Text(
                'Niveau $currentLevel/$maxLevel',
                style: TextStyle(
                  fontSize: 12,
                  color: skill.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: skill.color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ] else ...[
              Icon(
                Icons.lock,
                color: Colors.grey,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                'Verrouillé',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _isSkillUnlocked(SkillData skill) {
    switch (skill.subject) {
      case Subject.alphabet:
        return true;
      case Subject.expression:
        return (userProgress.completedLevels[Subject.alphabet] ?? 0) >= 1;
      case Subject.number:
        return (userProgress.completedLevels[Subject.expression] ?? 0) >= 1;
      case Subject.famille:
        return (userProgress.completedLevels[Subject.number] ?? 0) >= 1;
      case Subject.conjugation:
        return (userProgress.completedLevels[Subject.famille] ?? 0) >= 1;
      case Subject.pronoun:
        return (userProgress.completedLevels[Subject.conjugation] ?? 0) >= 1;
      case Subject.article:
        return (userProgress.completedLevels[Subject.pronoun] ?? 0) >= 1;
      case Subject.phrase:
        return (userProgress.completedLevels[Subject.article] ?? 0) >= 1;
      case Subject.animaux:
        return (userProgress.completedLevels[Subject.phrase] ?? 0) >= 1;
    }
  }

  List<SkillData> _getSkillsData() {
    return [
      SkillData(
        subject: Subject.alphabet,
        title: 'Alphabet',
        icon: Icons.abc,
        color: const Color(0xFF89CFF0),
      ),
      SkillData(
        subject: Subject.expression,
        title: 'Expressions',
        icon: Icons.chat_bubble,
        color: const Color(0xFF58CC02),
      ),
      SkillData(
        subject: Subject.number,
        title: 'Nombres',
        icon: Icons.tag,
        color: const Color(0xFFCE82FF),
      ),
      SkillData(
        subject: Subject.famille,
        title: 'Famille',
        icon: Icons.people,
        color: const Color(0xFFFF9600),
      ),
      SkillData(
        subject: Subject.conjugation,
        title: 'Conjugaison',
        icon: Icons.edit_note,
        color: const Color(0xFF58A6FF),
      ),
      SkillData(
        subject: Subject.pronoun,
        title: 'Pronoms',
        icon: Icons.person_pin,
        color: const Color(0xFFFF6B6B),
      ),
      SkillData(
        subject: Subject.article,
        title: 'Articles',
        icon: Icons.article,
        color: const Color(0xFF4ECDC4),
      ),
      SkillData(
        subject: Subject.phrase,
        title: 'Phrases',
        icon: Icons.format_quote,
        color: const Color(0xFF95E1D3),
      ),
      SkillData(
        subject: Subject.animaux,
        title: 'Animaux',
        icon: Icons.pets,
        color: const Color(0xFFFFA502),
      ),
    ];
  }
}

class SkillData {
  final Subject subject;
  final String title;
  final IconData icon;
  final Color color;

  SkillData({
    required this.subject,
    required this.title,
    required this.icon,
    required this.color,
  });
}
