import 'dart:math';

import 'package:flutter/material.dart';

import '../data/demo_content.dart';
import '../localization/app_texts.dart';
import '../models/models.dart';
import '../services/local_storage_service.dart';

class AppController extends ChangeNotifier {
  AppController._(this._storage) {
    _restoreState();
  }

  static Future<AppController> create() async {
    final storage = await LocalStorageService.create();
    return AppController._(storage);
  }

  final LocalStorageService _storage;
  final List<Book> books = buildDemoBooks();
  final Map<String, WordProgress> _wordStats = {};
  final Map<String, UnitProgress> _unitStats = {};
  final Map<String, Map<String, dynamic>> _accounts = {};
  final List<CustomWordNote> _customWords = [];
  final Map<String, GroupUnitAssignment> _groupAssignments = {};

  UserProfile? _user;
  int _xp = 0;
  int _streak = 1;
  int _dailyLearned = 0;
  String _lastStudyDate = _todayKey();
  int _currentTab = 0;
  bool _remindersEnabled = true;
  AppLanguage _language = AppLanguage.ru;
  String? _activeEmail;

  UserProfile? get user => _user;
  int get xp => _xp;
  int get streak => _streak;
  int get currentTab => _currentTab;
  int get dailyLearned => _dailyLearned;
  bool get remindersEnabled => _remindersEnabled;
  AppLanguage get language => _language;
  List<CustomWordNote> get customWords => List.unmodifiable(_customWords);
  bool get isTeacher => _user?.role == UserRole.teacher;
  GroupUnitAssignment? get currentGroupAssignment {
    final groupCode = _user?.groupCode;
    if (groupCode == null) return null;
    return _groupAssignments[groupCode];
  }
  GroupUnitAssignment? get latestAssignment {
    if (_groupAssignments.isEmpty) return null;
    final items = _groupAssignments.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items.first;
  }

  int get level => (_xp / 120).floor() + 1;
  int get remainingDailyGoal {
    _refreshDailyProgressIfNeeded();
    return max(0, (_user?.dailyGoal ?? 10) - _dailyLearned);
  }
  double get dailyGoalProgress {
    _refreshDailyProgressIfNeeded();
    final goal = (_user?.dailyGoal ?? 10).toDouble();
    if (goal == 0) return 0;
    return (_dailyLearned / goal).clamp(0, 1);
  }

  bool get isAuthorized => _user != null;

  set currentTab(int value) {
    _currentTab = value;
    _notifyAndPersist();
  }

  void setLanguage(AppLanguage language) {
    _language = language;
    _notifyAndPersist();
  }

  String t(String key) => AppTexts.tr(_language, key);

  String? login({required String email, required String password}) {
    final normalizedEmail = email.trim().toLowerCase();
    final trimmedPassword = password.trim();

    if (!_isValidEmail(normalizedEmail)) {
      return 'Почта дұрыс емес';
    }
    if (trimmedPassword.isEmpty) {
      return 'Құпиясөзді енгізіңіз';
    }

    final account = _accounts[normalizedEmail];
    if (account == null) {
      return 'Мұндай аккаунт табылмады';
    }
    if ((account['password'] as String? ?? '') != trimmedPassword) {
      return 'Құпиясөз қате';
    }

    _activeEmail = normalizedEmail;
    _loadAccount(normalizedEmail);
    _notifyAndPersist();
    return null;
  }

  String? register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required UserRole role,
    required String groupCode,
    required String bookId,
  }) {
    final normalizedEmail = email.trim().toLowerCase();
    final trimmedPassword = password.trim();

    if (!_isValidEmail(normalizedEmail)) {
      return 'Почта дұрыс емес';
    }
    if (trimmedPassword.length < 4) {
      return 'Құпиясөз кемінде 4 таңба болуы керек';
    }
    if (_accounts.containsKey(normalizedEmail)) {
      return 'Бұл почтаға аккаунт бұрын тіркелген';
    }

    _user = UserProfile(
      email: normalizedEmail,
      firstName: firstName,
      lastName: lastName,
      role: role,
      groupCode: groupCode,
      bookId: bookId,
    );
    _xp = 0;
    _streak = 1;
    _dailyLearned = 0;
    _currentTab = 0;
    _remindersEnabled = true;
    _wordStats.clear();
    _unitStats.clear();
    _customWords.clear();
    _activeEmail = normalizedEmail;
    _accounts[normalizedEmail] = <String, dynamic>{'password': trimmedPassword};
    _saveCurrentAccount();
    _notifyAndPersist();
    return null;
  }

  void logout() {
    _saveCurrentAccount();
    _user = null;
    _xp = 0;
    _streak = 1;
    _dailyLearned = 0;
    _currentTab = 0;
    _remindersEnabled = true;
    _activeEmail = null;
    _wordStats.clear();
    _unitStats.clear();
    _customWords.clear();
    _notifyAndPersist();
  }

  Book get selectedBook {
    final id = _user?.bookId;
    return books.firstWhere((b) => b.id == id, orElse: () => books.first);
  }

  List<StudyUnit> get units => selectedBook.units;

  UnitProgress unitProgress(String unitId) =>
      _unitStats[unitId] ?? const UnitProgress();

  WordProgress wordProgress(String wordId) =>
      _wordStats[wordId] ?? const WordProgress();

  void toggleFavorite(String wordId) {
    final current = wordProgress(wordId);
    _wordStats[wordId] = current.copyWith(isFavorite: !current.isFavorite);
    _notifyAndPersist();
  }

  void markWord(String unitId, String wordId, {required bool known}) {
    _refreshDailyProgressIfNeeded();
    final current = wordProgress(wordId);
    final mastery = known
        ? min(current.mastery + 1, 5)
        : max(current.mastery - 1, 0);
    final wrong = known ? current.wrongCount : current.wrongCount + 1;

    _wordStats[wordId] = current.copyWith(
      mastery: mastery,
      wrongCount: wrong,
      reviewCount: current.reviewCount + 1,
    );

    final unit = units.firstWhere((u) => u.id == unitId);
    final learned = unit.words
        .where((word) => wordProgress(word.id).mastery >= 2)
        .length;
    final oldProgress = unitProgress(unitId);
    _unitStats[unitId] = oldProgress.copyWith(learnedWords: learned);

    if (known) {
      _xp += 5;
      _dailyLearned += 1;
    } else {
      _xp += 1;
    }
    _notifyAndPersist();
  }

  void applyFlashcard(String unitId, String wordId, FlashcardResult result) {
    switch (result) {
      case FlashcardResult.know:
        markWord(unitId, wordId, known: true);
      case FlashcardResult.hard:
        markWord(unitId, wordId, known: false);
      case FlashcardResult.later:
        _xp += 1;
        _notifyAndPersist();
    }
  }

  void toggleReminders(bool value) {
    _remindersEnabled = value;
    _notifyAndPersist();
  }

  void setDailyGoal(int value) {
    final current = _user;
    if (current == null) return;
    _user = UserProfile(
      email: current.email,
      firstName: current.firstName,
      lastName: current.lastName,
      role: current.role,
      groupCode: current.groupCode,
      bookId: current.bookId,
      dailyGoal: value.clamp(1, 100),
    );
    _notifyAndPersist();
  }

  void saveQuizResult(
    String unitId,
    int scorePercent,
    List<String> wrongWordIds,
  ) {
    final progress = unitProgress(unitId);
    _unitStats[unitId] = progress.copyWith(quizScore: scorePercent);
    _xp += max(10, scorePercent ~/ 4);
    if (scorePercent >= 80) {
      _streak += 1;
    }

    for (final id in wrongWordIds) {
      final current = wordProgress(id);
      _wordStats[id] = current.copyWith(wrongCount: current.wrongCount + 1);
    }
    _notifyAndPersist();
  }

  int get totalWords {
    return units.fold(0, (sum, u) => sum + u.words.length);
  }

  int get learnedWords {
    final allWords = units.expand((u) => u.words);
    return allWords.where((w) => wordProgress(w.id).mastery >= 2).length;
  }

  int get completedUnits {
    return units
        .where(
          (u) =>
              unitProgress(u.id).statusForTotal(u.words.length) ==
              UnitStatus.completed,
        )
        .length;
  }

  double get overallProgress => totalWords == 0 ? 0 : learnedWords / totalWords;

  List<WordEntry> get favoriteWords {
    final allWords = units.expand((u) => u.words);
    return allWords.where((w) => wordProgress(w.id).isFavorite).toList();
  }

  List<WordEntry> get weakWords {
    final allWords = units.expand((u) => u.words).toList();
    allWords.sort(
      (a, b) => wordProgress(
        b.id,
      ).wrongCount.compareTo(wordProgress(a.id).wrongCount),
    );
    return allWords
        .where((w) => wordProgress(w.id).wrongCount > 0)
        .take(10)
        .toList();
  }

  List<WordEntry> get todayWords {
    final allWords = units.expand((u) => u.words).toList();
    allWords.sort(
      (a, b) => wordProgress(
        a.id,
      ).reviewCount.compareTo(wordProgress(b.id).reviewCount),
    );
    return allWords.take(8).toList();
  }

  WordEntry get wordOfDay {
    final allWords = units.expand((u) => u.words).toList();
    final index = DateTime.now().day % allWords.length;
    return allWords[index];
  }

  WordEntry randomWord() {
    final allWords = units.expand((u) => u.words).toList();
    return allWords[Random().nextInt(allWords.length)];
  }

  StudyUnit get recommendedUnit {
    return units.firstWhere(
      (u) =>
          unitProgress(u.id).statusForTotal(u.words.length) !=
          UnitStatus.completed,
      orElse: () => units.first,
    );
  }

  int masteredWordsInUnit(StudyUnit unit) {
    return unit.words.where((w) => wordProgress(w.id).mastery >= 2).length;
  }

  List<WordEntry> smartReviewQueue({int limit = 12}) {
    final allWords = units.expand((u) => u.words).toList();
    allWords.sort((a, b) {
      final pa = wordProgress(a.id);
      final pb = wordProgress(b.id);
      final scoreA = pa.wrongCount * 3 + (2 - pa.mastery) + pa.reviewCount;
      final scoreB = pb.wrongCount * 3 + (2 - pb.mastery) + pb.reviewCount;
      return scoreB.compareTo(scoreA);
    });
    return allWords.take(limit).toList();
  }

  String achievementLabel() {
    if (learnedWords >= 50) return 'Word Master';
    if (streak >= 7) return '7-day Streak';
    if (xp >= 200) return 'XP Explorer';
    return 'New Learner';
  }

  void addCustomWord({
    required String word,
    required String translation,
    required String note,
  }) {
    _customWords.insert(
      0,
      CustomWordNote(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        word: word.trim(),
        translation: translation.trim(),
        note: note.trim(),
        createdAt: DateTime.now(),
      ),
    );
    _notifyAndPersist();
  }

  void updateCustomWord({
    required String id,
    required String word,
    required String translation,
    required String note,
  }) {
    final index = _customWords.indexWhere((item) => item.id == id);
    if (index == -1) return;
    _customWords[index] = _customWords[index].copyWith(
      word: word.trim(),
      translation: translation.trim(),
      note: note.trim(),
    );
    _notifyAndPersist();
  }

  void deleteCustomWord(String id) {
    _customWords.removeWhere((item) => item.id == id);
    _notifyAndPersist();
  }

  void assignUnitToGroup({
    required String groupCode,
    required String unitId,
    required String deadline,
  }) {
    final assignedBook = books.firstWhere(
      (book) => book.units.any((unit) => unit.id == unitId),
    );
    final assignedUnit = assignedBook.units.firstWhere(
      (unit) => unit.id == unitId,
    );
    _groupAssignments[groupCode] = GroupUnitAssignment(
      groupCode: groupCode,
      unitId: assignedUnit.id,
      unitTitle: assignedUnit.title,
      bookId: assignedBook.id,
      assignedBy: _user?.fullName ?? 'Teacher',
      deadline: deadline.trim(),
      createdAt: DateTime.now(),
    );
    _notifyAndPersist();
  }

  void changeBook(String bookId) {
    final current = _user;
    if (current == null) return;
    _user = UserProfile(
      email: current.email,
      firstName: current.firstName,
      lastName: current.lastName,
      role: current.role,
      groupCode: current.groupCode,
      bookId: bookId,
      dailyGoal: current.dailyGoal,
    );
    _wordStats.clear();
    _unitStats.clear();
    _dailyLearned = 0;
    _notifyAndPersist();
  }

  List<QuizQuestion> buildQuiz(StudyUnit unit) {
    final words = unit.words;
    if (words.length < 4) return [];

    return [
      QuizQuestion(
        typeLabel: 'Multiple Choice',
        prompt: 'Выберите перевод слова "${words[0].en}"',
        options: [words[0].ru, words[1].ru, words[2].ru, words[3].ru],
        correctIndex: 0,
        explanation: '${words[0].en} = ${words[0].ru}',
      ),
      QuizQuestion(
        typeLabel: 'Matching',
        prompt: 'Найдите правильную пару для "${words[1].en}"',
        options: [words[2].ru, words[1].ru, words[3].ru, words[0].ru],
        correctIndex: 1,
        explanation: '${words[1].en} = ${words[1].ru}',
      ),
      QuizQuestion(
        typeLabel: 'Definition',
        prompt: 'Какая definition подходит к "${words[2].en}"?',
        options: [
          words[3].definitionA1,
          words[2].definitionA1,
          words[1].definitionA1,
          words[0].definitionA1,
        ],
        correctIndex: 1,
        explanation: words[2].definitionA1,
      ),
      QuizQuestion(
        typeLabel: 'Fill in the blank',
        prompt: 'I do my ____ every evening.',
        options: [words[0].en, words[3].en, words[2].en, words[1].en],
        correctIndex: words[0].en == 'homework' ? 0 : 2,
        explanation: 'Правильный ответ: homework',
      ),
      QuizQuestion(
        typeLabel: 'Listening',
        prompt:
            'Нажмите на "play" и выберите услышанное слово (демо): ${words[3].en}',
        options: [words[3].en, words[0].en, words[1].en, words[2].en],
        correctIndex: 0,
        explanation: 'Это демо listening режима.',
        audioText: words[3].en,
      ),
    ];
  }

  void _restoreState() {
    final state = _storage.loadState();
    _language = _parseLanguage(state['language']) ?? AppLanguage.ru;

    final rawAccounts = state['accounts'];
    if (rawAccounts is Map) {
      for (final entry in rawAccounts.entries) {
        final key = entry.key;
        final value = entry.value;
        if (key is String && value is Map) {
          _accounts[key] = Map<String, dynamic>.from(value);
        }
      }
    }

    final activeEmail = state['activeEmail'];
    if (activeEmail is String && _accounts.containsKey(activeEmail)) {
      _activeEmail = activeEmail;
      _loadAccount(activeEmail);
    }
  }

  void _loadAccount(String email) {
    final account = _accounts[email];
    if (account == null) return;

    final profile = Map<String, dynamic>.from(
      account['profile'] as Map? ?? const <String, dynamic>{},
    );
    _user = UserProfile(
      email: email,
      firstName: profile['firstName'] as String? ?? 'Студент',
      lastName: profile['lastName'] as String? ?? 'Solutions',
      role: _parseRole(profile['role']) ?? UserRole.student,
      groupCode: profile['groupCode'] as String? ?? '1f1',
      bookId: profile['bookId'] as String? ?? books.first.id,
      dailyGoal: profile['dailyGoal'] as int? ?? 10,
    );
    _xp = account['xp'] as int? ?? 0;
    _streak = account['streak'] as int? ?? 1;
    _dailyLearned = account['dailyLearned'] as int? ?? 0;
    _lastStudyDate = account['lastStudyDate'] as String? ?? _todayKey();
    _currentTab = account['currentTab'] as int? ?? 0;
    _remindersEnabled = account['remindersEnabled'] as bool? ?? true;

    _wordStats
      ..clear()
      ..addAll(_deserializeWordStats(account['wordStats']));
    _unitStats
      ..clear()
      ..addAll(_deserializeUnitStats(account['unitStats']));
    _customWords
      ..clear()
      ..addAll(_deserializeCustomWords(account['customWords']));
    _groupAssignments
      ..clear()
      ..addAll(_deserializeAssignments(account['groupAssignments']));
  }

  void _saveCurrentAccount() {
    final user = _user;
    final email = _activeEmail;
    if (user == null || email == null) return;

    final existing = _accounts[email] ?? <String, dynamic>{};
    _accounts[email] = <String, dynamic>{
      'password': existing['password'] as String? ?? '',
      'profile': <String, dynamic>{
        'firstName': user.firstName,
        'lastName': user.lastName,
        'role': user.role.name,
        'groupCode': user.groupCode,
        'bookId': user.bookId,
        'dailyGoal': user.dailyGoal,
      },
      'xp': _xp,
      'streak': _streak,
      'dailyLearned': _dailyLearned,
      'lastStudyDate': _lastStudyDate,
      'currentTab': _currentTab,
      'remindersEnabled': _remindersEnabled,
      'wordStats': _serializeWordStats(),
      'unitStats': _serializeUnitStats(),
      'customWords': _serializeCustomWords(),
      'groupAssignments': _serializeAssignments(),
    };
  }

  void _notifyAndPersist() {
    _saveCurrentAccount();
    _persistState();
    notifyListeners();
  }

  void _persistState() {
    _storage.saveState(<String, dynamic>{
      'language': _language.name,
      'activeEmail': _activeEmail,
      'accounts': _accounts,
    });
  }

  Map<String, dynamic> _serializeWordStats() {
    return _wordStats.map(
      (key, value) => MapEntry(
        key,
        <String, dynamic>{
          'isFavorite': value.isFavorite,
          'mastery': value.mastery,
          'reviewCount': value.reviewCount,
          'wrongCount': value.wrongCount,
        },
      ),
    );
  }

  Map<String, dynamic> _serializeUnitStats() {
    return _unitStats.map(
      (key, value) => MapEntry(
        key,
        <String, dynamic>{
          'learnedWords': value.learnedWords,
          'quizScore': value.quizScore,
        },
      ),
    );
  }

  List<Map<String, dynamic>> _serializeCustomWords() {
    return _customWords
        .map(
          (item) => <String, dynamic>{
            'id': item.id,
            'word': item.word,
            'translation': item.translation,
            'note': item.note,
            'createdAt': item.createdAt.toIso8601String(),
          },
        )
        .toList();
  }

  Map<String, dynamic> _serializeAssignments() {
    return _groupAssignments.map(
      (key, value) => MapEntry(
        key,
        <String, dynamic>{
          'groupCode': value.groupCode,
          'unitId': value.unitId,
          'unitTitle': value.unitTitle,
          'bookId': value.bookId,
          'assignedBy': value.assignedBy,
          'deadline': value.deadline,
          'createdAt': value.createdAt.toIso8601String(),
        },
      ),
    );
  }

  Map<String, WordProgress> _deserializeWordStats(Object? raw) {
    final result = <String, WordProgress>{};
    if (raw is! Map) return result;

    for (final entry in raw.entries) {
      final key = entry.key;
      final value = entry.value;
      if (key is! String || value is! Map) continue;
      result[key] = WordProgress(
        isFavorite: value['isFavorite'] as bool? ?? false,
        mastery: value['mastery'] as int? ?? 0,
        reviewCount: value['reviewCount'] as int? ?? 0,
        wrongCount: value['wrongCount'] as int? ?? 0,
      );
    }
    return result;
  }

  Map<String, UnitProgress> _deserializeUnitStats(Object? raw) {
    final result = <String, UnitProgress>{};
    if (raw is! Map) return result;

    for (final entry in raw.entries) {
      final key = entry.key;
      final value = entry.value;
      if (key is! String || value is! Map) continue;
      result[key] = UnitProgress(
        learnedWords: value['learnedWords'] as int? ?? 0,
        quizScore: value['quizScore'] as int? ?? 0,
      );
    }
    return result;
  }

  List<CustomWordNote> _deserializeCustomWords(Object? raw) {
    if (raw is! List) return const [];

    return raw.whereType<Map>().map((item) {
      final createdAtRaw = item['createdAt'] as String?;
      return CustomWordNote(
        id: item['id'] as String? ?? DateTime.now().toIso8601String(),
        word: item['word'] as String? ?? '',
        translation: item['translation'] as String? ?? '',
        note: item['note'] as String? ?? '',
        createdAt:
            DateTime.tryParse(createdAtRaw ?? '') ?? DateTime.now(),
      );
    }).toList();
  }

  Map<String, GroupUnitAssignment> _deserializeAssignments(Object? raw) {
    final result = <String, GroupUnitAssignment>{};
    if (raw is! Map) return result;

    for (final entry in raw.entries) {
      final key = entry.key;
      final value = entry.value;
      if (key is! String || value is! Map) continue;
      result[key] = GroupUnitAssignment(
        groupCode: value['groupCode'] as String? ?? key,
        unitId: value['unitId'] as String? ?? '',
        unitTitle: value['unitTitle'] as String? ?? 'Unit',
        bookId: value['bookId'] as String? ?? books.first.id,
        assignedBy: value['assignedBy'] as String? ?? 'Teacher',
        deadline: value['deadline'] as String? ?? '',
        createdAt:
            DateTime.tryParse(value['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );
    }
    return result;
  }

  AppLanguage? _parseLanguage(Object? raw) {
    if (raw is! String) return null;
    for (final language in AppLanguage.values) {
      if (language.name == raw) return language;
    }
    return null;
  }

  UserRole? _parseRole(Object? raw) {
    if (raw is! String) return null;
    for (final role in UserRole.values) {
      if (role.name == raw) return role;
    }
    return null;
  }

  bool _isValidEmail(String email) {
    return email.contains('@') && email.contains('.');
  }

  void _refreshDailyProgressIfNeeded() {
    final today = _todayKey();
    if (_lastStudyDate == today) return;
    _lastStudyDate = today;
    _dailyLearned = 0;
    _saveCurrentAccount();
    _persistState();
  }

  static String _todayKey() {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }
}
