import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/mindweave_provider.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<MindWeaveProvider>(
      builder: (context, provider, _) {
        final progress = provider.progress;
        final sessions = provider.sessions;
        final profile = provider.profile;

        final gamesCompleted = progress['gamesCompleted'] ?? sessions.length;
        final totalAttempts = progress['totalAttempts'] ?? 0;
        final totalErrors = progress['totalErrors'] ?? 0;
        final bestAccuracy = (progress['bestAccuracy'] as num?)?.toDouble() ?? 0.0;
        final bestTime = (progress['bestTime'] as num?)?.toInt() ?? 0;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              '📊 Cognitive Progress',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                onPressed: () => provider.refreshData(),
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh Local Storage',
              ),
            ],
          ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Cognitive Progress',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Offline-first longitudinal metrics persisted locally in Hive.',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                      const SizedBox(height: 24),

                      // Metric Cards Grid
                      Row(
                        children: [
                          Expanded(
                            child: _statCard('🎮', 'Sessions', '$gamesCompleted'),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _statCard(
                              '🎯',
                              'Best Accuracy',
                              '${bestAccuracy.toStringAsFixed(0)}%',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _statCard(
                              '⏱️',
                              'Best Time',
                              bestTime == 0 ? '--' : '$bestTime sec',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _statCard('🔢', 'Total Attempts', '$totalAttempts'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _statCard('⚠️', 'Total Errors', '$totalErrors'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // Cognitive Domain Baselines
                      if (profile != null) ...[
                        const Text(
                          '🧠 Domain Baselines',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              children: [
                                _domainRow('Memory Domain', profile.memoryScore, Colors.blue),
                                const Divider(height: 20),
                                _domainRow('Attention & Focus', profile.attentionScore, Colors.teal),
                                const Divider(height: 20),
                                _domainRow('Pattern Recognition', profile.patternScore, Colors.purple),
                                const Divider(height: 20),
                                _domainRow('Routine & Sequential', profile.routineScore, Colors.amber.shade800),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                      ],

                      // Recent Cognitive Sessions
                      const Text(
                        '📜 Recent Sessions (Hive Stored)',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (sessions.isEmpty)
                        Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(
                              child: Text(
                                'No sessions completed yet. Play a memory game to record your first local session!',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16, color: Colors.black54),
                              ),
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: sessions.take(8).length,
                          itemBuilder: (context, index) {
                            final s = sessions[index];
                            final formattedDate =
                                '${s.timestamp.hour.toString().padLeft(2, '0')}:${s.timestamp.minute.toString().padLeft(2, '0')} • ${s.timestamp.day}/${s.timestamp.month}/${s.timestamp.year}';
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.indigo.shade50,
                                  child: Text(
                                    s.gameType.startsWith('seq')
                                        ? '🔢'
                                        : s.gameType.startsWith('rem')
                                            ? '🧩'
                                            : '🃏',
                                  ),
                                ),
                                title: Text(
                                  _formatGameType(s.gameType),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  '$formattedDate\nErrors: ${s.errorCounts}  |  Time: ${s.completionTimeSeconds}s  |  Level: ${s.difficulty}',
                                  style: const TextStyle(height: 1.3),
                                ),
                                trailing: Text(
                                  '${s.accuracy.toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: s.accuracy >= 70
                                        ? Colors.green.shade700
                                        : Colors.orange.shade800,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  String _formatGameType(String raw) {
    switch (raw.toLowerCase()) {
      case 'memory_match':
        return 'Memory Match';
      case 'sequence_memory':
      case 'sequence_recall':
        return 'Sequence Recall';
      case 'remember_objects':
        return 'Remember Objects';
      default:
        return raw.replaceAll('_', ' ').toUpperCase();
    }
  }

  Widget _statCard(String icon, String title, String value) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _domainRow(String label, double score, Color color) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          flex: 6,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (score / 100).clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '${score.toStringAsFixed(0)}%',
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}