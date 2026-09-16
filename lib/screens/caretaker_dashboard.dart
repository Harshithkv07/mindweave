import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../services/storage_service.dart';
import '../services/mindweave_provider.dart';
import 'login_screen.dart';

/// Professional Caretaker Analytics Dashboard.
///
/// Features:
/// - Card-based layout using ListView clearly separating 'Daily Adherence'
///   (medication & water) from 'Cognitive Trends' (game performance scores).
/// - Clean `fl_chart` LineChart rendering game performance with large, highly
///   legible axes, labels, and rich tooltips.
/// - Strictly bound to local offline Hive data with zero cloud dependencies.
class CaretakerDashboardScreen extends StatefulWidget {
  final String patientName;

  const CaretakerDashboardScreen({
    super.key,
    this.patientName = 'Margaret',
  });

  @override
  State<CaretakerDashboardScreen> createState() =>
      _CaretakerDashboardScreenState();
}

class _CaretakerDashboardScreenState extends State<CaretakerDashboardScreen> {
  String _selectedGameFilter = 'All'; // 'All', 'Memory Match', 'Remember Objects', 'Sequence Memory'
  int _dailyWaterGlasses = 5; // Local tracking state for daily hydration target
  final int _targetWaterGlasses = 8;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refresh();
    });
  }

  Future<void> _refresh() async {
    try {
      final provider = Provider.of<MindWeaveProvider>(context, listen: false);
      await provider.refreshData();
    } catch (_) {
      // StorageService/Provider not attached in testing environments
    }
  }

  /// Seeds sample cognitive training sessions directly into Hive
  /// for offline demonstration and chart validation.
  Future<void> _seedSampleOfflineData() async {
    setState(() => _isLoading = true);
    final now = DateTime.now();

    final sampleSessions = [
      CognitiveSession(
        id: 'sample_${now.subtract(const Duration(days: 6)).millisecondsSinceEpoch}',
        gameType: 'Memory Match',
        timestamp: now.subtract(const Duration(days: 6, hours: 2)),
        errorCounts: 2,
        completionTimeSeconds: 48,
        accuracy: 72.0,
        attempts: 8,
        difficulty: 'Easy',
      ),
      CognitiveSession(
        id: 'sample_${now.subtract(const Duration(days: 5)).millisecondsSinceEpoch}',
        gameType: 'Sequence Memory',
        timestamp: now.subtract(const Duration(days: 5, hours: 3)),
        errorCounts: 1,
        completionTimeSeconds: 52,
        accuracy: 80.0,
        attempts: 10,
        difficulty: 'Medium',
      ),
      CognitiveSession(
        id: 'sample_${now.subtract(const Duration(days: 4)).millisecondsSinceEpoch}',
        gameType: 'Remember Objects',
        timestamp: now.subtract(const Duration(days: 4, hours: 1)),
        errorCounts: 3,
        completionTimeSeconds: 60,
        accuracy: 75.0,
        attempts: 10,
        difficulty: 'Medium',
      ),
      CognitiveSession(
        id: 'sample_${now.subtract(const Duration(days: 3)).millisecondsSinceEpoch}',
        gameType: 'Memory Match',
        timestamp: now.subtract(const Duration(days: 3, hours: 4)),
        errorCounts: 1,
        completionTimeSeconds: 44,
        accuracy: 88.0,
        attempts: 8,
        difficulty: 'Medium',
      ),
      CognitiveSession(
        id: 'sample_${now.subtract(const Duration(days: 2)).millisecondsSinceEpoch}',
        gameType: 'Sequence Memory',
        timestamp: now.subtract(const Duration(days: 2, hours: 2)),
        errorCounts: 0,
        completionTimeSeconds: 38,
        accuracy: 94.0,
        attempts: 10,
        difficulty: 'Hard',
      ),
      CognitiveSession(
        id: 'sample_${now.subtract(const Duration(days: 1)).millisecondsSinceEpoch}',
        gameType: 'Remember Objects',
        timestamp: now.subtract(const Duration(days: 1, hours: 5)),
        errorCounts: 1,
        completionTimeSeconds: 46,
        accuracy: 89.0,
        attempts: 9,
        difficulty: 'Medium',
      ),
      CognitiveSession(
        id: 'sample_${now.millisecondsSinceEpoch}',
        gameType: 'Memory Match',
        timestamp: now.subtract(const Duration(hours: 1)),
        errorCounts: 0,
        completionTimeSeconds: 39,
        accuracy: 96.0,
        attempts: 8,
        difficulty: 'Hard',
      ),
    ];

    final provider = Provider.of<MindWeaveProvider>(context, listen: false);
    for (final session in sampleSessions) {
      await StorageService.saveSession(session);
    }
    await provider.refreshData();

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sample analytics sessions saved to local Hive storage.'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MindWeaveProvider>(
      builder: (context, provider, _) {
        final sessions = provider.sessions;
        final reminders = provider.reminders;
        final profile = provider.profile ?? StorageService.getProfile();

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            elevation: 0,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shield_rounded, color: AppColors.primaryDark, size: 28),
                const SizedBox(width: 10),
                Text(
                  'Caretaker Analytics',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 22.0,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            centerTitle: true,
            actions: [
              IconButton(
                tooltip: 'Refresh Analytics Data',
                icon: const Icon(Icons.refresh_rounded, size: 26),
                onPressed: _refresh,
              ),
              IconButton(
                tooltip: 'Sign Out',
                icon: const Icon(Icons.logout_rounded, size: 26),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
              ),
            ],
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
                  children: [
                    // 1. Clinical Overview Banner Card
                    _buildOverviewCard(sessions, profile),
                    const SizedBox(height: 18.0),

                    // 2. DAILY ADHERENCE SECTION (Medication & Water)
                    _buildDailyAdherenceCard(reminders, provider),
                    const SizedBox(height: 18.0),

                    // 3. COGNITIVE TRENDS SECTION (Game Performance Line Graph)
                    _buildCognitiveTrendsCard(sessions),
                    const SizedBox(height: 18.0),

                    // 4. Recent Sessions History Table Card
                    _buildRecentSessionsCard(sessions),
                    const SizedBox(height: 24.0),
                  ],
                ),
        );
      },
    );
  }

  // ==========================================================================
  // 1. CLINICAL OVERVIEW CARD
  // ==========================================================================
  Widget _buildOverviewCard(
      List<CognitiveSession> sessions, PatientProfile? profile) {
    final avgAccuracy = sessions.isEmpty
        ? 75.0
        : sessions.fold<double>(0.0, (acc, s) => acc + s.accuracy) /
            sessions.length;

    return Card(
      elevation: 0,
      color: AppColors.surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        side: const BorderSide(color: AppColors.borderLight, width: 1.5),
      ),
      child: Padding(
        padding: AppDimensions.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Patient Care Overview',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        '${widget.patientName}\'s Monitoring Profile',
                        style: const TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    color: AppColors.successContainer,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                    border: Border.all(color: AppColors.success, width: 1.2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.circle, size: 8, color: AppColors.success),
                      SizedBox(width: 6),
                      Text(
                        'Local Offline Storage',
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSuccessContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18.0),

            // Stat Badges
            Row(
              children: [
                _buildStatBadge(
                  label: 'Baseline Score',
                  value: '${(profile?.baselineScore ?? avgAccuracy).toStringAsFixed(1)}%',
                  icon: Icons.speed_rounded,
                  color: AppColors.primaryDark,
                  backgroundColor: AppColors.primaryContainer,
                ),
                const SizedBox(width: 12.0),
                _buildStatBadge(
                  label: 'Total Sessions',
                  value: '${sessions.length}',
                  icon: Icons.history_rounded,
                  color: AppColors.secondary,
                  backgroundColor: AppColors.secondaryContainer,
                ),
                const SizedBox(width: 12.0),
                _buildStatBadge(
                  label: 'Avg Accuracy',
                  value: '${avgAccuracy.toStringAsFixed(1)}%',
                  icon: Icons.check_circle_outline_rounded,
                  color: AppColors.tertiary,
                  backgroundColor: AppColors.tertiaryContainer,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBadge({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required Color backgroundColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 22.0, color: color),
            const SizedBox(height: 6.0),
            Text(
              value,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2.0),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // 2. DAILY ADHERENCE CARD (MEDICATION & WATER SEPARATION)
  // ==========================================================================
  Widget _buildDailyAdherenceCard(
      List<DailyReminder> reminders, MindWeaveProvider provider) {
    // Categorize reminders
    final medReminders = reminders
        .where((r) =>
            r.category.toLowerCase().contains('med') ||
            r.title.toLowerCase().contains('medication') ||
            r.title.toLowerCase().contains('pressure') ||
            r.title.toLowerCase().contains('pill'))
        .toList();

    final activeMedCount = medReminders.where((r) => r.isEnabled).length;
    final totalMeds = medReminders.length;
    final medAdherencePct =
        totalMeds == 0 ? 100 : ((activeMedCount / totalMeds) * 100).toInt();

    final waterPct =
        ((_dailyWaterGlasses / _targetWaterGlasses) * 100).clamp(0, 100).toInt();

    return Card(
      elevation: 0,
      color: AppColors.surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        side: const BorderSide(color: AppColors.borderLight, width: 1.5),
      ),
      child: Padding(
        padding: AppDimensions.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                  ),
                  child: const Icon(
                    Icons.checklist_rounded,
                    color: AppColors.error,
                    size: 26.0,
                  ),
                ),
                const SizedBox(width: 14.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Daily Adherence',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2.0),
                      Text(
                        'Medication routines & hydration tracking',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                  ),
                  child: Text(
                    'Hive Synced',
                    style: const TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),

            // A. MEDICATION SUBSECTION
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.25), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.medication_rounded, color: AppColors.error, size: 24.0),
                          SizedBox(width: 8.0),
                          Text(
                            'Medication Adherence',
                            style: TextStyle(
                              fontSize: 17.0,
                              fontWeight: FontWeight.w800,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '$activeMedCount / $totalMeds Taken ($medAdherencePct%)',
                        style: const TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w700,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14.0),

                  if (medReminders.isEmpty)
                    const Text(
                      'No medication schedules registered in Hive yet.',
                      style: TextStyle(color: AppColors.textSecondary),
                    )
                  else
                    ...medReminders.map(
                      (rem) => Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                            border: Border.all(
                              color: rem.isEnabled ? AppColors.success : AppColors.borderLight,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                rem.isEnabled
                                    ? Icons.check_circle_rounded
                                    : Icons.radio_button_unchecked_rounded,
                                color: rem.isEnabled ? AppColors.success : AppColors.textMuted,
                                size: 26.0,
                              ),
                              const SizedBox(width: 12.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      rem.title,
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w700,
                                        color: rem.isEnabled
                                            ? AppColors.textPrimary
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      'Scheduled: ${rem.time}',
                                      style: const TextStyle(
                                        fontSize: 13.0,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // High touch target toggle switch (min 48x48)
                              SizedBox(
                                width: 56.0,
                                height: 48.0,
                                child: Switch(
                                  value: rem.isEnabled,
                                  activeThumbColor: AppColors.success,
                                  onChanged: (val) async {
                                    await provider.toggleReminder(rem.id);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),

            // B. HYDRATION SUBSECTION
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F9FF),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                border: Border.all(color: AppColors.info.withValues(alpha: 0.25), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.water_drop_rounded, color: AppColors.info, size: 24.0),
                          SizedBox(width: 8.0),
                          Text(
                            'Hydration Tracking',
                            style: TextStyle(
                              fontSize: 17.0,
                              fontWeight: FontWeight.w800,
                              color: AppColors.info,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '$_dailyWaterGlasses / $_targetWaterGlasses Glasses ($waterPct%)',
                        style: const TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w700,
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14.0),

                  // Visual Glass Indicators
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: List.generate(_targetWaterGlasses, (index) {
                      final isFilled = index < _dailyWaterGlasses;
                      return Container(
                        width: 48.0,
                        height: 48.0,
                        decoration: BoxDecoration(
                          color: isFilled ? AppColors.info : Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(color: AppColors.info, width: 1.5),
                        ),
                        child: Icon(
                          Icons.local_drink_rounded,
                          color: isFilled ? Colors.white : AppColors.info.withValues(alpha: 0.5),
                          size: 26.0,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 14.0),

                  // Quick log action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.info,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                          ),
                          onPressed: () {
                            setState(() {
                              if (_dailyWaterGlasses < _targetWaterGlasses) {
                                _dailyWaterGlasses++;
                              }
                            });
                          },
                          icon: const Icon(Icons.add, size: 20),
                          label: const Text('+1 Glass Logged'),
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.info,
                          side: const BorderSide(color: AppColors.info, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                        ),
                        onPressed: () {
                          setState(() {
                            if (_dailyWaterGlasses > 0) _dailyWaterGlasses--;
                          });
                        },
                        icon: const Icon(Icons.remove, size: 18),
                        label: const Text('Undo'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // 3. COGNITIVE TRENDS CARD (LINE GRAPH WITH LARGE LEGIBLE AXES & TOOLTIPS)
  // ==========================================================================
  Widget _buildCognitiveTrendsCard(List<CognitiveSession> allSessions) {
    // Filter sessions based on selected game filter
    final filteredSessions = _selectedGameFilter == 'All'
        ? allSessions
        : allSessions
            .where((s) =>
                s.gameType.toLowerCase() == _selectedGameFilter.toLowerCase())
            .toList();

    return Card(
      elevation: 0,
      color: AppColors.surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        side: const BorderSide(color: AppColors.borderLight, width: 1.5),
      ),
      child: Padding(
        padding: AppDimensions.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                  ),
                  child: const Icon(
                    Icons.trending_up_rounded,
                    color: AppColors.primaryDark,
                    size: 26.0,
                  ),
                ),
                const SizedBox(width: 14.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Cognitive Trends',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2.0),
                      Text(
                        'Game accuracy trajectory & score trends',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18.0),

            // Game Type Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All'),
                  _buildFilterChip('Memory Match'),
                  _buildFilterChip('Remember Objects'),
                  _buildFilterChip('Sequence Memory'),
                ],
              ),
            ),
            const SizedBox(height: 20.0),

            // Clean fl_chart LineGraph
            if (filteredSessions.isEmpty)
              _buildEmptyTrendsState()
            else ...[
              // Line Chart Container with large legible axes
              SizedBox(
                height: 290.0,
                child: _buildLineGraph(filteredSessions),
              ),
              const SizedBox(height: 12.0),

              // Legend and target threshold explanation
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 16.0,
                    height: 4.0,
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark,
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  const Text(
                    'Performance Accuracy',
                    style: TextStyle(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 20.0),
                  Container(
                    width: 16.0,
                    height: 2.0,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 8.0),
                  const Text(
                    '75% Clinical Target',
                    style: TextStyle(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String gameName) {
    final isSelected = _selectedGameFilter == gameName;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(gameName),
        selected: isSelected,
        selectedColor: AppColors.primaryContainer,
        backgroundColor: AppColors.backgroundLight,
        labelStyle: TextStyle(
          fontSize: 14.0,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
        ),
        side: BorderSide(
          color: isSelected ? AppColors.primaryDark : AppColors.borderLight,
          width: 1.5,
        ),
        onSelected: (selected) {
          if (selected) {
            setState(() => _selectedGameFilter = gameName);
          }
        },
      ),
    );
  }

  /// Constructs the fl_chart LineChart with oversized, highly legible axes,
  /// clear labels, and rich touch tooltips.
  Widget _buildLineGraph(List<CognitiveSession> sessions) {
    // Sort chronologically
    final sorted = List<CognitiveSession>.from(sessions)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Take the last 7 sessions for clean spacing
    final recent = sorted.length > 7 ? sorted.sublist(sorted.length - 7) : sorted;

    final spots = <FlSpot>[];
    for (int i = 0; i < recent.length; i++) {
      spots.add(FlSpot(i.toDouble(), recent[i].accuracy));
    }

    final double maxX = (recent.length - 1).toDouble().clamp(1.0, 6.0);

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: maxX,
        minY: 40,
        maxY: 100,
        clipData: const FlClipData.none(),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 20,
          getDrawingHorizontalLine: (val) => FlLine(
            color: AppColors.borderLight.withValues(alpha: 0.6),
            strokeWidth: 1.0,
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          // Left Y-Axis (Large, bold, highly legible)
          leftTitles: AxisTitles(
            axisNameWidget: const Padding(
              padding: EdgeInsets.only(bottom: 4.0),
              child: Text(
                'Accuracy %',
                style: TextStyle(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48.0,
              interval: 20,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: Text(
                    '${value.toInt()}%',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 14.0, // Large legible font
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                );
              },
            ),
          ),
          // Bottom X-Axis (Large legible session markers)
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36.0,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx >= 0 && idx < recent.length) {
                  final date = recent[idx].timestamp;
                  final label = '${date.month}/${date.day}';
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 14.0, // Large legible font
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: const Border(
            bottom: BorderSide(color: AppColors.borderLight, width: 1.5),
            left: BorderSide(color: AppColors.borderLight, width: 1.5),
          ),
        ),
        // Baseline reference guide line at 75%
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: 75.0,
              color: AppColors.success,
              strokeWidth: 2.0,
              dashArray: [6, 4],
              label: HorizontalLineLabel(
                show: true,
                alignment: Alignment.topRight,
                padding: const EdgeInsets.only(right: 8.0, bottom: 2.0),
                style: const TextStyle(
                  color: AppColors.success,
                  fontSize: 13.0,
                  fontWeight: FontWeight.w800,
                ),
                labelResolver: (_) => 'Target 75%',
              ),
            ),
          ],
        ),
        // Line data with large dots and gradient fill
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: AppColors.primaryDark,
            barWidth: 3.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(
                radius: 6.0, // Large dot target
                color: AppColors.surfaceLight,
                strokeWidth: 2.5,
                strokeColor: AppColors.primaryDark,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primaryContainer.withValues(alpha: 0.7),
                  AppColors.primaryContainer.withValues(alpha: 0.05),
                ],
              ),
            ),
          ),
        ],
        // Rich high-contrast legible tooltip configuration
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => const Color(0xFF0F172A),
            tooltipBorder: const BorderSide(color: Color(0xFF334155), width: 1.5),
            tooltipPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((touchedSpot) {
                final idx = touchedSpot.x.toInt();
                final session = idx < recent.length ? recent[idx] : null;
                final game = session?.gameType ?? 'Session';
                return LineTooltipItem(
                  '$game\n',
                  const TextStyle(
                    color: Colors.white70,
                    fontSize: 13.0,
                    fontWeight: FontWeight.w600,
                  ),
                  children: [
                    TextSpan(
                      text: 'Accuracy: ${touchedSpot.y.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16.0, // Large, highly legible tooltip font
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                );
              }).toList();
            },
          ),
        ),
      ),
      duration: Duration.zero,
    );
  }

  Widget _buildEmptyTrendsState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36.0, horizontal: 20.0),
      alignment: Alignment.center,
      child: Column(
        children: [
          const Icon(Icons.query_stats_rounded, size: 52, color: AppColors.textMuted),
          const SizedBox(height: 12.0),
          const Text(
            'No session records found in Hive for this filter.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6.0),
          const Text(
            'Complete cognitive games in the Patient View or seed sample data.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.0, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16.0),
          ElevatedButton.icon(
            onPressed: _seedSampleOfflineData,
            icon: const Icon(Icons.add_chart_rounded),
            label: const Text('Seed Sample Analytics Data'),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // 4. RECENT SESSIONS TABLE CARD
  // ==========================================================================
  Widget _buildRecentSessionsCard(List<CognitiveSession> sessions) {
    final recent = sessions.reversed.take(6).toList();

    return Card(
      elevation: 0,
      color: AppColors.surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        side: const BorderSide(color: AppColors.borderLight, width: 1.5),
      ),
      child: Padding(
        padding: AppDimensions.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Session Activity',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${sessions.length} Recorded',
                  style: const TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14.0),

            if (recent.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'No sessions recorded yet.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingTextStyle: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14.0,
                    color: AppColors.textPrimary,
                  ),
                  dataTextStyle: const TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                  columnSpacing: 22.0,
                  columns: const [
                    DataColumn(label: Text('Game Type')),
                    DataColumn(label: Text('Accuracy')),
                    DataColumn(label: Text('Mistakes')),
                    DataColumn(label: Text('Duration')),
                    DataColumn(label: Text('Difficulty')),
                  ],
                  rows: recent.map((s) {
                    final accuracyColor = s.accuracy >= 80.0
                        ? AppColors.success
                        : (s.accuracy >= 65.0 ? AppColors.warning : AppColors.error);
                    return DataRow(
                      cells: [
                        DataCell(Text(
                          s.gameType,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        )),
                        DataCell(Text(
                          '${s.accuracy.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: accuracyColor,
                          ),
                        )),
                        DataCell(Text('${s.errorCounts}')),
                        DataCell(Text('${s.completionTimeSeconds}s')),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 4.0),
                            decoration: BoxDecoration(
                              color: s.difficulty == 'Hard'
                                  ? AppColors.errorContainer
                                  : (s.difficulty == 'Easy'
                                      ? AppColors.successContainer
                                      : AppColors.primaryContainer),
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                            child: Text(
                              s.difficulty,
                              style: TextStyle(
                                fontSize: 12.0,
                                fontWeight: FontWeight.w700,
                                color: s.difficulty == 'Hard'
                                    ? AppColors.error
                                    : (s.difficulty == 'Easy'
                                        ? AppColors.success
                                        : AppColors.primaryDark),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
