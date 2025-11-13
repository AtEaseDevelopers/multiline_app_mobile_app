import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_response.dart';
import '../models/inspection_model.dart';
import '../providers/api_client.dart';
import '../services/storage_service.dart';
import '../../core/values/api_constants.dart';

class InspectionService {
  final ApiClient _apiClient = ApiClient();
  static const String _draftKey = 'inspection_draft';

  /// Get Vehicle Inspection Checklist
  Future<List<InspectionSection>> getVehicleCheckList() async {
    try {
      final response = await _apiClient.post<InspectionVehicleCheckResponse>(
        ApiConstants.inspectionVehicleCheck,
        fromJson: (data) => InspectionVehicleCheckResponse.fromJson(data),
      );

      if (response.isSuccess && response.data != null) {
        return response.data!.items;
      } else {
        throw ApiException(
          message: response.message.isEmpty
              ? 'Failed to fetch inspection checklist'
              : response.message,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Submit Vehicle Inspection
  Future<void> submitInspection({
    required List<InspectionSection> sections,
    int? clockinId,
  }) async {
    try {
      final userId = await StorageService.getUserId();
      if (userId == null) {
        throw ApiException(message: 'User ID not found');
      }

      if (sections.isEmpty) {
        throw ApiException(message: 'No inspection data to submit');
      }

      // Get template_id from first section
      final inspectionTemplateId = sections.first.templateId;

      // Build responses array
      final List<Map<String, dynamic>> responses = [];

      for (var section in sections) {
        for (var item in section.items) {
          final response = <String, dynamic>{
            'item_id': item.id,
            'answer': item.value ?? '',
          };

          // Add photo if exists
          if (item.photoPath != null && item.photoPath!.isNotEmpty) {
            response['photo'] = await MultipartFile.fromFile(
              item.photoPath!,
              filename: item.photoPath!.split('/').last,
            );
          } else {
            response['photo'] = null;
          }

          responses.add(response);
        }
      }

      // Prepare form data (removed vehicle_id)
      final formData = FormData.fromMap({
        'user_id': userId,
        'inspection_template_id': inspectionTemplateId,
        if (clockinId != null) 'clockin_id': clockinId,
      });

      // Add responses - need to serialize them properly for multipart
      for (int i = 0; i < responses.length; i++) {
        formData.fields.add(
          MapEntry(
            'responses[$i][item_id]',
            responses[i]['item_id'].toString(),
          ),
        );
        formData.fields.add(
          MapEntry('responses[$i][answer]', responses[i]['answer'].toString()),
        );

        if (responses[i]['photo'] != null) {
          formData.files.add(
            MapEntry('responses[$i][photo]', responses[i]['photo']),
          );
        }
      }

      final response = await _apiClient.dio.post(
        ApiConstants.inspectionSubmit,
        data: formData,
      );

      // Check if response is successful
      if (response.data == null ||
          (response.data is Map && response.data['success'] == false)) {
        throw ApiException(
          message: response.data?['message'] ?? 'Failed to submit inspection',
        );
      }

      // Clear draft after successful submission
      await clearDraft();
    } catch (e) {
      rethrow;
    }
  }

  /// Save Inspection Draft
  Future<void> saveDraft({required List<InspectionSection> sections}) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Convert sections to JSON
      final draftData = {
        'timestamp': DateTime.now().toIso8601String(),
        'sections': sections.map((s) => s.toJson()).toList(),
      };

      await prefs.setString(_draftKey, jsonEncode(draftData));
    } catch (e) {
      rethrow;
    }
  }

  /// Load Inspection Draft
  Future<List<InspectionSection>?> loadDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final draftString = prefs.getString(_draftKey);

      if (draftString == null) return null;

      final draftData = jsonDecode(draftString) as Map<String, dynamic>;
      final sectionsJson = draftData['sections'] as List<dynamic>;

      return sectionsJson
          .map((s) => InspectionSection.fromJson(s as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return null;
    }
  }

  /// Clear Inspection Draft
  Future<void> clearDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_draftKey);
    } catch (e) {
      rethrow;
    }
  }

  /// Check if draft exists
  Future<bool> hasDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_draftKey);
    } catch (e) {
      return false;
    }
  }
}
