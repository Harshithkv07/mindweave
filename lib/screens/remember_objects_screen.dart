import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/adaptive_difficulty_engine.dart';

class RememberObjectsScreen extends StatefulWidget {
  const RememberObjectsScreen({super.key});

  @override
  State<RememberObjectsScreen> createState() => _RememberObjectsScreenState();
}

class _RememberObjectsScreenState extends State<RememberObjectsScreen> {
  final List<String> allObjects = [
    '🍎', '🚗', '🌸', '🐱', '⭐', '🍌',
    '🏠', '🐶', '⚽', '🌳', '🍇', '🎈',
  ];

  late RememberObjectsConfig _config;

  late List<String> objectsToRemember;
  late List<String> options;

  bool showingObjects = true;
  String? selectedAnswer;

  int score = 0;
  int failedAttempts = 0;
  int currentRound = 1;
  final int totalRounds = 5;

  DateTime? gameStartTime;
  DateTime? questionShownTime;
  double totalResponseSeconds = 0.0;
  int responseCount = 0;
  Timer? displayTimer;

  @override
  void initState() {
    super.initState();
    _loadAdaptiveConfigAndStart();
  }

  void _loadAdaptiveConfigAndStart() {
    _config = AdaptiveDifficultyEngine.getRememberObjectsConfig();
    score = 0;
    failedAttempts = 0;
    currentRound = 1;
    totalResponseSeconds = 0.0;
    responseCount = 0;
    gameStartTime = DateTime.now();
    startRound();
  }

  @override
  void dispose() {
    displayTimer?.cancel();
    super.dispose();
  }

  void startRound() {
    final random = Random();

    final shuffled = List<String>.from(allObjects)..shuffle(random);
    objectsToRemember = shuffled.take(_config.objectsToRememberCount).toList();

    final remaining = allObjects
        .where((object) => !objectsToRemember.contains(object))
        .toList()
      ..shuffle(random);

    // Build options according to adapted optionsCount
    final correctPick = objectsToRemember[random.nextInt(objectsToRemember.length)];
    final distractors = remaining.take(_config.optionsCount - 1).toList();

    options = [correctPick, ...distractors]..shuffle(random);

    selectedAnswer = null;
    showingObjects = true;
    setState(() {});

    displayTimer?.cancel();
    displayTimer = Timer(Duration(seconds: _config.displayDurationSeconds), () {
      if (!mounted) return;
      setState(() {
        showingObjects = false;
        questionShownTime = DateTime.now();
      });
    });
  }

  void checkAnswer(String answer) {
    if (selectedAnswer != null) return;

    // Track response speed for this round
    if (questionShownTime != null) {
      final responseTime =
          DateTime.now().difference(questionShownTime!).inMilliseconds / 1000.0;
      totalResponseSeconds += responseTime;
      responseCount++;
    }

    final isCorrect = objectsToRemember.contains(answer);

    setState(() {
      selectedAnswer = answer;
      if (isCorrect) {
        score++;
      } else {
        failedAttempts++;
      }
    });

    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;

      if (currentRound >= totalRounds) {
        finishGame();
      } else {
        currentRound++;
        startRound();
      }
    });
  }

  double get accuracy {
    return ((score / totalRounds) * 100).clamp(0.0, 100.0);
  }

  double get averageResponseSpeed {
    if (responseCount == 0) return 0.0;
    return totalResponseSeconds / responseCount;
  }

  Future<void> finishGame() async {
    final elapsedSeconds = gameStartTime == null
        ? 0
        : DateTime.now().difference(gameStartTime!).inSeconds;

    await StorageService.saveGameResult(
      attempts: totalRounds,
      accuracy: accuracy,
      timeSeconds: elapsedSeconds,
      gameType: 'remember_objects',
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
              const Text('🎉 Round Completed!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const Spacer(),
              _difficultyTag(_config.difficulty),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'You finished the Remember Objects exercise!',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 18),
              _metricRow('🎯 Accuracy', '${accuracy.toStringAsFixed(0)}% ($score/$totalRounds)'),
              _metricRow('⚡ Response Speed', '${averageResponseSpeed.toStringAsFixed(1)}s / question'),
              _metricRow('⚠️ Failed Attempts', '$failedAttempts incorrect'),
              _metricRow('⏱️ Total Time', '$elapsedSeconds seconds'),
              _metricRow('🧠 Adapted Setting', '${_config.objectsToRememberCount} items • ${_config.displayDurationSeconds}s timer'),
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
                backgroundColor: Colors.indigo,
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
        color = Colors.indigo;
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
        title: const Text('🔍 Remember Objects', style: TextStyle(fontWeight: FontWeight.bold)),
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
              // Adaptive Difficulty Info Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.indigo.shade100),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, size: 18, color: Colors.indigo),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Adapted to your performance: ${_config.objectsToRememberCount} items, ${_config.displayDurationSeconds}s memorization, ${_config.optionsCount} choices',
                        style: TextStyle(fontSize: 12, color: Colors.indigo.shade900, fontWeight: FontWeight.w500),
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
                  _statBox('Round', '$currentRound/$totalRounds', Icons.flag_outlined),
                  _statBox('Score', '$score', Icons.stars_outlined),
                  _statBox('Speed', '${averageResponseSpeed.toStringAsFixed(1)}s', Icons.speed),
                  _statBox('Mistakes', '$failedAttempts', Icons.error_outline),
                ],
              ),

              const SizedBox(height: 30),

              if (showingObjects) ...[
                Text(
                  'Memorize these ${_config.objectsToRememberCount} items! (${_config.displayDurationSeconds}s)',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'They will disappear in a few moments.',
                  style: TextStyle(fontSize: 15, color: Colors.black54),
                ),
                const SizedBox(height: 30),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: objectsToRemember
                      .map(
                        (obj) => Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.indigo.shade200, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.indigo.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(obj, style: const TextStyle(fontSize: 48)),
                        ),
                      )
                      .toList(),
                ),
              ] else ...[
                const Text(
                  'Which item was in the group?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Tap the correct symbol that appeared earlier.',
                  style: TextStyle(fontSize: 15, color: Colors.black54),
                ),
                const SizedBox(height: 30),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _config.optionsColumns,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.15,
                  ),
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options[index];
                    final isSelected = selectedAnswer == option;
                    final isCorrect = objectsToRemember.contains(option);

                    Color cardColor = Colors.white;
                    Color borderColor = Colors.grey.shade300;

                    if (selectedAnswer != null) {
                      if (isSelected) {
                        cardColor = isCorrect ? Colors.green.shade50 : Colors.red.shade50;
                        borderColor = isCorrect ? Colors.green : Colors.red;
                      } else if (isCorrect) {
                        cardColor = Colors.green.shade50;
                        borderColor = Colors.green;
                      }
                    }

                    return GestureDetector(
                      onTap: () => checkAnswer(option),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: borderColor, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(option, style: const TextStyle(fontSize: 44)),
                        ),
                      ),
                    );
                  },
                ),
              ],
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
          Icon(icon, size: 22, color: Colors.indigo),
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