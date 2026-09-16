import 'package:flutter/foundation.dart';
import 'storage_service.dart';

/// Central ChangeNotifier Provider for MindWeave.
/// Fully offline-first and backed by Hive, completely eliminating
/// external network API dependencies.
class MindWeaveProvider extends ChangeNotifier {
  List<CognitiveSession> _sessions = [];
  List<DailyReminder> _reminders = [];
  PatientProfile? _profile;
  Map<String, dynamic> _progress = {
    'gamesCompleted': 0,
    'totalAttempts': 0,
    'totalErrors': 0,
    'bestAccuracy': 0.0,
    'bestTime': 0,
  };
  bool _isLoading = false;
  bool _isInitialized = false;

  List<CognitiveSession> get sessions => List.unmodifiable(_sessions);
  List<DailyReminder> get reminders => List.unmodifiable(_reminders);
  PatientProfile? get profile => _profile;
  Map<String, dynamic> get progress => Map.unmodifiable(_progress);
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  // Domain score helpers
  double get memoryScore => _profile?.memoryScore ?? 80.0;
  double get attentionScore => _profile?.attentionScore ?? 75.0;
  double get patternScore => _profile?.patternScore ?? 78.0;
  double get routineScore => _profile?.routineScore ?? 82.0;
  double get baselineScore => _profile?.baselineScore ?? 78.5;

  /// Initializes the provider and synchronizes with local Hive boxes.
  Future<void> init({String? subDir}) async {
    if (_isInitialized) return;
    _isLoading = true;
    notifyListeners();

    await StorageService.init(subDir: subDir);
    await refreshData();

    _isLoading = false;
    _isInitialized = true;
    notifyListeners();
  }

  /// Reloads all reactive collections from Hive storage.
  Future<void> refreshData() async {
    _sessions = StorageService.getAllSessions();
    _reminders = StorageService.getAllReminders();
    _profile = StorageService.getProfile();
    _progress = await StorageService.getProgress();
    notifyListeners();
  }

  /// Records a new cognitive game session into Hive and recalculates profile domain baselines.
  Future<void> recordSession({
    required String gameType,
    required int errorCounts,
    required int completionTimeSeconds,
    required double accuracy,
    required int attempts,
    String difficulty = 'Medium',
  }) async {
    final session = CognitiveSession(
      id: 'session_${DateTime.now().millisecondsSinceEpoch}',
      gameType: gameType,
      timestamp: DateTime.now(),
      errorCounts: errorCounts,
      completionTimeSeconds: completionTimeSeconds,
      accuracy: accuracy,
      attempts: attempts,
      difficulty: difficulty,
    );

    await StorageService.saveSession(session);
    await _recalculateProfileDomains(session);
    await refreshData();
  }

  /// Local algorithm calculating domain baselines purely offline.
  Future<void> _recalculateProfileDomains(CognitiveSession newSession) async {
    if (_profile == null) return;

    double mem = _profile!.memoryScore;
    double att = _profile!.attentionScore;
    double pat = _profile!.patternScore;
    double rout = _profile!.routineScore;

    // Adjust domain baselines based on game type and accuracy
    final factor = (newSession.accuracy - 70.0) * 0.05; // gentle moving average adjustment

    switch (newSession.gameType.toLowerCase()) {
      case 'memory_match':
      case 'memory':
        mem = (mem + factor).clamp(50.0, 100.0);
        break;
      case 'sequence_memory':
      case 'sequence':
        att = (att + factor).clamp(50.0, 100.0);
        break;
      case 'remember_objects':
      case 'objects':
        pat = (pat + factor).clamp(50.0, 100.0);
        break;
      default:
        rout = (rout + factor).clamp(50.0, 100.0);
    }

    final newBaseline = ((mem + att + pat + rout) / 4.0).clamp(50.0, 100.0);

    final updated = _profile!.copyWith(
      memoryScore: double.parse(mem.toStringAsFixed(1)),
      attentionScore: double.parse(att.toStringAsFixed(1)),
      patternScore: double.parse(pat.toStringAsFixed(1)),
      routineScore: double.parse(rout.toStringAsFixed(1)),
      baselineScore: double.parse(newBaseline.toStringAsFixed(1)),
      lastUpdated: DateTime.now(),
    );

    await StorageService.saveProfile(updated);
    _profile = updated;
  }

  /// Adds a new scheduled daily reminder to Hive.
  Future<void> addReminder({
    required String title,
    required String time,
    required String category,
  }) async {
    final reminder = DailyReminder(
      id: 'rem_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      time: time,
      category: category,
      isEnabled: true,
      timestamp: DateTime.now(),
    );

    await StorageService.saveReminder(reminder);
    await refreshData();
  }

  /// Toggles the active/inactive state of a reminder in Hive.
  Future<void> toggleReminder(String id) async {
    await StorageService.toggleReminder(id);
    await refreshData();
  }

  /// Removes a reminder from Hive.
  Future<void> deleteReminder(String id) async {
    await StorageService.deleteReminder(id);
    await refreshData();
  }

  /// Updates patient profile metadata in Hive.
  Future<void> updateProfile({
    String? name,
    String? email,
    String? language,
  }) async {
    if (_profile == null) return;

    final updated = _profile!.copyWith(
      name: name,
      email: email,
      language: language,
      lastUpdated: DateTime.now(),
    );

    await StorageService.saveProfile(updated);
    await refreshData();
  }
}
