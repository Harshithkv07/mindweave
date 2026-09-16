import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
  runApp(const MindWeaveApp());
}

// ============================================================
// MODELS
// ============================================================

class Reminder {
  String id;
  String title;
  String time;
  String category;
  bool enabled;

  Reminder({
    required this.id,
    required this.title,
    required this.time,
    required this.category,
    this.enabled = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'time': time,
        'category': category,
        'enabled': enabled,
      };

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id']?.toString() ?? DateTime.now().toString(),
      title: json['title']?.toString() ?? 'Reminder',
      time: json['time']?.toString() ?? '17:00',
      category: json['category']?.toString() ?? 'General',
      enabled: json['enabled'] ?? true,
    );
  }
}

class GameRecord {
  final String game;
  final int score;
  final int accuracy;
  final int responseTime;
  final String difficulty;
  final DateTime date;

  GameRecord({
    required this.game,
    required this.score,
    required this.accuracy,
    required this.responseTime,
    required this.difficulty,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'game': game,
        'score': score,
        'accuracy': accuracy,
        'responseTime': responseTime,
        'difficulty': difficulty,
        'date': date.toIso8601String(),
      };

  factory GameRecord.fromJson(Map<String, dynamic> json) {
    return GameRecord(
      game: json['game']?.toString() ?? 'Game',
      score: (json['score'] ?? 0) as int,
      accuracy: (json['accuracy'] ?? 0) as int,
      responseTime: (json['responseTime'] ?? 0) as int,
      difficulty: json['difficulty']?.toString() ?? 'Medium',
      date: DateTime.tryParse(
            json['date']?.toString() ?? '',
          ) ??
          DateTime.now(),
    );
  }
}

class Performance {
  int gamesCompleted = 0;
  int totalScore = 0;
  int bestScore = 0;
  int totalAccuracy = 0;
  int totalResponseTime = 0;
  int currentStreak = 0;

  List<GameRecord> history = [];

  double get averageScore =>
      gamesCompleted == 0 ? 0 : totalScore / gamesCompleted;

  double get averageAccuracy =>
      gamesCompleted == 0 ? 0 : totalAccuracy / gamesCompleted;

  double get averageResponseTime =>
      gamesCompleted == 0 ? 0 : totalResponseTime / gamesCompleted;

  String get level {
    if (averageAccuracy >= 85 && averageScore >= 80) {
      return 'Excellent';
    }

    if (averageAccuracy >= 70 && averageScore >= 60) {
      return 'Good';
    }

    if (averageAccuracy >= 50) {
      return 'Improving';
    }

    return 'Needs Practice';
  }
}

// ============================================================
// ADAPTIVE AI ENGINE
// ============================================================

class AdaptiveAI {
  static String difficulty(Performance p) {
    if (p.gamesCompleted == 0) {
      return 'Easy';
    }

    if (p.averageAccuracy >= 85 && p.averageScore >= 80) {
      return 'Hard';
    }

    if (p.averageAccuracy >= 65 && p.averageScore >= 60) {
      return 'Medium';
    }

    return 'Easy';
  }

  static String recommendation(Performance p) {
    if (p.gamesCompleted == 0) {
      return 'Start with an easy Memory Match activity for 5 minutes.';
    }

    if (p.averageAccuracy >= 85) {
      return 'Excellent progress! Try harder memory and sequence activities.';
    }

    if (p.averageAccuracy >= 70) {
      return 'Good progress. Continue medium-level cognitive activities daily.';
    }

    if (p.averageAccuracy >= 50) {
      return 'Performance is improving. Continue short guided activities.';
    }

    return 'Use simpler memory activities with more repetition and voice assistance.';
  }

  static String nextGame(Performance p) {
    if (p.gamesCompleted == 0) {
      return 'Memory Match';
    }

    if (p.averageAccuracy >= 80) {
      return 'Sequence Recall – Hard';
    }

    if (p.averageAccuracy >= 60) {
      return 'Pattern Recall – Medium';
    }

    return 'Memory Match – Easy';
  }

  static String insight(Performance p) {
    if (p.gamesCompleted == 0) {
      return 'The AI needs more activity data before making a personalized recommendation.';
    }

    if (p.averageAccuracy >= 85) {
      return 'The patient is performing strongly. AI recommends gradually increasing cognitive challenge.';
    }

    if (p.averageAccuracy >= 70) {
      return 'The patient shows good cognitive engagement. AI recommends continuing medium-level activities.';
    }

    if (p.averageAccuracy >= 50) {
      return 'The patient is improving. AI recommends repetition and shorter guided sessions.';
    }

    return 'The patient may benefit from simpler activities, repetition and additional caregiver support.';
  }
}

// ============================================================
// APP STORE
// ============================================================

class MindWeaveStore extends ChangeNotifier {
  static final MindWeaveStore instance = MindWeaveStore._();

  MindWeaveStore._();

  String language = 'English';
  final Performance performance = Performance();

  final FlutterTts _tts = FlutterTts();
  bool isSpeakingReminder = false;
  String? currentSpeakingText;
  Reminder? activeReminderAlert;
  String caregiverEmail = 'caregiver@example.com';
  bool isCaregiverLoggedIn = false;
  String patientEmail = 'patient@mindweave.com';
  bool isPatientLoggedIn = false;
  String patientName = 'Margaret';

  final Set<String> _triggeredReminderKeys = {};

  List<Reminder> reminders = [
    Reminder(
      id: '1',
      title: 'Drink Water',
      time: '17:00',
      category: 'Water',
    ),
    Reminder(
      id: '2',
      title: 'Take Medicine',
      time: '20:00',
      category: 'Medicine',
    ),
    Reminder(
      id: '3',
      title: 'Medical Appointment',
      time: '10:00',
      category: 'Appointment',
    ),
    Reminder(
      id: '4',
      title: 'Daily Routine',
      time: '11:00',
      category: 'Routine',
    ),
  ];

  Timer? reminderTimer;
  String? lastReminderKey;
  bool initialized = false;

  Future<void> initialize() async {
    if (initialized) return;

    try {
      _tts.setStartHandler(() {
        isSpeakingReminder = true;
        notifyListeners();
      });

      _tts.setCompletionHandler(() {
        isSpeakingReminder = false;
        notifyListeners();
      });

      _tts.setErrorHandler((_) {
        isSpeakingReminder = false;
        notifyListeners();
      });
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    language = prefs.getString('language') ?? 'English';
    patientName = prefs.getString('patientName') ?? 'Margaret';
    patientEmail = prefs.getString('patientEmail') ?? 'patient@mindweave.com';
    isPatientLoggedIn = prefs.getBool('isPatientLoggedIn') ?? false;
    caregiverEmail = prefs.getString('caregiverEmail') ?? 'caregiver@example.com';
    isCaregiverLoggedIn = prefs.getBool('isCaregiverLoggedIn') ?? false;

    final reminderData = prefs.getString('reminders');
    if (reminderData != null) {
      try {
        final List data = jsonDecode(reminderData);
        reminders = data
            .map(
              (item) => Reminder.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();
      } catch (_) {}
    }

    performance.gamesCompleted = prefs.getInt('gamesCompleted') ?? 0;
    performance.totalScore = prefs.getInt('totalScore') ?? 0;
    performance.bestScore = prefs.getInt('bestScore') ?? 0;
    performance.totalAccuracy = prefs.getInt('totalAccuracy') ?? 0;
    performance.totalResponseTime = prefs.getInt('totalResponseTime') ?? 0;
    performance.currentStreak = prefs.getInt('currentStreak') ?? 0;

    final historyData = prefs.getString('history');
    if (historyData != null) {
      try {
        final List data = jsonDecode(historyData);
        performance.history = data
            .map(
              (item) => GameRecord.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();
      } catch (_) {}
    }

    initialized = true;
    startReminderEngine();
    notifyListeners();
  }

  bool loginPatient({
    required String email,
    required String password,
    String? name,
  }) {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty || password.length < 4) {
      return false;
    }
    isPatientLoggedIn = true;
    patientEmail = cleanEmail;
    final extractedName = name?.trim().isNotEmpty == true
        ? name!.trim()
        : (cleanEmail.contains('@')
            ? cleanEmail.split('@').first
            : cleanEmail);
    patientName = extractedName.isNotEmpty
        ? '${extractedName[0].toUpperCase()}${extractedName.substring(1)}'
        : 'Margaret';
    savePatientSession();
    startReminderEngine();
    notifyListeners();
    return true;
  }

  void logoutPatient() {
    isPatientLoggedIn = false;
    savePatientSession();
    notifyListeners();
  }

  Future<void> savePatientSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isPatientLoggedIn', isPatientLoggedIn);
    await prefs.setString('patientEmail', patientEmail);
    await prefs.setString('patientName', patientName);
  }

  bool loginCaregiver(String email, String password) {
    if (email.trim().isNotEmpty && password.length >= 6) {
      caregiverEmail = email.trim();
      isCaregiverLoggedIn = true;
      saveCaregiverSession();
      notifyListeners();
      return true;
    }
    return false;
  }

  void logoutCaregiver() {
    isCaregiverLoggedIn = false;
    saveCaregiverSession();
    notifyListeners();
  }

  Future<void> saveCaregiverSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isCaregiverLoggedIn', isCaregiverLoggedIn);
    await prefs.setString('caregiverEmail', caregiverEmail);
  }

  Future<void> setLanguage(String value) async {
    language = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', value);
    notifyListeners();
  }

  Future<void> setPatientName(String value) async {
    patientName = value.trim().isEmpty ? 'Margaret' : value.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('patientName', patientName);
    notifyListeners();
  }

  Future<void> savePerformance() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('gamesCompleted', performance.gamesCompleted);
    await prefs.setInt('totalScore', performance.totalScore);
    await prefs.setInt('bestScore', performance.bestScore);
    await prefs.setInt('totalAccuracy', performance.totalAccuracy);
    await prefs.setInt('totalResponseTime', performance.totalResponseTime);
    await prefs.setInt('currentStreak', performance.currentStreak);
    await prefs.setString(
      'history',
      jsonEncode(
        performance.history.map((item) => item.toJson()).toList(),
      ),
    );
  }

  Future<void> recordGame({
    required String game,
    required int score,
    required int accuracy,
    int responseTime = 0,
    String? difficulty,
  }) async {
    performance.gamesCompleted++;
    performance.totalScore += score;
    performance.totalAccuracy += accuracy;
    performance.totalResponseTime += responseTime;

    if (score > performance.bestScore) {
      performance.bestScore = score;
    }

    performance.currentStreak++;

    performance.history.add(
      GameRecord(
        game: game,
        score: score,
        accuracy: accuracy,
        responseTime: responseTime,
        difficulty:
            difficulty ?? AdaptiveAI.difficulty(performance),
        date: DateTime.now(),
      ),
    );

    await savePerformance();
    notifyListeners();
  }

  Future<void> saveReminders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'reminders',
      jsonEncode(
        reminders.map((r) => r.toJson()).toList(),
      ),
    );
    notifyListeners();
  }

  Future<void> addReminder(Reminder reminder) async {
    reminders.add(reminder);
    await saveReminders();
  }

  Future<void> deleteReminder(String id) async {
    reminders.removeWhere((r) => r.id == id);
    await saveReminders();
  }

  Future<void> toggleReminder(Reminder reminder) async {
    reminder.enabled = !reminder.enabled;
    await saveReminders();
  }

  void startReminderEngine([BuildContext? context]) {
    reminderTimer?.cancel();
    _checkReminders(context);
    // Continuous 1-second precision check for scheduled alarms
    reminderTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        _checkReminders(context);
      },
    );
  }

  void stopReminderEngine() {
    reminderTimer?.cancel();
  }

  void _checkReminders([BuildContext? context]) {
    final now = DateTime.now();
    final hourStr = now.hour.toString().padLeft(2, '0');
    final minStr = now.minute.toString().padLeft(2, '0');
    final currentTime = '$hourStr:$minStr';
    final dateKey = '${now.year}-${now.month}-${now.day}-$currentTime';

    for (final reminder in reminders) {
      if (!reminder.enabled) continue;

      if (reminder.time == currentTime) {
        final triggerKey = '${reminder.id}-$dateKey';
        if (_triggeredReminderKeys.contains(triggerKey)) continue;
        _triggeredReminderKeys.add(triggerKey);
        speakReminder(
          reminder,
          context: context,
          showBanner: true,
          isScheduledAlarm: true,
        );
      }
    }
  }

  void scheduleOneMinuteTestReminder(BuildContext context) {
    final nextMin = DateTime.now().add(const Duration(minutes: 1));
    final nextHour = nextMin.hour.toString().padLeft(2, '0');
    final nextMinute = nextMin.minute.toString().padLeft(2, '0');
    final targetTime = '$nextHour:$nextMinute';

    final testReminder = Reminder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Scheduled Time-Triggered Alarm',
      time: targetTime,
      category: 'Medicine',
      enabled: true,
    );
    addReminder(testReminder);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.deepPurple.shade900,
        duration: const Duration(seconds: 6),
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            const Icon(Icons.alarm_on, color: Colors.amberAccent),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '⏰ Real-time alarm set for $targetTime (in 1 min). The app will read it aloud automatically when the clock strikes!',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );

    speakText('Scheduled alarm set for $targetTime. It will read aloud automatically at that time.');
  }

  Future<void> speakReminder(
    Reminder reminder, {
    BuildContext? context,
    bool showBanner = true,
    bool isScheduledAlarm = false,
  }) async {
    final baseMessage = localizedReminder(reminder.title);
    String message = isScheduledAlarm
        ? (language == 'Tamil'
            ? 'கவனம் $patientName. நேரம் ${reminder.time}. $baseMessage'
            : (language == 'Hindi'
                ? 'ध्यान दें $patientName। समय ${reminder.time} है। $baseMessage'
                : (language == 'Telugu'
                    ? 'శ్రద్ధ వహించండి $patientName. సమయం ${reminder.time}. $baseMessage'
                    : 'Attention $patientName. It is ${reminder.time}. $baseMessage')))
        : baseMessage;

    activeReminderAlert = reminder;
    currentSpeakingText = message;
    isSpeakingReminder = true;
    notifyListeners();

    if (context != null && showBanner && context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 10),
          behavior: SnackBarBehavior.floating,
          backgroundColor: isScheduledAlarm ? Colors.deepPurple.shade900 : Colors.indigo.shade900,
          content: Row(
            children: [
              Icon(
                isScheduledAlarm ? Icons.alarm_on : Icons.volume_up_rounded,
                color: Colors.amberAccent,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isScheduledAlarm
                          ? '⏰ Scheduled Alarm (${reminder.time}): ${reminder.title}'
                          : '🔊 Voice Reminder: ${reminder.title}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.amberAccent,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      message,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.replay, color: Colors.white70),
                tooltip: 'Replay voice alert',
                onPressed: () => speakReminder(reminder, context: context),
              ),
            ],
          ),
        ),
      );
    }

    String ttsLanguage = 'en-US';
    if (language == 'Tamil') {
      ttsLanguage = 'ta-IN';
    } else if (language == 'Hindi') {
      ttsLanguage = 'hi-IN';
    } else if (language == 'Telugu') {
      ttsLanguage = 'te-IN';
    }

    try {
      await _tts.stop();
      await _tts.setLanguage(ttsLanguage);
      await _tts.setSpeechRate(0.45);
      await _tts.setPitch(1.0);
      await _tts.speak(message);
    } catch (_) {}
  }

  Future<void> speakText(String text, {String? lang}) async {
    currentSpeakingText = text;
    isSpeakingReminder = true;
    notifyListeners();

    String ttsLanguage = lang ?? 'en-US';
    if (lang == null) {
      if (language == 'Tamil') {
        ttsLanguage = 'ta-IN';
      } else if (language == 'Hindi') {
        ttsLanguage = 'hi-IN';
      } else if (language == 'Telugu') {
        ttsLanguage = 'te-IN';
      }
    }

    try {
      await _tts.stop();
      await _tts.setLanguage(ttsLanguage);
      await _tts.setSpeechRate(0.45);
      await _tts.speak(text);
    } catch (_) {}
  }

  Future<void> stopSpeaking() async {
    try {
      await _tts.stop();
    } catch (_) {}
    isSpeakingReminder = false;
    notifyListeners();
  }

  void dismissActiveReminderAlert() {
    activeReminderAlert = null;
    notifyListeners();
  }

  Future<void> testVoiceNotification([BuildContext? context]) async {
    String testMsg =
        'Attention: This is the MindWeave voice notification system. All your daily reminders and memory prompts will be announced clearly with voice.';
    if (language == 'Tamil') {
      testMsg =
          'கவனம்: இது மைண்ட்வீவ் குரல் நினைவூட்டல் அமைப்பு. உங்கள் தினசரி நினைவூட்டல்கள் தெளிவாக குரல் மூலம் அறிவிக்கப்படும்.';
    } else if (language == 'Hindi') {
      testMsg =
          'ध्यान दें: यह माइंडवीव वॉइस नोटिफिकेशन सिस्टम है। आपकी दैनिक याद दिलाने वाली सूचनाएं स्पष्ट रूप से आवाज में सुनाई देंगी।';
    } else if (language == 'Telugu') {
      testMsg =
          'శ్రద్ధ వహించండి: ఇది మైండ్‌వీవ్ వాయిస్ నోటిఫికేషన్ సిస్టమ్. మీ రోజువారీ రిమైండర్‌లు స్పష్టంగా వాయిస్ ద్వారా తెలియజేయబడతాయి.';
    }

    final testReminder = Reminder(
      id: 'test-voice',
      title: 'Voice Alert Test',
      time: 'Now',
      category: 'General',
    );

    activeReminderAlert = testReminder;
    currentSpeakingText = testMsg;
    isSpeakingReminder = true;
    notifyListeners();

    if (context != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.teal.shade800,
          content: Row(
            children: [
              const Icon(Icons.volume_up, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text('🔊 Test Voice Alert: $testMsg'),
              ),
            ],
          ),
        ),
      );
    }

    speakText(testMsg);
  }

  Future<void> announceAllTodayReminders(BuildContext context) async {
    final active = reminders.where((r) => r.enabled).toList();
    if (active.isEmpty) {
      String noReminders = 'You have no active reminders for today.';
      if (language == 'Tamil') {
        noReminders = 'இன்று உங்களுக்கு செயலில் உள்ள நினைவூட்டல்கள் எதுவும் இல்லை.';
      } else if (language == 'Hindi') {
        noReminders = 'आज के लिए आपकी कोई सक्रिय याद दिलाने वाली सूचना नहीं है।';
      } else if (language == 'Telugu') {
        noReminders = 'ఈ రోజు కోసం మీకు ఎటువంటి యాక్టివ్ రిమైండర్‌లు లేవు.';
      }
      speakText(noReminders);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(noReminders)));
      }
      return;
    }

    String fullSpeech = 'Here are your reminders for today: ';
    if (language == 'Tamil') {
      fullSpeech = 'இன்றைய உங்கள் நினைவூட்டல்கள்: ';
    } else if (language == 'Hindi') {
      fullSpeech = 'आज की आपकी याद दिलाने वाली सूचनाएं: ';
    } else if (language == 'Telugu') {
      fullSpeech = 'ఈ రోజు మీ రిమైండర్‌లు: ';
    }

    for (int i = 0; i < active.length; i++) {
      final r = active[i];
      fullSpeech += '${r.time}, ${localizedReminder(r.title)}. ';
    }

    speakText(fullSpeech);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.indigo.shade800,
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              const Icon(Icons.record_voice_over, color: Colors.amberAccent),
              const SizedBox(width: 10),
              Expanded(child: Text('🔊 Announcing ${active.length} reminders out loud...')),
            ],
          ),
        ),
      );
    }
  }

  String localizedReminder(String title) {
    if (language == 'Tamil') {
      if (title == 'Drink Water') {
        return 'கவனம்: தண்ணீர் குடிக்க வேண்டிய நேரம் வந்துவிட்டது, தண்ணீர் அருந்தவும்';
      }
      if (title == 'Take Medicine') {
        return 'கவனம்: உங்கள் மருந்து எடுத்துக்கொள்ள வேண்டிய நேரம் வந்துவிட்டது';
      }
      if (title == 'Medical Appointment') {
        return 'கவனம்: மருத்துவ சந்திப்பு நேரம் வந்துவிட்டது';
      }
      if (title == 'Daily Routine') {
        return 'கவனம்: தினசரி செயல்பாட்டிற்கான நேரம் வந்துவிட்டது';
      }
      return 'நினைவூட்டல்: $title நேரம் வந்துவிட்டது';
    }

    if (language == 'Hindi') {
      if (title == 'Drink Water') {
        return 'कृपया ध्यान दें: पानी पीने और हाइड्रेटेड रहने का समय है';
      }
      if (title == 'Take Medicine') {
        return 'कृपया ध्यान दें: आपकी निर्धारित दवाई लेने का समय है';
      }
      if (title == 'Medical Appointment') {
        return 'कृपया ध्यान दें: चिकित्सा अपॉइंटमेंट का समय है';
      }
      if (title == 'Daily Routine') {
        return 'कृपया ध्यान दें: दैनिक गतिविधि का समय है';
      }
      return 'याद दिलाना: $title का समय है';
    }

    if (language == 'Telugu') {
      if (title == 'Drink Water') {
        return 'శ్రద్ధ వహించండి: నీళ్లు తాగే సమయం వచ్చింది, నీళ్లు తాగండి';
      }
      if (title == 'Take Medicine') {
        return 'శ్రద్ధ వహించండి: మీ మందులు తీసుకునే సమయం వచ్చింది';
      }
      if (title == 'Medical Appointment') {
        return 'శ్రద్ధ వహించండి: వైద్య అపాయింట్‌మెంట్ సమయం వచ్చింది';
      }
      if (title == 'Daily Routine') {
        return 'శ్రద్ధ వహించండి: రోజువారీ కార్యకలాప సమయం వచ్చింది';
      }
      return 'జ్ఞాపిక: $title సమయం వచ్చింది';
    }

    if (title == 'Drink Water') {
      return 'Attention: It is time to drink water and stay hydrated.';
    }
    if (title == 'Take Medicine') {
      return 'Attention: It is time to take your scheduled medicine.';
    }
    if (title == 'Medical Appointment') {
      return 'Attention: It is time for your scheduled medical appointment.';
    }
    if (title == 'Daily Routine') {
      return 'Attention: It is time for your daily routine cognitive activity.';
    }

    return 'Attention: Reminder for $title.';
  }

  static IconData categoryIcon(String category) {
    switch (category) {
      case 'Water':
        return Icons.water_drop;
      case 'Medicine':
        return Icons.medication;
      case 'Appointment':
        return Icons.local_hospital;
      case 'Exercise':
        return Icons.directions_walk;
      case 'Routine':
        return Icons.schedule;
      default:
        return Icons.notifications_active;
    }
  }
}

// ============================================================
// TRANSLATIONS
// ============================================================

class T {
  static String text(
    String key,
    String language,
  ) {
    final translations =
        <String, Map<String, String>>{
      'welcome': {
        'English': 'Welcome to MindWeave',
        'Tamil': 'MindWeave-க்கு வரவேற்கிறோம்',
        'Hindi': 'MindWeave में आपका स्वागत है',
        'Telugu': 'MindWeave కి స్వాగతం',
      },
      'login': {
        'English': 'Login',
        'Tamil': 'உள்நுழைவு',
        'Hindi': 'लॉगिन',
        'Telugu': 'లాగిన్',
      },
      'patient': {
        'English': 'Patient',
        'Tamil': 'நோயாளி',
        'Hindi': 'रोगी',
        'Telugu': 'రోగి',
      },
      'caregiver': {
        'English': 'Caregiver / Family',
        'Tamil': 'பராமரிப்பாளர் / குடும்பம்',
        'Hindi': 'देखभालकर्ता / परिवार',
        'Telugu': 'సంరక్షకుడు / కుటుంబం',
      },
      'chooseLanguage': {
        'English': 'Choose your language',
        'Tamil': 'உங்கள் மொழியைத் தேர்ந்தெடுக்கவும்',
        'Hindi': 'अपनी भाषा चुनें',
        'Telugu': 'మీ భాషను ఎంచుకోండి',
      },
      'continue': {
        'English': 'Continue',
        'Tamil': 'தொடரவும்',
        'Hindi': 'जारी रखें',
        'Telugu': 'కొనసాగించండి',
      },
      'dashboard': {
        'English': 'Dashboard',
        'Tamil': 'முகப்பு',
        'Hindi': 'डैशबोर्ड',
        'Telugu': 'డాష్‌బోర్డ్',
      },
      'games': {
        'English': 'Cognitive Games',
        'Tamil': 'நினைவாற்றல் விளையாட்டுகள்',
        'Hindi': 'संज्ञानात्मक खेल',
        'Telugu': 'జ్ఞాపకశక్తి ఆటలు',
      },
      'voice': {
        'English': 'Voice Assistant',
        'Tamil': 'குரல் உதவியாளர்',
        'Hindi': 'वॉइस असिस्टेंट',
        'Telugu': 'వాయిస్ అసిస్టెంట్',
      },
      'reminders': {
        'English': 'Reminders',
        'Tamil': 'நினைவூட்டல்கள்',
        'Hindi': 'रिमाइंडर',
        'Telugu': 'రిమైండర్లు',
      },
      'progress': {
        'English': 'My Progress',
        'Tamil': 'எனது முன்னேற்றம்',
        'Hindi': 'मेरी प्रगति',
        'Telugu': 'నా పురోగతి',
      },
    };

    return translations[key]?[language] ??
        translations[key]?['English'] ??
        key;
  }
}

// ============================================================
// APP
// ============================================================

class MindWeaveApp extends StatefulWidget {
  const MindWeaveApp({super.key});

  @override
  State<MindWeaveApp> createState() =>
      _MindWeaveAppState();
}

class _MindWeaveAppState
    extends State<MindWeaveApp> {
  @override
  void initState() {
    super.initState();

    MindWeaveStore.instance.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MindWeave',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        scaffoldBackgroundColor:
            const Color(0xfff6f8fc),
        cardTheme: const CardThemeData(
          elevation: 1,
          margin: EdgeInsets.zero,
        ),
      ),
      home: const LoginPage(),
    );
  }
}

// ============================================================
// LOGIN & PORTAL SELECTION
// ============================================================

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  void _enterPatientPortal() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PatientLoginPage(),
      ),
    );
  }

  void _enterCaretakerPortal() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CaretakerLoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 490),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.indigo.shade600, Colors.indigo.shade400],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.indigo.withOpacity(0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.psychology,
                        size: 46,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'MindWeave',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'AI Cognitive Companion & Caregiver Platform',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // PATIENT PORTAL CARD (CREDENTIALS REQUIRED)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.indigo.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.indigo.shade600,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Patient Portal',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.indigo,
                                      ),
                                    ),
                                    Text(
                                      'Voice prompts, games & spoken alerts',
                                      style: TextStyle(fontSize: 12, color: Colors.black54),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Sign in with patient credentials to access tailored daily routines, cognitive games & voice notifications.',
                            style: TextStyle(fontSize: 13, color: Colors.black87),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.indigo.shade600,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.lock_person_outlined),
                              label: const Text(
                                'Patient Login (Credentials Required)',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              onPressed: _enterPatientPortal,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // CARETAKER PORTAL CARD
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.teal.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.teal.shade700,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.health_and_safety,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Caretaker Portal',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.teal,
                                      ),
                                    ),
                                    Text(
                                      'Password-protected clinical dashboard',
                                      style: TextStyle(fontSize: 12, color: Colors.black54),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Monitor cognitive performance, configure reminders & review AI insights.',
                            style: TextStyle(fontSize: 13, color: Colors.black87),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.teal.shade800,
                                side: BorderSide(color: Colors.teal.shade700, width: 1.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.shield_outlined),
                              label: const Text(
                                'Caretaker Login (Credentials Required)',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              onPressed: _enterCaretakerPortal,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.record_voice_over, size: 16, color: Colors.indigo),
                        SizedBox(width: 6),
                        Text(
                          'Voice Alarms Enabled • Multi-Credential Auth',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// DEDICATED PATIENT LOGIN PAGE (CREDENTIALS REQUIRED)
// ============================================================

class PatientLoginPage extends StatefulWidget {
  const PatientLoginPage({super.key});

  @override
  State<PatientLoginPage> createState() => _PatientLoginPageState();
}

class _PatientLoginPageState extends State<PatientLoginPage> {
  final TextEditingController _emailController =
      TextEditingController(text: 'patient@mindweave.com');
  final TextEditingController _passwordController =
      TextEditingController(text: 'patient123');

  bool _obscurePassword = true;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _autofillDemoCredentials() {
    setState(() {
      _emailController.text = 'patient@mindweave.com';
      _passwordController.text = 'patient123';
      _errorMessage = null;
    });
  }

  Future<void> _submitLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _errorMessage = null;
    });

    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter patient Email or Username.';
      });
      return;
    }

    if (password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter patient password credentials.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 300));

    final success = MindWeaveStore.instance.loginPatient(
      email: email,
      password: password,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.indigo.shade800,
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Welcome, ${MindWeaveStore.instance.patientName}! Logged into Patient Portal.'),
              ),
            ],
          ),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LanguagePage(),
        ),
      );
    } else {
      setState(() {
        _errorMessage =
            'Invalid patient credentials. Password must be at least 4 characters or use demo credentials.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Authentication'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade50,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: Colors.indigo.shade200, width: 1.5),
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 42,
                          color: Colors.indigo,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Center(
                      child: Text(
                        'Patient Portal Login',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Center(
                      child: Text(
                        'Sign in with patient credentials to access personalized voice reminders, memory games & routines.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // DEMO CREDENTIALS QUICK FILL
                    InkWell(
                      onTap: _autofillDemoCredentials,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.indigo.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.key, size: 20, color: Colors.indigo),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Demo Patient Credentials',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.indigo,
                                    ),
                                  ),
                                  Text(
                                    'patient@mindweave.com / patient123',
                                    style: TextStyle(fontSize: 11, color: Colors.black87),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: _autofillDemoCredentials,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text('Auto-fill', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ERROR MESSAGE BANNER
                    if (_errorMessage != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.red, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    const Text(
                      'Patient Email / Username',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'patient@mindweave.com',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Password Credentials',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Enter patient password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onSubmitted: (_) => _submitLogin(),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.indigo.shade600,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isLoading ? null : _submitLogin,
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Sign In to Patient Portal',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Center(
                      child: TextButton.icon(
                        icon: const Icon(Icons.arrow_back, size: 18),
                        label: const Text('Back to Portal Selection'),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),

                    const SizedBox(height: 12),
                    const Center(
                      child: Text(
                        '🔒 Secure Patient Access • MindWeave 2026',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// DEDICATED CARETAKER LOGIN PAGE
// ============================================================

class CaretakerLoginPage extends StatefulWidget {
  const CaretakerLoginPage({super.key});

  @override
  State<CaretakerLoginPage> createState() => _CaretakerLoginPageState();
}

class _CaretakerLoginPageState extends State<CaretakerLoginPage> {
  final TextEditingController _emailController =
      TextEditingController(text: 'caregiver@example.com');
  final TextEditingController _passwordController =
      TextEditingController(text: 'password123');

  bool _obscurePassword = true;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _autofillDemoCredentials() {
    setState(() {
      _emailController.text = 'caregiver@example.com';
      _passwordController.text = 'password123';
      _errorMessage = null;
    });
  }

  Future<void> _submitLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _errorMessage = null;
    });

    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your Caretaker Email or Username.';
      });
      return;
    }

    if (password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your password credentials.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 350));

    final success = MindWeaveStore.instance.loginCaregiver(email, password);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.teal.shade800,
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text('Welcome, $email! Logged in as Caretaker.'),
            ],
          ),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const CaregiverDashboard(),
        ),
      );
    } else {
      setState(() {
        _errorMessage =
            'Invalid credentials. Please verify your password or use demo credentials.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caretaker Authentication'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: Colors.teal.shade200, width: 1.5),
                        ),
                        child: const Icon(
                          Icons.medical_services_outlined,
                          size: 42,
                          color: Colors.teal,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Center(
                      child: Text(
                        'Caretaker Portal',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Center(
                      child: Text(
                        'Sign in with caretaker password credentials to access patient analytics & manage voice reminders.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // DEMO CREDENTIALS QUICK FILL
                    InkWell(
                      onTap: _autofillDemoCredentials,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.shade300),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.key, size: 20, color: Colors.amber),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Demo Credentials',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.brown,
                                    ),
                                  ),
                                  Text(
                                    'caregiver@example.com / password123',
                                    style: TextStyle(fontSize: 11, color: Colors.black87),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: _autofillDemoCredentials,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text('Auto-fill', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ERROR MESSAGE BANNER
                    if (_errorMessage != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.red, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    const Text(
                      'Email / Username',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Enter caretaker email',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Password Credentials',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Enter password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onSubmitted: (_) => _submitLogin(),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.teal.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isLoading ? null : _submitLogin,
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Sign In to Caretaker Dashboard',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Center(
                      child: TextButton.icon(
                        icon: const Icon(Icons.arrow_back, size: 18),
                        label: const Text('Back to Patient Portal Selection'),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),

                    const SizedBox(height: 12),
                    const Center(
                      child: Text(
                        '🔒 HIPAA-Compliant Session Simulation • MindWeave 2026',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// LANGUAGE
// ============================================================

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() =>
      _LanguagePageState();
}

class _LanguagePageState
    extends State<LanguagePage> {
  String selected = 'English';

  final languages = [
    ('English', 'English', '🇬🇧'),
    ('Tamil', 'தமிழ்', '🇮🇳'),
    ('Hindi', 'हिन्दी', '🇮🇳'),
    ('Telugu', 'తెలుగు', '🇮🇳'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MindWeave'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: 550),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Icon(
                  Icons.translate,
                  size: 55,
                  color: Colors.indigo,
                ),
                const SizedBox(height: 20),
                Text(
                  T.text(
                    'chooseLanguage',
                    selected,
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This language will be used for the patient experience and voice assistance.',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 28),
                ...languages.map(
                  (language) {
                    final selectedNow =
                        selected == language.$1;

                    return Padding(
                      padding:
                          const EdgeInsets.only(
                        bottom: 10,
                      ),
                      child: InkWell(
                        borderRadius:
                            BorderRadius.circular(16),
                        onTap: () {
                          setState(() {
                            selected =
                                language.$1;
                          });
                        },
                        child: Container(
                          padding:
                              const EdgeInsets.all(16),
                          decoration:
                              BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(
                                    16),
                            border: Border.all(
                              color: selectedNow
                                  ? Colors.indigo
                                  : Colors
                                      .grey.shade300,
                              width:
                                  selectedNow ? 2 : 1,
                            ),
                            color: selectedNow
                                ? Colors
                                    .indigo.shade50
                                : Colors.white,
                          ),
                          child: Row(
                            children: [
                              Text(
                                language.$3,
                                style:
                                    const TextStyle(
                                  fontSize: 24,
                                ),
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              Expanded(
                                child: Text(
                                  language.$2,
                                  style:
                                      const TextStyle(
                                    fontSize: 18,
                                    fontWeight:
                                        FontWeight
                                            .w600,
                                  ),
                                ),
                              ),
                              Icon(
                                selectedNow
                                    ? Icons
                                        .radio_button_checked
                                    : Icons
                                        .radio_button_off,
                                color: selectedNow
                                    ? Colors.indigo
                                    : Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      await MindWeaveStore.instance
                          .setLanguage(selected);

                      if (!context.mounted) return;

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const PatientDashboard(),
                        ),
                      );
                    },
                    child: Text(
                      T.text(
                        'continue',
                        selected,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// PATIENT DASHBOARD
// ============================================================

class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() =>
      _PatientDashboardState();
}

class _PatientDashboardState
    extends State<PatientDashboard> {
  final store = MindWeaveStore.instance;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        store.startReminderEngine(context);
      },
    );
  }

  @override
  void dispose() {
    store.stopReminderEngine();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final language = store.language;

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  T.text('dashboard', language),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 19,
                  ),
                ),
                Text(
                  'Patient: ${store.patientName}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Speak with Voice Assistant',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const VoiceAssistantPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.mic_none),
              ),
              PopupMenuButton<String>(
                tooltip: 'Patient Account',
                icon: const Icon(Icons.account_circle),
                onSelected: (value) {
                  if (value == 'logout') {
                    store.logoutPatient();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                      (route) => false,
                    );
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    enabled: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Signed in as Patient',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                        Text(
                          store.patientEmail.isNotEmpty ? store.patientEmail : 'patient@mindweave.com',
                          style: const TextStyle(fontSize: 13, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.redAccent, size: 20),
                        SizedBox(width: 8),
                        Text('Log Out / Exit Portal', style: TextStyle(color: Colors.redAccent)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Center(
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(maxWidth: 900),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    if (store.activeReminderAlert != null || store.isSpeakingReminder) ...[
                      _activeVoiceAlertBanner(),
                      const SizedBox(height: 16),
                    ],
                    _welcomeCard(language),
                    const SizedBox(height: 16),
                    _todayVoiceRemindersCard(language),
                    const SizedBox(height: 16),
                    _aiPatientCard(),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _miniStat(
                            Icons.extension,
                            '${store.performance.gamesCompleted}',
                            'Games',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _miniStat(
                            Icons.percent,
                            '${store.performance.averageAccuracy.toStringAsFixed(0)}%',
                            'Accuracy',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _miniStat(
                            Icons.trending_up,
                            store.performance.level,
                            'Level',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Text(
                      T.text('games', language),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount:
                          MediaQuery.of(context)
                                      .size
                                      .width >
                                  650
                              ? 4
                              : 2,
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.2,
                      children: [
                        _featureCard(
                          context,
                          Icons.grid_view_rounded,
                          'Memory Match',
                          'Match the pairs',
                          const MemoryMatchPage(),
                        ),
                        _featureCard(
                          context,
                          Icons.format_list_numbered,
                          'Sequence Recall',
                          'Remember order',
                          const SequenceRecallPage(),
                        ),
                        _featureCard(
                          context,
                          Icons.pattern,
                          'Pattern Recall',
                          'Find the pattern',
                          const PatternPage(),
                        ),
                        _featureCard(
                          context,
                          Icons.schedule,
                          'Routine Recall',
                          'Remember routine',
                          const RoutineRecallPage(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Daily Care & Voice Assistant',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount:
                          MediaQuery.of(context)
                                      .size
                                      .width >
                                  650
                              ? 3
                              : 2,
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.2,
                      children: [
                        _featureCard(
                          context,
                          Icons.notifications_active_outlined,
                          T.text(
                            'reminders',
                            language,
                          ),
                          'Voice & text alerts',
                          const ReminderPage(),
                        ),
                        _featureCard(
                          context,
                          Icons.mic_none,
                          T.text(
                            'voice',
                            language,
                          ),
                          'Speak with MindWeave',
                          const VoiceAssistantPage(),
                        ),
                        _featureCard(
                          context,
                          Icons.bar_chart,
                          T.text(
                            'progress',
                            language,
                          ),
                          'View performance',
                          const ProgressPage(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _activeVoiceAlertBanner() {
    final alert = store.activeReminderAlert;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade900, Colors.indigo.shade700],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.amberAccent.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.volume_up_rounded,
              color: Colors.amberAccent,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      '🔊 Active Voice Notification',
                      style: TextStyle(
                        color: Colors.amberAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    if (store.isSpeakingReminder) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'SPEAKING',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  store.currentSpeakingText ?? alert?.title ?? 'Scheduled Reminder',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (alert != null)
            IconButton(
              icon: const Icon(Icons.replay, color: Colors.white),
              tooltip: 'Hear Voice Again',
              onPressed: () => store.speakReminder(alert, context: context),
            ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white70),
            tooltip: 'Dismiss Alert',
            onPressed: () {
              store.stopSpeaking();
              store.dismissActiveReminderAlert();
            },
          ),
        ],
      ),
    );
  }

  Widget _todayVoiceRemindersCard(String language) {
    final activeReminders = store.reminders.where((r) => r.enabled).toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.notifications_active,
                    color: Colors.orange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🌟 Today’s Voice Reminders',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Spoken automatically in $language (${activeReminders.length} active)',
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.tune, size: 20),
                  tooltip: 'Manage Reminders',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ReminderPage()),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Reminders row chips / list
            if (activeReminders.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('No active reminders for today. Tap Manage to add routines.'),
              )
            else
              Column(
                children: activeReminders.take(3).map((r) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          MindWeaveStore.categoryIcon(r.category),
                          size: 20,
                          color: Colors.indigo,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '${r.time} • ${r.category}',
                                style: const TextStyle(fontSize: 11, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo.shade50,
                            foregroundColor: Colors.indigo.shade800,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.volume_up, size: 16),
                          label: const Text('Hear Voice', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          onPressed: () => store.speakReminder(r, context: context),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 12),

            // ACTION BUTTONS
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.indigo.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.record_voice_over, size: 18),
                  label: const Text('🔊 Read All Out Loud'),
                  onPressed: () => store.announceAllTodayReminders(context),
                ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.teal.shade800,
                    side: BorderSide(color: Colors.teal.shade600),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.hearing, size: 18),
                  label: const Text('🔔 Test Voice Alert'),
                  onPressed: () => store.testVoiceNotification(context),
                ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.deepPurple.shade800,
                    side: BorderSide(color: Colors.deepPurple.shade400, width: 1.5),
                    backgroundColor: Colors.deepPurple.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.alarm_add, size: 18),
                  label: const Text('⏰ Test Alarm (+1 Min)'),
                  onPressed: () => store.scheduleOneMinuteTestReminder(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _aiPatientCard() {
    final difficulty =
        AdaptiveAI.difficulty(store.performance);

    return Card(
      color: Colors.indigo.shade50,
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Row(
          children: [
            const Icon(
              Icons.auto_awesome,
              color: Colors.indigo,
              size: 30,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'MindWeave Adaptive AI',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Current difficulty: $difficulty',
                  ),
                  Text(
                    'Next: ${AdaptiveAI.nextGame(store.performance)}',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _welcomeCard(String language) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Colors.indigo.shade700,
            Colors.indigo.shade400,
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color:
                  Colors.white.withOpacity(.18),
              borderRadius:
                  BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.psychology,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  '${T.text('welcome', language)}, ${store.patientName}! 👋',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Your daily voice reminders & cognitive exercises are ready.',
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(
    IconData icon,
    String value,
    String label,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 14,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 22,
              color: Colors.indigo,
            ),
            const SizedBox(height: 7),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Widget page,
  ) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => page,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 29,
                color: Colors.indigo,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// MEMORY MATCH
// ============================================================

class MemoryMatchPage extends StatefulWidget {
  const MemoryMatchPage({super.key});

  @override
  State<MemoryMatchPage> createState() =>
      _MemoryMatchPageState();
}

class _MemoryMatchPageState
    extends State<MemoryMatchPage> {
  late List<String> cards;

  final opened = <int>[];
  final matched = <int>[];

  int score = 0;
  int attempts = 0;
  final Stopwatch stopwatch = Stopwatch();

  String get difficulty =>
      AdaptiveAI.difficulty(
        MindWeaveStore.instance.performance,
      );

  List<String> get symbols {
    if (difficulty == 'Hard') {
      return [
        '🍎',
        '🍎',
        '🌸',
        '🌸',
        '⭐',
        '⭐',
        '🍀',
        '🍀',
        '🌻',
        '🌻',
        '🍋',
        '🍋',
      ];
    }

    return [
      '🍎',
      '🍎',
      '🌸',
      '🌸',
      '⭐',
      '⭐',
      '🍀',
      '🍀',
    ];
  }

  @override
  void initState() {
    super.initState();

    cards = [...symbols]..shuffle();

    stopwatch.start();
  }

  void tapCard(int index) {
    if (opened.length == 2 ||
        opened.contains(index) ||
        matched.contains(index)) {
      return;
    }

    attempts++;

    setState(() {
      opened.add(index);
    });

    if (opened.length == 2) {
      if (cards[opened[0]] ==
          cards[opened[1]]) {
        setState(() {
          matched.addAll(opened);
          opened.clear();

          score += 100 ~/ (cards.length ~/ 2);
        });

        if (matched.length == cards.length) {
          stopwatch.stop();

          final accuracy = attempts == 0
              ? 100
              : ((matched.length / 2) /
                      attempts *
                      100)
                  .round();

          final finalScore =
              min(100, score);

          MindWeaveStore.instance.recordGame(
            game: 'Memory Match',
            score: finalScore,
            accuracy: accuracy,
            responseTime:
                stopwatch.elapsed.inSeconds,
            difficulty: difficulty,
          );

          Future.delayed(
            const Duration(milliseconds: 500),
            () {
              if (!mounted) return;

              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text(
                    'Well Done! 🎉',
                  ),
                  content: Text(
                    'Score: $finalScore\n'
                    'Accuracy: $accuracy%\n'
                    'Difficulty: $difficulty',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child:
                          const Text('Finish'),
                    ),
                  ],
                ),
              );
            },
          );
        }
      } else {
        Future.delayed(
          const Duration(milliseconds: 700),
          () {
            if (!mounted) return;

            setState(() {
              opened.clear();
            });
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Memory Match'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding:
                const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  'Adaptive Level: $difficulty',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Score: $score',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child:
                      GridView.builder(
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          cards.length > 8
                              ? 4
                              : 4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount:
                        cards.length,
                    itemBuilder:
                        (context, index) {
                      final visible =
                          opened.contains(
                                  index) ||
                              matched.contains(
                                  index);

                      return InkWell(
                        onTap: () =>
                            tapCard(index),
                        borderRadius:
                            BorderRadius.circular(
                                15),
                        child: Container(
                          decoration:
                              BoxDecoration(
                            color: visible
                                ? Colors.white
                                : Colors.indigo,
                            borderRadius:
                                BorderRadius.circular(
                                    15),
                            border: Border.all(
                              color: Colors
                                  .indigo.shade200,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              visible
                                  ? cards[index]
                                  : '?',
                              style:
                                  const TextStyle(
                                fontSize: 30,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SEQUENCE RECALL
// ============================================================

class SequenceRecallPage
    extends StatefulWidget {
  const SequenceRecallPage({super.key});

  @override
  State<SequenceRecallPage> createState() =>
      _SequenceRecallPageState();
}

class _SequenceRecallPageState
    extends State<SequenceRecallPage> {
  late List<int> sequence;

  bool showSequence = true;

  final answer = <int>[];

  late DateTime startTime;

  String get difficulty =>
      AdaptiveAI.difficulty(
        MindWeaveStore.instance.performance,
      );

  @override
  void initState() {
    super.initState();

    final random = Random();

    final length =
        difficulty == 'Hard'
            ? 7
            : difficulty == 'Medium'
                ? 6
                : 5;

    sequence = List.generate(
      length,
      (_) => random.nextInt(9) + 1,
    );

    startTime = DateTime.now();

    Future.delayed(
      Duration(
        seconds:
            difficulty == 'Hard'
                ? 5
                : 3,
      ),
      () {
        if (mounted) {
          setState(() {
            showSequence = false;
            startTime = DateTime.now();
          });
        }
      },
    );
  }

  void choose(int number) {
    if (answer.contains(number)) {
      return;
    }

    setState(() {
      answer.add(number);
    });

    if (answer.length ==
        sequence.length) {
      final correct =
          answer.join() == sequence.join();

      final accuracy = correct ? 100 : 40;

      final score = correct ? 100 : 40;

      final responseTime =
          DateTime.now()
              .difference(startTime)
              .inSeconds;

      MindWeaveStore.instance.recordGame(
        game: 'Sequence Recall',
        score: score,
        accuracy: accuracy,
        responseTime: responseTime,
        difficulty: difficulty,
      );

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(
            correct
                ? 'Excellent! 🎉'
                : 'Good Try!',
          ),
          content: Text(
            correct
                ? 'You remembered the sequence correctly.'
                : 'Correct sequence: ${sequence.join(' → ')}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child:
                  const Text('Finish'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Sequence Recall'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Text(
                'Adaptive Level: $difficulty',
                style: const TextStyle(
                  color: Colors.indigo,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Remember the sequence',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              const SizedBox(height: 25),
              if (showSequence)
                Text(
                  sequence.join(' → '),
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight:
                        FontWeight.bold,
                  ),
                )
              else
                const Text(
                  'Now select the numbers',
                  style:
                      TextStyle(fontSize: 18),
                ),
              const SizedBox(height: 35),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children:
                    List.generate(
                  9,
                  (index) {
                    final number =
                        index + 1;

                    return SizedBox(
                      width: 60,
                      height: 60,
                      child: FilledButton(
                        onPressed:
                            showSequence
                                ? null
                                : () =>
                                    choose(
                                        number),
                        child: Text(
                          '$number',
                          style:
                              const TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// PATTERN
// ============================================================

class PatternPage
    extends StatefulWidget {
  const PatternPage({super.key});

  @override
  State<PatternPage> createState() =>
      _PatternPageState();
}

class _PatternPageState
    extends State<PatternPage> {
  late List<String> sequence;
  late String correct;

  final options = [
    '🔴',
    '🟢',
    '🟡',
    '🔵',
  ];

  final stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();

    final difficulty =
        AdaptiveAI.difficulty(
      MindWeaveStore.instance.performance,
    );

    if (difficulty == 'Hard') {
      sequence = [
        '🔴',
        '🔵',
        '🟢',
        '🔴',
        '🔵',
        '?',
      ];
      correct = '🟢';
    } else {
      sequence = [
        '🔴',
        '🔵',
        '🔴',
        '🔵',
        '?',
      ];
      correct = '🔴';
    }

    stopwatch.start();
  }

  void answer(String value) {
    stopwatch.stop();

    final isCorrect =
        value == correct;

    final score =
        isCorrect ? 100 : 30;

    MindWeaveStore.instance.recordGame(
      game: 'Pattern Recall',
      score: score,
      accuracy:
          isCorrect ? 100 : 30,
      responseTime:
          stopwatch.elapsed.inSeconds,
      difficulty: AdaptiveAI.difficulty(
        MindWeaveStore.instance.performance,
      ),
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          isCorrect
              ? 'Correct! 🎉'
              : 'Try Again',
        ),
        content: Text(
          isCorrect
              ? 'You found the pattern!'
              : 'Look carefully at the repeating pattern.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child:
                const Text('Finish'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Pattern Recall'),
      ),
      body: Center(
        child: Padding(
          padding:
              const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              const Text(
                'What comes next?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children:
                    sequence.map(
                  (item) {
                    return Container(
                      margin:
                          const EdgeInsets.all(
                              5),
                      width: 55,
                      height: 55,
                      decoration:
                          BoxDecoration(
                        borderRadius:
                            BorderRadius
                                .circular(
                                    12),
                        color: Colors.white,
                        border:
                            Border.all(
                          color: Colors
                              .grey.shade300,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          item,
                          style:
                              const TextStyle(
                            fontSize: 25,
                          ),
                        ),
                      ),
                    );
                  },
                ).toList(),
              ),
              const SizedBox(height: 30),
              Wrap(
                spacing: 12,
                children:
                    options.map(
                  (option) {
                    return OutlinedButton(
                      onPressed: () =>
                          answer(option),
                      child: Text(
                        option,
                        style:
                            const TextStyle(
                          fontSize: 25,
                        ),
                      ),
                    );
                  },
                ).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ROUTINE RECALL - NEW
// ============================================================

class RoutineRecallPage
    extends StatefulWidget {
  const RoutineRecallPage({super.key});

  @override
  State<RoutineRecallPage> createState() =>
      _RoutineRecallPageState();
}

class _RoutineRecallPageState
    extends State<RoutineRecallPage> {
  final routine = [
    'Wake up',
    'Drink Water',
    'Take Medicine',
    'Breakfast',
    'Morning Walk',
  ];

  late List<String> shuffled;

  final selected = <String>[];

  @override
  void initState() {
    super.initState();

    shuffled = [...routine]..shuffle();
  }

  void selectItem(String item) {
    if (selected.contains(item)) {
      return;
    }

    setState(() {
      selected.add(item);
    });

    if (selected.length ==
        routine.length) {
      final correct =
          selected.join('|') ==
              routine.join('|');

      MindWeaveStore.instance.recordGame(
        game: 'Routine Recall',
        score: correct ? 100 : 50,
        accuracy: correct ? 100 : 50,
        responseTime: 0,
        difficulty: AdaptiveAI.difficulty(
          MindWeaveStore.instance.performance,
        ),
      );

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(
            correct
                ? 'Excellent! 🌟'
                : 'Good Try!',
          ),
          content: Text(
            correct
                ? 'You remembered the daily routine correctly.'
                : 'A helpful routine is:\n${routine.join(' → ')}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child:
                  const Text('Finish'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Routine Recall'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(22),
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 650,
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.schedule,
                  size: 55,
                  color: Colors.indigo,
                ),
                const SizedBox(height: 15),
                const Text(
                  'Remember the daily routine',
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Arrange the activities in the order they normally happen.',
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 25),
                ...shuffled.map(
                  (item) {
                    final isSelected =
                        selected
                            .contains(item);

                    return Padding(
                      padding:
                          const EdgeInsets.only(
                        bottom: 10,
                      ),
                      child: SizedBox(
                        width:
                            double.infinity,
                        child: OutlinedButton(
                          onPressed:
                              isSelected
                                  ? null
                                  : () =>
                                      selectItem(
                                          item),
                          child: Padding(
                            padding:
                                const EdgeInsets
                                    .all(10),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  child: Text(
                                    isSelected
                                        ? '${selected.indexOf(item) + 1}'
                                        : '?',
                                  ),
                                ),
                                const SizedBox(
                                    width: 12),
                                Text(item),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// VOICE ASSISTANT
// ============================================================

class VoiceAssistantPage
    extends StatefulWidget {
  const VoiceAssistantPage({super.key});

  @override
  State<VoiceAssistantPage> createState() =>
      _VoiceAssistantPageState();
}

class _VoiceAssistantPageState
    extends State<VoiceAssistantPage> {
  final speech = stt.SpeechToText();

  final tts = FlutterTts();

  bool listening = false;

  String recognizedText = '';

  String response = '';

  @override
  void initState() {
    super.initState();

    _configureTts();
  }

  Future<void> _configureTts() async {
    final language =
        MindWeaveStore.instance.language;

    String locale = 'en-US';

    if (language == 'Tamil') {
      locale = 'ta-IN';
    }

    if (language == 'Hindi') {
      locale = 'hi-IN';
    }

    if (language == 'Telugu') {
      locale = 'te-IN';
    }

    await tts.setLanguage(locale);

    await tts.setSpeechRate(.45);
  }

  Future<void> startListening() async {
    final available =
        await speech.initialize();

    if (!available) {
      setState(() {
        response =
            'Speech recognition is not available.';
      });

      return;
    }

    setState(() {
      listening = true;
      recognizedText = '';
      response = '';
    });

    String localeId = 'en_US';

    final language =
        MindWeaveStore.instance.language;

    if (language == 'Tamil') {
      localeId = 'ta_IN';
    }

    if (language == 'Hindi') {
      localeId = 'hi_IN';
    }

    if (language == 'Telugu') {
      localeId = 'te_IN';
    }

    await speech.listen(
      localeId: localeId,
      onResult: (result) {
        setState(() {
          recognizedText =
              result.recognizedWords;
        });

        if (result.finalResult) {
          respondToUser(
            recognizedText,
          );
        }
      },
    );
  }

  Future<void> stopListening() async {
    await speech.stop();

    setState(() {
      listening = false;
    });
  }

  Future<void> respondToUser(
    String text,
  ) async {
    final lower = text.toLowerCase();

    String answer;

    final store =
        MindWeaveStore.instance;

    if (lower.contains('water') ||
        lower.contains('தண்ணீர்') ||
        lower.contains('पानी')) {
      answer =
          store.localizedReminder(
        'Drink Water',
      );
    } else if (lower.contains('medicine') ||
        lower.contains('மருந்து') ||
        lower.contains('दवाई')) {
      answer =
          store.localizedReminder(
        'Take Medicine',
      );
    } else if (lower.contains('appointment') ||
        lower.contains('hospital') ||
        lower.contains('doctor')) {
      answer =
          store.localizedReminder(
        'Medical Appointment',
      );
    } else if (lower.contains('reminder')) {
      answer =
          'You have ${store.reminders.length} reminders configured.';
    } else if (lower.contains('score') ||
        lower.contains('progress')) {
      answer =
          'Your average score is ${store.performance.averageScore.toStringAsFixed(0)} percent.';
    } else {
      final language = store.language;

      answer = language == 'Tamil'
          ? 'நான் உங்களுக்கு உதவ தயாராக இருக்கிறேன்.'
          : language == 'Hindi'
              ? 'मैं आपकी मदद करने के लिए तैयार हूँ।'
              : language == 'Telugu'
                  ? 'నేను మీకు సహాయం చేయడానికి సిద్ధంగా ఉన్నాను.'
                  : 'I am ready to help you.';
    }

    setState(() {
      response = answer;
      listening = false;
    });

    await _configureTts();

    await tts.speak(answer);
  }

  @override
  void dispose() {
    speech.stop();
    tts.stop();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final language =
        MindWeaveStore.instance.language;

    return Scaffold(
      appBar: AppBar(
        title:
            Text(T.text('voice', language)),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(25),
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 600,
            ),
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration:
                      BoxDecoration(
                    color:
                        Colors.indigo.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    listening
                        ? Icons.mic
                        : Icons.mic_none,
                    size: 48,
                    color:
                        Colors.indigo,
                  ),
                ),
                const SizedBox(height: 25),
                const Text(
                  'Talk to MindWeave',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Ask about reminders, water, medicine, appointments or progress.',
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 30),
                if (recognizedText.isNotEmpty)
                  Card(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(
                              16),
                      child: Column(
                        children: [
                          const Text(
                            'You said:',
                            style: TextStyle(
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                          const SizedBox(
                              height: 7),
                          Text(
                            recognizedText,
                            textAlign:
                                TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                if (response.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Card(
                    color:
                        Colors.indigo.shade50,
                    child: Padding(
                      padding:
                          const EdgeInsets.all(
                              16),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.volume_up,
                            color:
                                Colors.indigo,
                          ),
                          const SizedBox(
                              height: 8),
                          Text(
                            response,
                            textAlign:
                                TextAlign.center,
                            style:
                                const TextStyle(
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 25),
                SizedBox(
                  width:
                      double.infinity,
                  child: FilledButton.icon(
                    onPressed: listening
                        ? stopListening
                        : startListening,
                    icon: Icon(
                      listening
                          ? Icons.stop
                          : Icons.mic,
                    ),
                    label: Text(
                      listening
                          ? 'Stop Listening'
                          : 'Start Voice Assistant',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// REMINDERS
// ============================================================

class ReminderPage extends StatefulWidget {
  const ReminderPage({super.key});

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  final store = MindWeaveStore.instance;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final activeReminders = store.reminders.where((r) => r.enabled).toList();

        return Scaffold(
          appBar: AppBar(
            title: Text(
              T.text('reminders', store.language),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.volume_up),
                tooltip: 'Announce All Reminders',
                onPressed: () => store.announceAllTodayReminders(context),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _addReminder(context),
            backgroundColor: Colors.indigo.shade700,
            icon: const Icon(Icons.add_alarm, color: Colors.white),
            label: const Text('Add Reminder', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          body: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              // VOICE NOTIFICATION HEADER CARD
              Card(
                elevation: 2,
                color: Colors.indigo.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.indigo.shade600,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.record_voice_over,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '🔊 Voice-Guided Reminder Notifications',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.indigo,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Reminders speak aloud automatically in ${store.language}. Tap "Hear Voice" on any reminder to listen anytime.',
                                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children: [
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.indigo.shade700,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.volume_up, size: 18),
                            label: Text('🔊 Announce All (${activeReminders.length})'),
                            onPressed: () => store.announceAllTodayReminders(context),
                          ),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.teal.shade800,
                              side: BorderSide(color: Colors.teal.shade700),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.hearing, size: 18),
                            label: const Text('🔔 Test Voice Alert'),
                            onPressed: () => store.testVoiceNotification(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Active Reminders (${store.reminders.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (store.isSpeakingReminder)
                    Row(
                      children: [
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () => store.stopSpeaking(),
                          child: const Text('Stop Voice', style: TextStyle(color: Colors.red, fontSize: 12)),
                        ),
                      ],
                    ),
                ],
              ),

              const SizedBox(height: 10),

              ...store.reminders.map(
                (reminder) {
                  final isThisSpeaking =
                      store.isSpeakingReminder && store.activeReminderAlert?.id == reminder.id;

                  return Card(
                    elevation: isThisSpeaking ? 3 : 1,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: isThisSpeaking
                          ? BorderSide(color: Colors.indigo.shade600, width: 2)
                          : BorderSide.none,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: isThisSpeaking
                                ? Colors.indigo.shade700
                                : Colors.indigo.shade50,
                            child: Icon(
                              MindWeaveStore.categoryIcon(reminder.category),
                              color: isThisSpeaking ? Colors.white : Colors.indigo,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      reminder.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: isThisSpeaking
                                            ? Colors.indigo.shade900
                                            : Colors.black87,
                                      ),
                                    ),
                                    if (isThisSpeaking) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.redAccent,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          'SPEAKING',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '⏰ ${reminder.time}  •  ${reminder.category}',
                                  style: const TextStyle(
                                      fontSize: 13, color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.volume_up_rounded,
                              color: isThisSpeaking
                                  ? Colors.amber.shade800
                                  : Colors.indigo,
                              size: 26,
                            ),
                            tooltip: 'Hear Voice Announcement',
                            onPressed: () {
                              store.speakReminder(reminder, context: context);
                            },
                          ),
                          Switch(
                            value: reminder.enabled,
                            activeColor: Colors.indigo,
                            onChanged: (_) {
                              store.toggleReminder(reminder);
                            },
                          ),
                          IconButton(
                            onPressed: () {
                              store.deleteReminder(reminder.id);
                            },
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 60),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addReminder(BuildContext context) async {
    final titleController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();
    String category = 'General';

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Daily Reminder'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Reminder Title',
                        hintText: 'e.g., Drink water',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      value: category,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'General',
                          child: Text('General'),
                        ),
                        DropdownMenuItem(
                          value: 'Water',
                          child: Text('Drink Water'),
                        ),
                        DropdownMenuItem(
                          value: 'Medicine',
                          child: Text('Medicine'),
                        ),
                        DropdownMenuItem(
                          value: 'Appointment',
                          child: Text('Medical Appointment'),
                        ),
                        DropdownMenuItem(
                          value: 'Exercise',
                          child: Text('Exercise'),
                        ),
                        DropdownMenuItem(
                          value: 'Routine',
                          child: Text('Daily Routine'),
                        ),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          category = value ?? 'General';
                        });
                      },
                    ),
                    const SizedBox(height: 15),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                        );

                        if (picked != null) {
                          setDialogState(() {
                            selectedTime = picked;
                          });
                        }
                      },
                      icon: const Icon(Icons.access_time),
                      label: Text(
                        'Time: ${selectedTime.format(context)}',
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        final title = titleController.text.trim().isEmpty
                            ? 'Daily Routine'
                            : titleController.text.trim();
                        final testReminder = Reminder(
                          id: 'preview',
                          title: title,
                          time:
                              '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                          category: category,
                        );
                        MindWeaveStore.instance.speakReminder(testReminder);
                      },
                      icon: const Icon(Icons.volume_up, color: Colors.indigo),
                      label: const Text('🔊 Voice Preview'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    if (titleController.text.trim().isEmpty) {
                      return;
                    }

                    final time =
                        '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';

                    final newReminder = Reminder(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: titleController.text.trim(),
                      time: time,
                      category: category,
                    );

                    MindWeaveStore.instance.addReminder(newReminder);
                    MindWeaveStore.instance.speakText(
                      'Reminder added for ${newReminder.title} at ${newReminder.time}',
                    );

                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ============================================================
// PROGRESS
// ============================================================

class ProgressPage
    extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store =
        MindWeaveStore.instance;

    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final average =
            store.performance.averageScore;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              T.text(
                'progress',
                store.language,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding:
                const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(
                  maxWidth: 800,
                ),
                child: Column(
                  children: [
                    Card(
                      child: Padding(
                        padding:
                            const EdgeInsets.all(
                                25),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.insights,
                              size: 45,
                              color:
                                  Colors.indigo,
                            ),
                            const SizedBox(
                                height: 12),
                            const Text(
                              'Cognitive Performance',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                            const SizedBox(
                                height: 20),
                            LinearProgressIndicator(
                              value: min(
                                average / 100,
                                1,
                              ),
                              minHeight: 12,
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          10),
                            ),
                            const SizedBox(
                                height: 10),
                            Text(
                              '${average.toStringAsFixed(0)}% average score',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                        height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: _stat(
                            'Games',
                            '${store.performance.gamesCompleted}',
                            Icons.games_outlined,
                          ),
                        ),
                        const SizedBox(
                            width: 10),
                        Expanded(
                          child: _stat(
                            'Accuracy',
                            '${store.performance.averageAccuracy.toStringAsFixed(0)}%',
                            Icons.percent,
                          ),
                        ),
                        const SizedBox(
                            width: 10),
                        Expanded(
                          child: _stat(
                            'Streak',
                            '${store.performance.currentStreak}',
                            Icons.local_fire_department,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                        height: 15),
                    Card(
                      child: ListTile(
                        leading:
                            const Icon(
                          Icons.psychology,
                          color:
                              Colors.indigo,
                        ),
                        title: const Text(
                          'Cognitive Level',
                        ),
                        subtitle: Text(
                          store.performance
                              .level,
                        ),
                      ),
                    ),
                    const SizedBox(
                        height: 15),
                    Card(
                      child: Padding(
                        padding:
                            const EdgeInsets.all(
                                18),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            const Text(
                              'Weekly Activity',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                            const SizedBox(
                                height: 20),
                            SizedBox(
                              height: 180,
                              child:
                                  PerformanceChart(
                                records: store
                                    .performance
                                    .history,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                        height: 15),
                    Card(
                      color:
                          Colors.indigo.shade50,
                      child: Padding(
                        padding:
                            const EdgeInsets.all(
                                18),
                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            const Icon(
                              Icons
                                  .auto_awesome,
                              color:
                                  Colors.indigo,
                            ),
                            const SizedBox(
                                width: 12),
                            Expanded(
                              child: Text(
                                AdaptiveAI
                                    .recommendation(
                                  store
                                      .performance,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _stat(
    String title,
    String value,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(14),
        child: Column(
          children: [
            Icon(
              icon,
              size: 27,
              color: Colors.indigo,
            ),
            const SizedBox(height: 7),
            Text(
              value,
              style: const TextStyle(
                fontSize: 21,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            Text(
              title,
              textAlign:
                  TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// PERFORMANCE CHART
// ============================================================

class PerformanceChart
    extends StatelessWidget {
  final List<GameRecord> records;

  const PerformanceChart({
    super.key,
    required this.records,
  });

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return const Center(
        child: Text(
          'Complete games to generate your performance chart.',
          textAlign: TextAlign.center,
        ),
      );
    }

    final recent =
        records.length > 7
            ? records.sublist(
                records.length - 7,
              )
            : records;

    return CustomPaint(
      painter: _ChartPainter(recent),
      child: Container(),
    );
  }
}

class _ChartPainter
    extends CustomPainter {
  final List<GameRecord> records;

  _ChartPainter(this.records);

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    if (records.isEmpty) return;

    final paint = Paint()
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..style = PaintingStyle.fill;

    final path = Path();

    for (int i = 0;
        i < records.length;
        i++) {
      final x = records.length == 1
          ? size.width / 2
          : i *
              size.width /
              (records.length - 1);

      final y = size.height -
          (records[i].score / 100) *
              size.height;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(
      path,
      paint,
    );

    for (int i = 0;
        i < records.length;
        i++) {
      final x = records.length == 1
          ? size.width / 2
          : i *
              size.width /
              (records.length - 1);

      final y = size.height -
          (records[i].score / 100) *
              size.height;

      canvas.drawCircle(
        Offset(x, y),
        5,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant _ChartPainter oldDelegate,
  ) {
    return oldDelegate.records !=
        records;
  }
}

// ============================================================
// CAREGIVER DASHBOARD
// ============================================================

class CaregiverDashboard
    extends StatelessWidget {
  const CaregiverDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final store =
        MindWeaveStore.instance;

    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final average =
            store.performance.averageScore;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Caregiver / Family Portal',
              style: TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                tooltip: 'Test Voice Alert',
                icon: const Icon(Icons.volume_up_outlined),
                onPressed: () => store.testVoiceNotification(),
              ),
              PopupMenuButton<String>(
                tooltip: 'Caretaker Account',
                icon: const Icon(Icons.account_circle),
                onSelected: (value) {
                  if (value == 'logout') {
                    store.logoutCaregiver();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                      (route) => false,
                    );
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    enabled: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Signed in as Caretaker',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                        Text(
                          store.caregiverEmail.isNotEmpty ? store.caregiverEmail : 'caregiver@example.com',
                          style: const TextStyle(fontSize: 13, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Log Out / Exit Portal',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding:
                const EdgeInsets.all(18),
            child: Center(
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(
                  maxWidth: 1000,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Card(
                      color:
                          Colors.indigo.shade50,
                      child: Padding(
                        padding:
                            const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 28,
                              child: Icon(
                                Icons.admin_panel_settings,
                              ),
                            ),
                            const SizedBox(
                                width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'Caretaker Portal',
                                        style:
                                            TextStyle(
                                          fontSize:
                                              21,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade100,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          'Authenticated',
                                          style: TextStyle(
                                            color: Colors.green.shade800,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                      height: 4),
                                  Text(
                                    'Logged in as: ${store.caregiverEmail.isNotEmpty ? store.caregiverEmail : "caregiver@example.com"} • Monitoring ${store.patientName}',
                                    style: const TextStyle(
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: () {
                                store.logoutCaregiver();
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginPage(),
                                  ),
                                  (route) => false,
                                );
                              },
                              icon: const Icon(Icons.logout, size: 16),
                              label: const Text('Sign Out'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                        height: 20),
                    const Text(
                      'Cognitive Analytics',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                        height: 12),
                    GridView.count(
                      crossAxisCount:
                          MediaQuery.of(context)
                                      .size
                                      .width >
                                  700
                              ? 4
                              : 2,
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.25,
                      children: [
                        _metric(
                          Icons.games_outlined,
                          '${store.performance.gamesCompleted}',
                          'Games',
                        ),
                        _metric(
                          Icons.percent,
                          '${store.performance.averageAccuracy.toStringAsFixed(0)}%',
                          'Accuracy',
                        ),
                        _metric(
                          Icons.analytics_outlined,
                          '${average.toStringAsFixed(0)}%',
                          'Average Score',
                        ),
                        _metric(
                          Icons.psychology,
                          store.performance
                              .level,
                          'Cognitive Level',
                        ),
                      ],
                    ),
                    const SizedBox(
                        height: 20),
                    Card(
                      child: Padding(
                        padding:
                            const EdgeInsets.all(
                                18),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons
                                      .auto_awesome,
                                  color:
                                      Colors.indigo,
                                ),
                                SizedBox(
                                    width: 10),
                                Text(
                                  'AI Personalized Insight',
                                  style:
                                      TextStyle(
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                                height: 14),
                            Text(
                              AdaptiveAI
                                  .insight(
                                store
                                    .performance,
                              ),
                            ),
                            const SizedBox(
                                height: 14),
                            Container(
                              padding:
                                  const EdgeInsets
                                      .all(14),
                              decoration:
                                  BoxDecoration(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                            12),
                                color: Colors
                                    .indigo
                                    .shade50,
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons
                                        .recommend,
                                    color:
                                        Colors.indigo,
                                  ),
                                  const SizedBox(
                                      width: 10),
                                  Expanded(
                                    child: Text(
                                      'Recommended: ${AdaptiveAI.nextGame(store.performance)}',
                                      style:
                                          const TextStyle(
                                        fontWeight:
                                            FontWeight
                                                .w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                        height: 20),
                    Card(
                      child: Padding(
                        padding:
                            const EdgeInsets.all(
                                18),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            const Text(
                              'Weekly Performance',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                            const SizedBox(
                                height: 15),
                            SizedBox(
                              height: 180,
                              child:
                                  PerformanceChart(
                                records: store
                                    .performance
                                    .history,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                        height: 20),
                    const Text(
                      'Caregiver Actions',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                        height: 12),
                    Row(
                      children: [
                        Expanded(
                          child:
                              _actionCard(
                            context,
                            Icons
                                .add_alert_outlined,
                            'Add Reminder',
                            'Medicine, water or appointment',
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const CaregiverReminderPage(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(
                            width: 10),
                        Expanded(
                          child:
                              _actionCard(
                            context,
                            Icons
                                .volume_up_outlined,
                            'Voice Reminders',
                            'Test patient speech announcements',
                            () {
                              store.testVoiceNotification();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    '🔊 Playing test voice reminder for patient portal...',
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                        height: 20),
                    Card(
                      child: Padding(
                        padding:
                            const EdgeInsets.all(
                                18),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Configured Care Plan & Voice Alerts',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const CaregiverReminderPage(),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.add, size: 16),
                                  label: const Text('Add New'),
                                ),
                              ],
                            ),
                            const SizedBox(
                                height: 12),
                            if (store.reminders.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(12),
                                child: Text('No reminders configured yet.'),
                              )
                            else
                              ...store.reminders
                                  .map(
                                (reminder) =>
                                    ListTile(
                                  dense: true,
                                  leading:
                                      Icon(
                                    MindWeaveStore
                                        .categoryIcon(
                                      reminder
                                          .category,
                                    ),
                                    color: Colors
                                        .indigo,
                                  ),
                                  title: Text(
                                    reminder
                                        .title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle:
                                      Text(
                                    '${reminder.time} • ${reminder.category}',
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        tooltip: 'Speak this reminder aloud',
                                        icon: const Icon(
                                          Icons.volume_up,
                                          color: Colors.indigo,
                                        ),
                                        onPressed: () {
                                          store.speakReminder(reminder);
                                        },
                                      ),
                                      IconButton(
                                        tooltip: 'Delete reminder',
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.redAccent,
                                        ),
                                        onPressed: () {
                                          store.deleteReminder(reminder.id);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                        height: 20),
                    Card(
                      color:
                          Colors.green.shade50,
                      child: const Padding(
                        padding:
                            EdgeInsets.all(18),
                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Icon(
                              Icons
                                  .offline_bolt,
                              color:
                                  Colors.green,
                            ),
                            SizedBox(
                                width: 12),
                            Expanded(
                              child: Text(
                                'Offline-first: patient performance and reminders are stored locally. Voice alerts use offline TTS to deliver spoken notifications to patients at all times.',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _metric(
    IconData icon,
    String value,
    String label,
  ) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.indigo,
              size: 27,
            ),
            const SizedBox(
                height: 7),
            Text(
              value,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 17,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            Text(
              label,
              textAlign:
                  TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(12),
        child: Padding(
          padding:
              const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: Colors.indigo,
              ),
              const SizedBox(
                  height: 10),
              Text(
                title,
                textAlign:
                    TextAlign.center,
                style: const TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              const SizedBox(
                  height: 5),
              Text(
                subtitle,
                textAlign:
                    TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// CAREGIVER ADD REMINDER
// ============================================================

class CaregiverReminderPage
    extends StatefulWidget {
  const CaregiverReminderPage({
    super.key,
  });

  @override
  State<CaregiverReminderPage>
      createState() =>
          _CaregiverReminderPageState();
}

class _CaregiverReminderPageState
    extends State<CaregiverReminderPage> {
  final titleController =
      TextEditingController();

  TimeOfDay selectedTime =
      const TimeOfDay(
    hour: 17,
    minute: 0,
  );

  String category = 'Water';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text(
          'Add Patient Reminder',
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(22),
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 550,
            ),
            child: Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    const Icon(
                      Icons.add_alert,
                      size: 40,
                      color:
                          Colors.indigo,
                    ),
                    const SizedBox(
                        height: 15),
                    const Text(
                      'Create a daily reminder',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                        height: 7),
                    const Text(
                      'The patient will receive an in-app text banner and a spoken voice notification.',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(
                        height: 25),
                    TextField(
                      controller:
                          titleController,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Reminder title',
                        hintText:
                            'Example: Drink Water',
                        prefixIcon:
                            Icon(Icons.edit_outlined),
                        border:
                            OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(
                        height: 16),
                    DropdownButtonFormField<
                        String>(
                      value: category,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Category',
                        border:
                            OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Water',
                          child:
                              Text('Water'),
                        ),
                        DropdownMenuItem(
                          value: 'Medicine',
                          child:
                              Text('Medicine'),
                        ),
                        DropdownMenuItem(
                          value: 'Appointment',
                          child: Text(
                            'Medical Appointment',
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Exercise',
                          child:
                              Text('Exercise'),
                        ),
                        DropdownMenuItem(
                          value: 'Routine',
                          child: Text(
                            'Daily Routine',
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'General',
                          child:
                              Text('General'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          category =
                              value ??
                                  'General';
                        });
                      },
                    ),
                    const SizedBox(
                        height: 16),
                    SizedBox(
                      width:
                          double.infinity,
                      child:
                          OutlinedButton.icon(
                        onPressed: () async {
                          final picked =
                              await showTimePicker(
                            context:
                                context,
                            initialTime:
                                selectedTime,
                          );

                          if (picked !=
                              null) {
                            setState(() {
                              selectedTime =
                                  picked;
                            });
                          }
                        },
                        icon: const Icon(
                          Icons.access_time,
                        ),
                        label: Padding(
                          padding:
                              const EdgeInsets
                                  .all(4),
                          child: Text(
                            'Reminder time: ${selectedTime.format(context)}',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                        height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          final title = titleController.text.trim().isEmpty
                              ? 'Take your afternoon routine'
                              : titleController.text.trim();
                          final testReminder = Reminder(
                            id: 'preview',
                            title: title,
                            time: '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                            category: category,
                          );
                          MindWeaveStore.instance.speakReminder(testReminder);
                        },
                        icon: const Icon(Icons.volume_up, color: Colors.indigo),
                        label: const Text('🔊 Preview Voice Spoken Alert'),
                      ),
                    ),
                    const SizedBox(
                        height: 20),
                    SizedBox(
                      width:
                          double.infinity,
                      child:
                          FilledButton.icon(
                        onPressed: () {
                          if (titleController
                              .text
                              .trim()
                              .isEmpty) {
                            return;
                          }

                          final time =
                              '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';

                          final newReminder = Reminder(
                            id: DateTime
                                .now()
                                .millisecondsSinceEpoch
                                .toString(),
                            title:
                                titleController
                                    .text
                                    .trim(),
                            time: time,
                            category:
                                category,
                          );

                          MindWeaveStore
                              .instance
                              .addReminder(newReminder);

                          // Also speak confirmation
                          MindWeaveStore.instance.speakText(
                            'Reminder created for ${newReminder.title} at ${newReminder.time}',
                          );

                          ScaffoldMessenger
                              .of(context)
                              .showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Reminder added successfully with voice alert',
                              ),
                            ),
                          );

                          Navigator.pop(
                              context);
                        },
                        icon: const Icon(
                          Icons.save_outlined,
                        ),
                        label: const Text(
                          'Save Reminder',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}