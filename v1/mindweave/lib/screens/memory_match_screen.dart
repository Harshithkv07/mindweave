import 'dart:async';
import '../core/theme.dart';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/adaptive_difficulty_engine.dart';

class MemoryMatchScreen extends StatefulWidget {
  const MemoryMatchScreen({super.key});

  @override
  State<MemoryMatchScreen> createState() => _MemoryMatchScreenState();
}

class _MemoryMatchScreenState extends State<MemoryMatchScreen> {
  late MemoryMatchConfig _config;

  late List<String> cards;
  late List<String> shuffledCards;
  late List<bool> revealed;

  int? firstCard;
  int? secondCard;

  int matches = 0;
  int attempts = 0;
  int failedAttempts = 0;

  bool checking = false;

  DateTime? startTime;
  DateTime? moveStartTime;
  double totalReactionSeconds = 0.0;
  int reactionEvents = 0;

  int elapsedSeconds = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _loadAdaptiveConfigAndStart();
  }

  void _loadAdaptiveConfigAndStart() {
    _config = AdaptiveDifficultyEngine.getMemoryMatchConfig();

    // Generate pairs according to adapted pairCount
    final List<String> pairList = [];
    for (final sym in _config.availableSymbols) {
      pairList.add(sym);
      pairList.add(sym);
    }
    cards = pairList;

    startGame();
  }

  void startGame() {
    shuffledCards = List.from(cards)..shuffle();
    revealed = List.filled(shuffledCards.length, false);

    firstCard = null;
    secondCard = null;
    matches = 0;
    attempts = 0;
    failedAttempts = 0;
    checking = false;
    totalReactionSeconds = 0.0;
    reactionEvents = 0;

    startTime = DateTime.now();
    moveStartTime = DateTime.now();

    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && startTime != null) {
        setState(() {
          elapsedSeconds = DateTime.now().difference(startTime!).inSeconds;
        });
      }
    });

    setState(() {});
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void selectCard(int index) {
    if (checking || revealed[index]) {
      return;
    }

    // Track response speed per card selection
    if (moveStartTime != null) {
      final moveTime = DateTime.now().difference(moveStartTime!).inMilliseconds / 1000.0;
      totalReactionSeconds += moveTime;
      reactionEvents++;
    }
    moveStartTime = DateTime.now();

    setState(() {
      revealed[index] = true;
    });

    if (firstCard == null) {
      firstCard = index;
      return;
    }

    secondCard = index;
    attempts++;

    checking = true;

    // Use rule-based adapted display duration for flip-back
    Future.delayed(Duration(milliseconds: _config.flipBackDurationMs), () {
      if (!mounted) return;

      if (shuffledCards[firstCard!] == shuffledCards[secondCard!]) {
        matches++;
      } else {
        failedAttempts++;
        revealed[firstCard!] = false;
        revealed[secondCard!] = false;
      }

      firstCard = null;
      secondCard = null;
      checking = false;
      moveStartTime = DateTime.now();

      setState(() {});

      if (matches == _config.pairCount) {
        timer?.cancel();

        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            showResult();
          }
        });
      }
    });
  }

  double get accuracy {
    if (attempts == 0) return 0.0;
    return ((matches / attempts) * 100).clamp(0.0, 100.0);
  }

  double get averageResponseSpeed {
    if (reactionEvents == 0) return 0.0;
    return totalReactionSeconds / reactionEvents;
  }

  void showResult() {
    StorageService.saveGameResult(
      attempts: attempts,
      accuracy: accuracy,
      timeSeconds: elapsedSeconds,
      gameType: 'memory_match',
      errorCounts: failedAttempts,
      difficulty: _config.difficulty,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Text('🎉 Well Done!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Spacer(),
              _difficultyTag(_config.difficulty),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'You completed the Memory Match challenge!',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 18),
              _metricRow('🎯 Accuracy', '${accuracy.toStringAsFixed(0)}%'),
              _metricRow('⚡ Response Speed', '${averageResponseSpeed.toStringAsFixed(1)}s / move'),
              _metricRow('⚠️ Failed Attempts', '$failedAttempts mismatches'),
              _metricRow('⏱️ Total Time', '$elapsedSeconds seconds'),
              _metricRow('🧩 Adapted Grid', '${_config.gridColumns} cols (${_config.totalCards} cards)'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _loadAdaptiveConfigAndStart();
              },
              child: const Text('Play Again', style: TextStyle(fontSize: 16)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Done', style: TextStyle(fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  Widget _metricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 15, color: Colors.black54)),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _difficultyTag(String difficulty) {
    Color color;
    switch (difficulty.toLowerCase()) {
      case 'easy':
        color = Colors.green;
        break;
      case 'hard':
        color = Colors.redAccent;
        break;
      case 'medium':
      default:
        color = AppColors.primary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        'Adaptive: $difficulty',
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: const Text('🧩 Memory Match', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(child: _difficultyTag(_config.difficulty)),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Adaptive Difficulty Info Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryContainer),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Adapted to your recent performance: ${_config.totalCards} cards (${_config.gridColumns} cols, ${_config.flipBackDurationMs}ms reveal)',
                        style: TextStyle(fontSize: 12, color: AppColors.primaryDark, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Live Stats Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _statBox('Matches', '$matches/${_config.pairCount}', Icons.check_circle_outline),
                  _statBox('Attempts', '$attempts', Icons.touch_app_outlined),
                  _statBox('Speed', '${averageResponseSpeed.toStringAsFixed(1)}s', Icons.speed),
                  _statBox('Time', '${elapsedSeconds}s', Icons.timer_outlined),
                ],
              ),

              const SizedBox(height: 25),

              // Dynamic Responsive GridView
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _config.gridColumns,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.05,
                ),
                itemCount: shuffledCards.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => selectCard(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: revealed[index] ? Colors.white : AppColors.primary,
                        border: Border.all(
                          color: revealed[index] ? AppColors.primaryLight : AppColors.primaryDark,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          revealed[index] ? shuffledCards[index] : '?',
                          style: TextStyle(
                            fontSize: revealed[index] ? 38 : 30,
                            fontWeight: FontWeight.bold,
                            color: revealed[index] ? Colors.black : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Accuracy: ${accuracy.toStringAsFixed(0)}%',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    'Mistakes: $failedAttempts',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: failedAttempts > 2 ? Colors.red : Colors.grey.shade700),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statBox(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, size: 22, color: AppColors.primary),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}