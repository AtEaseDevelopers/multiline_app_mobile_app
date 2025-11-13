// Clock Status Model
class ClockStatus {
  final bool isCurrentlyClockedIn;
  final bool hasOldPendingClockOut;
  final bool canClockInToday;
  final bool showReminder;
  final String? lastClockInTime;
  final String? odometer;
  final bool canUndoClockout;
  final String? lastClockOutTime;
  final String? clockOutOdometer;
  final bool hasActiveRest;

  ClockStatus({
    required this.isCurrentlyClockedIn,
    required this.hasOldPendingClockOut,
    required this.canClockInToday,
    required this.showReminder,
    this.lastClockInTime,
    this.odometer,
    required this.canUndoClockout,
    this.lastClockOutTime,
    this.clockOutOdometer,
    required this.hasActiveRest,
  });

  factory ClockStatus.fromJson(Map<String, dynamic> json) {
    return ClockStatus(
      isCurrentlyClockedIn: json['is_currently_clocked_in'] as bool? ?? false,
      hasOldPendingClockOut:
          json['has_old_pending_clock_out'] as bool? ?? false,
      canClockInToday: json['can_clock_in_today'] as bool? ?? true,
      showReminder: json['show_reminder'] as bool? ?? false,
      lastClockInTime: json['last_clock_in_time'] as String?,
      odometer: json['odometer'] as String?,
      canUndoClockout: json['can_undo_clockout'] as bool? ?? false,
      lastClockOutTime: json['last_clock_out_time'] as String?,
      clockOutOdometer: json['clock_out_odometer'] as String?,
      hasActiveRest: json['has_active_rest'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_currently_clocked_in': isCurrentlyClockedIn,
      'has_old_pending_clock_out': hasOldPendingClockOut,
      'can_clock_in_today': canClockInToday,
      'show_reminder': showReminder,
      'last_clock_in_time': lastClockInTime,
      'odometer': odometer,
      'can_undo_clockout': canUndoClockout,
      'last_clock_out_time': lastClockOutTime,
      'clock_out_odometer': clockOutOdometer,
      'has_active_rest': hasActiveRest,
    };
  }
}

class DashboardUserData {
  final String group;
  final int userId;
  final String userName;
  final String? odoMeter;
  final String? companyName;
  final String? lorryNo;
  final int? clockinId;

  DashboardUserData({
    required this.group,
    required this.userId,
    required this.userName,
    this.odoMeter,
    this.companyName,
    this.lorryNo,
    this.clockinId,
  });

  factory DashboardUserData.fromJson(Map<String, dynamic> json) {
    return DashboardUserData(
      group: json['group'] as String? ?? '',
      userId: json['user_id'] as int? ?? 0,
      userName: json['user_name'] as String? ?? 'Driver',
      odoMeter: json['odo_meter'] as String?,
      companyName: json['company_name'] as String?,
      lorryNo: json['lorry_no'] as String?,
      clockinId: json['clockin_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'group': group,
      'user_id': userId,
      'user_name': userName,
      'odo_meter': odoMeter,
      'company_name': companyName,
      'lorry_no': lorryNo,
      'clockin_id': clockinId,
    };
  }
}

// Inspection Report Status Model
class InspectionReport {
  final bool canSubmit;
  final String lastStatus; // 'pending', 'approved', 'rejected', 'not_submitted'

  InspectionReport({required this.canSubmit, required this.lastStatus});

  factory InspectionReport.fromJson(Map<String, dynamic> json) {
    return InspectionReport(
      canSubmit: json['can_submit'] as bool? ?? true,
      lastStatus: json['last_status'] as String? ?? 'not_submitted',
    );
  }

  Map<String, dynamic> toJson() {
    return {'can_submit': canSubmit, 'last_status': lastStatus};
  }

  bool get isNotSubmitted => lastStatus == 'not_submitted';
  bool get isPending => lastStatus == 'pending';
  bool get isApproved => lastStatus == 'approved';
  bool get isRejected => lastStatus == 'rejected';
  bool get needsAttention => isNotSubmitted && canSubmit;
}

// Checklist Response Status Model
class ChecklistResponse {
  final bool canSubmit;
  final String lastStatus; // 'pending', 'approved', 'rejected', 'not_submitted'

  ChecklistResponse({required this.canSubmit, required this.lastStatus});

  factory ChecklistResponse.fromJson(Map<String, dynamic> json) {
    return ChecklistResponse(
      canSubmit: json['can_submit'] as bool? ?? true,
      lastStatus: json['last_status'] as String? ?? 'not_submitted',
    );
  }

  Map<String, dynamic> toJson() {
    return {'can_submit': canSubmit, 'last_status': lastStatus};
  }

  bool get isNotSubmitted => lastStatus == 'not_submitted';
  bool get isPending => lastStatus == 'pending';
  bool get isApproved => lastStatus == 'approved';
  bool get isRejected => lastStatus == 'rejected';
  bool get needsAttention => isNotSubmitted && canSubmit;
}

class DashboardData {
  final DashboardUserData userData;
  final ClockStatus clockStatus;
  final InspectionReport inspectionReport;
  final ChecklistResponse checklistResponse;
  final int notificationsCount;
  final bool hasActiveRest;

  DashboardData({
    required this.userData,
    required this.clockStatus,
    required this.inspectionReport,
    required this.checklistResponse,
    this.notificationsCount = 0,
    required this.hasActiveRest,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      userData: DashboardUserData.fromJson(
        json['user_data'] as Map<String, dynamic>,
      ),
      clockStatus: ClockStatus.fromJson(
        json['clock_status'] as Map<String, dynamic>,
      ),
      inspectionReport: InspectionReport.fromJson(
        json['inspection_report'] as Map<String, dynamic>? ?? {},
      ),
      checklistResponse: ChecklistResponse.fromJson(
        json['checklist_response'] as Map<String, dynamic>? ?? {},
      ),
      notificationsCount: json['notifications'] as int? ?? 0,
      hasActiveRest: json['has_active_rest'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_data': userData.toJson(),
      'clock_status': clockStatus.toJson(),
      'inspection_report': inspectionReport.toJson(),
      'checklist_response': checklistResponse.toJson(),
      'notifications': notificationsCount,
    };
  }

  // Convenience getters based on new logic
  bool get showReminder => clockStatus.showReminder;
  bool get canClockInToday => clockStatus.canClockInToday;
  bool get isCurrentlyClockedIn => clockStatus.isCurrentlyClockedIn;
  bool get hasOldPendingClockOut => clockStatus.hasOldPendingClockOut;

  // Button states based on conditions
  // Clock In button: Show only when NOT clocked in AND can clock in today
  bool get shouldShowClockInButton => !isCurrentlyClockedIn && canClockInToday;
  bool get shouldEnableClockInButton => canClockInToday;

  // Normal clock-out (current day shift)
  bool get shouldShowNormalClockOutButton =>
      isCurrentlyClockedIn && !hasOldPendingClockOut;

  // Urgent clock-out (old shift)
  bool get shouldShowUrgentClockOutButton =>
      isCurrentlyClockedIn && hasOldPendingClockOut;
}
