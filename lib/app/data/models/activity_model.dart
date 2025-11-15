import 'package:flutter/material.dart';

/// Activity Type Enum
enum ActivityType {
  clockIn,
  clockOut,
  inspection,
  checklist,
  incident,
  navigation,
  other,
}

/// Activity Item Model
class ActivityItem {
  final String id;
  final ActivityType type;
  final String title;
  final String description;
  final DateTime timestamp;
  final IconData icon;
  final Color color;
  final Map<String, dynamic>? metadata;

  ActivityItem({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.icon,
    required this.color,
    this.metadata,
  });

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'icon': icon.codePoint,
      'color': color.value,
      'metadata': metadata,
    };
  }

  /// Create from JSON
  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    return ActivityItem(
      id: json['id'] ?? '',
      type: ActivityType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ActivityType.other,
      ),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      icon: const IconData(
        0xe3af, // Default icon code point for circle
        fontFamily: 'MaterialIcons',
      ),
      color: const Color(0xFF2196F3), // Default blue color
      metadata: json['metadata'],
    );
  }

  /// Helper to create clock in activity
  factory ActivityItem.clockIn({
    required String vehicleNumber,
    required String meterReading,
  }) {
    return ActivityItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: ActivityType.clockIn,
      title: 'Clocked In',
      description: 'Vehicle: $vehicleNumber | Meter: $meterReading km',
      timestamp: DateTime.now(),
      icon: Icons.login,
      color: Colors.green,
      metadata: {'vehicleNumber': vehicleNumber, 'meterReading': meterReading},
    );
  }

  /// Helper to create clock out activity
  factory ActivityItem.clockOut({
    required String vehicleNumber,
    required String meterReading,
  }) {
    return ActivityItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: ActivityType.clockOut,
      title: 'Clocked Out',
      description: 'Vehicle: $vehicleNumber | Meter: $meterReading km',
      timestamp: DateTime.now(),
      icon: Icons.logout,
      color: Colors.orange,
      metadata: {'vehicleNumber': vehicleNumber, 'meterReading': meterReading},
    );
  }

  /// Helper to create inspection activity
  factory ActivityItem.inspection({
    required String vehicleNumber,
    required String status,
  }) {
    return ActivityItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: ActivityType.inspection,
      title: 'Vehicle Inspection',
      description: 'Vehicle: $vehicleNumber | Status: $status',
      timestamp: DateTime.now(),
      icon: Icons.assignment,
      color: Colors.blue,
      metadata: {'vehicleNumber': vehicleNumber, 'status': status},
    );
  }

  /// Helper to create checklist activity
  factory ActivityItem.checklist({
    required String vehicleNumber,
    required int completedItems,
    required int totalItems,
  }) {
    return ActivityItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: ActivityType.checklist,
      title: 'Daily Checklist',
      description:
          'Vehicle: $vehicleNumber | $completedItems/$totalItems items',
      timestamp: DateTime.now(),
      icon: Icons.checklist,
      color: Colors.purple,
      metadata: {
        'vehicleNumber': vehicleNumber,
        'completedItems': completedItems,
        'totalItems': totalItems,
      },
    );
  }

  /// Helper to create incident activity
  factory ActivityItem.incident({
    required String incidentType,
    required String location,
  }) {
    return ActivityItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: ActivityType.incident,
      title: 'Incident Reported',
      description: '$incidentType at $location',
      timestamp: DateTime.now(),
      icon: Icons.warning,
      color: Colors.red,
      metadata: {'incidentType': incidentType, 'location': location},
    );
  }

  /// Check if activity is today
  bool get isToday {
    final now = DateTime.now();
    return timestamp.year == now.year &&
        timestamp.month == now.month &&
        timestamp.day == now.day;
  }

  /// Get relative time string
  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  /// Get formatted time
  String get formattedTime {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
