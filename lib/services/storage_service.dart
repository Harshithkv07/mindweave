import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

// ============================================================================
// 1. STRONGLY-TYPED MODELS
// ============================================================================

/// Represents an individual cognitive training session.
class CognitiveSession {
  final String id;
  final String gameType;
  final DateTime timestamp;
  final int errorCounts;
  final int completionTimeSeconds;
  final double accuracy;
  final int attempts;
  final String difficulty;

  CognitiveSession({
    required this.id,
    required this.gameType,
    required this.timestamp,
    required this.errorCounts,
    required this.completionTimeSeconds,
    required this.accuracy,
    required this.attempts,
    this.difficulty = 'Medium',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'gameType': gameType,
      'timestamp': timestamp.toIso8601String(),
      'errorCounts': errorCounts,
      'completionTimeSeconds': completionTimeSeconds,
      'accuracy': accuracy,
      'attempts': attempts,
      'difficulty': difficulty,
    };
  }

  factory CognitiveSession.fromMap(Map<String, dynamic> map) {
    return CognitiveSession(
      id: map['id'] as String,
      gameType: map['gameType'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      errorCounts: (map['errorCounts'] as num).toInt(),
      completionTimeSeconds: (map['completionTimeSeconds'] as num).toInt(),
      accuracy: (map['accuracy'] as num).toDouble(),
      attempts: (map['attempts'] as num).toInt(),
      difficulty: (map['difficulty'] as String?) ?? 'Medium',
    );
  }
}

/// Represents a scheduled daily routine or medication reminder.
class DailyReminder {
  final String id;
  final String title;
  final String time;
  final String category;
  bool isEnabled;
  final DateTime timestamp;

  DailyReminder({
    required this.id,
    required this.title,
    required this.time,
    required this.category,
    this.isEnabled = true,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'time': time,
      'category': category,
      'isEnabled': isEnabled,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory DailyReminder.fromMap(Map<String, dynamic> map) {
    return DailyReminder(
      id: map['id'] as String,
      title: map['title'] as String,
      time: map['time'] as String,
      category: map['category'] as String,
      isEnabled: map['isEnabled'] as bool? ?? true,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }
}

/// Represents the localized personal profile and cognitive domain baseline scores.
class PatientProfile {
  final String patientId;
  final String name;
  final String email;
  final String language;
  final double baselineScore;
  final DateTime lastUpdated;
  final double memoryScore;
  final double attentionScore;
  final double patternScore;
  final double routineScore;

  PatientProfile({
    required this.patientId,
    required this.name,
    required this.email,
    required this.language,
    this.baselineScore = 75.0,
    required this.lastUpdated,
    this.memoryScore = 80.0,
    this.attentionScore = 75.0,
    this.patternScore = 78.0,
    this.routineScore = 82.0,
  });

  PatientProfile copyWith({
    String? patientId,
    String? name,
    String? email,
    String? language,
    double? baselineScore,
    DateTime? lastUpdated,
    double? memoryScore,
    double? attentionScore,
    double? patternScore,
    double? routineScore,
  }) {
    return PatientProfile(
      patientId: patientId ?? this.patientId,
      name: name ?? this.name,
      email: email ?? this.email,
      language: language ?? this.language,
      baselineScore: baselineScore ?? this.baselineScore,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      memoryScore: memoryScore ?? this.memoryScore,
      attentionScore: attentionScore ?? this.attentionScore,
      patternScore: patternScore ?? this.patternScore,
      routineScore: routineScore ?? this.routineScore,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'name': name,
      'email': email,
      'language': language,
      'baselineScore': baselineScore,
      'lastUpdated': lastUpdated.toIso8601String(),
      'memoryScore': memoryScore,
      'attentionScore': attentionScore,
      'patternScore': patternScore,
      'routineScore': routineScore,
    };
  }

  factory PatientProfile.fromMap(Map<String, dynamic> map) {
    return PatientProfile(
      patientId: map['patientId'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      language: map['language'] as String,
      baselineScore: (map['baselineScore'] as num).toDouble(),
      lastUpdated: DateTime.parse(map['lastUpdated'] as String),
      memoryScore: (map['memoryScore'] as num).toDouble(),
      attentionScore: (map['attentionScore'] as num).toDouble(),
      patternScore: (map['patternScore'] as num).toDouble(),
      routineScore: (map['routineScore'] as num).toDouble(),
    );
  }
}

// ============================================================================
// 2. STRONGLY-TYPED HIVE ADAPTERS
// ============================================================================

/// Hive TypeAdapter for CognitiveSession (typeId: 0)
class CognitiveSessionAdapter extends TypeAdapter<CognitiveSession> {
  @override
  final int typeId = 0;

  @override
  CognitiveSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CognitiveSession(
      id: fields[0] as String,
      gameType: fields[1] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(fields[2] as int),
      errorCounts: fields[3] as int,
      completionTimeSeconds: fields[4] as int,
      accuracy: fields[5] as double,
      attempts: fields[6] as int,
      difficulty: fields[7] as String? ?? 'Medium',
    );
  }

  @override
  void write(BinaryWriter writer, CognitiveSession obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.gameType)
      ..writeByte(2)
      ..write(obj.timestamp.millisecondsSinceEpoch)
      ..writeByte(3)
      ..write(obj.errorCounts)
      ..writeByte(4)
      ..write(obj.completionTimeSeconds)
      ..writeByte(5)
      ..write(obj.accuracy)
      ..writeByte(6)
      ..write(obj.attempts)
      ..writeByte(7)
      ..write(obj.difficulty);
  }
}

/// Hive TypeAdapter for DailyReminder (typeId: 1)
class DailyReminderAdapter extends TypeAdapter<DailyReminder> {
  @override
  final int typeId = 1;

  @override
  DailyReminder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyReminder(
      id: fields[0] as String,
      title: fields[1] as String,
      time: fields[2] as String,
      category: fields[3] as String,
      isEnabled: fields[4] as bool? ?? true,
      timestamp: DateTime.fromMillisecondsSinceEpoch(fields[5] as int),
    );
  }

  @override
  void write(BinaryWriter writer, DailyReminder obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.time)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.isEnabled)
      ..writeByte(5)
      ..write(obj.timestamp.millisecondsSinceEpoch);
  }
}

/// Hive TypeAdapter for PatientProfile (typeId: 2)
class PatientProfileAdapter extends TypeAdapter<PatientProfile> {
  @override
  final int typeId = 2;

  @override
  PatientProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PatientProfile(
      patientId: fields[0] as String,
      name: fields[1] as String,
      email: fields[2] as String,
      language: fields[3] as String,
      baselineScore: fields[4] as double,
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(fields[5] as int),
      memoryScore: fields[6] as double? ?? 80.0,
      attentionScore: fields[7] as double? ?? 75.0,
      patternScore: fields[8] as double? ?? 78.0,
      routineScore: fields[9] as double? ?? 82.0,
    );
  }

  @override
  void write(BinaryWriter writer, PatientProfile obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.patientId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.language)
      ..writeByte(4)
      ..write(obj.baselineScore)
      ..writeByte(5)
      ..write(obj.lastUpdated.millisecondsSinceEpoch)
      ..writeByte(6)
      ..write(obj.memoryScore)
      ..writeByte(7)
      ..write(obj.attentionScore)
      ..writeByte(8)
      ..write(obj.patternScore)
      ..writeByte(9)
      ..write(obj.routineScore);
  }
}

// ============================================================================
// 3. STORAGE SERVICE IMPLEMENTATION
// ============================================================================

class StorageService {
  static const String sessionBoxName = 'cognitive_sessions';
  static const String reminderBoxName = 'daily_reminders';
  static const String profileBoxName = 'patient_profiles';

  static Box<CognitiveSession>? _sessionBox;
  static Box<DailyReminder>? _reminderBox;
  static Box<PatientProfile>? _profileBox;

  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  /// Initializes Hive, registers strongly-typed adapters, and opens all boxes.
  static Future<void> init({String? subDir}) async {
    if (_isInitialized) return;

    if (subDir != null) {
      Hive.init(subDir);
    } else {
      await Hive.initFlutter();
    }

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CognitiveSessionAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(DailyReminderAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(PatientProfileAdapter());
    }

    _sessionBox = await Hive.openBox<CognitiveSession>(sessionBoxName);
    _reminderBox = await Hive.openBox<DailyReminder>(reminderBoxName);
    _profileBox = await Hive.openBox<PatientProfile>(profileBoxName);

    // Seed default daily reminders if empty
    if (_reminderBox!.isEmpty) {
      await _seedDefaultReminders();
    }

    // Seed default patient profile if empty
    if (_profileBox!.isEmpty) {
      await _seedDefaultProfile();
    }

    _isInitialized = true;
    debugPrint('StorageService: Hive boxes initialized successfully (offline-first).');
  }

  static Future<void> _seedDefaultReminders() async {
    final now = DateTime.now();
    final defaults = [
      DailyReminder(
        id: 'rem_1',
        title: 'Morning Medication & Water',
        time: '08:30 AM',
        category: 'Medication',
        isEnabled: true,
        timestamp: now,
      ),
      DailyReminder(
        id: 'rem_2',
        title: 'Mid-Morning Hydration Break',
        time: '11:00 AM',
        category: 'Hydration',
        isEnabled: true,
        timestamp: now,
      ),
      DailyReminder(
        id: 'rem_3',
        title: 'Afternoon Cognitive Exercise',
        time: '03:00 PM',
        category: 'Cognitive',
        isEnabled: true,
        timestamp: now,
      ),
      DailyReminder(
        id: 'rem_4',
        title: 'Evening Walk or Gentle Stretch',
        time: '06:00 PM',
        category: 'Activity',
        isEnabled: true,
        timestamp: now,
      ),
    ];

    for (final rem in defaults) {
      await _reminderBox!.put(rem.id, rem);
    }
  }

  static Future<void> _seedDefaultProfile() async {
    final profile = PatientProfile(
      patientId: 'patient_001',
      name: 'Margaret',
      email: 'patient@mindweave.com',
      language: 'English',
      baselineScore: 78.5,
      lastUpdated: DateTime.now(),
      memoryScore: 82.0,
      attentionScore: 76.0,
      patternScore: 80.0,
      routineScore: 84.0,
    );
    await _profileBox!.put('current', profile);
  }

  // --------------------------------------------------------------------------
  // COGNITIVE SESSIONS CRUD
  // --------------------------------------------------------------------------

  static Future<void> saveSession(CognitiveSession session) async {
    await _ensureInitialized();
    await _sessionBox!.put(session.id, session);
  }

  static List<CognitiveSession> getAllSessions() {
    if (_sessionBox == null) return [];
    final list = _sessionBox!.values.toList();
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  // --------------------------------------------------------------------------
  // DAILY REMINDERS CRUD
  // --------------------------------------------------------------------------

  static Future<void> saveReminder(DailyReminder reminder) async {
    await _ensureInitialized();
    await _reminderBox!.put(reminder.id, reminder);
  }

  static Future<void> toggleReminder(String id) async {
    await _ensureInitialized();
    final reminder = _reminderBox!.get(id);
    if (reminder != null) {
      reminder.isEnabled = !reminder.isEnabled;
      await _reminderBox!.put(id, reminder);
    }
  }

  static Future<void> deleteReminder(String id) async {
    await _ensureInitialized();
    await _reminderBox!.delete(id);
  }

  static List<DailyReminder> getAllReminders() {
    if (_reminderBox == null) return [];
    return _reminderBox!.values.toList();
  }

  // --------------------------------------------------------------------------
  // PATIENT PROFILE CRUD
  // --------------------------------------------------------------------------

  static Future<void> saveProfile(PatientProfile profile) async {
    await _ensureInitialized();
    await _profileBox!.put('current', profile);
  }

  static PatientProfile? getProfile() {
    if (_profileBox == null) return null;
    return _profileBox!.get('current');
  }

  // --------------------------------------------------------------------------
  // BACKWARDS-COMPATIBILITY ADAPTER METHODS
  // --------------------------------------------------------------------------

  /// Preserves the existing `saveGameResult` contract used across game screens,
  /// persisting a new strongly-typed `CognitiveSession` into Hive.
  static Future<void> saveGameResult({
    required int attempts,
    required double accuracy,
    required int timeSeconds,
    String gameType = 'memory_match',
    int errorCounts = 0,
    String difficulty = 'Medium',
  }) async {
    await _ensureInitialized();

    final session = CognitiveSession(
      id: 'session_${DateTime.now().millisecondsSinceEpoch}',
      gameType: gameType,
      timestamp: DateTime.now(),
      errorCounts: errorCounts > 0 ? errorCounts : (attempts - (attempts * (accuracy / 100)).round()).clamp(0, 999),
      completionTimeSeconds: timeSeconds,
      accuracy: accuracy,
      attempts: attempts,
      difficulty: difficulty,
    );

    await saveSession(session);
  }

  /// Preserves the existing `getProgress` contract used across screens,
  /// computing metrics dynamically from strongly-typed Hive sessions.
  static Future<Map<String, dynamic>> getProgress() async {
    await _ensureInitialized();
    final sessions = getAllSessions();

    int totalAttempts = 0;
    int totalErrors = 0;
    double bestAccuracy = 0.0;
    int bestTime = 0;

    for (final s in sessions) {
      totalAttempts += s.attempts;
      totalErrors += s.errorCounts;
      if (s.accuracy > bestAccuracy) {
        bestAccuracy = s.accuracy;
      }
      if (s.completionTimeSeconds > 0) {
        if (bestTime == 0 || s.completionTimeSeconds < bestTime) {
          bestTime = s.completionTimeSeconds;
        }
      }
    }

    return {
      'gamesCompleted': sessions.length,
      'totalAttempts': totalAttempts,
      'totalErrors': totalErrors,
      'bestAccuracy': bestAccuracy,
      'bestTime': bestTime,
      'recentSessions': sessions.take(10).toList(),
    };
  }

  static Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await init();
    }
  }
}