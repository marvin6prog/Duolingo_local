import 'package:google_generative_ai/google_generative_ai.dart' as genai;
import '../models/language_data.dart' as ld;

class GeminiService {
  static const String _apiKey = 'AIzaSyAnJiBE9J8rWi4Ik4jNXDnHfRW4TEPAIi4';
  static late final genai.GenerativeModel _model;

  static void initialize() {
    _model = genai.GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
    );
  }

  static Future<String> getLanguageHelp({
    required String query,
    required ld.Language targetLanguage,
    required String sourceLanguage,
  }) async {
    try {
      final languageName = targetLanguage.name;
      final prompt = '''
Tu es un assistant expert pour l'apprentissage des langues camerounaises, spécialisé en $languageName.
L'utilisateur parle $sourceLanguage et pose la question suivante: "$query"

Réponds de manière:
1. Précise et utile pour l'apprentissage
2. Inclusive de la prononciation phonétique si possible
3. Pédagogique avec des exemples si nécessaire
4. En $sourceLanguage

Si la question concerne un mot spécifique, donne sa traduction, sa prononciation et un exemple d'utilisation.
Si la question concerne la grammaire, explique les règles clairement.
Sois concis mais complet.
''';

      final content = genai.Content.text(prompt);
      final response = await _model.generateContent([content]);
      return response.text ?? 'Désolé, je n\'ai pas pu traiter votre demande.';
    } catch (e) {
      print('Error calling Gemini: $e');
      return 'Désolé, une erreur est survenue. Veuillez réessayer.';
    }
  }

  static Future<String> getWordInfo({
    required String word,
    required ld.Language targetLanguage,
    required String sourceLanguage,
  }) async {
    try {
      final languageName = targetLanguage.name;
      final prompt = '''
Donne-moi des informations complètes sur le mot "$word" en $languageName pour un apprenant $sourceLanguage:

1. Traduction en $sourceLanguage
2. Prononciation phonétique
3. Type de mot (nom, verbe, adjectif, etc.)
4. Un exemple de phrase simple
5. Contexte culturel si pertinent

Sois précis et formaté de manière lisible.
''';

      final content = genai.Content.text(prompt);
      final response = await _model.generateContent([content]);
      return response.text ?? 'Informations non disponibles pour ce mot.';
    } catch (e) {
      print('Error getting word info: $e');
      return 'Impossible de récupérer les informations pour ce mot.';
    }
  }

  static Future<String> getPronunciationHelp({
    required String word,
    required ld.Language targetLanguage,
  }) async {
    try {
      final languageName = targetLanguage.name;
      final prompt = '''
Explique comment prononcer le mot "$word" en $languageName:

1. Décomposition phonétique syllabe par syllabe
2. Sons difficiles à expliquer
3. Comparaisons avec des sons français si possible
4. Conseils pratiques pour une bonne prononciation

Sois très détaillé dans l'explication phonétique.
''';

      final content = genai.Content.text(prompt);
      final response = await _model.generateContent([content]);
      return response.text ?? 'Aide de prononciation non disponible.';
    } catch (e) {
      print('Error getting pronunciation help: $e');
      return 'Impossible de fournir une aide de prononciation.';
    }
  }

  static Future<String> getGrammarExplanation({
    required String topic,
    required ld.Language targetLanguage,
    required String sourceLanguage,
  }) async {
    try {
      final languageName = targetLanguage.name;
      final prompt = '''
Explique la règle de grammaire "$topic" en $languageName pour un apprenant $sourceLanguage:

1. La règle clairement expliquée
2. Exemples avec traduction
3. Exceptions si elles existent
4. Conseils pour éviter les erreurs courantes

Sois pédagogique et structuré.
''';

      final content = genai.Content.text(prompt);
      final response = await _model.generateContent([content]);
      return response.text ?? 'Explication grammaticale non disponible.';
    } catch (e) {
      print('Error getting grammar explanation: $e');
      return 'Impossible de fournir cette explication grammaticale.';
    }
  }
}
