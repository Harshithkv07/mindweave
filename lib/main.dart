import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'screens/home_screen.dart';
import 'screens/caretaker_dashboard.dart';
import 'services/storage_service.dart';
import 'services/mindweave_provider.dart';
import 'services/reminder_service.dart';

/// Database initialization script that seeds the local Hive database
/// with default daily routines on the very first app launch without requiring
/// any external network call.
Future<void> initializeOfflineDatabase({String? subDir}) async {
  // Ensure local Hive boxes and adapters are registered
  await StorageService.init(subDir: subDir);

  // Check if routines exist; if none exist, seed default daily routines
  final existingRoutines = StorageService.getAllReminders();
  if (existingRoutines.isEmpty) {
    final now = DateTime.now();
    final defaultRoutines = [
      DailyReminder(
        id: 'routine_med_morning',
        title: 'Morning Medication',
        time: '08:00 AM',
        category: 'Medication',
        isEnabled: true,
        timestamp: now,
      ),
      DailyReminder(
        id: 'routine_water_morning',
        title: 'Morning Glass of Water',
        time: '09:00 AM',
        category: 'Hydration',
        isEnabled: true,
        timestamp: now,
      ),
      DailyReminder(
        id: 'routine_memory_game',
        title: 'Morning Memory Training Game',
        time: '10:30 AM',
        category: 'Cognitive',
        isEnabled: true,
        timestamp: now,
      ),
      DailyReminder(
        id: 'routine_water_afternoon',
        title: 'Afternoon Hydration Refresh',
        time: '02:00 PM',
        category: 'Hydration',
        isEnabled: true,
        timestamp: now,
      ),
      DailyReminder(
        id: 'routine_med_evening',
        title: 'Evening Medication',
        time: '07:30 PM',
        category: 'Medication',
        isEnabled: true,
        timestamp: now,
      ),
      DailyReminder(
        id: 'routine_relaxation',
        title: 'Evening Relaxation & Voice Check-in',
        time: '08:30 PM',
        category: 'Activity',
        isEnabled: true,
        timestamp: now,
      ),
    ];

    for (final routine in defaultRoutines) {
      await StorageService.saveReminder(routine);
    }
    debugPrint('Offline database successfully initialized and seeded with ${defaultRoutines.length} default routines.');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeOfflineDatabase();
  await ReminderService.init();
  await ReminderService.configureDefaultHydrationAlerts();
  await ReminderService.configureDefaultMedicationAlerts();
  runApp(const MindWeaveApp());
}

/// Root application widget configuring the accessibility-first theme
/// and launching the persistent navigation shell.
class MindWeaveApp extends StatelessWidget {
  const MindWeaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MindWeaveProvider>(
      create: (_) => MindWeaveProvider()..init(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MindWeave',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        home: const MainNavigationShell(),
      ),
    );
  }
}

/// Persistent navigation shell that allows seamless, instant toggling between
/// 'Patient View' and 'Caretaker View' without complex routing.
///
/// Features:
/// - High-contrast color pairings conforming to WCAG AAA.
/// - Minimum 48x48 logical pixel touch targets (56px bar items).
/// - Large, scalable typography (16sp bold labels).
/// - State preservation using IndexedStack with zero route stack complexity.
class MainNavigationShell extends StatefulWidget {
  final int initialIndex;
  final String patientName;
  final String language;

  const MainNavigationShell({
    super.key,
    this.initialIndex = 0,
    this.patientName = 'Margaret',
    this.language = 'en',
  });

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabTapped(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPatientView = _currentIndex == 0;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(
            name: widget.patientName,
            language: widget.language,
          ),
          CaretakerDashboardScreen(
            patientName: widget.patientName,
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
          border: const Border(
            top: BorderSide(
              color: AppColors.borderLight,
              width: 1.5,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                _buildNavItem(
                  index: 0,
                  label: 'Patient View',
                  icon: Icons.psychology_outlined,
                  activeIcon: Icons.psychology_rounded,
                  tooltip: 'Switch to Patient Activity & Games View',
                  isSelected: isPatientView,
                ),
                const SizedBox(width: 12.0),
                _buildNavItem(
                  index: 1,
                  label: 'Caretaker View',
                  icon: Icons.medical_services_outlined,
                  activeIcon: Icons.medical_services_rounded,
                  tooltip: 'Switch to Caretaker Analytics & Dashboard',
                  isSelected: !isPatientView,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a high-contrast, large touch target navigation item
  /// enforcing minimum 48x48 logical pixels interactive area.
  Widget _buildNavItem({
    required int index,
    required String label,
    required IconData icon,
    required IconData activeIcon,
    required String tooltip,
    required bool isSelected,
  }) {
    return Expanded(
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: () => _onTabTapped(index),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AppDimensions.standardTouchTarget, // 56.0 logical px
              minWidth: AppDimensions.minTouchTarget, // 48.0 logical px
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryContainer
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryDark
                      : AppColors.borderLight,
                  width: isSelected ? 2.0 : 1.0,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isSelected ? activeIcon : icon,
                    size: 28.0,
                    color: isSelected
                        ? AppColors.primaryDark
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8.0),
                  Flexible(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected
                            ? AppColors.primaryDark
                            : AppColors.textSecondary,
                        letterSpacing: 0.2,
                        fontFamily: 'Arial',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}