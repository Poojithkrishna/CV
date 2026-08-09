import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Thin wrapper around `flutter_local_notifications` — every module with
/// a reminder flag (Loans, Recurring Payments, Calendar tasks/events)
/// schedules through this single service rather than talking to the
/// plugin directly, so channel setup and timezone handling only happen
/// once.
class NotificationService {
  NotificationService() : _plugin = FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  static const String _channelId = 'lifeos_reminders';
  static const String _channelName = 'Reminders';
  static const String _channelDescription =
      'Due-date and event reminders for loans, bills, tasks and calendar events.';

  final StreamController<NotificationResponse> _responseController =
      StreamController<NotificationResponse>.broadcast();

  /// Emits every time a notification (or one of its action buttons) is
  /// tapped while the app process is already alive (foreground or
  /// background) — the "warm" counterpart to [initialLaunchResponse]'s
  /// cold-start case. `response.notificationResponseType` distinguishes
  /// a plain tap from an action button, and `response.actionId` names
  /// which one; see `notification_deep_link_service.dart` (routing) and
  /// `notification_action_handler.dart` (Mark done/paid, Snooze).
  Stream<NotificationResponse> get onNotificationResponse => _responseController.stream;

  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (_) {
      // Falls back to whatever `timezone` defaults to (UTC) if the
      // platform's zone can't be resolved — reminders still fire, just
      // anchored to UTC instead of local time.
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(
      const InitializationSettings(android: androidSettings),
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _responseController.add(response);
      },
    );

    final AndroidFlutterLocalNotificationsPlugin? android =
        _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.high,
      ),
    );
    await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();

    _initialized = true;
  }

  /// The response for the notification that launched the app process
  /// fresh (cold start), or `null` if the app wasn't launched that way
  /// — the counterpart to [onNotificationResponse]'s warm-tap stream.
  Future<NotificationResponse?> initialLaunchResponse() async {
    final NotificationAppLaunchDetails? details = await _plugin.getNotificationAppLaunchDetails();
    if (details == null || !details.didNotificationLaunchApp) return null;
    return details.notificationResponse;
  }

  /// Schedules a one-time reminder at [dateTime], replacing whatever was
  /// previously scheduled for [id]. A no-op if [dateTime] has already
  /// passed — never fires a reminder for a due date that's already gone
  /// by. [payload] (a `lifeos://notification/<type>/<id>` string — see
  /// `notification_deep_link.dart`) is handed back verbatim when the
  /// notification is tapped, so the app can open the entity it's about.
  /// [actions] attaches quick-action buttons (Mark done, Snooze — see
  /// `notification_actions.dart`); omit for reminder types that don't
  /// have any.
  Future<void> scheduleAt({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
    String? payload,
    List<AndroidNotificationAction>? actions,
  }) async {
    await cancel(id);
    if (!dateTime.isAfter(DateTime.now())) return;

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(dateTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          actions: actions,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // Android-only app — this only affects the iOS code path — but the
      // plugin's cross-platform API requires it regardless. `absoluteTime`
      // is correct for a fixed wall-clock `dateTime`, as opposed to
      // `wallClockTime`'s "the same clock time every day" semantics.
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  Future<void> cancel(int id) => _plugin.cancel(id);
}
