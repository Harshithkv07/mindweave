import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive/hive.dart';
import 'package:mindweave/core/theme.dart';
import 'package:mindweave/main.dart';
import 'package:mindweave/screens/home_screen.dart';
import 'package:mindweave/screens/caretaker_dashboard.dart';
import 'package:mindweave/services/mindweave_provider.dart';
import 'package:mindweave/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('theme_nav_test_');
    await StorageService.init(subDir: tempDir.path);
    await StorageService.saveSession(
      CognitiveSession(
        id: 'test_session_1',
        gameType: 'Memory Match',
        timestamp: DateTime.now(),
        errorCounts: 1,
        completionTimeSeconds: 40,
        accuracy: 92.0,
        attempts: 8,
      ),
    );
  });

  tearDownAll(() async {
    try {
      await Hive.close();
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    } catch (_) {}
  });
  group('Accessibility-First Theme & AppDimensions', () {
    test('AppDimensions enforces minimum 48x48 logical pixel touch targets', () {
      expect(AppDimensions.minTouchTarget, equals(48.0));
      expect(AppDimensions.standardTouchTarget, greaterThanOrEqualTo(48.0));
      expect(AppDimensions.minLegibleFontSize, greaterThanOrEqualTo(14.0));
    });

    test('AppTheme enforces high-contrast colors and large scalable typography', () {
      final lightTheme = AppTheme.lightTheme;

      // Color contrast validation
      expect(lightTheme.colorScheme.primary, equals(AppColors.primaryDark));
      expect(lightTheme.scaffoldBackgroundColor, equals(AppColors.backgroundLight));
      expect(lightTheme.colorScheme.surface, equals(AppColors.surfaceLight));

      // Scalable typography validation
      expect(lightTheme.textTheme.bodyLarge?.fontSize, greaterThanOrEqualTo(18.0));
      expect(lightTheme.textTheme.bodyMedium?.fontSize, greaterThanOrEqualTo(16.0));
      expect(lightTheme.textTheme.labelLarge?.fontSize, greaterThanOrEqualTo(16.0));
      expect(lightTheme.textTheme.headlineMedium?.fontWeight, equals(FontWeight.w700));

      // Button minimum touch targets
      final elevatedStyle = lightTheme.elevatedButtonTheme.style;
      final minSize = elevatedStyle?.minimumSize?.resolve({});
      expect(minSize?.width, greaterThanOrEqualTo(48.0));
      expect(minSize?.height, greaterThanOrEqualTo(48.0));
    });
  });

  group('Persistent Navigation Shell Seamless Toggling', () {
    testWidgets('Toggles between Patient View and Caretaker View seamlessly',
        (WidgetTester tester) async {
      // Build the application inside a Provider tree
      await tester.pumpWidget(
        ChangeNotifierProvider<MindWeaveProvider>(
          create: (_) => MindWeaveProvider(),
          child: const MaterialApp(
            home: MainNavigationShell(),
          ),
        ),
      );

      await tester.pump();

      // Verify persistent navigation bar items exist
      expect(find.text('Patient View'), findsOneWidget);
      expect(find.text('Caretaker View'), findsOneWidget);

      // Verify Patient View is visible initially
      expect(find.byIcon(Icons.psychology_rounded), findsOneWidget);

      // Tap Caretaker View in the bottom navigation bar
      await tester.tap(find.text('Caretaker View'));
      await tester.pump();

      // Verify Caretaker View is now active
      expect(find.byIcon(Icons.medical_services_rounded), findsOneWidget);

      // Toggle back to Patient View seamlessly
      await tester.tap(find.text('Patient View'));
      await tester.pump();

      // Verify back on Patient View
      expect(find.byIcon(Icons.psychology_rounded), findsOneWidget);
    });
  });

  group('Patient Dashboard 2x2 Oversized Grid Simplicity', () {
    testWidgets('Renders 2x2 grid with 4 massive cards and handles interactions',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(
            name: 'Margaret',
            language: 'en-US',
          ),
        ),
      );

      await tester.pump();

      // Verify 2x2 GridView exists
      expect(find.byType(GridView), findsOneWidget);

      // Verify all 4 distinct, large cards exist with single bold text labels
      expect(find.text('Memory Games'), findsOneWidget);
      expect(find.text('Medication'), findsOneWidget);
      expect(find.text('Hydration'), findsOneWidget);
      expect(find.text('Voice Assistant'), findsOneWidget);

      // Verify massive universally understood icons are present
      expect(find.byIcon(Icons.extension_rounded), findsOneWidget);
      expect(find.byIcon(Icons.medication_rounded), findsOneWidget);
      expect(find.byIcon(Icons.water_drop_rounded), findsOneWidget);
      expect(find.byIcon(Icons.record_voice_over_rounded), findsOneWidget);

      // Tap Medication card and verify accessible reminder dialog opens
      await tester.tap(find.text('Medication'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('I Took It'), findsOneWidget);

      // Dismiss dialog
      await tester.tap(find.text('I Took It'));
      await tester.pumpAndSettle();

      // Tap Hydration card and verify accessible reminder dialog opens
      await tester.ensureVisible(find.text('Hydration'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hydration'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Drank Water'), findsOneWidget);

      // Dismiss dialog
      await tester.tap(find.text('Drank Water'));
      await tester.pumpAndSettle();
    });
  });

  group('Caretaker Analytics Dashboard Card-Based Layout & Charts', () {
    testWidgets('Renders Daily Adherence, Cognitive Trends with LineChart and controls',
        (WidgetTester tester) async {
      final provider = MindWeaveProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider<MindWeaveProvider>.value(
          value: provider,
          child: const MaterialApp(
            home: CaretakerDashboardScreen(patientName: 'Margaret'),
          ),
        ),
      );

      await tester.pump();

      // Verify Card-based ListView exists
      expect(find.byType(ListView), findsOneWidget);

      // Verify distinct sections: 'Daily Adherence' and 'Cognitive Trends'
      expect(find.text('Daily Adherence'), findsOneWidget);
      expect(find.text('Medication Adherence'), findsOneWidget);
      expect(find.text('Hydration Tracking'), findsOneWidget);

      // Verify Quick-Log hydration button interactions
      expect(find.text('+1 Glass Logged'), findsOneWidget);
      await tester.ensureVisible(find.text('+1 Glass Logged'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('+1 Glass Logged'));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('6 / 8 Glasses (75%)'), findsOneWidget);

      // Scroll down to Cognitive Trends in ListView
      await tester.drag(find.byType(ListView), const Offset(0, -350));
      await tester.pump();
      expect(find.text('Cognitive Trends'), findsOneWidget);

      // Verify fl_chart LineChart renders for game performance
      expect(find.byType(LineChart), findsOneWidget);
    });
  });

  group('Offline Standalone Package Initialization', () {
    test('initializeOfflineDatabase seeds default daily routines without network calls', () async {
      final tempDir = await Directory.systemTemp.createTemp('offline_db_init_test_');
      try {
        await initializeOfflineDatabase(subDir: tempDir.path);

        final reminders = StorageService.getAllReminders();
        expect(reminders.isNotEmpty, isTrue);

        final titles = reminders.map((r) => r.title).toList();
        expect(titles.any((t) => t.contains('Medication')), isTrue);
        expect(titles.any((t) => t.contains('Water') || t.contains('Hydration')), isTrue);
      } finally {
        try {
          await Hive.close();
          if (tempDir.existsSync()) {
            await tempDir.delete(recursive: true);
          }
        } catch (_) {}
      }
    });
  });
}
