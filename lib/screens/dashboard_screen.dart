import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/language_data.dart';
import '../widgets/skill_tree_widget.dart';
import '../widgets/hearts_widget.dart';
import '../widgets/xp_widget.dart';
import '../widgets/streak_widget.dart';
import 'lesson_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF58CC02),
        elevation: 0,
        title: const Text(
          'Langues du Cameroun',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [
          HeartsWidget(),
          SizedBox(width: 8),
          XPWidget(),
          SizedBox(width: 16),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF58CC02)),
              ),
            );
          }

          if (userProvider.userProgress == null) {
            return const Center(
              child: Text(
                'Erreur de chargement des données',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, userProvider),
                const SizedBox(height: 20),
                _buildStreakSection(userProvider),
                const SizedBox(height: 20),
                _buildLanguageInfo(userProvider),
                const SizedBox(height: 30),
                _buildSkillTreeTitle(),
                const SizedBox(height: 20),
                SkillTreeWidget(
                  userProgress: userProvider.userProgress!,
                  onSkillTap: (subject) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => LessonScreen(
                          subject: subject,
                          targetLanguage: userProvider.userProgress!.targetLanguage,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserProvider userProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFF58CC02),
            child: Text(
              userProvider.userProfile?['displayName']?.substring(0, 2).toUpperCase() ?? 'U',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bonjour, ${userProvider.userProfile?['displayName'] ?? 'Apprenant'} !',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3C3C3C),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Prêt à apprendre aujourd\'hui ?',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2);
  }

  Widget _buildStreakSection(UserProvider userProvider) {
    final streak = userProvider.userProgress?.streak ?? 0;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange[400]!, Colors.orange[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            streak > 0 ? Icons.local_fire_department : Icons.local_fire_department_outlined,
            color: Colors.white,
            size: 40,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Série d\'apprentissage',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$streak ${streak <= 1 ? 'jour' : 'jours'} consécutifs',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2);
  }

  Widget _buildLanguageInfo(UserProvider userProvider) {
    final targetLang = userProvider.userProgress?.targetLanguage ?? Language.bulu;
    final sourceLang = userProvider.userProgress?.sourceLanguage ?? Language.bulu;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF58CC02).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF58CC02).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _getLanguageName(sourceLang),
              style: const TextStyle(
                color: Color(0xFF58CC02),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Icon(Icons.arrow_forward, color: Color(0xFF58CC02)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF58CC02),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _getLanguageName(targetLang),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 1000.ms).scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildSkillTreeTitle() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Votre parcours d\'apprentissage',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3C3C3C),
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Commencez par les bases et progressez étape par étape',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  String _getLanguageName(Language language) {
    switch (language) {
      case Language.bulu:
        return 'Bulu';
      case Language.bassaa:
        return 'Bassaa';
      case Language.bamileke:
        return 'Bamiléké';
      case Language.ewondo:
        return 'Ewondo';
    }
  }
}
