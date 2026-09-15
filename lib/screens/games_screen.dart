import 'package:flutter/material.dart';
import 'memory_match_screen.dart';
import 'remember_objects_screen.dart';
import 'sequence_memory_screen.dart';
class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🧩 Memory Games',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose a game',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Train your memory and attention',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 30),

            _gameCard(
              context,
              '🧠',
              'Memory Match',
              'Find matching pairs',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MemoryMatchScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            _gameCard(
              context,
              '👀',
              'Remember Objects',
              'Remember objects shown to you',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RememberObjectsScreen(),
                  ),
                );
},
            ),

            const SizedBox(height: 16),

            _gameCard(
              context,
              '🔢',
              'Sequence Memory',
              'Remember the correct sequence',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SequenceMemoryScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _gameCard(
    BuildContext context,
    String icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Text(
                icon,
                style: const TextStyle(fontSize: 45),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }
}