import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../constants/api_endpoints.dart';
import '../network/dio_client.dart';

part 'fcm_service.g.dart';

// ---------------------------------------------------------------------------
// Background message handler (top-level, required by FCM)
// ---------------------------------------------------------------------------

/// Must be a top-level function — annotated with @pragma for tree-shaking.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[FCM] Background message: ${message.messageId}');
  // Note: Firebase.initializeApp() should already be called in main().
}

// ---------------------------------------------------------------------------
// Local notification channel
// ---------------------------------------------------------------------------

const _kChannelId = 'money_manager_channel';
const _kChannelName = 'MoneyManager Notifications';
const _kChannelDesc = 'Notifications from MoneyManager';

// ---------------------------------------------------------------------------
// FcmService
// ---------------------------------------------------------------------------

/// Handles Firebase Cloud Messaging setup, token registration, and
/// displaying local push notifications.
class FcmService {
  FcmService(this._dio);

  final Dio _dio;

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Initialises FCM: requests permission, sets up local notifications,
  /// registers the FCM token with the backend, and wires up handlers.
  Future<void> initialize() async {
    await _setupLocalNotifications();

    // Request permissions (iOS / Android 13+)
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('[FCM] Permission: ${settings.authorizationStatus}');

    // Register background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Foreground message handler
    FirebaseMessaging.onMessage.listen(_onMessageReceived);

    // App-opened-from-notification handler
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageReceived);

    // Get and register FCM token
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await _registerToken(token);
    }

    // Listen for token refreshes
    FirebaseMessaging.instance.onTokenRefresh.listen(_registerToken);
  }

  // -------------------------------------------------------------------------
  // Message handler
  // -------------------------------------------------------------------------

  Future<void> _onMessageReceived(RemoteMessage message) async {
    debugPrint('[FCM] Message received: ${message.messageId}');
    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      _kChannelId,
      _kChannelName,
      channelDescription: _kChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'MoneyManager',
    );

    const details = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
      payload: jsonEncode(message.data),
    );
  }

  // -------------------------------------------------------------------------
  // Private helpers
  // -------------------------------------------------------------------------

  Future<void> _setupLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('[FCM] Notification tapped: ${details.payload}');
      },
    );

    // Create Android notification channel
    if (Platform.isAndroid) {
      final androidPlugin =
          _localNotifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          _kChannelId,
          _kChannelName,
          description: _kChannelDesc,
          importance: Importance.high,
        ),
      );
    }
  }

  Future<void> _registerToken(String token) async {
    try {
      await _dio.post<dynamic>(
        ApiEndpoints.userFcmToken,
        data: {'token': token, 'platform': Platform.isAndroid ? 'android' : 'ios'},
      );
      debugPrint('[FCM] Token registered: $token');
    } catch (e) {
      debugPrint('[FCM] Token registration failed: $e');
    }
  }
}

// ---------------------------------------------------------------------------
// Riverpod provider
// ---------------------------------------------------------------------------

/// Provides the [FcmService] singleton.
@Riverpod(keepAlive: true)
FcmService fcmService(Ref ref) {
  final dio = ref.watch(dioClientProvider);
  return FcmService(dio);
}
