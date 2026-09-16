import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'screens/profile_select_screen.dart';
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
/// and launching the profile picker.
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
        home: const ProfileSelectScreen(),
      ),
    );
  }
}