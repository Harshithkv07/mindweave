import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'storage_service.dart';

/// ReminderService manages offline scheduled notifications using flutter_local_notifications.
/// Operates entirely locally without internet connectivity for hydration, medication,
/// and cognitive training routines.
class ReminderService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  // Notification channel constants
  static const String medicationChannelId = 'mindweave_medication';
  static const String medicationChannelName = 'Medication Reminders';
  static const String medicationChannelDesc =
      'Essential scheduled medication alerts for patients and caregivers';

  static const String hydrationChannelId = 'mindweave_hydration';
  static const String hydrationChannelName = 'Hydration Alerts';
  static const String hydrationChannelDesc =
      'Gentle hydration check-in notifications throughout the day';

  static const String generalChannelId = 'mindweave_general';
  static const String generalChannelName = 'General Care Reminders';
  static const String generalChannelDesc =
      'Cognitive routine and daily wellness alerts';

  /// Initializes the local notification plugin across platforms and prepares timezone data.
  static Future<void> init() async {
    if (_isInitialized) return;

    try {
      tz.initializeTimeZones();

      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const linuxSettings = LinuxInitializationSettings(
        defaultActionName: 'Open MindWeave',
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
        linux: linuxSettings,
      );

      await _notificationsPlugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint(
              'ReminderService: Notification tapped with payload: ${response.payload}');
        },
      );

      await requestPermissions();

      _isInitialized = true;
      debugPrint('ReminderService: Initialized successfully (offline-first).');
    } catch (e, stack) {
      debugPrint('ReminderService initialization failed: $e\n$stack');
    }
  }

  /// Requests notification permissions where necessary (iOS, macOS, Android 13+).
  static Future<void> requestPermissions() async {
    try {
      final androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
      }

      final iosImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      if (iosImplementation != null) {
        await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      final macosImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>();
      if (macosImplementation != null) {
        await macosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      }
    } catch (e) {
      debugPrint('ReminderService: Error requesting permissions: $e');
    }
  }

  /// Displays an instant notification immediately without network access.
  static Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String channelId = generalChannelId,
    String channelName = generalChannelName,
    String channelDesc = generalChannelDesc,
  }) async {
    await _ensureInitialized();

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDesc,
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    await _notificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: payload,
    );
  }

  /// Schedules a repeating daily notification at a specific hour and minute offline.
  static Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
    String channelId = generalChannelId,
    String channelName = generalChannelName,
    String channelDesc = generalChannelDesc,
  }) async {
    await _ensureInitialized();

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    final scheduledDate = _nextInstanceOfTime(hour, minute);

    try {
      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );
      debugPrint(
          'ReminderService: Scheduled daily alert [$id] "$title" for $hour:${minute.toString().padLeft(2, '0')}');
    } catch (e) {
      debugPrint('ReminderService: Failed exact zoned schedule ($e). Falling back to non-exact schedule.');
      try {
        await _notificationsPlugin.zonedSchedule(
          id: id,
          title: title,
          body: body,
          scheduledDate: scheduledDate,
          notificationDetails: notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexact,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: payload,
        );
      } catch (inner) {
        debugPrint('ReminderService: Fallback scheduling failed: $inner');
      }
    }
  }

  /// Configures default offline daily alerts for hydration (10:00 AM, 02:00 PM, 05:00 PM).
  static Future<void> configureDefaultHydrationAlerts() async {
    await scheduleDailyNotification(
      id: 101,
      title: '💧 Hydration Time',
      body: 'Time for a fresh glass of water to keep your body and mind refreshed.',
      hour: 10,
      minute: 0,
      channelId: hydrationChannelId,
      channelName: hydrationChannelName,
      channelDesc: hydrationChannelDesc,
    );

    await scheduleDailyNotification(
      id: 102,
      title: '💧 Midday Hydration',
      body: 'Remember to drink some water with your afternoon meal or snack.',
      hour: 14,
      minute: 0,
      channelId: hydrationChannelId,
      channelName: hydrationChannelName,
      channelDesc: hydrationChannelDesc,
    );

    await scheduleDailyNotification(
      id: 103,
      title: '💧 Evening Hydration',
      body: 'Stay comfortable and hydrated with a warm drink or glass of water.',
      hour: 17,
      minute: 30,
      channelId: hydrationChannelId,
      channelName: hydrationChannelName,
      channelDesc: hydrationChannelDesc,
    );
  }

  /// Configures default offline daily alerts for medication (08:30 AM, 08:00 PM).
  static Future<void> configureDefaultMedicationAlerts() async {
    await scheduleDailyNotification(
      id: 201,
      title: '💊 Morning Medication Alert',
      body: 'Good morning! Please take your prescribed morning medication with water.',
      hour: 8,
      minute: 30,
      channelId: medicationChannelId,
      channelName: medicationChannelName,
      channelDesc: medicationChannelDesc,
    );

    await scheduleDailyNotification(
      id: 202,
      title: '💊 Evening Medication Alert',
      body: 'Time for your evening medications before winding down for bed.',
      hour: 20,
      minute: 0,
      channelId: medicationChannelId,
      channelName: medicationChannelName,
      channelDesc: medicationChannelDesc,
    );
  }

  /// Syncs scheduled local notifications with active Hive reminders from StorageService.
  static Future<void> syncWithHiveReminders() async {
    await _ensureInitialized();
    final reminders = StorageService.getAllReminders();

    for (final rem in reminders) {
      final id = rem.id.hashCode.abs() % 10000;
      if (!rem.isEnabled) {
        await cancelNotification(id);
        continue;
      }

      // Parse time string e.g. "08:30 AM"
      final parsed = _parseTimeString(rem.time);
      final channel = rem.category.toLowerCase().contains('med')
          ? medicationChannelId
          : rem.category.toLowerCase().contains('hydra')
              ? hydrationChannelId
              : generalChannelId;

      await scheduleDailyNotification(
        id: id,
        title: '${_getCategoryEmoji(rem.category)} ${rem.title}',
        body: 'Scheduled care routine reminder (${rem.time})',
        hour: parsed.$1,
        minute: parsed.$2,
        channelId: channel,
      );
    }
  }

  /// Cancels a specific notification by id.
  static Future<void> cancelNotification(int id) async {
    await _ensureInitialized();
    await _notificationsPlugin.cancel(id: id);
  }

  /// Cancels all scheduled and active notifications.
  static Future<void> cancelAllNotifications() async {
    await _ensureInitialized();
    await _notificationsPlugin.cancelAll();
  }

  // --------------------------------------------------------------------------
  // Helper calculations
  // --------------------------------------------------------------------------

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  static (int, int) _parseTimeString(String timeStr) {
    try {
      final parts = timeStr.trim().split(' ');
      final hm = parts[0].split(':');
      var hour = int.parse(hm[0]);
      final minute = int.parse(hm[1]);

      if (parts.length > 1) {
        final isPm = parts[1].toUpperCase() == 'PM';
        if (isPm && hour < 12) hour += 12;
        if (!isPm && hour == 12) hour = 0;
      }
      return (hour, minute);
    } catch (_) {
      return (9, 0); // fallback 09:00 AM
    }
  }

  static String _getCategoryEmoji(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('med')) return '💊';
    if (cat.contains('hydra') || cat.contains('water')) return '💧';
    if (cat.contains('cognit') || cat.contains('brain')) return '🧠';
    if (cat.contains('walk') || cat.contains('activ')) return '🚶';
    return '⏰';
  }

  static Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await init();
    }
  }
}
