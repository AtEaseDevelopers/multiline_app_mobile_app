import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/api_response.dart';
import '../models/report_model.dart';
import '../providers/api_client.dart';
import '../services/storage_service.dart';
import '../../core/values/api_constants.dart';

class ReportService {
  final ApiClient _apiClient = ApiClient();

  /// Get list of reports for a specific driver
  Future<DriverReportsResponse> getDriverReports(int driverId) async {
    try {
      final path = 'drivers/reports/$driverId';

      // Use Dio directly since this endpoint returns {success, reports, ...}
      // instead of the standard {data, message, status} format
      final response = await _apiClient.dio.get(path);

      print('🔍 ReportService - Status: ${response.statusCode}');
      print('🔍 ReportService - Data type: ${response.data.runtimeType}');

      if (response.statusCode == 200 && response.data != null) {
        // Response data is the JSON object directly
        final jsonData = response.data as Map<String, dynamic>;
        print('🔍 ReportService - JSON keys: ${jsonData.keys.toList()}');
        print('🔍 ReportService - success: ${jsonData['success']}');
        print(
          '🔍 ReportService - reports count: ${jsonData['reports']?.length ?? 0}',
        );

        final result = DriverReportsResponse.fromJson(jsonData);
        print('✅ ReportService - Parsed success: ${result.success}');
        print('✅ ReportService - Parsed reports: ${result.reports.length}');

        return result;
      } else {
        print('❌ ReportService - Bad status: ${response.statusCode}');
        throw ApiException(
          message: 'Failed to load reports',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('❌ ReportService - Exception: $e');
      rethrow;
    }
  }

  /// Download a specific report PDF
  /// Returns the file path where PDF was saved
  Future<String> downloadReport({
    required int driverId,
    required String fileName,
    required String downloadPath,
    Function(int received, int total)? onProgress,
  }) async {
    try {
      // Get token for authorization
      final token = await StorageService.getToken();
      if (token == null) {
        throw ApiException(message: 'Not authenticated');
      }

      // Build download URL
      final url =
          '${ApiConstants.baseUrl}${ApiConstants.driverReportDownload}/$driverId/reports/$fileName/download';

      print('📥 Downloading report from: $url');

      // Create request with authorization
      final request = http.Request('GET', Uri.parse(url));
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/pdf';

      // Send request
      final streamedResponse = await request.send();

      if (streamedResponse.statusCode != 200) {
        throw ApiException(
          message: 'Download failed: ${streamedResponse.statusCode}',
        );
      }

      // Get content length for progress
      final contentLength = streamedResponse.contentLength ?? 0;
      print('📦 Content length: $contentLength bytes');

      if (contentLength == 0) {
        print(
          '⚠️ Warning: Content length is 0 or unknown - progress tracking may not work',
        );
      }

      // Create file
      final file = File(downloadPath);
      final sink = file.openWrite();
      int received = 0;
      int lastReportedProgress = 0;
      int lastReportedBytes = 0;

      // Download with progress tracking
      await for (var chunk in streamedResponse.stream) {
        received += chunk.length;
        sink.add(chunk);

        // Update progress - report every 5% or on significant chunk
        if (onProgress != null && contentLength > 0) {
          final currentProgress = (received / contentLength * 100).toInt();

          // Report progress if: first chunk, or every 5%, or last chunk
          if (lastReportedProgress == 0 ||
              currentProgress >= lastReportedProgress + 5 ||
              received == contentLength) {
            onProgress(received, contentLength);
            lastReportedProgress = currentProgress;

            print(
              '📊 Progress: $received / $contentLength = ${(received / contentLength * 100).toStringAsFixed(1)}%',
            );
          }
        } else if (onProgress != null && contentLength == 0) {
          // Content length unknown - still send progress for UI feedback
          // Report every ~50KB to show activity without spamming
          if (received - lastReportedBytes >= 50000 || lastReportedBytes == 0) {
            // Send special signal: total = 0 means "unknown, show indeterminate"
            onProgress(received, 0);
            lastReportedBytes = received;
            print('📊 Downloading: ${(received / 1024).toStringAsFixed(1)} KB');
          }
        }
      }

      await sink.flush();
      await sink.close();

      // Final progress update
      if (onProgress != null) {
        if (contentLength > 0) {
          // Known content length - send final 100%
          onProgress(contentLength, contentLength);
          print('✅ Final progress update: 100%');
        } else {
          // Unknown content length - send received bytes as completion signal
          onProgress(received, received);
          print(
            '✅ Final progress update: Download complete ($received bytes total)',
          );
        }
      }

      print('✅ Report downloaded successfully to: $downloadPath');
      return downloadPath;
    } catch (e) {
      print('❌ Download error: $e');
      rethrow;
    }
  }
}
