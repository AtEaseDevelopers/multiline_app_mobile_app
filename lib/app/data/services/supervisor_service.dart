import '../models/api_response.dart';
import '../models/supervisor_dashboard_model.dart';
import '../models/inspection_detail_model.dart';
import '../models/checklist_detail_model.dart';
import '../providers/api_client.dart';
import '../../core/values/api_constants.dart';
import 'storage_service.dart';

class SupervisorService {
  final ApiClient _apiClient = ApiClient();

  /// Get Supervisor Dashboard
  Future<SupervisorDashboardData> getSupervisorDashboard() async {
    try {
      final response = await _apiClient.postFormData(
        ApiConstants.supervisorDashboard,
        data: {},
      );

      if (response.isSuccess && response.data != null) {
        return SupervisorDashboardData.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw ApiException(
          message: response.message.isEmpty
              ? 'Failed to fetch supervisor dashboard'
              : response.message,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get Inspection Details
  Future<InspectionDetail> getInspectionDetails(int id) async {
    try {
      final response = await _apiClient.get('inspection-details/$id');

      if (response.isSuccess && response.data != null) {
        // Parse from data.details
        final detailsData = response.data['details'] as Map<String, dynamic>?;
        if (detailsData != null) {
          return InspectionDetail.fromJson(detailsData);
        } else {
          throw ApiException(message: 'Invalid response format');
        }
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

  /// Get Checklist Details
  Future<ChecklistDetail> getChecklistDetails(int id) async {
    try {
      final response = await _apiClient.get('checklist-details/$id');

      if (response.isSuccess && response.data != null) {
        // Parse from data.details
        final detailsData = response.data['details'] as Map<String, dynamic>?;
        if (detailsData != null) {
          return ChecklistDetail.fromJson(detailsData);
        } else {
          throw ApiException(message: 'Invalid response format');
        }
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

  /// Approve Inspection
  Future<void> approveInspection(int id, {String? notes}) async {
    try {
      final userId = await StorageService.getUserId();
      if (userId == null) {
        throw ApiException(message: 'User not authenticated');
      }

      final response = await _apiClient.postFormData(
        'approve-list',
        data: {
          'user_id': userId.toString(),
          'type': 'inspection_list',
          'id': id.toString(),
          'remarks': notes ?? '',
        },
      );

      if (!response.isSuccess) {
        throw ApiException(
          message: response.message.isEmpty
              ? 'Failed to approve inspection'
              : response.message,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Reject Inspection
  Future<void> rejectInspection(int id, {required String reason}) async {
    try {
      final userId = await StorageService.getUserId();
      if (userId == null) {
        throw ApiException(message: 'User not authenticated');
      }

      final response = await _apiClient.postFormData(
        'reject-list',
        data: {
          'id': id.toString(),
          'type': 'inspection_list',
          'user_id': userId.toString(),
          'remarks': reason,
        },
      );

      if (!response.isSuccess) {
        throw ApiException(
          message: response.message.isEmpty
              ? 'Failed to reject inspection'
              : response.message,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Approve Checklist
  Future<void> approveChecklist(int id, {String? notes}) async {
    try {
      final userId = await StorageService.getUserId();
      if (userId == null) {
        throw ApiException(message: 'User not authenticated');
      }

      final response = await _apiClient.postFormData(
        'approve-list',
        data: {
          'user_id': userId.toString(),
          'type': 'checklist',
          'id': id.toString(),
          'remarks': notes ?? '',
        },
      );

      if (!response.isSuccess) {
        throw ApiException(
          message: response.message.isEmpty
              ? 'Failed to approve checklist'
              : response.message,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Reject Checklist
  Future<void> rejectChecklist(int id, {required String reason}) async {
    try {
      final userId = await StorageService.getUserId();
      if (userId == null) {
        throw ApiException(message: 'User not authenticated');
      }

      final response = await _apiClient.postFormData(
        'reject-list',
        data: {
          'id': id.toString(),
          'type': 'checklist',
          'user_id': userId.toString(),
          'remarks': reason,
        },
      );

      if (!response.isSuccess) {
        throw ApiException(
          message: response.message.isEmpty
              ? 'Failed to reject checklist'
              : response.message,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get Approve List
  Future<Map<String, dynamic>> getApproveList() async {
    try {
      final response = await _apiClient.postFormData(
        ApiConstants.approveList,
        data: {},
      );

      if (response.isSuccess && response.data != null) {
        return response.data as Map<String, dynamic>;
      } else {
        throw ApiException(
          message: response.message.isEmpty
              ? 'Failed to fetch approve list'
              : response.message,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get Reject List
  Future<Map<String, dynamic>> getRejectList() async {
    try {
      final response = await _apiClient.postFormData(
        ApiConstants.rejectList,
        data: {},
      );

      if (response.isSuccess && response.data != null) {
        return response.data as Map<String, dynamic>;
      } else {
        throw ApiException(
          message: response.message.isEmpty
              ? 'Failed to fetch reject list'
              : response.message,
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
