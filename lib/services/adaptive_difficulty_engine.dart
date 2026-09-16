import 'package:flutter/foundation.dart';
import 'storage_service.dart';

/// Configuration for Memory Match game based on player's recent performance.
class MemoryMatchConfig {
  final int pairCount;
  final int gridColumns;
  final int flipBackDurationMs;
  final String difficulty;
  final List<String> availableSymbols;

  const MemoryMatchConfig({
    required this.pairCount,
    required this.gridColumns,
    required this.flipBackDurationMs,
    required this.difficulty,
    required this.availableSymbols,
  });

  int get totalCards => pairCount * 2;
}

/// Configuration for Remember Objects game based on player's recent performance.
class RememberObjectsConfig {
  final int objectsToRememberCount;
  final int optionsCount;
  final int optionsColumns;
  final int displayDurationSeconds;
  final String difficulty;

  const RememberObjectsConfig({
    required this.objectsToRememberCount,
    required this.optionsCount,
    required this.optionsColumns,
    required this.displayDurationSeconds,
    required this.difficulty,
  });
}

/// Configuration for Sequence Memory game based on player's recent performance.
class SequenceMemoryConfig {
  final int availableSymbolsCount;
  final int symbolGridColumns;
  final int initialSequenceLength;
  final int displayIntervalMs;
  final String difficulty;

  const SequenceMemoryConfig({
    required this.availableSymbolsCount,
    required this.symbolGridColumns,
    required this.initialSequenceLength,
    required this.displayIntervalMs,
    required this.difficulty,
  });
}

/// Local Rule-Based Engine that analyzes recent session history in Hive
/// and automatically calculates optimal grid dimensions, item counts, and display durations.
class AdaptiveDifficultyEngine {
  static const List<String> masterSymbols = [
    '🍎', '🐱', '🌸', '⭐', '🚗', '🍌',
    '🏠', '🐶', '⚽', '🌳', '🍇', '🎈',
  ];

  /// Evaluates recent performance for Memory Match and returns an adapted game config.
  static MemoryMatchConfig getMemoryMatchConfig() {
    final recentSessions = _getRecentSessionsFor('memory_match');
    final tier = _calculateTier(recentSessions);

    switch (tier) {
      case DifficultyTier.easy:
        // Struggling or low accuracy: 2x2 grid (2 pairs, 4 cards), longer reveal time
        return MemoryMatchConfig(
          pairCount: 2,
          gridColumns: 2,
          flipBackDurationMs: 1200,
          difficulty: 'Easy',
          availableSymbols: masterSymbols.take(2).toList(),
        );

      case DifficultyTier.hard:
        // High accuracy & low errors: 3x4 grid (6 pairs, 12 cards), quick reveal
        return MemoryMatchConfig(
          pairCount: 6,
          gridColumns: 3,
          flipBackDurationMs: 600,
          difficulty: 'Hard',
          availableSymbols: masterSymbols.take(6).toList(),
        );

      case DifficultyTier.medium:
        // Standard baseline: 2x4 grid (4 pairs, 8 cards), standard reveal
        return MemoryMatchConfig(
          pairCount: 4,
          gridColumns: 2,
          flipBackDurationMs: 800,
          difficulty: 'Medium',
          availableSymbols: masterSymbols.take(4).toList(),
        );
    }
  }

  /// Evaluates recent performance for Remember Objects and returns an adapted game config.
  static RememberObjectsConfig getRememberObjectsConfig() {
    final recentSessions = _getRecentSessionsFor('remember_objects');
    final tier = _calculateTier(recentSessions);

    switch (tier) {
      case DifficultyTier.easy:
        // 3 items to remember, 3 options grid, 6 seconds display duration
        return const RememberObjectsConfig(
          objectsToRememberCount: 3,
          optionsCount: 3,
          optionsColumns: 3,
          displayDurationSeconds: 6,
          difficulty: 'Easy',
        );

      case DifficultyTier.hard:
        // 5 items to remember, 6 options grid (2x3), 3 seconds display duration
        return const RememberObjectsConfig(
          objectsToRememberCount: 5,
          optionsCount: 6,
          optionsColumns: 3,
          displayDurationSeconds: 3,
          difficulty: 'Hard',
        );

      case DifficultyTier.medium:
        // 4 items to remember, 4 options grid (2x2), 4 seconds display duration
        return const RememberObjectsConfig(
          objectsToRememberCount: 4,
          optionsCount: 4,
          optionsColumns: 2,
          displayDurationSeconds: 4,
          difficulty: 'Medium',
        );
    }
  }

  /// Evaluates recent performance for Sequence Memory and returns an adapted game config.
  static SequenceMemoryConfig getSequenceMemoryConfig() {
    final recentSessions = _getRecentSessionsFor('sequence_memory');
    final tier = _calculateTier(recentSessions);

    switch (tier) {
      case DifficultyTier.easy:
        // 4 symbols (2x2 grid), starts with 2 elements, slower 1200ms preview
        return const SequenceMemoryConfig(
          availableSymbolsCount: 4,
          symbolGridColumns: 2,
          initialSequenceLength: 2,
          displayIntervalMs: 1200,
          difficulty: 'Easy',
        );

      case DifficultyTier.hard:
        // 9 symbols (3x3 grid), starts with 4 elements, brisk 500ms preview
        return const SequenceMemoryConfig(
          availableSymbolsCount: 9,
          symbolGridColumns: 3,
          initialSequenceLength: 4,
          displayIntervalMs: 500,
          difficulty: 'Hard',
        );

      case DifficultyTier.medium:
        // 6 symbols (2x3 grid), starts with 3 elements, 800ms preview
        return const SequenceMemoryConfig(
          availableSymbolsCount: 6,
          symbolGridColumns: 3,
          initialSequenceLength: 3,
          displayIntervalMs: 800,
          difficulty: 'Medium',
        );
    }
  }

  // --------------------------------------------------------------------------
  // Internal Rule Calculation Logic
  // --------------------------------------------------------------------------

  static List<CognitiveSession> _getRecentSessionsFor(String targetGameType) {
    try {
      final allSessions = StorageService.getAllSessions();
      final target = targetGameType.toLowerCase();

      final filtered = allSessions.where((s) {
        final type = s.gameType.toLowerCase();
        return type.contains(target) ||
            (target == 'memory_match' && type.contains('match')) ||
            (target == 'remember_objects' && type.contains('object')) ||
            (target == 'sequence_memory' && (type.contains('sequence') || type.contains('recall')));
      }).take(5).toList();

      if (filtered.isNotEmpty) return filtered;

      // Fallback: if no specific game sessions yet, use general recent sessions
      return allSessions.take(5).toList();
    } catch (e) {
      debugPrint('AdaptiveDifficultyEngine error retrieving sessions: $e');
      return [];
    }
  }

  static DifficultyTier _calculateTier(List<CognitiveSession> sessions) {
    if (sessions.isEmpty) {
      return DifficultyTier.medium; // Default baseline for new users
    }

    final totalAccuracy = sessions.fold<double>(0.0, (acc, s) => acc + s.accuracy);
    final avgAccuracy = totalAccuracy / sessions.length;

    final totalErrors = sessions.fold<int>(0, (acc, s) => acc + s.errorCounts);
    final avgErrors = totalErrors / sessions.length;

    debugPrint(
        'AdaptiveDifficultyEngine: Analyzed ${sessions.length} sessions. Avg Accuracy: ${avgAccuracy.toStringAsFixed(1)}%, Avg Errors: ${avgErrors.toStringAsFixed(1)}');

    // Rule 1: Struggling / high mistakes
    // Accuracy < 70% OR average errors >= 3.5
    if (avgAccuracy < 70.0 || avgErrors >= 3.5) {
      return DifficultyTier.easy;
    }

    // Rule 2: Advanced / Master
    // Accuracy >= 85% AND average errors <= 1.5
    if (avgAccuracy >= 85.0 && avgErrors <= 1.5) {
      return DifficultyTier.hard;
    }

    // Rule 3: Balanced standard progression
    return DifficultyTier.medium;
  }
}

enum DifficultyTier {
  easy,
  medium,
  hard,
}
