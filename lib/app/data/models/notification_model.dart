class NotificationItem {
  final int id;
  final bool isRead;
  final String title;
  final String message;
  final String type;
  final String? expiryDate;
  final String createdAt;

  NotificationItem({
    required this.id,
    required this.isRead,
    required this.title,
    required this.message,
    required this.type,
    this.expiryDate,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as int,
      isRead: (json['is_read'] as int? ?? 0) == 1,
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      type: json['type'] as String? ?? '',
      expiryDate: json['expiry_date'] as String?,
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'is_read': isRead ? 1 : 0,
      'title': title,
      'message': message,
      'type': type,
      'expiry_date': expiryDate,
      'created_at': createdAt,
    };
  }

  // Helper to get formatted date
  String get formattedDate {
    try {
      final dateTime = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    } catch (e) {
      return '';
    }
  }

  // Helper to get notification icon based on type
  String get icon {
    switch (type) {
      case 'license_expiry':
        return '🪪';
      case 'gdl_expiry':
        return '📋';
      case 'inspection':
        return '🔍';
      case 'checklist':
        return '✅';
      case 'incident':
        return '⚠️';
      default:
        return '📢';
    }
  }
}

class NotificationsResponse {
  final bool success;
  final List<NotificationItem> notifications;
  final int unreadCount;

  NotificationsResponse({
    required this.success,
    required this.notifications,
    required this.unreadCount,
  });

  factory NotificationsResponse.fromJson(Map<String, dynamic> json) {
    return NotificationsResponse(
      success: json['success'] as bool? ?? false,
      notifications:
          (json['notifications'] as List<dynamic>?)
              ?.map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      unreadCount: json['unread_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'notifications': notifications.map((e) => e.toJson()).toList(),
      'unread_count': unreadCount,
    };
  }
}
