import '../models/api_response.dart';
import '../models/history_model.dart';
import '../providers/api_client.dart';
import '../services/storage_service.dart';
import '../../core/values/api_constants.dart';

class HistoryService {
  final ApiClient _apiClient = ApiClient();

  /// Get Driver History
  Future<HistoryResponse> getDriverHistory() async {
    try {
      final userId = await StorageService.getUserId();
      if (userId == null) {
        throw ApiException(message: 'User ID not found');
      }

      final response = await _apiClient.post<HistoryResponse>(
        ApiConstants.driverHistory,
        data: {'user_id': userId.toString()},
        fromJson: (data) => HistoryResponse.fromJson(data),
      );

      if (response.isSuccess && response.data != null) {
        return response.data!;
      } else {
        throw ApiException(
          message: response.message.isEmpty
              ? 'Failed to fetch history'
              : response.message,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get Supervisor History
  Future<HistoryResponse> getSupervisorHistory() async {
    try {
      final userId = await StorageService.getUserId();
      if (userId == null) {
        throw ApiException(message: 'User ID not found');
      }

      final response = await _apiClient.post<HistoryResponse>(
        ApiConstants.supervisorHistory,
        data: {'user_id': userId.toString()},
        fromJson: (data) => HistoryResponse.fromJson(data),
      );

      if (response.isSuccess && response.data != null) {
        return response.data!;
      } else {
        throw ApiException(
          message: response.message.isEmpty
              ? 'Failed to fetch history'
              : response.message,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get Inspection Details by ID
  Future<InspectionDetailResponse> getInspectionDetails(int id) async {
    try {
      final response = await _apiClient.get<InspectionDetailResponse>(
        '${ApiConstants.driverInspectionDetails}/$id',
        fromJson: (data) => InspectionDetailResponse.fromJson(data),
      );

      if (response.isSuccess && response.data != null) {
        return response.data!;
      } else {
        throw ApiException(
          message: response.message.isEmpty
              ? 'Failed to fetch inspection details'
              : response.message,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get Checklist Details by ID
  Future<ChecklistDetailResponse> getChecklistDetails(int id) async {
    try {
      final response = await _apiClient.get<ChecklistDetailResponse>(
        '${ApiConstants.driverChecklistDetails}/$id',
        fromJson: (data) => ChecklistDetailResponse.fromJson(data),
      );

      if (response.isSuccess && response.data != null) {
        return response.data!;
      } else {
        throw ApiException(
          message: response.message.isEmpty
              ? 'Failed to fetch checklist details'
              : response.message,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get Incident Details by ID
  Future<IncidentDetailResponse> getIncidentDetails(int id) async {
    try {
      final response = await _apiClient.get<IncidentDetailResponse>(
        '${ApiConstants.driverIncidentDetails}/$id',
        fromJson: (data) => IncidentDetailResponse.fromJson(data),
      );

      if (response.isSuccess && response.data != null) {
        return response.data!;
      } else {
        throw ApiException(
          message: response.message.isEmpty
              ? 'Failed to fetch incident details'
              : response.message,
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
