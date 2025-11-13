class ApiConstants {
  // Base URL
  static const String baseUrl = 'http://app.multiline.site/api/';

  // Auth Endpoints
  static const String login = 'login';
  static const String logout = 'logout';

  // Driver Endpoints
  static const String getLorries = 'get-lorries';
  static const String clockIn = 'clock-in';
  static const String clockOut = 'clock-out';
  static const String undoClockOut = 'undo-clock-out';
  static const String driverDashboard = 'driver/dashboard';
  static const String clockHistory = 'driver/clock-history';
  static const String restStart = 'rest/start';
  static const String restEnd = 'rest/end';

  // Inspection Endpoints
  static const String inspectionVehicleCheck = 'inspection-vehicle-check';
  static const String inspectionSubmit = 'inspection-vehicle-check-submit';

  // Incident Endpoints
  static const String incidentReportTypes = 'incident-report-types';
  static const String incidentReportSubmit = 'incident-report-submit';

  // Daily Checklist
  static const String dailyChecklist = 'daily-checklist';
  static const String dailyChecklistSubmit = 'daily-checklist-submit';

  // Supervisor Endpoints
  static const String supervisorDashboard = 'supervisor/dashboard';
  static const String approveList = 'approve-list';
  static const String rejectList = 'reject-list';

  // History Endpoints
  static const String driverHistory = 'driver/history';
  static const String supervisorHistory = 'supervisor/history';
  static const String driverInspectionDetails = 'driver/inspection-details';
  static const String driverChecklistDetails = 'driver/checklist-details';
  static const String driverIncidentDetails = 'driver/incident-details';

  // Report Endpoints
  static const String driverReports = 'drivers'; // drivers/{id}/reports
  static const String driverReportDownload =
      'drivers'; // drivers/{id}/reports/driver_report_{id}_{date}.pdf/download

  // Dashboard
  static const String dashboard = 'dashboard';

  // Notification Endpoints
  static const String notifications = 'notifications';
  static const String notificationsReadAll = 'notifications/read-all';
  static const String notificationMarkAsRead =
      'notifications'; // notifications/{id}/read
}
