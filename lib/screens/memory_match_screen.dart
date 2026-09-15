import 'dart:async';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';
class MemoryMatchScreen extends StatefulWidget {
  const MemoryMatchScreen({super.key});

  @override
  State<MemoryMatchScreen> createState() => _MemoryMatchScreenState();
}

class _MemoryMatchScreenState extends State<MemoryMatchScreen> {
  final List<String> cards = [
    '🍎',
    '🍎',
    '🐱',
    '🐱',
    '🌸',
    '🌸',
    '⭐',
    '⭐',
  ];

  late List<String> shuffledCards;
  late List<bool> revealed;

  int? firstCard;
  int? secondCard;

  int matches = 0;
  int attempts = 0;

  bool checking = false;

  DateTime? startTime;
  int elapsedSeconds = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    shuffledCards = List.from(cards)..shuffle();
    revealed = List.filled(shuffledCards.length, false);

    firstCard = null;
    secondCard = null;
    matches = 0;
    attempts = 0;
    checking = false;

    startTime = DateTime.now();

    timer?.cancel();

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && startTime != null) {
        setState(() {
          elapsedSeconds =
              DateTime.now().difference(startTime!).inSeconds;
        });
      }
    });

    setState(() {});
  }

  void selectCard(int index) {
    if (checking || revealed[index]) {
      return;
    }

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

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;

      if (shuffledCards[firstCard!] == shuffledCards[secondCard!]) {
        matches++;
      } else {
        revealed[firstCard!] = false;
        revealed[secondCard!] = false;
      }

      firstCard = null;
      secondCard = null;
      checking = false;

      setState(() {});

      if (matches == cards.length ~/ 2) {
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
    if (attempts == 0) return 0;

    return (matches / attempts) * 100;
  }

  void showResult() {
    StorageService.saveGameResult(
      attempts: attempts,
      accuracy: accuracy,
      timeSeconds: elapsedSeconds,
  );
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            '🎉 Well Done!',
            style: TextStyle(fontSize: 26),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'You completed the Memory Match!',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              Text(
                'Attempts: $attempts',
                style: const TextStyle(fontSize: 18),
              ),
              Text(
                'Accuracy: ${accuracy.toStringAsFixed(0)}%',
                style: const TextStyle(fontSize: 18),
              ),
              Text(
                'Time: $elapsedSeconds seconds',
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                startGame();
              },
              child: const Text(
                'Play Again',
                style: TextStyle(fontSize: 18),
              ),
            ),
            ElevatedButton(
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
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🧠 Memory Match',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: startGame,
            icon: const Icon(Icons.refresh),
            tooltip: 'Restart',
          ),
        ],
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
                const Text(
                  'Find all matching pairs',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Tap two cards to reveal them',
                  style: TextStyle(fontSize: 18),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _statBox(
                      'Matches',
                      '$matches / 4',
                      Icons.favorite,
                    ),
                    _statBox(
                      'Attempts',
                      '$attempts',
                      Icons.touch_app,
                    ),
                    _statBox(
                      'Time',
                      '${elapsedSeconds}s',
                      Icons.timer,
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1,
                  ),
                  itemCount: shuffledCards.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => selectCard(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: revealed[index]
                              ? Colors.white
                              : Colors.indigo,
                          border: Border.all(
                            color: Colors.indigo,
                            width: 2,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            revealed[index]
                                ? shuffledCards[index]
                                : '?',
                            style: TextStyle(
                              fontSize: revealed[index] ? 42 : 34,
                              fontWeight: FontWeight.bold,
                              color: revealed[index]
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 25),

                Text(
                  'Accuracy: ${accuracy.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 20,
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

  Widget _statBox(
    String title,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.indigo.shade50,
      ),
      child: Column(
        children: [
          Icon(icon, size: 28),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}