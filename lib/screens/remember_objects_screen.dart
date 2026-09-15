import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class RememberObjectsScreen extends StatefulWidget {
  const RememberObjectsScreen({super.key});

  @override
  State<RememberObjectsScreen> createState() =>
      _RememberObjectsScreenState();
}

class _RememberObjectsScreenState
    extends State<RememberObjectsScreen> {
  final List<String> allObjects = [
    '🍎',
    '🚗',
    '🌸',
    '🐱',
    '⭐',
    '🍌',
    '🏠',
    '🐶',
    '⚽',
    '🌳',
  ];

  late List<String> objectsToRemember;
  late List<String> options;

  bool showingObjects = true;
  String? selectedAnswer;

  int score = 0;
  int currentRound = 1;
  final int totalRounds = 5;

  DateTime? startTime;

  @override
  void initState() {
    super.initState();
    startRound();
  }

  void startRound() {
    final random = Random();

    final shuffled = List<String>.from(allObjects)
      ..shuffle(random);

    objectsToRemember = shuffled.take(4).toList();

    final remaining = allObjects
        .where((object) => !objectsToRemember.contains(object))
        .toList()
      ..shuffle(random);

    options = [
      objectsToRemember[random.nextInt(objectsToRemember.length)],
      remaining[0],
      remaining[1],
      remaining[2],
    ]..shuffle(random);

    selectedAnswer = null;
    showingObjects = true;
    startTime = DateTime.now();

    setState(() {});

    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;

      setState(() {
        showingObjects = false;
      });
    });
  }

  void checkAnswer(String answer) {
    if (selectedAnswer != null) return;

    setState(() {
      selectedAnswer = answer;

      if (objectsToRemember.contains(answer)) {
        score++;
      }
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;

      if (currentRound >= totalRounds) {
        finishGame();
      } else {
        currentRound++;
        startRound();
      }
    });
  }

  Future<void> finishGame() async {
    final accuracy = (score / totalRounds) * 100;

    final elapsedSeconds = startTime == null
        ? 0
        : DateTime.now()
            .difference(startTime!)
            .inSeconds;

    await StorageService.saveGameResult(
      attempts: totalRounds,
      accuracy: accuracy,
      timeSeconds: elapsedSeconds,
      gameType: 'remember_objects',
    );

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            '🎉 Great Job!',
            style: TextStyle(fontSize: 26),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Remember Objects completed!',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              Text(
                'Score: $score / $totalRounds',
                style: const TextStyle(fontSize: 20),
              ),
              Text(
                'Accuracy: ${accuracy.toStringAsFixed(0)}%',
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text(
                'Done',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '👀 Remember Objects',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 600,
            ),
            child: Column(
              children: [
                Text(
                  'Round $currentRound / $totalRounds',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  showingObjects
                      ? 'Remember these objects'
                      : 'Which object did you see?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                if (showingObjects)
                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    alignment: WrapAlignment.center,
                    children: objectsToRemember.map((object) {
                      return Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(20),
                          color: Colors.indigo.shade50,
                          border: Border.all(
                            color: Colors.indigo,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            object,
                            style: const TextStyle(
                              fontSize: 55,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  )
                else
                  Column(
                    children: options.map((option) {
                      final isSelected =
                          selectedAnswer == option;

                      final isCorrect =
                          objectsToRemember.contains(option);

                      return Padding(
                        padding:
                            const EdgeInsets.only(bottom: 15),
                        child: SizedBox(
                          width: double.infinity,
                          height: 70,
                          child: ElevatedButton(
                            onPressed: selectedAnswer == null
                                ? () => checkAnswer(option)
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isSelected
                                      ? (isCorrect
                                          ? Colors.green
                                          : Colors.red)
                                      : null,
                            ),
                            child: Text(
                              option,
                              style: const TextStyle(
                                fontSize: 40,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                const SizedBox(height: 30),

                Text(
                  'Score: $score',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
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