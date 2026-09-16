import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../services/mindweave_provider.dart';
import '../services/storage_service.dart';
import 'games_screen.dart';
import 'voice_screen.dart';
import 'progress_screen.dart';

/// Patient dashboard: greeting header, live stat cards, quick actions, and
/// today's schedule — a full home dashboard rather than a bare action grid.
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MindWeaveProvider>(context, listen: false).refreshData();
    });
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

  IconData _iconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'medication':
        return Icons.medication_rounded;
      case 'hydration':
        return Icons.water_drop_rounded;
      case 'cognitive':
        return Icons.extension_rounded;
      default:
        return Icons.notifications_active_rounded;
    }
  }

  Color _colorForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'medication':
        return AppColors.error;
      case 'hydration':
        return AppColors.info;
      case 'cognitive':
        return Colors.orange.shade800;
      default:
        return AppColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MindWeaveProvider>(
      builder: (context, provider, _) {
        final sessions = provider.sessions;
        final reminders = provider.reminders;
        final gamesCompleted = provider.progress['gamesCompleted'] ?? sessions.length;
        final bestAccuracy = (provider.progress['bestAccuracy'] as num?)?.toDouble() ?? 0.0;
        final todaysReminders = reminders.take(4).toList();

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gradient dashboard header with avatar + quick actions.
                  _buildHeader(reminders.length),
                  const SizedBox(height: 18.0),

                  // Live stat row pulled from real session/progress data.
                  Row(
                    children: [
                      _statCard(
                        icon: Icons.videogame_asset_rounded,
                        color: AppColors.primary,
                        value: '$gamesCompleted',
                        label: 'Games Played',
                      ),
                      const SizedBox(width: 12.0),
                      _statCard(
                        icon: Icons.gps_fixed_rounded,
                        color: AppColors.success,
                        value: '${bestAccuracy.toStringAsFixed(0)}%',
                        label: 'Best Accuracy',
                      ),
                      const SizedBox(width: 12.0),
                      _statCard(
                        icon: Icons.insights_rounded,
                        color: Colors.orange.shade800,
                        value: '${provider.baselineScore.toStringAsFixed(0)}%',
                        label: 'Baseline',
                      ),
                    ],
                  ),
                  const SizedBox(height: 26.0),

                  const Text(
                    'What would you like to do?',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14.0),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 14.0,
                    mainAxisSpacing: 14.0,
                    childAspectRatio: 1.15,
                    children: [
                      _buildActionCard(
                        label: 'Memory Games',
                        icon: Icons.extension_rounded,
                        color: Colors.orange.shade800,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const GamesScreen()),
                          );
                        },
                      ),
                      _buildActionCard(
                        label: 'Medication',
                        icon: Icons.medication_rounded,
                        color: AppColors.error,
                        onTap: _showMedicationDialog,
                      ),
                      _buildActionCard(
                        label: 'Hydration',
                        icon: Icons.water_drop_rounded,
                        color: AppColors.info,
                        onTap: _showHydrationDialog,
                      ),
                      _buildActionCard(
                        label: 'Voice Assistant',
                        icon: Icons.record_voice_over_rounded,
                        color: AppColors.secondary,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const VoiceScreen()),
                          );
                        },
                      ),
                      _buildActionCard(
                        label: 'My Progress',
                        icon: Icons.bar_chart_rounded,
                        color: AppColors.primary,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ProgressScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 28.0),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Today's Schedule",
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${reminders.length} routines',
                        style: const TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.0),

                  if (todaysReminders.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                        boxShadow: softCardShadow(),
                      ),
                      child: const Text(
                        'No routines scheduled yet.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                        boxShadow: softCardShadow(),
                      ),
                      child: Column(
                        children: [
                          for (int i = 0; i < todaysReminders.length; i++) ...[
                            _buildReminderRow(context, provider, todaysReminders[i]),
                            if (i != todaysReminders.length - 1)
                              const Divider(height: 1, indent: 20, endIndent: 20),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Gradient dashboard header: avatar, greeting, notification + profile-switch.
  Widget _buildHeader(int reminderCount) {
    final initial = widget.name.isNotEmpty ? widget.name[0].toUpperCase() : 'M';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: AppGradients.hero,
        borderRadius: BorderRadius.circular(AppDimensions.radiusExtraLarge),
        boxShadow: softCardShadow(opacity: 0.18),
      ),
      child: Row(
        children: [
          Container(
            width: 54.0,
            height: 54.0,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              shape: BoxShape.circle,
            ),
            child: Text(
              initial,
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 14.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getGreeting(),
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                Text(
                  widget.name,
                  style: const TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Material(
                color: Colors.white.withValues(alpha: 0.18),
                shape: const CircleBorder(),
                child: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Icon(Icons.notifications_none_rounded, size: 22.0, color: Colors.white),
                ),
              ),
              if (reminderCount > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.all(3.0),
                    decoration: const BoxDecoration(color: AppColors.tertiary, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '$reminderCount',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 10.0, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10.0),
          Material(
            color: Colors.white.withValues(alpha: 0.18),
            shape: const CircleBorder(),
            child: IconButton(
              tooltip: 'Switch Profile',
              icon: const Icon(Icons.switch_account_rounded, size: 22.0, color: Colors.white),
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          boxShadow: softCardShadow(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 22.0, color: color),
            const SizedBox(height: 8.0),
            Text(
              value,
              style: TextStyle(fontSize: 19.0, fontWeight: FontWeight.w800, color: color),
            ),
            const SizedBox(height: 2.0),
            Text(
              label,
              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        boxShadow: softCardShadow(),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 14.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 56.0,
                  height: 56.0,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 30.0, color: color),
                ),
                const SizedBox(height: 10.0),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReminderRow(BuildContext context, MindWeaveProvider provider, DailyReminder reminder) {
    final color = _colorForCategory(reminder.category);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Container(
            width: 44.0,
            height: 44.0,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: Icon(_iconForCategory(reminder.category), size: 22.0, color: color),
          ),
          const SizedBox(width: 14.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title,
                  style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                Text(
                  reminder.time,
                  style: const TextStyle(fontSize: 13.0, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Switch(
            value: reminder.isEnabled,
            activeThumbColor: AppColors.success,
            onChanged: (_) => provider.toggleReminder(reminder.id),
          ),
        ],
      ),
    );
  }
}
