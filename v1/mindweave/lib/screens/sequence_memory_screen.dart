import 'dart:async';
import '../core/theme.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/adaptive_difficulty_engine.dart';

class SequenceMemoryScreen extends StatefulWidget {
  const SequenceMemoryScreen({super.key});

  @override
  State<SequenceMemoryScreen> createState() => _SequenceMemoryScreenState();
}

class _SequenceMemoryScreenState extends State<SequenceMemoryScreen> {
  static const List<String> allMasterSymbols = [
    '🍎', '⭐', '🐱', '🌸', '🍌', '🚗',
    '🏠', '🐶', '⚽',
  ];

  late SequenceMemoryConfig _config;
  late List<String> activeSymbols;

  List<String> sequence = [];
  List<String> userSequence = [];

  int level = 1;
  final int maxLevels = 5;
  int score = 0;
  int failedAttempts = 0;
  int correctInputs = 0;
  int totalInputs = 0;

  bool showingSequence = true;
  bool gameFinished = false;
  int? highlightedIndex;

  DateTime? gameStartTime;
  DateTime? stepStartTime;
  double totalReactionSeconds = 0.0;
  int reactionCount = 0;

  Timer? sequenceDisplayTimer;

  @override
  void initState() {
    super.initState();
    _loadAdaptiveConfigAndStart();
  }

  void _loadAdaptiveConfigAndStart() {
    _config = AdaptiveDifficultyEngine.getSequenceMemoryConfig();
    activeSymbols = allMasterSymbols.take(_config.availableSymbolsCount).toList();

    level = 1;
    score = 0;
    failedAttempts = 0;
    correctInputs = 0;
    totalInputs = 0;
    gameFinished = false;
    totalReactionSeconds = 0.0;
    reactionCount = 0;
    gameStartTime = DateTime.now();

    startLevel();
  }

  @override
  void dispose() {
    sequenceDisplayTimer?.cancel();
    super.dispose();
  }

  void startLevel() {
    final random = Random();

    // Sequence length scales with level starting from adapted initialSequenceLength
    final sequenceLength = _config.initialSequenceLength + (level - 1);
    sequence = List.generate(
      sequenceLength,
      (_) => activeSymbols[random.nextInt(activeSymbols.length)],
    );

    userSequence = [];
    showingSequence = true;
    highlightedIndex = null;
    setState(() {});

    _playSequenceAnimation();
  }

  /// Step-by-step sequential flashing of the target pattern
  void _playSequenceAnimation() {
    int currentStep = 0;
    sequenceDisplayTimer?.cancel();

    sequenceDisplayTimer = Timer.periodic(
      Duration(milliseconds: _config.displayIntervalMs),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (currentStep < sequence.length) {
          setState(() {
            highlightedIndex = currentStep;
          });
          currentStep++;
        } else {
          timer.cancel();
          setState(() {
            highlightedIndex = null;
            showingSequence = false;
            stepStartTime = DateTime.now();
          });
        }
      },
    );
  }

  void selectSymbol(String symbol) {
    if (showingSequence || gameFinished) return;

    // Track response speed for each tapped symbol
    if (stepStartTime != null) {
      final tapDuration =
          DateTime.now().difference(stepStartTime!).inMilliseconds / 1000.0;
      totalReactionSeconds += tapDuration;
      reactionCount++;
    }
    stepStartTime = DateTime.now();

    totalInputs++;

    setState(() {
      userSequence.add(symbol);
    });

    final index = userSequence.length - 1;

    if (userSequence[index] != sequence[index]) {
      // Mistake made in sequence
      failedAttempts++;
      finishGame(completedAll: false);
      return;
    }

    correctInputs++;

    // Completed full sequence for current level
    if (userSequence.length == sequence.length) {
      score++;

      if (level >= maxLevels) {
        finishGame(completedAll: true);
      } else {
        level++;
        Future.delayed(const Duration(milliseconds: 700), () {
          if (mounted) {
            startLevel();
          }
        });
      }
    }
  }

  double get accuracy {
    if (totalInputs == 0) return 0.0;
    return ((correctInputs / totalInputs) * 100).clamp(0.0, 100.0);
  }

  double get averageResponseSpeed {
    if (reactionCount == 0) return 0.0;
    return totalReactionSeconds / reactionCount;
  }

  Future<void> finishGame({required bool completedAll}) async {
    gameFinished = true;
    sequenceDisplayTimer?.cancel();

    final elapsedSeconds = gameStartTime == null
        ? 0
        : DateTime.now().difference(gameStartTime!).inSeconds;

    await StorageService.saveGameResult(
      attempts: totalInputs > 0 ? totalInputs : level,
      accuracy: accuracy,
      timeSeconds: elapsedSeconds,
      gameType: 'sequence_memory',
      errorCounts: failedAttempts,
      difficulty: _config.difficulty,
    );

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Text(
                completedAll ? '🎉 Master Memory!' : '✨ Good Effort!',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              _difficultyTag(_config.difficulty),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                completedAll
                    ? 'Incredible! You completed all $maxLevels levels in the sequence challenge!'
                    : 'Sequence missed at level $level. Great cognitive exercise!',
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 18),
              _metricRow('🎯 Accuracy', '${accuracy.toStringAsFixed(0)}% ($correctInputs/$totalInputs steps)'),
              _metricRow('⚡ Response Speed', '${averageResponseSpeed.toStringAsFixed(1)}s / tap'),
              _metricRow('⚠️ Failed Attempts', '$failedAttempts error(s)'),
              _metricRow('🏆 Levels Cleared', '$score of $maxLevels'),
              _metricRow('⏱️ Total Time', '$elapsedSeconds seconds'),
              _metricRow('🧠 Adapted Settings', '${_config.availableSymbolsCount} symbols (${_config.symbolGridColumns} cols, ${_config.displayIntervalMs}ms)'),
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
        title: const Text('🔢 Sequence Memory', style: TextStyle(fontWeight: FontWeight.bold)),
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
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Adaptive Info Banner
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
                        'Adapted to your performance: ${_config.availableSymbolsCount} symbols (${_config.symbolGridColumns} cols, ${_config.displayIntervalMs}ms flash)',
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
                  _statBox('Level', '$level/$maxLevels', Icons.stairs_outlined),
                  _statBox('Accuracy', '${accuracy.toStringAsFixed(0)}%', Icons.check_circle_outline),
                  _statBox('Speed', '${averageResponseSpeed.toStringAsFixed(1)}s', Icons.speed),
                  _statBox('Mistakes', '$failedAttempts', Icons.error_outline),
                ],
              ),

              const SizedBox(height: 30),

              Text(
                showingSequence ? '👀 Watch the sequence closely!' : '👉 Repeat the sequence:',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),

              const SizedBox(height: 20),

              // Sequence preview line
              Container(
                height: 80,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: sequence.length,
                    itemBuilder: (context, index) {
                      final isHighlighted = highlightedIndex == index;
                      final isUserFilled = index < userSequence.length;

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                        width: 54,
                        decoration: BoxDecoration(
                          color: isHighlighted
                              ? Colors.amber.shade100
                              : (isUserFilled ? AppColors.primaryContainer : Colors.grey.shade100),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isHighlighted
                                ? Colors.amber.shade700
                                : (isUserFilled ? AppColors.primary : Colors.grey.shade300),
                            width: isHighlighted ? 2.5 : 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            showingSequence
                                ? (isHighlighted ? sequence[index] : '•')
                                : (isUserFilled ? userSequence[index] : '?'),
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: isHighlighted ? Colors.black : AppColors.primaryDark,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Responsive Dynamic Input Keypad
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _config.symbolGridColumns,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.15,
                ),
                itemCount: activeSymbols.length,
                itemBuilder: (context, index) {
                  final symbol = activeSymbols[index];
                  return GestureDetector(
                    onTap: () => selectSymbol(symbol),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      decoration: BoxDecoration(
                        color: showingSequence ? Colors.grey.shade100 : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: showingSequence ? Colors.grey.shade300 : AppColors.primaryLight,
                          width: 2,
                        ),
                        boxShadow: showingSequence
                            ? []
                            : [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                      ),
                      child: Center(
                        child: Text(
                          symbol,
                          style: TextStyle(
                            fontSize: _config.symbolGridColumns > 2 ? 36 : 44,
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