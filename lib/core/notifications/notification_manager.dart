import 'dart:async';
import 'package:flutter/material.dart';
import 'notification_model.dart';

class NotificationManager {
  NotificationManager._();

  static final NotificationManager _instance = NotificationManager._();
  static NotificationManager get instance => _instance;

  final List<AppNotification> _notifications = [];
  final List<AppNotification> _popups = [];
  final List<VoidCallback> _listeners = [];
  final List<VoidCallback> _popupListeners = [];

  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  List<AppNotification> get popups => List.unmodifiable(_popups);

  void addListener(VoidCallback listener) => _listeners.add(listener);
  void removeListener(VoidCallback listener) => _listeners.remove(listener);
  void addPopupListener(VoidCallback listener) => _popupListeners.add(listener);
  void removePopupListener(VoidCallback listener) =>
      _popupListeners.remove(listener);

  void _notify() {
    for (final listener in _listeners) {
      listener();
    }
  }

  void _notifyPopups() {
    for (final listener in _popupListeners) {
      listener();
    }
  }

  static void show(AppNotification notification) {
    _instance._popups.add(notification);
    _instance._notifyPopups();

    Timer(const Duration(seconds: 5), () {
      _instance._popups.removeWhere((n) => n.id == notification.id);
      _instance._notifyPopups();
    });

    if (notification.type != NotificationType.temporary) {
      _instance._notifications.insert(0, notification);
      _instance._notify();
    }
  }

  static void updateProgress(String id, double progress) {
    final index = _instance._notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      final old = _instance._notifications[index];
      _instance._notifications[index] = old.copyWith(progress: progress);
      _instance._notify();
    }

    final popupIndex = _instance._popups.indexWhere((n) => n.id == id);
    if (popupIndex != -1) {
      final old = _instance._popups[popupIndex];
      _instance._popups[popupIndex] = old.copyWith(progress: progress);
      _instance._notifyPopups();
    }
  }

  static void dismiss(String id) {
    _instance._notifications.removeWhere((n) => n.id == id);
    _instance._popups.removeWhere((n) => n.id == id);
    _instance._notify();
    _instance._notifyPopups();
  }

  static void dismissPopup(String id) {
    _instance._popups.removeWhere((n) => n.id == id);
    _instance._notifyPopups();
  }

  static void clearAll() {
    _instance._notifications.clear();
    _instance._notify();
  }

  static int get unreadCount => _instance._notifications.length;
}
