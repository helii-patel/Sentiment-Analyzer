import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Simple local notifications wrapper so we can fire a login success alert.
class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  static const String _firstLaunchKey = 'first_launch_notification_shown';

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'login_events',
    'Login Events',
    description: 'Notifications related to authentication events',
    importance: Importance.high,
  );

  static NotificationDetails _notificationDetails() {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        channelDescription: _channel.description,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
    );
  }

  /// Call once during app startup.
  static Future<void> init() async {
    if (_initialized) return;
    if (kIsWeb) {
      _initialized = true; // No-op on web (plugin unsupported)
      return;
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    // Permissions for Android 13+ and iOS.
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    debugPrint('NotificationService initialized');
    _initialized = true;
  }

  static Future<bool> requestPermission() async {
    if (!_initialized) {
      await init();
    }
    if (kIsWeb) return false;

    final androidResult = await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    final iosResult = await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    return androidResult ?? iosResult ?? true;
  }

  static Future<void> showTestNotification() async {
    if (!_initialized) {
      await init();
    }
    if (kIsWeb) return;

    await _plugin.show(
      999,
      'Notifications are working',
      'You will now receive SentimentPro alerts on this device.',
      _notificationDetails(),
    );
  }

  static Future<void> showLoginSuccess({String? email}) async {
    if (!_initialized) {
      await init();
    }
    if (kIsWeb) return; // Skip on web

    await _plugin.show(
      1,
      'Login successful',
      email == null
          ? 'Welcome back to SentimentPro!'
          : 'Welcome back, $email',
      _notificationDetails(),
    );
    debugPrint('Login success notification posted for ${email ?? "unknown"}');
  }

  static Future<void> showInstallSuccessOnFirstLaunch() async {
    if (!_initialized) {
      await init();
    }
    if (kIsWeb) return;

    final prefs = await SharedPreferences.getInstance();
    final alreadyShown = prefs.getBool(_firstLaunchKey) ?? false;
    if (alreadyShown) return;

    await _plugin.show(
      2,
      'SentimentPro installed',
      'SentimentPro Analyzer is ready to use on your phone.',
      _notificationDetails(),
    );
    debugPrint('First-launch install notification posted');

    await prefs.setBool(_firstLaunchKey, true);
  }

}
