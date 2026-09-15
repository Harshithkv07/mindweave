import 'package:flutter/material.dart';
import 'games_screen.dart';
import 'voice_screen.dart';
import 'progress_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final String name;
  final String language;
  final bool isCaretaker;

  const HomeScreen({
    super.key,
    required this.name,
    required this.language,
    this.isCaretaker = false,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isSpeakingReminder = false;
  String currentReminderText =
      'Good morning Margaret. Remember to take your morning blood pressure medication with water.';

  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return 'Good Morning 🌅';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon ☀️';
    } else if (hour >= 17 && hour < 21) {
      return 'Good Evening 🌆';
    } else {
      return 'Good Night 🌙';
    }
  }

  void _simulateVoiceReminder() {
    setState(() {
      isSpeakingReminder = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.volume_up, color: Colors.white),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                '🔊 Spoken Voice Alert: "Good morning Margaret. Remember to take your morning medication with water."',
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
        backgroundColor: Colors.indigo.shade800,
      ),
    );

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          isSpeakingReminder = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isCaretaker ? '🛡️ Caretaker Portal' : '🧠 MindWeave',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Sign Out / Switch Portal',
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                ),
              );
            },
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.isCaretaker)
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.admin_panel_settings,
                          color: Colors.amber.shade900),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Authenticated Caretaker Session: Monitoring care plan and cognitive health.',
                          style: TextStyle(
                            color: Colors.amber.shade900,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              Text(
                getGreeting(),
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Welcome, ${widget.name}! 👋',
                style: const TextStyle(fontSize: 24),
              ),

              const SizedBox(height: 8),

              Text(
                'Ready for today\'s brain activity & care routine?',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade700,
                ),
              ),

              const SizedBox(height: 25),

              // VOICE REMINDER BANNER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isSpeakingReminder
                        ? [Colors.deepPurple.shade600, Colors.indigo.shade700]
                        : [Colors.indigo.shade600, Colors.blue.shade700],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.indigo.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isSpeakingReminder
                                ? Icons.record_voice_over
                                : Icons.volume_up,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isSpeakingReminder
                                    ? '🔊 Speaking Voice Alert...'
                                    : '🔔 Spoken Reminder Notification',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Voice: ${widget.language}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '"$currentReminderText"',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.4,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.indigo.shade900,
                          ),
                          onPressed: _simulateVoiceReminder,
                          icon: Icon(
                            isSpeakingReminder
                                ? Icons.hearing
                                : Icons.play_arrow,
                          ),
                          label: Text(
                            isSpeakingReminder
                                ? 'Speaking Now...'
                                : 'Hear Spoken Alert',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              _menuCard(
                context,
                icon: '🧩',
                title: 'Memory Games',
                subtitle: 'Exercise your memory and attention',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const GamesScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              _menuCard(
                context,
                icon: '🎤',
                title: 'Talk to MindWeave',
                subtitle: 'Speak and interact using your voice',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const VoiceScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              _menuCard(
                context,
                icon: '📊',
                title: 'My Progress',
                subtitle: 'See your cognitive training progress',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProgressScreen(),
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

  Widget _menuCard(
    BuildContext context, {
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
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

                    const SizedBox(height: 5),

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