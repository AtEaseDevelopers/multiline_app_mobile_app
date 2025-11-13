import 'package:get/get.dart';
import 'app_routes.dart';
import '../bindings/dashboard_binding.dart';
import '../bindings/supervisor_binding.dart';
import '../bindings/clock_binding.dart';
import '../bindings/clock_history_binding.dart';
import '../bindings/inspection_binding.dart';
import '../bindings/checklist_binding.dart';
import '../bindings/incident_binding.dart';
import '../bindings/history_binding.dart';
import '../bindings/notification_binding.dart';
import '../modules/splash/splash_page.dart';
import '../modules/auth/role_selection_page.dart';
import '../modules/auth/login_page.dart';
import '../modules/driver/dashboard/driver_dashboard_page.dart';
import '../modules/supervisor/dashboard/supervisor_dashboard_page.dart';
import '../modules/driver/clock/clock_page.dart';
import '../modules/driver/urgent_clock_out/urgent_clock_out_page.dart';
import '../modules/driver/clock_history/clock_history_page.dart';
import '../modules/driver/inspection/inspection_page.dart';
import '../modules/driver/checklist/daily_checklist_page.dart';
import '../modules/driver/incident/incident_page.dart';
import '../modules/driver/reports/driver_reports_page.dart';
import '../modules/driver/profile/profile_page.dart';
import '../modules/reports/reports_page.dart';
import '../modules/reports/report_detail_page.dart';
import '../modules/history/history_page.dart';
import '../modules/history/inspection_detail_page.dart' as history_inspection;
import '../modules/history/checklist_detail_page.dart' as history_checklist;
import '../modules/history/incident_detail_page.dart';
import '../modules/supervisor/review/review_list_page.dart';
import '../modules/supervisor/review/review_detail_page.dart';
import '../modules/supervisor/team/team_page.dart';
import '../modules/supervisor/reports/reports_page.dart';
import '../modules/supervisor/more/more_page.dart';
import '../modules/supervisor/inspection/inspection_detail_page.dart';
import '../modules/supervisor/checklist/checklist_detail_page.dart';
import '../modules/notifications/notification_page.dart';
import '../modules/settings/settings_page.dart';
import '../modules/app_lock/app_lock_page.dart';

class AppPages {
  static final pages = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.roleSelection,
      page: () => const RoleSelectionPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => LoginPage(
        role:
            Get.parameters['role'] ??
            (Get.arguments is String ? Get.arguments as String : 'driver'),
      ),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.driverDashboard,
      page: () => const DriverDashboardPage(),
      binding: DashboardBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.supervisorDashboard,
      page: () => const SupervisorDashboardPage(),
      binding: SupervisorBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.clockIn,
      page: () => const ClockPage(),
      binding: ClockBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.clockOut,
      page: () => const ClockPage(),
      binding: ClockBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.urgentClockOut,
      page: () => const UrgentClockOutPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.clockHistory,
      page: () => const ClockHistoryPage(),
      binding: ClockHistoryBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.inspection,
      page: () => const InspectionPage(),
      binding: InspectionBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.checklist,
      page: () => const DailyChecklistPage(),
      binding: ChecklistBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.incident,
      page: () => const IncidentPage(),
      binding: IncidentBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.driverReports,
      page: () => const DriverReportsPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.reports,
      page: () => const ReportsPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.reportDetail,
      page: () => const ReportDetailPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfilePage(),
      binding: DashboardBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.history,
      page: () => const HistoryPage(),
      binding: HistoryBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.supervisorHistory,
      page: () => const HistoryPage(),
      binding: HistoryBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.review,
      page: () => const ReviewListPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.reviewDetail,
      page: () => const ReviewDetailPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.supervisorTeam,
      page: () => const SupervisorTeamPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.supervisorReports,
      page: () => const SupervisorReportsPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.supervisorMore,
      page: () => const SupervisorMorePage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.inspectionDetail,
      page: () => const InspectionDetailPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.checklistDetail,
      page: () => const ChecklistDetailPage(),
      transition: Transition.rightToLeft,
    ),
    // History Detail Pages
    GetPage(
      name: AppRoutes.historyInspectionDetail,
      page: () => const history_inspection.InspectionDetailPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.historyChecklistDetail,
      page: () => const history_checklist.ChecklistDetailPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.historyIncidentDetail,
      page: () => const IncidentDetailPage(),
      transition: Transition.rightToLeft,
    ),
    // Notifications
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationPage(),
      binding: NotificationBinding(),
      transition: Transition.rightToLeft,
    ),
    // Settings
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsPage(),
      transition: Transition.rightToLeft,
    ),
    // App Lock
    GetPage(
      name: AppRoutes.appLock,
      page: () => const AppLockPage(),
      transition: Transition.fadeIn,
    ),
  ];
}
