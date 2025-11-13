/// Report Model for Driver Reports
class DriverReport {
  final String originalName; // e.g., "report_2025-10.pdf"
  final String fileSize; // e.g., "880.41 KB"
  final String fileType; // e.g., "pdf"
  final String downloadUrl; // Full download URL
  final DateTime? createdAt;

  DriverReport({
    required this.originalName,
    required this.fileSize,
    required this.fileType,
    required this.downloadUrl,
    this.createdAt,
  });

  factory DriverReport.fromJson(Map<String, dynamic> json) {
    String parseString(dynamic v) {
      if (v == null) return '';
      if (v is String) return v;
      return v.toString();
    }

    DateTime? parseDateTime(dynamic v) {
      if (v == null) return null;
      if (v is String) {
        try {
          return DateTime.parse(v.replaceAll(' ', 'T'));
        } catch (e) {
          return null;
        }
      }
      return null;
    }

    return DriverReport(
      originalName: parseString(json['original_name']),
      fileSize: parseString(json['file_size']),
      fileType: parseString(json['file_type']),
      downloadUrl: parseString(json['download_url']),
      createdAt: parseDateTime(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'original_name': originalName,
      'file_size': fileSize,
      'file_type': fileType,
      'download_url': downloadUrl,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Filename used by backend (extracted from download_url if present)
  String get fileName {
    if (downloadUrl.isNotEmpty) {
      try {
        final uri = Uri.parse(downloadUrl);
        // If the path ends with /download, take the segment before it
        final segments = uri.pathSegments;
        if (segments.isNotEmpty) {
          if (segments.last == 'download' && segments.length >= 2) {
            return segments[segments.length - 2];
          }
          return segments.last;
        }
      } catch (e) {
        // ignore
      }
    }
    return originalName;
  }

  /// Attempt to infer a friendly month/year from filename (e.g. 2025-10)
  String get formattedDate {
    final regex = RegExp(r'(\d{4})[-_](\d{1,2})');
    final match = regex.firstMatch(fileName);
    if (match != null) {
      final y = match.group(1)!;
      final m = match.group(2)!.padLeft(2, '0');
      return '$y-$m';
    }
    return '';
  }

  String get friendlyName {
    final fd = formattedDate;
    if (fd.isNotEmpty) {
      final parts = fd.split('-');
      if (parts.length == 2) {
        final year = parts[0];
        final monthNum = int.tryParse(parts[1]) ?? 0;
        const monthNames = [
          '',
          'January',
          'February',
          'March',
          'April',
          'May',
          'June',
          'July',
          'August',
          'September',
          'October',
          'November',
          'December',
        ];
        if (monthNum > 0 && monthNum <= 12) {
          return '${monthNames[monthNum]} $year Report';
        }
      }
    }
    return fileName.isNotEmpty ? fileName : originalName;
  }
}

/// Response wrapper for reports list
class DriverReportsResponse {
  final List<DriverReport> reports;
  final int driverId;
  final int count;
  final bool success;

  DriverReportsResponse({
    required this.reports,
    required this.driverId,
    required this.count,
    required this.success,
  });

  factory DriverReportsResponse.fromJson(Map<String, dynamic> json) {
    // Support multiple shapes: {data: [...], status: true} or {reports: [...], success: true}
    final List<dynamic> reportsList =
        (json['reports'] as List<dynamic>?) ??
        (json['data'] as List<dynamic>?) ??
        [];

    final reports = reportsList
        .map((item) => DriverReport.fromJson(item as Map<String, dynamic>))
        .toList();

    // Defensive extraction - handle int, String, or num types
    int extractDriverId(Map<String, dynamic> j) {
      final driverId = j['driver_id'];
      if (driverId != null) {
        if (driverId is int) return driverId;
        if (driverId is num) return driverId.toInt();
        if (driverId is String) return int.tryParse(driverId) ?? 0;
      }
      final data = j['data'];
      if (data is Map<String, dynamic> && data['driver_id'] != null) {
        final nestedId = data['driver_id'];
        if (nestedId is int) return nestedId;
        if (nestedId is num) return nestedId.toInt();
        if (nestedId is String) return int.tryParse(nestedId) ?? 0;
      }
      return 0;
    }

    int extractCount(Map<String, dynamic> j) {
      final count = j['count'];
      if (count != null) {
        if (count is int) return count;
        if (count is num) return count.toInt();
        if (count is String) return int.tryParse(count) ?? reports.length;
      }
      return reports.length;
    }

    final driverIdValue = extractDriverId(json);

    return DriverReportsResponse(
      reports: reports,
      driverId: driverIdValue,
      count: extractCount(json),
      success: json['success'] as bool? ?? json['status'] as bool? ?? false,
    );
  }
}
