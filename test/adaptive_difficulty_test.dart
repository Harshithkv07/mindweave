import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mindweave/services/storage_service.dart';
import 'package:mindweave/services/adaptive_difficulty_engine.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('adaptive_diff_test_');
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

    await StorageService.init(subDir: tempDir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('AdaptiveDifficultyEngine Local Rule-Based Tests', () {
    test('Defaults to Medium difficulty tier when no sessions exist', () {
      final matchConfig = AdaptiveDifficultyEngine.getMemoryMatchConfig();
      expect(matchConfig.difficulty, equals('Medium'));
      expect(matchConfig.pairCount, equals(4));
      expect(matchConfig.totalCards, equals(8));
      expect(matchConfig.flipBackDurationMs, equals(800));

      final objectsConfig = AdaptiveDifficultyEngine.getRememberObjectsConfig();
      expect(objectsConfig.difficulty, equals('Medium'));
      expect(objectsConfig.objectsToRememberCount, equals(4));
      expect(objectsConfig.displayDurationSeconds, equals(4));

      final seqConfig = AdaptiveDifficultyEngine.getSequenceMemoryConfig();
      expect(seqConfig.difficulty, equals('Medium'));
      expect(seqConfig.availableSymbolsCount, equals(6));
      expect(seqConfig.displayIntervalMs, equals(800));
    });

    test('Scales to Hard difficulty when user demonstrates high accuracy and low errors', () async {
      final now = DateTime.now();

      // Seed 3 high-performing sessions
      for (int i = 0; i < 3; i++) {
        await StorageService.saveSession(
          CognitiveSession(
            id: 'high_perf_$i',
            gameType: 'memory_match',
            timestamp: now.subtract(Duration(hours: i)),
            errorCounts: 0,
            completionTimeSeconds: 25,
            accuracy: 95.0,
            attempts: 8,
            difficulty: 'Medium',
          ),
        );
      }

      final adaptedMatch = AdaptiveDifficultyEngine.getMemoryMatchConfig();
      expect(adaptedMatch.difficulty, equals('Hard'));
      expect(adaptedMatch.pairCount, equals(6));
      expect(adaptedMatch.totalCards, equals(12));
      expect(adaptedMatch.gridColumns, equals(3));
      expect(adaptedMatch.flipBackDurationMs, equals(600));
    });

    test('Scales down to Easy difficulty when user has low accuracy or high errors', () async {
      final now = DateTime.now();

      // Seed 3 struggling sessions
      for (int i = 0; i < 3; i++) {
        await StorageService.saveSession(
          CognitiveSession(
            id: 'struggle_$i',
            gameType: 'remember_objects',
            timestamp: now.add(Duration(minutes: i + 1)), // newest timestamps
            errorCounts: 5,
            completionTimeSeconds: 65,
            accuracy: 50.0,
            attempts: 5,
            difficulty: 'Medium',
          ),
        );
      }

      final adaptedObjects = AdaptiveDifficultyEngine.getRememberObjectsConfig();
      expect(adaptedObjects.difficulty, equals('Easy'));
      expect(adaptedObjects.objectsToRememberCount, equals(3));
      expect(adaptedObjects.displayDurationSeconds, equals(6));
      expect(adaptedObjects.optionsCount, equals(3));
    });

    test('Sequence Memory engine adapts grid and intervals correctly', () async {
      final now = DateTime.now();

      // Seed high performing sequence session
      for (int i = 0; i < 3; i++) {
        await StorageService.saveSession(
          CognitiveSession(
            id: 'seq_high_$i',
            gameType: 'sequence_memory',
            timestamp: now.add(Duration(hours: i + 2)),
            errorCounts: 0,
            completionTimeSeconds: 20,
            accuracy: 100.0,
            attempts: 5,
            difficulty: 'Medium',
          ),
        );
      }

      final adaptedSeq = AdaptiveDifficultyEngine.getSequenceMemoryConfig();
      expect(adaptedSeq.difficulty, equals('Hard'));
      expect(adaptedSeq.availableSymbolsCount, equals(9));
      expect(adaptedSeq.symbolGridColumns, equals(3));
      expect(adaptedSeq.displayIntervalMs, equals(500));
    });
  });
}
