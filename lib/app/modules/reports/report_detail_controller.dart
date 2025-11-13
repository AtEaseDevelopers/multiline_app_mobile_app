import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/models/report_model.dart';
import '../../data/services/report_service.dart';
import '../../data/models/api_response.dart';

class ReportDetailController extends GetxController {
  final ReportService _reportService = ReportService();

  final isLoading = false.obs;
  final isDownloading = false.obs;
  final downloadProgress = 0.0.obs;
  final errorMessage = ''.obs;
  final downloadedFilePath = ''.obs;

  late final int driverId;
  late final DriverReport report;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    driverId = args?['driverId'] as int? ?? 0;
    report = args?['report'] as DriverReport;
  }

  /// Request storage permission
  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      // Android 13+ (API 33+) doesn't need WRITE_EXTERNAL_STORAGE for app-specific dirs
      final androidInfo = await _getAndroidVersion();
      if (androidInfo >= 33) {
        return true; // No permission needed for Downloads folder on Android 13+
      }

      final status = await Permission.storage.request();
      return status.isGranted;
    } else if (Platform.isIOS) {
      // iOS doesn't need permission for app documents
      return true;
    }
    return false;
  }

  Future<int> _getAndroidVersion() async {
    try {
      // Simple check - in production, use device_info_plus package
      return 33; // Assume modern Android
    } catch (e) {
      return 30;
    }
  }

  /// Download report to device
  Future<void> downloadReport() async {
    try {
      isDownloading.value = true;
      downloadProgress.value = 0.0;
      errorMessage.value = '';

      // Request permission
      final hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        throw Exception('Storage permission denied');
      }

      // Get download directory
      Directory? directory;
      if (Platform.isAndroid) {
        // Try to use Downloads directory
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        throw Exception('Could not access storage');
      }

      // Create AT-EASE Reports subfolder
      final reportsDir = Directory('${directory.path}/AT-EASE Reports');
      if (!await reportsDir.exists()) {
        await reportsDir.create(recursive: true);
      }

      final filePath = '${reportsDir.path}/${report.fileName}';

      // Check if file already exists
      final file = File(filePath);
      if (await file.exists()) {
        final shouldOverwrite = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('File Exists'),
            content: const Text(
              'This report has already been downloaded. Do you want to download it again?',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Download Again'),
              ),
            ],
          ),
        );

        if (shouldOverwrite != true) {
          isDownloading.value = false;
          downloadedFilePath.value = filePath;
          return;
        }
      }

      // Download the file
      final downloadedPath = await _reportService.downloadReport(
        driverId: driverId,
        fileName: report.fileName,
        downloadPath: filePath,
        onProgress: (received, total) {
          if (total > 0) {
            downloadProgress.value = received / total;
          }
        },
      );

      downloadedFilePath.value = downloadedPath;

      // Show success message
      Get.snackbar(
        'Download Complete',
        'Report saved to: ${Platform.isAndroid ? 'Download/AT-EASE Reports' : 'Documents/AT-EASE Reports'}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
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
    } on NetworkException catch (e) {
      errorMessage.value = e.message;
      Get.snackbar(
        'Network Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Download Failed',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isDownloading.value = false;
      downloadProgress.value = 0.0;
    }
  }

  /// Get the download URL for WebView
  String getReportUrl() {
    return 'http://app.multiline.site/api/drivers/$driverId/reports/${report.fileName}/download';
  }
}
