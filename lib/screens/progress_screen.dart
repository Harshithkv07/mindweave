import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  Map<String, dynamic> progress = {
    'gamesCompleted': 0,
    'totalAttempts': 0,
    'bestAccuracy': 0.0,
    'bestTime': 0,
  };

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadProgress();
  }

  Future<void> loadProgress() async {
    final data = await StorageService.getProgress();

    if (!mounted) return;

    setState(() {
      progress = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '📊 My Progress',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: loadProgress,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Cognitive Progress',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'MindWeave tracks your performance over time.',
                    style: TextStyle(fontSize: 18),
                  ),

                  const SizedBox(height: 30),

                  _progressCard(
                    '🎮',
                    'Games Completed',
                    '${progress['gamesCompleted']}',
                  ),

                  const SizedBox(height: 16),

                  _progressCard(
                    '🎯',
                    'Best Accuracy',
                    '${progress['bestAccuracy'].toStringAsFixed(0)}%',
                  ),

                  const SizedBox(height: 16),

                  _progressCard(
                    '⏱️',
                    'Best Time',
                    progress['bestTime'] == 0
                        ? '--'
                        : '${progress['bestTime']} sec',
                  ),

                  const SizedBox(height: 16),

                  _progressCard(
                    '🔢',
                    'Total Attempts',
                    '${progress['totalAttempts']}',
                  ),

                  const SizedBox(height: 30),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.indigo.shade50,
                    ),
                    child: const Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🌟 Keep Going!',
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Regular cognitive exercises help MindWeave understand your performance and personalize future activities.',
                          style: TextStyle(fontSize: 17),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _progressCard(
    String icon,
    String title,
    String value,
  ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Row(
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 42),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}