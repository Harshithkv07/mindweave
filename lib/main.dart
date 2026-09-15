import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MindWeaveApp());
}

class MindWeaveApp extends StatelessWidget {
  const MindWeaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MindWeave',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        fontFamily: 'Arial',
      ),
      home: const LoginScreen(),
    );
  }
}

// ======================================================
// WELCOME SCREEN
// ======================================================

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '🧠',
                  style: TextStyle(fontSize: 85),
                ),

                const SizedBox(height: 20),

                const Text(
                  'MindWeave',
                  style: TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                const Text(
                  'Personalized Memory Assistance',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 15),

                const Text(
                  'Train your memory, stay connected,\nand track your progress.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 45),

                SizedBox(
                  width: 280,
                  height: 65,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Start',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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

// ======================================================
// PATIENT DASHBOARD / HOME SCREEN
// ======================================================

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '🧠 MindWeave',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ------------------------------------------------
              // GREETING
              // ------------------------------------------------

              const Text(
                'Good Morning! 👋',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Welcome back! Let’s keep your mind active today.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 25),

              // ------------------------------------------------
              // PROGRESS CARD
              // ------------------------------------------------

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),

                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.indigo.shade600,
                      Colors.indigo.shade400,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text(
                      'Today’s Progress',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [

                        Text(
                          '60%',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(width: 12),

                        Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Text(
                            'completed',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),

                      child: const LinearProgressIndicator(
                        value: 0.6,
                        minHeight: 10,
                        backgroundColor: Colors.white30,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'Keep going! You are doing great 🌟',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ------------------------------------------------
              // SECTION TITLE
              // ------------------------------------------------

              const Text(
                'What would you like to do?',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // ------------------------------------------------
              // MEMORY GAMES
              // ------------------------------------------------

              _buildMenuCard(
                context,
                icon: '🧩',
                title: 'Memory Games',
                subtitle: 'Train your memory with fun activities',
                color: Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GamesScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 15),

              // ------------------------------------------------
              // VOICE ASSISTANT
              // ------------------------------------------------

              _buildMenuCard(
                context,
                icon: '🎤',
                title: 'Talk to MindWeave',
                subtitle: 'Use your voice to interact with the app',
                color: Colors.purple,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const VoiceAssistantScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 15),

              // ------------------------------------------------
              // REMINDERS
              // ------------------------------------------------

              _buildMenuCard(
                context,
                icon: '⏰',
                title: 'My Reminders',
                subtitle: 'View your daily reminders',
                color: Colors.green,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReminderScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 15),

              // ------------------------------------------------
              // PROGRESS
              // ------------------------------------------------

              _buildMenuCard(
                context,
                icon: '📊',
                title: 'My Progress',
                subtitle: 'View your memory training progress',
                color: Colors.teal,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProgressScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 25),

              // ------------------------------------------------
              // DAILY REMINDER
              // ------------------------------------------------

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),

                child: const Row(
                  children: [

                    Icon(
                      Icons.notifications_active,
                      size: 40,
                      color: Colors.orange,
                    ),

                    SizedBox(width: 15),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          Text(
                            'Today’s Reminder',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 6),

                          Text(
                            'Take your medicine at 12:00 PM',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ------------------------------------------------
              // MOTIVATION
              // ------------------------------------------------

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),

                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      '🌟 Daily Motivation',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 8),

                    Text(
                      'Every small step helps keep your mind active.',
                      style: TextStyle(
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              const Center(
                child: Text(
                  '💙 You are doing great!',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        color: Colors.white,
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

                Container(
                  width: 65,
                  height: 65,

                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),

                  child: Center(
                    child: Text(
                      icon,
                      style: const TextStyle(
                        fontSize: 35,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 18),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

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
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(
                  Icons.arrow_forward_ios,
                  size: 20,
                  color: color,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ======================================================
// GAMES SCREEN
// ======================================================

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Memory Games',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const Text(
              'Choose an activity 🧠',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Select a game to exercise your memory.',
              style: TextStyle(
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 80,

              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const MemoryMatchScreen(),
                    ),
                  );
                },

                child: const Text(
                  '🧩  Memory Match',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 80,

              child: OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Remember Objects game coming next!',
                      ),
                    ),
                  );
                },

                child: const Text(
                  '👀  Remember Objects',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 80,

              child: OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Sequence Memory game coming next!',
                      ),
                    ),
                  );
                },

                child: const Text(
                  '🔢  Sequence Memory',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// MEMORY MATCH GAME
// ======================================================

class MemoryMatchScreen extends StatefulWidget {
  const MemoryMatchScreen({super.key});

  @override
  State<MemoryMatchScreen> createState() =>
      _MemoryMatchScreenState();
}

class _MemoryMatchScreenState
    extends State<MemoryMatchScreen> {

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

  final List<bool> revealed =
      List.filled(8, false);

  int? firstCard;
  int? secondCard;

  int matches = 0;
  int attempts = 0;

  bool checking = false;

  void tapCard(int index) async {
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

    await Future.delayed(
      const Duration(milliseconds: 700),
    );

    if (cards[firstCard!] == cards[secondCard!]) {
      matches++;
    } else {
      setState(() {
        revealed[firstCard!] = false;
        revealed[secondCard!] = false;
      });
    }

    firstCard = null;
    secondCard = null;
    checking = false;

    setState(() {});

    if (matches == 4) {
      showDialog(
        context: context,

        builder: (context) {
          return AlertDialog(
            title: const Text(
              '🎉 Great Job!',
              style: TextStyle(
                fontSize: 25,
              ),
            ),

            content: Text(
              'You completed the game!\n\n'
              'Attempts: $attempts',
              style: const TextStyle(
                fontSize: 19,
              ),
            ),

            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },

                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  void restartGame() {
    setState(() {
      for (int i = 0;
          i < revealed.length;
          i++) {
        revealed[i] = false;
      }

      firstCard = null;
      secondCard = null;

      matches = 0;
      attempts = 0;

      checking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Memory Match',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            onPressed: restartGame,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),

          child: Column(
            children: [

              const Text(
                'Find the matching pairs 🧠',
                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              Text(
                'Matches: $matches / 4    '
                'Attempts: $attempts',

                style: const TextStyle(
                  fontSize: 19,
                ),
              ),

              const SizedBox(height: 30),

              Expanded(
                child: GridView.builder(
                  itemCount: cards.length,

                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),

                  itemBuilder: (context, index) {

                    return GestureDetector(
                      onTap: () => tapCard(index),

                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(15),

                          color: revealed[index]
                              ? Colors.white
                              : Colors.indigo,

                          border: Border.all(
                            width: 2,
                          ),
                        ),

                        child: Center(
                          child: Text(
                            revealed[index]
                                ? cards[index]
                                : '?',

                            style: TextStyle(
                              fontSize: revealed[index]
                                  ? 40
                                  : 32,

                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ======================================================
// VOICE ASSISTANT SCREEN
// ======================================================

class VoiceAssistantScreen extends StatelessWidget {
  const VoiceAssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Talk to MindWeave',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),

          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [

              const Text(
                '🎤',
                style: TextStyle(
                  fontSize: 80,
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                'Talk to MindWeave',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              const Text(
                'Voice assistance will help you interact '
                'with MindWeave easily.',
                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 35),

              SizedBox(
                width: 220,
                height: 65,

                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Voice recognition will be added next.',
                        ),
                      ),
                    );
                  },

                  icon: const Icon(
                    Icons.mic,
                    size: 30,
                  ),

                  label: const Text(
                    'Start Listening',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ======================================================
// REMINDER SCREEN
// ======================================================

class ReminderScreen extends StatelessWidget {
  const ReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Reminders',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            const Text(
              'Today’s Reminders ⏰',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            _reminderCard(
              icon: Icons.medication,
              title: 'Medicine',
              time: '12:00 PM',
              description:
                  'Take your medicine',
            ),

            const SizedBox(height: 15),

            _reminderCard(
              icon: Icons.local_hospital,
              title: 'Doctor Appointment',
              time: '4:00 PM',
              description:
                  'Visit the doctor',
            ),

            const SizedBox(height: 15),

            _reminderCard(
              icon: Icons.water_drop,
              title: 'Drink Water',
              time: '6:00 PM',
              description:
                  'Remember to drink water',
            ),
          ],
        ),
      ),
    );
  }

  Widget _reminderCard({
    required IconData icon,
    required String title,
    required String time,
    required String description,
  }) {
    return Card(
      elevation: 2,

      child: ListTile(
        contentPadding:
            const EdgeInsets.all(16),

        leading: CircleAvatar(
          radius: 28,

          child: Icon(
            icon,
            size: 28,
          ),
        ),

        title: Text(
          title,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Text(
          '$description\n$time',
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

// ======================================================
// PROGRESS SCREEN
// ======================================================

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Progress',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            const Text(
              'Your Memory Progress 📊',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            _progressCard(
              'Memory Match',
              0.75,
              '75%',
            ),

            const SizedBox(height: 18),

            _progressCard(
              'Remember Objects',
              0.55,
              '55%',
            ),

            const SizedBox(height: 18),

            _progressCard(
              'Sequence Memory',
              0.40,
              '40%',
            ),

            const SizedBox(height: 30),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),

              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius:
                    BorderRadius.circular(20),
              ),

              child: const Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Text(
                    '🌟 Keep Practicing!',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    'Regular practice can help you stay '
                    'mentally active.',
                    style: TextStyle(
                      fontSize: 17,
                    ),
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
    String title,
    double value,
    String percentage,
  ) {
    return Card(
      elevation: 2,

      child: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

              children: [

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  percentage,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            ClipRRect(
              borderRadius:
                  BorderRadius.circular(10),

              child: LinearProgressIndicator(
                value: value,
                minHeight: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}