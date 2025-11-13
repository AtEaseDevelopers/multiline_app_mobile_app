import '../models/api_response.dart';
import '../models/checklist_model.dart';
import '../providers/api_client.dart';
import '../services/storage_service.dart';
import '../../core/values/api_constants.dart';

class ChecklistService {
  final ApiClient _apiClient = ApiClient();

  /// Get Daily Checklist
  Future<DailyChecklistResponse> getDailyChecklist() async {
    try {
      final response = await _apiClient.post<DailyChecklistResponse>(
        ApiConstants.dailyChecklist,
        fromJson: (data) => DailyChecklistResponse.fromJson(data),
      );

      if (response.isSuccess && response.data != null) {
        return response.data!;
      } else {
        throw ApiException(
          message: response.message.isEmpty
              ? 'Failed to fetch daily checklist'
              : response.message,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Submit Daily Checklist
  Future<void> submitDailyChecklist({
    required int checklistTemplateId,
    required List<ChecklistSection> sections,
    int? clockinId,
  }) async {
    try {
      final userId = await StorageService.getUserId();
      if (userId == null) {
        throw ApiException(message: 'User ID not found');
      }

      if (sections.isEmpty) {
        throw ApiException(message: 'No checklist data to submit');
      }

      // Build responses array from sections
      final List<Map<String, dynamic>> responses = [];

      for (var section in sections) {
        for (var item in section.items) {
          if (item.answer != null && item.answer!.isNotEmpty) {
            responses.add({
              'checklist_question_id': item.id,
              'answer': item.answer!,
              'remarks': item.remarks,
            });
          }
        }
      }

      if (responses.isEmpty) {
        throw ApiException(message: 'Please answer at least one question');
      }

      // Prepare submission data (removed vehicle_id)
      final data = {
        'user_id': userId,
        'checklist_template_id': checklistTemplateId,
        if (clockinId != null) 'clockin_id': clockinId,
        'responses': responses,
      };

      final response = await _apiClient.post(
        ApiConstants.dailyChecklistSubmit,
        data: data,
      );

      if (!response.isSuccess) {
        throw ApiException(
          message: response.message.isEmpty
              ? 'Failed to submit daily checklist'
              : response.message,
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
