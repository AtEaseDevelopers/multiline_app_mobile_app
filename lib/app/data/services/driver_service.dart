import 'package:dio/dio.dart';
import '../models/api_response.dart';
import '../models/vehicle_model.dart';
import '../models/dashboard_model.dart';
import '../models/clock_history_model.dart';
import '../providers/api_client.dart';
import '../services/storage_service.dart';
import '../../core/values/api_constants.dart';

class DriverService {
  final ApiClient _apiClient = ApiClient();

  /// Get list of lorries/vehicles
  Future<List<Vehicle>> getLorries() async {
    try {
      final response = await _apiClient.post<VehiclesResponse>(
        ApiConstants.getLorries,
        fromJson: (data) => VehiclesResponse.fromJson(data),
      );

      if (response.isSuccess && response.data != null) {
        return response.data!.vehicles;
      } else {
        throw ApiException(
          message: response.message.isEmpty
              ? 'Failed to fetch vehicles'
              : response.message,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Clock In
  Future<void> clockIn({
    required int vehicleId,
    required String datetime,
    required String meterReading,
    required String readingPicturePath,
  }) async {
    try {
      final userId = await StorageService.getUserId();
      if (userId == null) {
        throw ApiException(message: 'User ID not found');
      }

      final response = await _apiClient.postFormData(
        ApiConstants.clockIn,
        data: {
          'user_id': userId.toString(),
          'vehicle_id': vehicleId.toString(),
          'datetime': datetime,
          'meter_reading': meterReading,
          'reading_picture': await MultipartFile.fromFile(
            readingPicturePath,
            filename: readingPicturePath.split('/').last,
          ),
        },
      );

      if (!response.isSuccess) {
        throw ApiException(
          message: response.message.isEmpty
              ? 'Clock in failed'
              : response.message,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Clock Out
  Future<void> clockOut({
    required String datetime,
    required String meterReading,
    required String readingPicturePath,
  }) async {
    try {
      final userId = await StorageService.getUserId();
      if (userId == null) {
        throw ApiException(message: 'User ID not found');
      }

      final response = await _apiClient.postFormData(
        ApiConstants.clockOut,
        data: {
          'user_id': userId.toString(),
          'datetime': datetime,
          'meter_reading': meterReading,
          'reading_picture': await MultipartFile.fromFile(
            readingPicturePath,
            filename: readingPicturePath.split('/').last,
          ),
        },
      );

      if (!response.isSuccess) {
        throw ApiException(
          message: response.message.isEmpty
              ? 'Clock out failed'
              : response.message,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Undo Clock Out
  Future<Map<String, dynamic>> undoClockOut(int userId) async {
    try {
      final response = await _apiClient.postFormData(
        ApiConstants.undoClockOut,
        data: {'user_id': userId.toString()},
      );

      // Return the raw response data
      return {
        'status': response.status,
        'message': response.message,
        'data': response.data,
      };
    } catch (e) {
      rethrow;
    }
  }

  /// Start Rest Time
  Future<Map<String, dynamic>> startRest({
    required int clockInId,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.postFormData(
        ApiConstants.restStart,
        data: {
          'clock_in_id': clockInId.toString(),
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        },
      );

      // Return the raw response data
      return {
        'status': response.status,
        'message': response.message,
        'data': response.data,
      };
    } catch (e) {
      rethrow;
    }
  }

  /// End Rest Time
  Future<Map<String, dynamic>> endRest({required int clockInId}) async {
    try {
      final response = await _apiClient.postFormData(
        ApiConstants.restEnd,
        data: {'clock_in_id': clockInId.toString()},
      );

      // Return the raw response data
      return {
        'status': response.status,
        'message': response.message,
        'data': response.data,
      };
    } catch (e) {
      rethrow;
    }
  }

  /// Get Driver Dashboard
  Future<DashboardData> getDriverDashboard() async {
    try {
      final userId = await StorageService.getUserId();
      if (userId == null) {
        throw ApiException(message: 'User ID not found');
      }

      final response = await _apiClient.postFormData<DashboardData>(
        ApiConstants.driverDashboard,
        data: {'user_id': userId.toString()},
        fromJson: (data) => DashboardData.fromJson(data),
      );

      if (response.isSuccess && response.data != null) {
        return response.data!;
      } else {
        throw ApiException(
          message: response.message.isEmpty
              ? 'Failed to fetch dashboard data'
              : response.message,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get Clock History with pagination
  Future<ClockHistoryData> getClockHistory({
    required int userId,
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final response = await _apiClient.get<ClockHistoryData>(
        '${ApiConstants.clockHistory}?user_id=$userId&page=$page&per_page=$perPage',
        fromJson: (data) => ClockHistoryData.fromJson(data),
      );

      if (response.isSuccess && response.data != null) {
        return response.data!;
      } else {
        throw ApiException(
          message: response.message.isEmpty
              ? 'Failed to fetch clock history'
              : response.message,
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
