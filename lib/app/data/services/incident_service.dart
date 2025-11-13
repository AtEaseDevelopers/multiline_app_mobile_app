import 'package:dio/dio.dart';
import '../models/api_response.dart';
import '../models/vehicle_model.dart';
import '../providers/api_client.dart';
import '../services/storage_service.dart';
import '../../core/values/api_constants.dart';

class IncidentService {
  final ApiClient _apiClient = ApiClient();

  /// Submit Incident Report
  Future<ApiResponse> submitIncidentReport({
    required int incidentTypeId,
    required int vehicleId,
    required String note,
    required List<String> photoPaths,
    int? clockinId,
  }) async {
    try {
      final userId = await StorageService.getUserId();
      if (userId == null) {
        throw ApiException(message: 'User ID not found');
      }

      // Prepare form data
      final Map<String, dynamic> data = {
        'user_id': userId.toString(),
        'incident_type_id': incidentTypeId.toString(),
        'vehicle_id': vehicleId.toString(),
        'note': note,
        if (clockinId != null) 'clockin_id': clockinId.toString(),
      };

      // Add multiple photos
      if (photoPaths.isNotEmpty) {
        final List<MultipartFile> photoFiles = [];

        for (var path in photoPaths) {
          final file = await MultipartFile.fromFile(
            path,
            filename: path.split('/').last,
          );
          photoFiles.add(file);
        }

        data['photos[]'] = photoFiles;
      }

      final response = await _apiClient.postFormData(
        ApiConstants.incidentReportSubmit,
        data: data,
      );

      if (!response.isSuccess) {
        throw ApiException(
          message: response.message.isEmpty
              ? 'Failed to submit incident report'
              : response.message,
        );
      }

      return response; // Return the response data
    } catch (e) {
      rethrow;
    }
  }

  /// Get Incident Types and Vehicles from API
  Future<Map<String, dynamic>> getIncidentTypesAndVehicles() async {
    try {
      final response = await _apiClient.post(ApiConstants.incidentReportTypes);

      if (!response.isSuccess) {
        throw ApiException(
          message: response.message.isEmpty
              ? 'Failed to load incident data'
              : response.message,
        );
      }

      // Parse the response data
      final data = response.data;

      // Parse incident types
      final List<Map<String, dynamic>> incidentTypes = [];
      if (data != null && data['incident_types'] != null) {
        final List<dynamic> types = data['incident_types'];
        incidentTypes.addAll(
          types.map((type) {
            return {
              'id': type['id'],
              'name': type['name'],
              'code': type['code'],
              'description': type['description'],
            };
          }),
        );
      }

      // Parse vehicles - handle missing company_name field
      final List<Vehicle> vehicles = [];
      if (data != null && data['vehicles'] != null) {
        final List<dynamic> vehicleList = data['vehicles'];
        vehicles.addAll(
          vehicleList.map((v) {
            return Vehicle(
              id: v['id'] as int,
              registrationNumber: v['registration_number'] as String,
              companyName:
                  v['company_name'] as String? ??
                  '', // Handle null company_name
            );
          }),
        );
      }

      return {'incident_types': incidentTypes, 'vehicles': vehicles};
    } catch (e) {
      rethrow;
    }
  }

  /// Get Incident Types from API (legacy method)
  Future<List<Map<String, dynamic>>> getIncidentTypes() async {
    final data = await getIncidentTypesAndVehicles();
    return data['incident_types'] as List<Map<String, dynamic>>;
  }
}
