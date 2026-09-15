import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String gamesCompletedKey = 'games_completed';
  static const String totalAttemptsKey = 'total_attempts';
  static const String bestAccuracyKey = 'best_accuracy';
  static const String bestTimeKey = 'best_time';

  static Future<void> saveGameResult({
    required int attempts,
    required double accuracy,
    required int timeSeconds,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final gamesCompleted =
        prefs.getInt(gamesCompletedKey) ?? 0;

    final totalAttempts =
        prefs.getInt(totalAttemptsKey) ?? 0;

    final previousBestAccuracy =
        prefs.getDouble(bestAccuracyKey) ?? 0;

    final previousBestTime =
        prefs.getInt(bestTimeKey) ?? 0;

    await prefs.setInt(
      gamesCompletedKey,
      gamesCompleted + 1,
    );

    await prefs.setInt(
      totalAttemptsKey,
      totalAttempts + attempts,
    );

    if (accuracy > previousBestAccuracy) {
      await prefs.setDouble(
        bestAccuracyKey,
        accuracy,
      );
    }

    if (previousBestTime == 0 ||
        timeSeconds < previousBestTime) {
      await prefs.setInt(
        bestTimeKey,
        timeSeconds,
      );
    }
  }

  static Future<Map<String, dynamic>> getProgress() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'gamesCompleted':
          prefs.getInt(gamesCompletedKey) ?? 0,
      'totalAttempts':
          prefs.getInt(totalAttemptsKey) ?? 0,
      'bestAccuracy':
          prefs.getDouble(bestAccuracyKey) ?? 0,
      'bestTime':
          prefs.getInt(bestTimeKey) ?? 0,
    };
  }
}