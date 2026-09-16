import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../core/theme.dart';
import 'games_screen.dart';
import 'voice_screen.dart';
import 'login_screen.dart';

/// Redesigned Patient Dashboard optimized for maximum simplicity.
///
/// Features:
/// - 2x2 oversized grid layout utilizing Flutter's GridView.
/// - Distinct, large cards for 'Memory Games', 'Medication', 'Hydration', and 'Voice Assistant'.
/// - Massive, universally understood icons (72dp) and single bold text labels (22sp).
/// - Completely uncluttered design eliminating all decorative distractions to reduce cognitive load.
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
  FlutterTts? _tts;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    _tts = FlutterTts();
    await _tts?.setLanguage(widget.language.isNotEmpty ? widget.language : 'en-US');
    await _tts?.setSpeechRate(0.42);
    await _tts?.setVolume(1.0);
    await _tts?.setPitch(1.0);
    _tts?.setCompletionHandler(() {
      if (mounted) {
        setState(() => _isSpeaking = false);
      }
    });
  }

  @override
  void dispose() {
    _tts?.stop();
    super.dispose();
  }

  Future<void> _speak(String message) async {
    if (_isSpeaking) {
      await _tts?.stop();
      setState(() => _isSpeaking = false);
      return;
    }
    setState(() => _isSpeaking = true);
    try {
      await _tts?.speak(message);
    } catch (_) {}
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon';
    } else if (hour >= 17 && hour < 21) {
      return 'Good Evening';
    } else {
      return 'Good Night';
    }
  }

  void _showMedicationDialog() {
    final message =
        '${widget.name}, remember to take your scheduled medication with a glass of water.';
    _speak(message);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          side: const BorderSide(color: AppColors.error, width: 2.0),
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.medication_rounded,
                size: 64.0,
                color: AppColors.error,
              ),
              SizedBox(height: 16.0),
              Text(
                'Medication',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 12.0),
              Text(
                'Please take your scheduled medication with water.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.0,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              onPressed: () {
                _tts?.stop();
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Medication marked as taken.',
                      style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              child: const Text(
                'I Took It',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          TextButton(
            onPressed: () {
              _tts?.stop();
              Navigator.pop(ctx);
            },
            child: const Text(
              'Remind Me Later',
              style: TextStyle(fontSize: 16.0, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  void _showHydrationDialog() {
    final message =
        '${widget.name}, drink a fresh glass of water to stay healthy and hydrated.';
    _speak(message);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          side: const BorderSide(color: AppColors.info, width: 2.0),
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.water_drop_rounded,
                size: 64.0,
                color: AppColors.info,
              ),
              SizedBox(height: 16.0),
              Text(
                'Hydration',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 12.0),
              Text(
                'Drink a fresh glass of water to stay energized.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.0,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.info,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              onPressed: () {
                _tts?.stop();
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Hydration goal recorded.',
                      style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              child: const Text(
                'Drank Water',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          TextButton(
            onPressed: () {
              _tts?.stop();
              Navigator.pop(ctx);
            },
            child: const Text(
              'Remind Me Later',
              style: TextStyle(fontSize: 16.0, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'MindWeave',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 24.0,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Sign Out',
            icon: const Icon(Icons.logout_rounded, size: 26.0),
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Clear, calming personalized greeting
              Text(
                '${getGreeting()}, ${widget.name}',
                style: const TextStyle(
                  fontSize: 26.0,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 16.0),

              // 2x2 Oversized Grid for Maximum Simplicity & Low Cognitive Load
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 1.05,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // Card 1: Memory Games
                    _buildOversizedCard(
                      label: 'Memory Games',
                      icon: Icons.extension_rounded,
                      color: AppColors.primaryDark,
                      backgroundColor: const Color(0xFFEFF6FF),
                      borderColor: AppColors.primaryDark,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const GamesScreen(),
                          ),
                        );
                      },
                    ),

                    // Card 2: Medication
                    _buildOversizedCard(
                      label: 'Medication',
                      icon: Icons.medication_rounded,
                      color: AppColors.error,
                      backgroundColor: const Color(0xFFFEF2F2),
                      borderColor: AppColors.error,
                      onTap: _showMedicationDialog,
                    ),

                    // Card 3: Hydration
                    _buildOversizedCard(
                      label: 'Hydration',
                      icon: Icons.water_drop_rounded,
                      color: AppColors.info,
                      backgroundColor: const Color(0xFFF0F9FF),
                      borderColor: AppColors.info,
                      onTap: _showHydrationDialog,
                    ),

                    // Card 4: Voice Assistant
                    _buildOversizedCard(
                      label: 'Voice Assistant',
                      icon: Icons.record_voice_over_rounded,
                      color: AppColors.secondary,
                      backgroundColor: const Color(0xFFF0FDF4),
                      borderColor: AppColors.secondary,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const VoiceScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a distinct, oversized card with a massive icon and a single bold text label.
  Widget _buildOversizedCard({
    required String label,
    required IconData icon,
    required Color color,
    required Color backgroundColor,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        side: BorderSide(color: borderColor, width: 2.5),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Massive, universally understood icon
              Icon(
                icon,
                size: 72.0,
                color: color,
              ),
              const SizedBox(height: 14.0),

              // Single bold text label
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w800,
                  color: color,
                  height: 1.2,
                  letterSpacing: -0.2,
                  fontFamily: 'Arial',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}