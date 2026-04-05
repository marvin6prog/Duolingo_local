import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/language_data.dart';
import '../services/firebase_service.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  UserProgress? _userProgress;
  Map<String, dynamic>? _userProfile;
  bool _isLoading = false;

  User? get user => _user;
  UserProgress? get userProgress => _userProgress;
  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  UserProvider() {
    _authStateListener();
  }

  void _authStateListener() {
    FirebaseService.authStateChanges.listen((User? user) {
      _user = user;
      if (user != null) {
        _loadUserData();
      } else {
        _userProgress = null;
        _userProfile = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserData() async {
    if (_user == null) return;
    
    _setLoading(true);
    try {
      await Future.wait([
        _loadUserProgress(),
        _loadUserProfile(),
      ]);
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadUserProgress() async {
    _userProgress = await FirebaseService.getUserProgress(_user!.uid);
    
    if (_userProgress == null) {
      _userProgress = await FirebaseService.createInitialUserProgress(_user!.uid);
      await FirebaseService.saveUserProgress(_userProgress!);
    }
  }

  Future<void> _loadUserProfile() async {
    _userProfile = await FirebaseService.getUserProfile(_user!.uid);
  }

  Future<void> signIn(String email, String password) async {
    _setLoading(true);
    try {
      await FirebaseService.signInWithEmail(email, password);
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> signUp(String email, String password, String displayName) async {
    _setLoading(true);
    try {
      final credential = await FirebaseService.signUpWithEmail(email, password);
      
      final progress = await FirebaseService.createInitialUserProgress(credential.user!.uid);
      await FirebaseService.saveUserProgress(progress);
      
      await FirebaseService.saveUserProfile(
        userId: credential.user!.uid,
        displayName: displayName,
        sourceLanguage: Language.bulu,
        targetLanguage: Language.bulu,
      );
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await FirebaseService.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await FirebaseService.resetPassword(email);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addXP(int xp) async {
    if (_userProgress == null || _user == null) return;
    
    try {
      await FirebaseService.updateUserXP(_user!.uid, xp);
      _userProgress!.totalXP += xp;
      notifyListeners();
    } catch (e) {
      print('Error adding XP: $e');
    }
  }

  Future<void> updateHearts(int hearts) async {
    if (_userProgress == null || _user == null) return;
    
    try {
      await FirebaseService.updateUserHearts(_user!.uid, hearts);
      _userProgress!.hearts = hearts;
      notifyListeners();
    } catch (e) {
      print('Error updating hearts: $e');
    }
  }

  Future<void> completeSubjectLevel(Subject subject, int level) async {
    if (_userProgress == null || _user == null) return;
    
    try {
      final currentLevel = _userProgress!.completedLevels[subject] ?? 0;
      if (level > currentLevel) {
        await FirebaseService.updateSubjectLevel(_user!.uid, subject, level);
        _userProgress!.completedLevels[subject] = level;
        notifyListeners();
      }
    } catch (e) {
      print('Error completing subject level: $e');
    }
  }

  Future<void> updateStreak() async {
    if (_userProgress == null || _user == null) return;
    
    try {
      final now = DateTime.now();
      final lastLesson = _userProgress!.lastLessonDate;
      
      int newStreak = 1;
      
      if (lastLesson != null) {
        final difference = now.difference(lastLesson).inDays;
        if (difference == 1) {
          newStreak = (_userProgress!.streak) + 1;
        } else if (difference > 1) {
          newStreak = 1;
        } else {
          newStreak = _userProgress!.streak;
        }
      }
      
      await FirebaseService.updateStreak(_user!.uid, newStreak);
      _userProgress!.streak = newStreak;
      _userProgress!.lastLessonDate = now;
      notifyListeners();
    } catch (e) {
      print('Error updating streak: $e');
    }
  }

  Future<void> updateLanguagePreferences({
    required Language sourceLanguage,
    required Language targetLanguage,
  }) async {
    if (_user == null) return;
    
    try {
      await FirebaseService.saveUserProfile(
        userId: _user!.uid,
        displayName: _userProfile?['displayName'] ?? _user!.email?.split('@')[0] ?? 'User',
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
      );
      
      if (_userProgress != null) {
        _userProgress!.sourceLanguage = sourceLanguage;
        _userProgress!.targetLanguage = targetLanguage;
        await FirebaseService.saveUserProgress(_userProgress!);
      }
      
      await _loadUserProfile();
      notifyListeners();
    } catch (e) {
      print('Error updating language preferences: $e');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
