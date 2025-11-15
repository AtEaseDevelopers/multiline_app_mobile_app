class SKeys {
  // Common
  static const ok = 'ok';
  static const cancel = 'cancel';
  static const tryAgain = 'try_again';
  static const offline = 'offline';
  static const dataWillSync = 'data_will_sync';

  // Splash & Role
  static const appName = 'app_name';
  static const selectYourRole = 'select_your_role';
  static const driver = 'driver';
  static const supervisor = 'supervisor';
  static const language = 'language';
  static const driverDesc = 'driver_desc';
  static const supervisorDesc = 'supervisor_desc';

  // Login
  static const login = 'login';
  static const emailOrId = 'email_or_id';
  static const password = 'password';
  static const rememberMe = 'remember_me';
  static const forgotPassword = 'forgot_password';
  static const biometricLogin = 'biometric_login';
  static const emailOrIdHint = 'email_or_id_hint';
  static const passwordHint = 'password_hint';

  // Dashboard Driver
  static const hi = 'hi';
  static const vehicle = 'vehicle';
  static const company = 'company';
  static const group = 'group';
  static const todaysStatus = 'todays_status';
  static const notClockedIn = 'not_clocked_in';
  static const clockedIn = 'clocked_in';
  static const workHours = 'work_hours';
  static const clockIn = 'clock_in';
  static const clockOut = 'clock_out';
  static const startYourDay = 'start_your_day';
  static const endYourDay = 'end_your_day';
  static const check = 'check';
  static const report = 'report';
  static const view = 'view';
  static const vehicleInspectionShort = 'vehicle_inspection_short';
  static const incidentReportShort = 'incident_report_short';
  static const dailyChecklistShort = 'daily_checklist_short';
  static const recentActivities = 'recent_activities';
  static const quickActions = 'quick_actions';
  static const viewRecords = 'view_records';
  static const backendReports = 'backend_reports';

  // Clock In/Out
  static const currentLocation = 'current_location';
  static const refreshLocation = 'refresh_location';
  static const odometerReading = 'odometer_reading';
  static const km = 'km';
  static const dashboardPhoto = 'dashboard_photo';
  static const notesOptional = 'notes_optional';
  static const confirmClockIn = 'confirm_clock_in';
  static const confirmClockOut = 'confirm_clock_out';

  // Inspection
  static const vehicleInspection = 'vehicle_inspection';
  static const progress = 'progress';
  static const saveDraft = 'save_draft';
  static const continueNext = 'continue_next';

  // Checklist
  static const dailyChecklist = 'daily_checklist';
  static const submit = 'submit';

  // Incident
  static const reportIncident = 'report_incident';
  static const incidentType = 'incident_type';
  static const date = 'date';
  static const time = 'time';
  static const location = 'location';
  static const description = 'description';
  static const photoEvidence = 'photo_evidence';
  static const severity = 'severity';
  static const emergencyPlan = 'emergency_plan';
  static const submitReport = 'submit_report';

  // Supervisor
  static const pendingReviews = 'pending_reviews';
  static const todaysStats = 'todays_stats';
  static const teamStatus = 'team_status';
  static const approve = 'approve';
  static const reject = 'reject';
  static const approved = 'approved';
  static const rejected = 'rejected';
  static const total = 'total';
  static const tapToReview = 'tap_to_review';

  // Errors/Empty
  static const somethingWentWrong = 'something_went_wrong';
  static const noItemsFound = 'no_items_found';
  static const pullToRefresh = 'pull_to_refresh';

  // Bottom navigation
  static const navHome = 'nav_home';
  static const navInspect = 'nav_inspect';
  static const navReport = 'nav_report';
  static const navMe = 'nav_me';
  static const navReview = 'nav_review';
  static const navTeam = 'nav_team';
  static const navReports = 'nav_reports';
  static const navMore = 'nav_more';
  static const status = 'status';
  // Misc
  static const settings = 'settings';
  static const helpSupport = 'help_support';
  static const incidentsSummary = 'incidents_summary';
  static const inspectionsSummary = 'inspections_summary';

  // Common Actions & Buttons
  static const retry = 'retry';
  static const loading = 'loading';
  static const markAllRead = 'mark_all_read';
  static const unlock = 'unlock';
  static const yes = 'yes';
  static const no = 'no';
  static const save = 'save';
  static const back = 'back';
  static const close = 'close';
  static const openSettings = 'open_settings';
  static const downloadAgain = 'download_again';

  // Messages & Notifications
  static const permissionRequired = 'permission_required';
  static const fileExists = 'file_exists';
  static const noDataAvailable = 'no_data_available';
  static const noReports = 'no_reports';
  static const loadingReports = 'loading_reports';
  static const initializingPdfViewer = 'initializing_pdf_viewer';
  static const loadingReport = 'loading_report';
  static const noPdfViewer = 'no_pdf_viewer';
  static const fileLocation = 'file_location';
  static const yourReportSaved = 'your_report_saved';
  static const showLocation = 'show_location';
  static const failedToLoadImage = 'failed_to_load_image';

  // Clock History
  static const clockHistory = 'clock_history';
  static const records = 'records';
  static const noClockHistory = 'no_clock_history';
  static const clockHistoryDesc = 'clock_history_desc';
  static const viewClockHistory = 'view_clock_history';

  // Rest Time
  static const takeRest = 'take_rest';
  static const backToWork = 'back_to_work';
  static const restBreak = 'rest_break';
  static const restBreakDesc = 'rest_break_desc';
  static const startRest = 'start_rest';
  static const endRest = 'end_rest';
  static const currentlyOnRest = 'currently_on_rest';
  static const onRestDesc = 'on_rest_desc';
  static const backToWorkConfirm = 'back_to_work_confirm';
  static const restNotes = 'rest_notes';

  // History & Details
  static const history = 'history';
  static const viewHistory = 'view_history';
  static const historyDesc = 'history_desc';
  static const checklistDetails = 'checklist_details';
  static const incidentDetails = 'incident_details';
  static const inspectionDetails = 'inspection_details';

  // Approval/Rejection
  static const approveChecklist = 'approve_checklist';
  static const rejectChecklist = 'reject_checklist';
  static const approveInspection = 'approve_inspection';
  static const rejectInspection = 'reject_inspection';
  static const approveConfirm = 'approve_confirm';
  static const rejectReason = 'reject_reason';
  static const provideReason = 'provide_reason';
  static const addOptionalNotes = 'add_optional_notes';

  // Photo & Media
  static const selectPhotoSource = 'select_photo_source';
  static const camera = 'camera';
  static const gallery = 'gallery';
  static const addPhoto = 'add_photo';
  static const takePhoto = 'take_photo';

  // Dashboard & Status
  static const welcomeBack = 'welcome_back';
  static const tapToGetStarted = 'tap_to_get_started';
  static const accessSubmissionHistory = 'access_submission_history';
  static const viewClockInOutRecords = 'view_clock_in_out_records';
  static const urgentClockOutRequired = 'urgent_clock_out_required';
  static const clockedOutForToday = 'clocked_out_for_today';
  static const currentlyClockedIn = 'currently_clocked_in';
  static const alreadyClockedOutToday = 'already_clocked_out_today';
  static const urgentClockOut = 'urgent_clock_out';
  static const undoClockOut = 'undo_clock_out';
  static const undoClockOutConfirm = 'undo_clock_out_confirm';
  static const yesUndo = 'yes_undo';

  // Reports
  static const myReports = 'my_reports';
  static const driverReports = 'driver_reports';
  static const viewDriverReports = 'view_driver_reports';

  // Inspection
  static const noInspectionAvailable = 'no_inspection_available';

  // Team & Supervisor
  static const active = 'active';
  static const driverLabel = 'driver_label';

  // Logout
  static const logout = 'logout';
  static const logoutConfirm = 'logout_confirm';

  // Clock Details
  static const clockInDetails = 'clock_in_details';
  static const clockOutDetails = 'clock_out_details';
  static const startOdometer = 'start_odometer';
  static const finalOdometer = 'final_odometer';
  static const clockedInAt = 'clocked_in_at';
  static const clockedOutAt = 'clocked_out_at';
  static const odometerReadingLabel = 'odometer_reading_label';

  // Button Labels
  static const completed = 'completed';

  // Dialog Messages
  static const backToWorkQuestion = 'back_to_work_question';
  static const backToWorkMessage = 'back_to_work_message';
  static const yesBackToWork = 'yes_back_to_work';
  static const undoClockOutQuestion = 'undo_clock_out_question';
  static const undoClockOutMessage = 'undo_clock_out_message';
  static const restDialogTitle = 'rest_dialog_title';
  static const restDialogMessage = 'rest_dialog_message';
  static const restNotesLabel = 'rest_notes_label';
  static const restNotesHint = 'rest_notes_hint';

  // Reports Page
  static const refresh = 'refresh';
  static const inspectionReports = 'inspection_reports';
  static const newInspection = 'new_inspection';
  static const passed = 'passed';
  static const failed = 'failed';
  static const underReview = 'under_review';
  static const today = 'today';
  static const yesterday = 'yesterday';
  static const daysAgo = 'days_ago';
  static const download = 'download';
  static const open = 'open';

  // Snackbar/Toast Messages
  static const error = 'error';
  static const success = 'success';
  static const networkError = 'network_error';
  static const failedToLoadDashboard = 'failed_to_load_dashboard';
  static const restStarted = 'rest_started';
  static const restEnded = 'rest_ended';
  static const undoSuccessful = 'undo_successful';
  static const clockOutReminder = 'clock_out_reminder';
  static const forgotClockOut = 'forgot_clock_out';
  static const pleaseClockOut = 'please_clock_out';

  // History Page
  static const incidents = 'incidents';
  static const inspections = 'inspections';
  static const dailyChecklists = 'daily_checklists';
  static const noIncidents = 'no_incidents';
  static const noInspections = 'no_inspections';
  static const noChecklists = 'no_checklists';
  static const incidentsWillAppear = 'incidents_will_appear';
  static const inspectionsWillAppear = 'inspections_will_appear';
  static const checklistsWillAppear = 'checklists_will_appear';

  // Detail Pages
  static const viewDetails = 'view_details';
  static const submittedBy = 'submitted_by';
  static const submittedAt = 'submitted_at';
  static const reviewedBy = 'reviewed_by';
  static const reviewedAt = 'reviewed_at';
  static const pending = 'pending';
  static const notes = 'notes';
  static const remarks = 'remarks';

  // Settings Page
  static const securityPrivacy = 'security_privacy';
  static const appLock = 'app_lock';
  static const quickLogin = 'quick_login';
  static const enabledAppRequiresUnlock = 'enabled_app_requires_unlock';
  static const disabledNoProtection = 'disabled_no_protection';
  static const useDeviceLockToLogin = 'use_device_lock_to_login';
  static const configureDuringLogin = 'configure_during_login';
  static const stayLoggedIn = 'stay_logged_in';
  static const about = 'about';
  static const settingsGuide = 'settings_guide';
  static const appLockRequiresAuth = 'app_lock_requires_auth';
  static const quickLoginUsesFingerprint = 'quick_login_uses_fingerprint';
  static const rememberMeKeepsLoggedIn = 'remember_me_keeps_logged_in';
  static const quickLoginRememberMeSetDuringLogin =
      'quick_login_remember_me_set_during_login';
  static const appLockEnabled = 'app_lock_enabled';
  static const appNowProtected = 'app_now_protected';
  static const authenticationFailed = 'authentication_failed';
  static const pleaseTryAgain = 'please_try_again';
  static const couldNotEnableAppLock = 'could_not_enable_app_lock';
  static const disableAppLock = 'disable_app_lock';
  static const appNoLongerRequireAuth = 'app_no_longer_require_auth';
  static const disable = 'disable';
  static const appLockDisabled = 'app_lock_disabled';
  static const appNoLongerProtected = 'app_no_longer_protected';
  static const disableRememberMe = 'disable_remember_me';
  static const willLogoutNextTime = 'will_logout_next_time';
  static const rememberMeDisabled = 'remember_me_disabled';
  static const willRequireLoginNextTime = 'will_require_login_next_time';
  static const disableQuickLogin = 'disable_quick_login';
  static const willRequirePasswordNextTime = 'will_require_password_next_time';
  static const quickLoginDisabled = 'quick_login_disabled';
  static const willRequirePasswordLogin = 'will_require_password_login';
}
