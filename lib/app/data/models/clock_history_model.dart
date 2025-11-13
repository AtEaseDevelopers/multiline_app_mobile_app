/// Rest Time Model - Individual rest period
class RestTime {
  final int id;
  final String restStart;
  final String? restEnd;
  final int durationMinutes;
  final String? notes;

  RestTime({
    required this.id,
    required this.restStart,
    this.restEnd,
    required this.durationMinutes,
    this.notes,
  });

  factory RestTime.fromJson(Map<String, dynamic> json) {
    // Parse duration_minutes - can be null, int, or string
    int parsedDuration = 0;
    final durationValue = json['duration_minutes'];
    if (durationValue != null) {
      if (durationValue is int) {
        parsedDuration = durationValue;
      } else if (durationValue is String) {
        parsedDuration = int.tryParse(durationValue) ?? 0;
      }
    }

    return RestTime(
      id: json['id'] as int? ?? 0,
      restStart: json['rest_start'] as String? ?? '',
      restEnd: json['rest_end'] as String?,
      durationMinutes: parsedDuration,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rest_start': restStart,
      'rest_end': restEnd,
      'duration_minutes': durationMinutes,
      'notes': notes,
    };
  }

  // Helper getter for active rest
  bool get isActive => restEnd == null || restEnd!.isEmpty;
}

/// Rest History Model - Collection of rest times
class RestHistory {
  final List<RestTime> restTimes;
  final int totalRestMinutes;

  RestHistory({required this.restTimes, required this.totalRestMinutes});

  factory RestHistory.fromJson(Map<String, dynamic> json) {
    // Parse total_rest_minutes - can be int or string
    int parsedTotal = 0;
    final totalValue = json['total_rest_minutes'];
    if (totalValue != null) {
      if (totalValue is int) {
        parsedTotal = totalValue;
      } else if (totalValue is String) {
        parsedTotal = int.tryParse(totalValue) ?? 0;
      }
    }

    return RestHistory(
      restTimes:
          (json['rest_times'] as List<dynamic>?)
              ?.map((item) => RestTime.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      totalRestMinutes: parsedTotal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rest_times': restTimes.map((item) => item.toJson()).toList(),
      'total_rest_minutes': totalRestMinutes,
    };
  }

  // Helper getters
  bool get hasRestTimes => restTimes.isNotEmpty;
  int get restCount => restTimes.length;
}

/// Clock History Models
class ClockHistoryItem {
  final int id;
  final String date;
  final String clockInTime;
  final String clockOutTime;
  final String vehicleNumber;
  final String duration;
  final String status;
  final bool isToday;
  final String clockInMeterReading;
  final String clockOutMeterReading;
  final RestHistory? restHistory;

  ClockHistoryItem({
    required this.id,
    required this.date,
    required this.clockInTime,
    required this.clockOutTime,
    required this.vehicleNumber,
    required this.duration,
    required this.status,
    required this.isToday,
    required this.clockInMeterReading,
    required this.clockOutMeterReading,
    this.restHistory,
  });

  factory ClockHistoryItem.fromJson(Map<String, dynamic> json) {
    return ClockHistoryItem(
      id: json['id'] as int? ?? 0,
      date: json['date'] as String? ?? '',
      clockInTime: json['clock_in_time'] as String? ?? '',
      clockOutTime: json['clock_out_time'] as String? ?? '',
      vehicleNumber: json['vehicle_number'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      status: json['status'] as String? ?? '',
      isToday: json['is_today'] as bool? ?? false,
      clockInMeterReading: json['clock_in_meter_reading'] as String? ?? '',
      clockOutMeterReading: json['clock_out_meter_reading'] as String? ?? '',
      restHistory: json['rest_history'] != null
          ? RestHistory.fromJson(json['rest_history'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'clock_in_time': clockInTime,
      'clock_out_time': clockOutTime,
      'vehicle_number': vehicleNumber,
      'duration': duration,
      'status': status,
      'is_today': isToday,
      'clock_in_meter_reading': clockInMeterReading,
      'clock_out_meter_reading': clockOutMeterReading,
      'rest_history': restHistory?.toJson(),
    };
  }

  // Status getters
  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isOngoing => status.toLowerCase() == 'ongoing';

  // Rest history getters
  bool get hasRestHistory => restHistory != null && restHistory!.hasRestTimes;
}

class ClockHistoryData {
  final List<ClockHistoryItem> clockHistory;
  final int currentPage;
  final int totalPages;
  final int totalRecords;
  final bool hasMore;

  ClockHistoryData({
    required this.clockHistory,
    required this.currentPage,
    required this.totalPages,
    required this.totalRecords,
    required this.hasMore,
  });

  factory ClockHistoryData.fromJson(Map<String, dynamic> json) {
    return ClockHistoryData(
      clockHistory:
          (json['clock_history'] as List<dynamic>?)
              ?.map(
                (item) =>
                    ClockHistoryItem.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
      currentPage: json['current_page'] as int? ?? 1,
      totalPages: json['total_pages'] as int? ?? 1,
      totalRecords: json['total_records'] as int? ?? 0,
      hasMore: json['has_more'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clock_history': clockHistory.map((item) => item.toJson()).toList(),
      'current_page': currentPage,
      'total_pages': totalPages,
      'total_records': totalRecords,
      'has_more': hasMore,
    };
  }
}
