class LanguageItem {
  final String id;
  final String subject;
  final String fr;
  final String en;
  final String bu;
  final String ew;
  final String phonetic;
  final String partOfSpeech;

  LanguageItem({
    required this.id,
    required this.subject,
    required this.fr,
    required this.en,
    required this.bu,
    required this.ew,
    required this.phonetic,
    required this.partOfSpeech,
  });

  factory LanguageItem.fromJson(Map<String, dynamic> json) {
    return LanguageItem(
      id: json['id'] ?? '',
      subject: json['subject'] ?? '',
      fr: json['fr'] ?? '',
      en: json['en'] ?? '',
      bu: json['bu'] ?? '',
      ew: json['ew'] ?? '',
      phonetic: json['phonetic'] ?? '',
      partOfSpeech: json['part_of_speech'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'fr': fr,
      'en': en,
      'bu': bu,
      'ew': ew,
      'phonetic': phonetic,
      'part_of_speech': partOfSpeech,
    };
  }

  String getTranslation(String sourceLang, String targetLang) {
    if (sourceLang == 'fr' && targetLang == 'bu') return bu;
    if (sourceLang == 'en' && targetLang == 'bu') return bu;
    if (sourceLang == 'bu' && targetLang == 'fr') return fr;
    if (sourceLang == 'bu' && targetLang == 'en') return en;
    if (sourceLang == 'fr' && targetLang == 'ewondo') return ew;
    if (sourceLang == 'en' && targetLang == 'ewondo') return ew;
    if (sourceLang == 'ewondo' && targetLang == 'fr') return fr;
    if (sourceLang == 'ewondo' && targetLang == 'en') return en;
    if (sourceLang == 'fr' && targetLang == 'en') return en;
    if (sourceLang == 'en' && targetLang == 'fr') return fr;
    return '';
  }
}

enum Language { bulu, bassaa, bamileke, ewondo }

enum Subject {
  alphabet,
  expression,
  number,
  conjugation,
  pronoun,
  article,
  phrase,
  famille,
  animaux,
}

class UserProgress {
  final String userId;
  Language sourceLanguage;
  Language targetLanguage;
  final Map<Subject, int> completedLevels;
  int totalXP;
  int hearts;
  DateTime? lastLessonDate;
  int streak;

  UserProgress({
    required this.userId,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.completedLevels,
    required this.totalXP,
    required this.hearts,
    this.lastLessonDate,
    required this.streak,
  });

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      userId: json['userId'] ?? '',
      sourceLanguage: _parseLanguage(json['sourceLanguage']),
      targetLanguage: _parseLanguage(json['targetLanguage']),
      completedLevels: _parseSubjects(json['completedLevels']),
      totalXP: json['totalXP'] ?? 0,
      hearts: json['hearts'] ?? 5,
      lastLessonDate: json['lastLessonDate'] != null
          ? DateTime.parse(json['lastLessonDate'])
          : null,
      streak: json['streak'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'sourceLanguage': sourceLanguage.name,
      'targetLanguage': targetLanguage.name,
      'completedLevels': completedLevels.map(
        (key, value) => MapEntry(key.name, value),
      ),
      'totalXP': totalXP,
      'hearts': hearts,
      'lastLessonDate': lastLessonDate?.toIso8601String(),
      'streak': streak,
    };
  }

  static Language _parseLanguage(String? lang) {
    switch (lang) {
      case 'bulu':
        return Language.bulu;
      case 'bassaa':
        return Language.bassaa;
      case 'bamileke':
        return Language.bamileke;
      case 'ewondo':
        return Language.ewondo;
      default:
        return Language.bulu;
    }
  }

  static Map<Subject, int> _parseSubjects(Map<String, dynamic>? subjects) {
    final Map<Subject, int> result = {};
    subjects?.forEach((key, value) {
      final subject = _parseSubject(key);
      result[subject] = (value as num).toInt();
    });
    return result;
  }

  static Subject _parseSubject(String subject) {
    switch (subject) {
      case 'alphabet':
        return Subject.alphabet;
      case 'expression':
        return Subject.expression;
      case 'number':
        return Subject.number;
      case 'conjugation':
        return Subject.conjugation;
      case 'pronoun':
        return Subject.pronoun;
      case 'article':
        return Subject.article;
      case 'phrase':
        return Subject.phrase;
      case 'famille':
        return Subject.famille;
      case 'animaux':
        return Subject.animaux;
      default:
        return Subject.alphabet;
    }
  }
}

class Question {
  final String id;
  final Subject subject;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String? phoneticHint;
  final QuestionType type;

  Question({
    required this.id,
    required this.subject,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.phoneticHint,
    required this.type,
  });
}

enum QuestionType { recognition, matching, reverseTranslation, phonetic }
