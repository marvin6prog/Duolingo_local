import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/language_data.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userProfile = userProvider.userProfile;
    final userProgress = userProvider.userProgress;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Profil',
          style: TextStyle(
            color: Color(0xFF3C3C3C),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () => userProvider.signOut(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildProfileHeader(userProfile),
            const SizedBox(height: 24),
            _buildLanguageSettings(context, userProvider, userProgress),
            const SizedBox(height: 24),
            _buildStatsSection(userProgress),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic>? profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: const Color(0xFF58CC02),
            child: Text(
              profile?['displayName']?.substring(0, 1).toUpperCase() ?? 'U',
              style: const TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile?['displayName'] ?? 'Utilisateur',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Apprenant passionné',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSettings(
    BuildContext context,
    UserProvider provider,
    UserProgress? progress,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Préférences de langue',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildLanguagePicker(
            context,
            'Langue cible',
            progress?.targetLanguage ?? Language.ewondo,
            (Language? lang) {
              if (lang != null) {
                provider.updateLanguagePreferences(
                  sourceLanguage: progress?.sourceLanguage ?? Language.ewondo,
                  targetLanguage: lang,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLanguagePicker(
    BuildContext context,
    String label,
    Language current,
    Function(Language?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        DropdownButton<Language>(
          value: current,
          isExpanded: true,
          items: Language.values.map((Language lang) {
            return DropdownMenuItem<Language>(
              value: lang,
              child: Text(_getLanguageName(lang)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildStatsSection(UserProgress? progress) {
    return Row(
      children: [
        _buildStatCard(
          'XP Total',
          '${progress?.totalXP ?? 0}',
          Icons.bolt,
          Colors.orange,
        ),
        const SizedBox(width: 16),
        _buildStatCard(
          'Série',
          '${progress?.streak ?? 0}',
          Icons.local_fire_department,
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  String _getLanguageName(Language lang) {
    switch (lang) {
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
