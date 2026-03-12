enum UnitStatus { notStarted, inProgress, completed }

enum FlashcardResult { know, hard, later }

enum AppLanguage { ru, kz, en }

enum UserRole { student, teacher }

class UserProfile {
  UserProfile({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.groupCode,
    required this.bookId,
    this.dailyGoal = 10,
  });

  final String email;
  final String firstName;
  final String lastName;
  final UserRole role;
  final String groupCode;
  final String bookId;
  final int dailyGoal;

  String get fullName => '$firstName $lastName';
}

class WordEntry {
  WordEntry({
    required this.id,
    required this.en,
    required this.ru,
    required this.kz,
    required this.definitionA1,
    required this.example,
  });

  final String id;
  final String en;
  final String ru;
  final String kz;
  final String definitionA1;
  final String example;
}

class StudyUnit {
  StudyUnit({
    required this.id,
    required this.title,
    required this.order,
    required this.words,
  });

  final String id;
  final String title;
  final int order;
  final List<WordEntry> words;
}

class Book {
  Book({
    required this.id,
    required this.title,
    required this.level,
    required this.units,
  });

  final String id;
  final String title;
  final String level;
  final List<StudyUnit> units;
}

class WordProgress {
  const WordProgress({
    this.isFavorite = false,
    this.mastery = 0,
    this.reviewCount = 0,
    this.wrongCount = 0,
  });

  final bool isFavorite;
  final int mastery;
  final int reviewCount;
  final int wrongCount;

  WordProgress copyWith({
    bool? isFavorite,
    int? mastery,
    int? reviewCount,
    int? wrongCount,
  }) {
    return WordProgress(
      isFavorite: isFavorite ?? this.isFavorite,
      mastery: mastery ?? this.mastery,
      reviewCount: reviewCount ?? this.reviewCount,
      wrongCount: wrongCount ?? this.wrongCount,
    );
  }
}

class UnitProgress {
  const UnitProgress({this.learnedWords = 0, this.quizScore = 0});

  final int learnedWords;
  final int quizScore;

  UnitStatus statusForTotal(int totalWords) {
    if (learnedWords == 0) return UnitStatus.notStarted;
    if (learnedWords >= totalWords) return UnitStatus.completed;
    return UnitStatus.inProgress;
  }

  double ratioForTotal(int totalWords) {
    if (totalWords == 0) return 0;
    return learnedWords / totalWords;
  }

  UnitProgress copyWith({int? learnedWords, int? quizScore}) {
    return UnitProgress(
      learnedWords: learnedWords ?? this.learnedWords,
      quizScore: quizScore ?? this.quizScore,
    );
  }
}

class QuizQuestion {
  QuizQuestion({
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.typeLabel,
    this.audioText,
  });

  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String typeLabel;
  final String? audioText;
}

class CustomWordNote {
  const CustomWordNote({
    required this.id,
    required this.word,
    required this.translation,
    required this.note,
    required this.createdAt,
  });

  final String id;
  final String word;
  final String translation;
  final String note;
  final DateTime createdAt;

  CustomWordNote copyWith({
    String? id,
    String? word,
    String? translation,
    String? note,
    DateTime? createdAt,
  }) {
    return CustomWordNote(
      id: id ?? this.id,
      word: word ?? this.word,
      translation: translation ?? this.translation,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class GroupUnitAssignment {
  const GroupUnitAssignment({
    required this.groupCode,
    required this.unitId,
    required this.unitTitle,
    required this.bookId,
    required this.assignedBy,
    required this.deadline,
    required this.createdAt,
  });

  final String groupCode;
  final String unitId;
  final String unitTitle;
  final String bookId;
  final String assignedBy;
  final String deadline;
  final DateTime createdAt;

  GroupUnitAssignment copyWith({
    String? groupCode,
    String? unitId,
    String? unitTitle,
    String? bookId,
    String? assignedBy,
    String? deadline,
    DateTime? createdAt,
  }) {
    return GroupUnitAssignment(
      groupCode: groupCode ?? this.groupCode,
      unitId: unitId ?? this.unitId,
      unitTitle: unitTitle ?? this.unitTitle,
      bookId: bookId ?? this.bookId,
      assignedBy: assignedBy ?? this.assignedBy,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
