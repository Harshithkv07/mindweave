import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mindweave/services/storage_service.dart';
import 'package:mindweave/services/mindweave_provider.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_test_');
    Hive.init(tempDir.path);

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CognitiveSessionAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(DailyReminderAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(PatientProfileAdapter());
    }
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('Hive Models & Strongly-Typed Adapters', () {
    test('CognitiveSession adapter serialization and retrieval', () async {
      final box = await Hive.openBox<CognitiveSession>('test_sessions');
      final now = DateTime.now();

      final session = CognitiveSession(
        id: 'sess_123',
        gameType: 'memory_match',
        timestamp: now,
        errorCounts: 3,
        completionTimeSeconds: 42,
        accuracy: 85.5,
        attempts: 10,
        difficulty: 'Hard',
      );

      await box.put(session.id, session);
      final retrieved = box.get('sess_123');

      expect(retrieved, isNotNull);
      expect(retrieved!.id, equals('sess_123'));
      expect(retrieved.gameType, equals('memory_match'));
      expect(retrieved.errorCounts, equals(3));
      expect(retrieved.completionTimeSeconds, equals(42));
      expect(retrieved.accuracy, equals(85.5));
      expect(retrieved.attempts, equals(10));
      expect(retrieved.difficulty, equals('Hard'));
      expect(retrieved.timestamp.millisecondsSinceEpoch, equals(now.millisecondsSinceEpoch));

      await box.close();
    });

    test('DailyReminder adapter serialization and toggle', () async {
      final box = await Hive.openBox<DailyReminder>('test_reminders');
      final now = DateTime.now();

      final reminder = DailyReminder(
        id: 'rem_99',
        title: 'Take vitamin D',
        time: '12:00 PM',
        category: 'Medication',
        isEnabled: true,
        timestamp: now,
      );

      await box.put(reminder.id, reminder);
      final retrieved = box.get('rem_99');

      expect(retrieved, isNotNull);
      expect(retrieved!.title, equals('Take vitamin D'));
      expect(retrieved.isEnabled, isTrue);

      retrieved.isEnabled = false;
      await box.put(retrieved.id, retrieved);

      final updated = box.get('rem_99');
      expect(updated!.isEnabled, isFalse);

      await box.close();
    });

    test('PatientProfile adapter serialization and domain baselines', () async {
      final box = await Hive.openBox<PatientProfile>('test_profiles');
      final now = DateTime.now();

      final profile = PatientProfile(
        patientId: 'p_1',
        name: 'Margaret',
        email: 'margaret@mindweave.com',
        language: 'English',
        baselineScore: 82.5,
        lastUpdated: now,
        memoryScore: 85.0,
        attentionScore: 80.0,
        patternScore: 84.0,
        routineScore: 81.0,
      );

      await box.put('current', profile);
      final retrieved = box.get('current');

      expect(retrieved, isNotNull);
      expect(retrieved!.name, equals('Margaret'));
      expect(retrieved.memoryScore, equals(85.0));
      expect(retrieved.attentionScore, equals(80.0));
      expect(retrieved.baselineScore, equals(82.5));

      await box.close();
    });
  });

  group('MindWeaveProvider Reactive Offline Functionality', () {
    test('Provider registers session and re-evaluates baselines without network', () async {
      final provider = MindWeaveProvider();
      await provider.init(subDir: tempDir.path);

      expect(provider.isInitialized, isTrue);
      expect(provider.reminders.isNotEmpty, isTrue);

      final initialSessionCount = provider.sessions.length;

      await provider.recordSession(
        gameType: 'memory_match',
        errorCounts: 1,
        completionTimeSeconds: 28,
        accuracy: 95.0,
        attempts: 8,
      );

      expect(provider.sessions.length, equals(initialSessionCount + 1));
      expect(provider.sessions.first.gameType, equals('memory_match'));
      expect(provider.sessions.first.accuracy, equals(95.0));
      expect(provider.sessions.first.errorCounts, equals(1));
      expect(provider.sessions.first.completionTimeSeconds, equals(28));

      // Provider progress map check
      expect(provider.progress['gamesCompleted'], equals(provider.sessions.length));
      expect(provider.progress['bestAccuracy'], greaterThanOrEqualTo(95.0));
    });
  });
}
