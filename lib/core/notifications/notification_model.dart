import 'dart:math';
import 'dart:ui';

enum NotificationType { temporary, normal, progress, warning, error }

class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final double? progress;
  final bool isClickable;
  final VoidCallback? onClick;
  final DateTime timestamp;

  AppNotification({
    String? id,
    required this.title,
    required this.message,
    this.type = NotificationType.normal,
    this.progress,
    this.isClickable = false,
    this.onClick,
  }) : id = id ?? _generateId(),
       timestamp = DateTime.now();

  static String _generateId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    double? progress,
    bool? isClickable,
    VoidCallback? onClick,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      progress: progress ?? this.progress,
      isClickable: isClickable ?? this.isClickable,
      onClick: onClick ?? this.onClick,
    );
  }
}
