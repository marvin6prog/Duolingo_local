import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/language_data.dart';

class LanguageService {
  static Map<String, List<LanguageItem>> _cache = {};

  static Future<List<LanguageItem>> loadLanguageData(Language language) async {
    final cacheKey = language.name;

    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    try {
      String fileName;
      switch (language) {
        case Language.bulu:
          fileName = 'assets/data/bulu_data.json';
          break;
        case Language.bassaa:
          fileName = 'assets/data/bassaa_data.json';
          break;
        case Language.bamileke:
          fileName = 'assets/data/bamileke_data.json';
          break;
        case Language.ewondo:
          fileName = 'assets/data/ewondo_data.json';
          break;
      }

      final String jsonString = await rootBundle.loadString(fileName);
      final List<dynamic> jsonList = json.decode(jsonString);

      final items = jsonList
          .map((json) => LanguageItem.fromJson(json))
          .where((item) => item.bu.isNotEmpty || item.ew.isNotEmpty)
          .toList();

      _cache[cacheKey] = items;
      return items;
    } catch (e) {
      print('Error loading language data for $language: $e');
      return [];
    }
  }

  static Future<List<LanguageItem>> getItemsBySubject(
    Language language,
    Subject subject,
  ) async {
    final allItems = await loadLanguageData(language);

    final subjectString = subject.name;
    return allItems.where((item) => item.subject == subjectString).toList();
  }

  static Future<List<LanguageItem>> getItemsBySubjects(
    Language language,
    List<Subject> subjects,
  ) async {
    final allItems = await loadLanguageData(language);

    final subjectStrings = subjects.map((s) => s.name).toSet();
    return allItems
        .where((item) => subjectStrings.contains(item.subject))
        .toList();
  }

  static List<LanguageItem> getRandomItems(
    List<LanguageItem> items,
    int count,
  ) {
    if (items.length <= count) return items;

    final shuffled = List<LanguageItem>.from(items)..shuffle();
    return shuffled.take(count).toList();
  }

  static Future<List<Question>> generateQuestions({
    required Language language,
    required Subject subject,
    required String sourceLang,
    required String targetLang,
    int questionCount = 10,
  }) async {
    final items = await getItemsBySubject(language, subject);
    if (items.isEmpty) return [];

    final questions = <Question>[];
    final randomItems = getRandomItems(items, questionCount);

    for (int i = 0; i < randomItems.length && i < questionCount; i++) {
      final item = randomItems[i];
      final questionType = _getRandomQuestionType();

      switch (questionType) {
        case QuestionType.recognition:
          questions.add(
            _createRecognitionQuestion(item, sourceLang, targetLang, i),
          );
          break;
        case QuestionType.reverseTranslation:
          questions.add(
            _createReverseTranslationQuestion(item, sourceLang, targetLang, i),
          );
          break;
        case QuestionType.phonetic:
          questions.add(
            _createPhoneticQuestion(item, sourceLang, targetLang, i),
          );
          break;
        case QuestionType.matching:
          questions.add(
            _createMatchingQuestion(item, sourceLang, targetLang, i),
          );
          break;
      }
    }

    return questions;
  }

  static QuestionType _getRandomQuestionType() {
    final types = QuestionType.values;
    types.shuffle();
    return types.first;
  }

  static Question _createRecognitionQuestion(
    LanguageItem item,
    String sourceLang,
    String targetLang,
    int index,
  ) {
    final sourceText = sourceLang == 'fr' ? item.fr : item.en;
    final correctAnswer = item.getTranslation(sourceLang, targetLang);

    final options = [correctAnswer];
    final otherItems = getRandomItems([item], 3);

    for (final otherItem in otherItems) {
      final answer = otherItem.getTranslation(sourceLang, targetLang);
      if (answer.isNotEmpty && !options.contains(answer)) {
        options.add(answer);
      }
    }

    while (options.length < 4) {
      options.add('Option ${options.length}');
    }

    options.shuffle();

    return Question(
      id: 'rec_${item.id}_$index',
      subject: _parseSubject(item.subject),
      question: 'Comment dit-on "$sourceText" ?',
      options: options,
      correctAnswer: correctAnswer,
      phoneticHint: item.phonetic,
      type: QuestionType.recognition,
    );
  }

  static Question _createReverseTranslationQuestion(
    LanguageItem item,
    String sourceLang,
    String targetLang,
    int index,
  ) {
    final sourceText = item.getTranslation(targetLang, sourceLang);
    final correctAnswer = sourceLang == 'fr' ? item.fr : item.en;

    final options = [correctAnswer];
    final otherItems = getRandomItems([item], 3);

    for (final otherItem in otherItems) {
      final answer = sourceLang == 'fr' ? otherItem.fr : otherItem.en;
      if (answer.isNotEmpty && !options.contains(answer)) {
        options.add(answer);
      }
    }

    while (options.length < 4) {
      options.add('Option ${options.length}');
    }

    options.shuffle();

    return Question(
      id: 'rev_${item.id}_$index',
      subject: _parseSubject(item.subject),
      question: 'Traduisez "$sourceText"',
      options: options,
      correctAnswer: correctAnswer,
      type: QuestionType.reverseTranslation,
    );
  }

  static Question _createPhoneticQuestion(
    LanguageItem item,
    String sourceLang,
    String targetLang,
    int index,
  ) {
    final correctAnswer = item.getTranslation(sourceLang, targetLang);

    final options = [correctAnswer];
    final otherItems = getRandomItems([item], 3);

    for (final otherItem in otherItems) {
      final answer = otherItem.getTranslation(sourceLang, targetLang);
      if (answer.isNotEmpty && !options.contains(answer)) {
        options.add(answer);
      }
    }

    while (options.length < 4) {
      options.add('Option ${options.length}');
    }

    options.shuffle();

    return Question(
      id: 'pho_${item.id}_$index',
      subject: _parseSubject(item.subject),
      question: 'Comment s\'écrit ce qui se prononce "${item.phonetic}" ?',
      options: options,
      correctAnswer: correctAnswer,
      type: QuestionType.phonetic,
    );
  }

  static Question _createMatchingQuestion(
    LanguageItem item,
    String sourceLang,
    String targetLang,
    int index,
  ) {
    final sourceText = sourceLang == 'fr' ? item.fr : item.en;
    final targetText = item.getTranslation(sourceLang, targetLang);

    return Question(
      id: 'mat_${item.id}_$index',
      subject: _parseSubject(item.subject),
      question: 'Associez "$sourceText" avec sa traduction',
      options: [targetText],
      correctAnswer: targetText,
      phoneticHint: item.phonetic,
      type: QuestionType.matching,
    );
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
