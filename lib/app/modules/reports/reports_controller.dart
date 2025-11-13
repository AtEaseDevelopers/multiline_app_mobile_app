import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../../data/models/report_model.dart';
import '../../data/services/report_service.dart';
import '../../data/models/api_response.dart';

class ReportsController extends GetxController {
  final ReportService _reportService = ReportService();

  final isLoading = false.obs;
  final reports = <DriverReport>[].obs;
  final errorMessage = ''.obs;
  final driverId = 0.obs;

  // Download state
  final downloadingReportIndex = RxnInt(); // Track which report is downloading
  final downloadProgress = 0.0.obs;
  final downloadedFiles =
      <String, String>{}.obs; // fileName -> filePath mapping

  @override
  void onInit() {
    super.onInit();
    // Get driver ID from arguments
    driverId.value = Get.arguments as int? ?? 0;
    if (driverId.value > 0) {
      loadReports();
      _checkExistingDownloads();
    }
  }

  /// Check which reports are already downloaded
  Future<void> _checkExistingDownloads() async {
    try {
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory != null) {
        final multilineDir = Directory('${directory.path}/multiline');
        if (await multilineDir.exists()) {
          final files = await multilineDir.list().toList();
          for (var entity in files) {
            if (entity is File) {
              final fileName = entity.path.split('/').last;
              downloadedFiles[fileName] = entity.path;
            }
          }
          print('📂 Found ${downloadedFiles.length} downloaded files');
        }
      }
    } catch (e) {
      print('Error checking existing downloads: $e');
    }
  }

  /// Load reports for driver
  Future<void> loadReports() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      print(
        '🔍 ReportsController - Loading reports for driver: ${driverId.value}',
      );
      final response = await _reportService.getDriverReports(driverId.value);

      print('🔍 ReportsController - Response success: ${response.success}');
      print(
        '🔍 ReportsController - Response reports count: ${response.reports.length}',
      );

      if (response.success) {
        reports.value = response.reports;
        print('✅ ReportsController - Reports loaded: ${reports.length}');
        if (reports.isEmpty) {
          errorMessage.value = 'No reports found';
          print('⚠️ ReportsController - No reports in list');
        } else {
          print(
            '✅ ReportsController - First report: ${reports.first.originalName}',
          );
        }
      } else {
        errorMessage.value = 'Failed to load reports';
        print('❌ ReportsController - Response success was false');
      }
    } on ApiException catch (e) {
      print('❌ ReportsController - ApiException: ${e.message}');
      errorMessage.value = e.message;
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } on NetworkException catch (e) {
      print('❌ ReportsController - NetworkException: ${e.message}');
      errorMessage.value = e.message;
      Get.snackbar(
        'Network Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('❌ ReportsController - Generic Exception: $e');
      print('❌ ReportsController - Exception type: ${e.runtimeType}');
      errorMessage.value = 'Failed to load reports';
      Get.snackbar(
        'Error',
        'Failed to load reports. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
      print(
        '🔍 ReportsController - Loading finished. Error: ${errorMessage.value}',
      );
    }
  }

  /// Request storage permission with proper handling for Android 13+
  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      // For Android 13+ (SDK 33+), use manageExternalStorage
      // For Android 10-12, use storage permission

      // First check Android version to determine which permission to request
      PermissionStatus status;

      // Try manageExternalStorage first (for Android 11+)
      try {
        status = await Permission.manageExternalStorage.status;

        if (status.isGranted) {
          print('✅ MANAGE_EXTERNAL_STORAGE permission granted');
          return true;
        }

        if (status.isDenied) {
          print('🔐 Requesting MANAGE_EXTERNAL_STORAGE permission...');
          status = await Permission.manageExternalStorage.request();

          if (status.isGranted) {
            print('✅ MANAGE_EXTERNAL_STORAGE permission granted after request');
            return true;
          }

          if (status.isPermanentlyDenied) {
            print('⛔ MANAGE_EXTERNAL_STORAGE permanently denied');
            return await _showPermissionSettingsDialog();
          }

          // If denied but not permanently, try regular storage permission
          if (!status.isGranted) {
            print(
              '⚠️ MANAGE_EXTERNAL_STORAGE denied, trying regular storage...',
            );
          }
        }
      } catch (e) {
        print(
          '⚠️ MANAGE_EXTERNAL_STORAGE not available, using storage permission: $e',
        );
      }

      // Fallback to regular storage permission (for Android 10-12)
      status = await Permission.storage.status;

      if (status.isGranted) {
        print('✅ Storage permission granted');
        return true;
      }

      if (status.isDenied) {
        print('🔐 Requesting storage permission...');
        status = await Permission.storage.request();

        if (status.isGranted) {
          print('✅ Storage permission granted after request');
          return true;
        }

        if (status.isPermanentlyDenied) {
          print('⛔ Storage permission permanently denied');
          return await _showPermissionSettingsDialog();
        }

        return status.isGranted;
      }

      // Try to request permission anyway
      print('🔐 Requesting storage permission (fallback)...');
      status = await Permission.storage.request();
      return status.isGranted;
    } else if (Platform.isIOS) {
      // iOS doesn't need permission for app documents
      return true;
    }
    return false;
  }

  /// Show dialog to open app settings for permission
  Future<bool> _showPermissionSettingsDialog() async {
    final shouldOpenSettings = await Get.dialog<bool>(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.settings, color: Colors.orange.shade700, size: 28),
            const SizedBox(width: 12),
            const Text('Permission Required'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Storage permission is required to download reports to your device.',
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How to enable:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildSettingsStep('1', 'Tap "Open Settings" below'),
                  const SizedBox(height: 4),
                  _buildSettingsStep('2', 'Go to Permissions'),
                  const SizedBox(height: 4),
                  _buildSettingsStep(
                    '3',
                    'Enable "Files and Media" or "Storage"',
                  ),
                  const SizedBox(height: 4),
                  _buildSettingsStep('4', 'Return to app and try again'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () => Get.back(result: true),
            icon: const Icon(Icons.settings, size: 18),
            label: const Text('Open Settings'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade700,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );

    if (shouldOpenSettings == true) {
      print('📱 Opening app settings...');
      await openAppSettings();
      // Give user time to change settings, then check again
      await Future.delayed(const Duration(seconds: 1));

      // Check both permissions again
      try {
        final manageStatus = await Permission.manageExternalStorage.status;
        if (manageStatus.isGranted) {
          print('✅ MANAGE_EXTERNAL_STORAGE granted from settings');
          return true;
        }
      } catch (e) {
        print('⚠️ Could not check MANAGE_EXTERNAL_STORAGE: $e');
      }

      final storageStatus = await Permission.storage.status;
      print('📋 Storage permission status after settings: $storageStatus');
      return storageStatus.isGranted;
    }

    return false;
  }

  /// Open downloaded file
  Future<void> openDownloadedFile(String fileName) async {
    try {
      final filePath = downloadedFiles[fileName];
      if (filePath == null) {
        Get.snackbar(
          'Error',
          'File not found. Please download again.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Check if file still exists
      final file = File(filePath);
      if (!await file.exists()) {
        downloadedFiles.remove(fileName);
        Get.snackbar(
          'File Not Found',
          'The file was deleted or moved. Please download again.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Try to open file using open_file plugin
      try {
        final result = await OpenFile.open(filePath);
        if (result.type == ResultType.done) {
          print('✅ File opened successfully');
        } else if (result.type == ResultType.noAppToOpen) {
          _showNoAppDialog(filePath);
        } else {
          throw Exception(result.message);
        }
      } on MissingPluginException {
        // Fallback: Use platform channel directly
        print('⚠️ Plugin not available, using platform channel');
        await _openFileWithIntent(filePath);
      } on PlatformException catch (e) {
        print('❌ Platform exception: $e');
        await _openFileWithIntent(filePath);
      }
    } catch (e) {
      print('❌ Error opening file: $e');
      Get.snackbar(
        'Error',
        'Failed to open file. Please open it manually from Downloads/multiline folder.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
    }
  }

  /// Open file using Android Intent (fallback method)
  Future<void> _openFileWithIntent(String filePath) async {
    if (Platform.isAndroid) {
      try {
        const platform = MethodChannel('com.example.multiline_app/file_opener');
        await platform.invokeMethod('openFile', {'path': filePath});
        print('✅ File opened via intent');
      } catch (e) {
        print('❌ Intent failed: $e');
        _showFileLocationDialog(filePath);
      }
    } else {
      _showFileLocationDialog(filePath);
    }
  }

  /// Show dialog when no app can open the file
  void _showNoAppDialog(String filePath) {
    Get.dialog(
      AlertDialog(
        title: const Text('No PDF Viewer'),
        content: const Text(
          'No app found to open PDF files. Please install a PDF viewer app from Play Store.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              _showFileLocationDialog(filePath);
            },
            child: const Text('Show Location'),
          ),
          TextButton(onPressed: () => Get.back(), child: const Text('OK')),
        ],
      ),
    );
  }

  /// Show dialog with file location
  void _showFileLocationDialog(String filePath) {
    Get.dialog(
      AlertDialog(
        title: const Text('File Location'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your report has been saved to:'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                filePath,
                style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Open your file manager and navigate to:\nDownload → multiline',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('OK')),
        ],
      ),
    );
  }

  // Helper widget for settings steps
  Widget _buildSettingsStep(String number, String text) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.orange.shade700,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
        ),
      ],
    );
  }

  /// Download report to device
  Future<void> downloadReport(int index) async {
    try {
      downloadingReportIndex.value = index;
      downloadProgress.value =
          0.01; // Start with 1% to show progress immediately
      errorMessage.value = '';

      final report = reports[index];

      // Request permission directly without explanation dialog
      final hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        // Show a final message if permission still denied
        Get.snackbar(
          'Download Cancelled',
          'Storage permission is required to download reports. You can enable it anytime from app settings.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.grey.shade700,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
          icon: const Icon(Icons.info_outline, color: Colors.white),
          mainButton: TextButton(
            onPressed: () {
              Get.closeAllSnackbars();
              openAppSettings();
            },
            child: const Text(
              'Settings',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
        downloadingReportIndex.value = null;
        return;
      }

      // Show starting download message
      Get.snackbar(
        'Starting Download',
        'Preparing to download ${report.friendlyName}...',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue.shade700,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.downloading, color: Colors.white),
      );

      // Get download directory with fallback options
      Directory? directory;
      String? pathDescription;

      if (Platform.isAndroid) {
        // Try multiple directory options in order of preference
        List<Directory?> possibleDirs = [
          Directory('/storage/emulated/0/Download'), // Public Downloads
          await getExternalStorageDirectory(), // App external storage
          await getApplicationDocumentsDirectory(), // App documents (fallback)
        ];

        List<String> pathDescriptions = [
          'Download',
          'App Files',
          'App Documents',
        ];

        for (int i = 0; i < possibleDirs.length; i++) {
          final testDir = possibleDirs[i];
          if (testDir != null) {
            try {
              // Test if we can create a directory here
              final testPath = '${testDir.path}/multiline';
              final testDirectory = Directory(testPath);

              if (await testDirectory.exists() ||
                  await testDirectory
                      .create(recursive: true)
                      .then((_) => true)
                      .catchError((_) => false)) {
                directory = testDir;
                pathDescription = pathDescriptions[i];
                break;
              }
            } catch (e) {
              print('Failed to access directory ${testDir.path}: $e');
              continue;
            }
          }
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
        pathDescription = 'Documents';
      }

      if (directory == null) {
        throw Exception('Could not find accessible storage location');
      }

      // Create multiline subfolder
      final reportsDir = Directory('${directory.path}/multiline');
      if (!await reportsDir.exists()) {
        try {
          await reportsDir.create(recursive: true);
        } catch (e) {
          throw Exception('Failed to create multiline directory: $e');
        }
      }

      final filePath = '${reportsDir.path}/${report.fileName}';

      // Delete existing file if it exists (auto-overwrite)
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        print('🗑️ Deleted existing file: ${report.fileName}');
      }

      // Download the file
      print('🔽 Starting download for: ${report.fileName}');
      print('📍 Downloading to: $filePath');

      await _reportService.downloadReport(
        driverId: driverId.value,
        fileName: report.fileName,
        downloadPath: filePath,
        onProgress: (received, total) {
          if (total > 0 && received != total) {
            // Normal progress tracking when content length is known
            final progress = received / total;
            downloadProgress.value = progress;
            print(
              '📊 Progress: ${(progress * 100).toStringAsFixed(1)}% ($received / $total bytes)',
            );
          } else if (received == total && total > 0) {
            // This is the FINAL chunk when content length is known
            downloadProgress.value = 1.0;
            print('📊 Final progress: 100.0% ($received / $total bytes)');
          } else if (total == 0) {
            // Content length unknown - keep at 0.01 to show indeterminate spinner
            // Just keep it at 0.01, the spinner will animate automatically
            downloadProgress.value = 0.01;
            print('📊 Downloading: ${(received / 1024).toStringAsFixed(1)} KB');
          }
        },
      );

      // Ensure progress is set to 1.0 when complete
      downloadProgress.value = 1.0;
      print('✅ Download complete: ${report.fileName}');
      print('✅ Final progress set to: ${downloadProgress.value}');

      // Save downloaded file path BEFORE delay
      downloadedFiles[report.fileName] = filePath;
      print('✅ File saved to downloadedFiles map');

      // Small delay to show 100% completion before hiding progress
      await Future.delayed(const Duration(milliseconds: 500));
      print('✅ Showing folder icon now');

      // Show success message with actual path
      Get.snackbar(
        'Download Complete',
        'Report saved to: ${pathDescription ?? 'Device Storage'}/multiline',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      Get.snackbar(
        'Download Failed',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } catch (e) {
      errorMessage.value = 'Failed to download report';
      Get.snackbar(
        'Download Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      downloadingReportIndex.value = null;
      downloadProgress.value = 0.0;
    }
  }
}
