import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class SequenceMemoryScreen extends StatefulWidget {
  const SequenceMemoryScreen({super.key});

  @override
  State<SequenceMemoryScreen> createState() =>
      _SequenceMemoryScreenState();
}

class _SequenceMemoryScreenState
    extends State<SequenceMemoryScreen> {
  final List<String> symbols = [
    '🍎',
    '⭐',
    '🐱',
    '🌸',
    '🍌',
    '🚗',
  ];

  List<String> sequence = [];
  List<String> userSequence = [];

  int level = 1;
  int score = 0;

  bool showingSequence = true;
  bool gameFinished = false;

  @override
  void initState() {
    super.initState();
    startLevel();
  }

  void startLevel() {
    final random = Random();

    sequence = List.generate(
      level + 2,
      (_) => symbols[random.nextInt(symbols.length)],
    );

    userSequence = [];
    showingSequence = true;

    setState(() {});

    Future.delayed(
      Duration(seconds: 2 + level),
      () {
        if (!mounted) return;

        setState(() {
          showingSequence = false;
        });
      },
    );
  }

  void selectSymbol(String symbol) {
    if (showingSequence || gameFinished) return;

    setState(() {
      userSequence.add(symbol);
    });

    final index = userSequence.length - 1;

    if (userSequence[index] != sequence[index]) {
      finishGame();
      return;
    }

    if (userSequence.length == sequence.length) {
      score++;

      if (level >= 5) {
        finishGame();
      } else {
        level++;

        Future.delayed(
          const Duration(milliseconds: 700),
          () {
            if (mounted) {
              startLevel();
            }
          },
        );
      }
    }
  }

  Future<void> finishGame() async {
    gameFinished = true;

    final accuracy = (score / 5) * 100;

    await StorageService.saveGameResult(
      attempts: level,
      accuracy: accuracy,
      timeSeconds: 0,
    );

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            '🎉 Great Memory!',
            style: TextStyle(fontSize: 26),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Sequence Memory completed!',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              Text(
                'Levels completed: $score',
                style: const TextStyle(fontSize: 20),
              ),
              Text(
                'Performance: ${accuracy.toStringAsFixed(0)}%',
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
          '🔢 Sequence Memory',
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
                  'Level $level',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                Text(
                  showingSequence
                      ? 'Remember the sequence'
                      : 'Repeat the sequence',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                if (showingSequence)
                  Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Wrap(
                      spacing: 15,
                      alignment: WrapAlignment.center,
                      children: sequence.map((symbol) {
                        return Text(
                          symbol,
                          style: const TextStyle(
                            fontSize: 48,
                          ),
                        );
                      }).toList(),
                    ),
                  )
                else
                  Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.grey.shade100,
                        ),
                        child: Text(
                          userSequence.isEmpty
                              ? 'Your answer will appear here'
                              : userSequence.join('  '),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 40,
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      const Text(
                        'Choose the symbols in order',
                        style: TextStyle(fontSize: 18),
                      ),

                      const SizedBox(height: 20),

                      Wrap(
                        spacing: 15,
                        runSpacing: 15,
                        alignment: WrapAlignment.center,
                        children: symbols.map((symbol) {
                          return SizedBox(
                            width: 90,
                            height: 70,
                            child: ElevatedButton(
                              onPressed: () =>
                                  selectSymbol(symbol),
                              child: Text(
                                symbol,
                                style: const TextStyle(
                                  fontSize: 35,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
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