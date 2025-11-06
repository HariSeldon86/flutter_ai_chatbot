import 'package:dio/dio.dart';
import '../constants/llm_models.dart';

class ModelService {
  final Dio _dio;
  final String apiKey;

  ModelService({required this.apiKey})
    : _dio = Dio(
        BaseOptions(
          baseUrl: 'https://api.together.xyz/v1',
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ),
      );

  Future<List<LLMModel>> fetchModels() async {
    try {
      final response = await _dio.get('/models');

      if (response.data is List) {
        final models = (response.data as List)
            .map((json) => LLMModel.fromJson(json))
            .where((model) => model.type == 'chat') // Only chat models
            .toList();

        // drop models with 'Unknown' or '' organization
        models.removeWhere(
          (model) =>
              model.organization == 'Unknown' || model.organization == '',
        );

        // Sort by organization and display name
        models.sort((a, b) {
          final orgCompare = a.organization.compareTo(b.organization);
          if (orgCompare != 0) return orgCompare;
          return a.displayName.compareTo(b.displayName);
        });

        return models;
      } else {
        throw Exception('Unexpected response format');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          'API Error: ${e.response?.statusCode} - ${e.response?.data}',
        );
      } else {
        throw Exception('Network Error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error fetching models: $e');
    }
  }

  /// Test API connection by attempting to fetch models
  Future<void> testConnection() async {
    try {
      final response = await _dio.get('/models');

      if (response.statusCode != 200) {
        throw Exception('Invalid API response');
      }

      if (response.data is! List) {
        throw Exception('Unexpected response format');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        if (e.response?.statusCode == 401) {
          throw Exception('Invalid API key');
        } else if (e.response?.statusCode == 403) {
          throw Exception('Access forbidden - check your API key');
        } else {
          throw Exception('API Error (${e.response?.statusCode})');
        }
      } else {
        throw Exception('Network error - check your internet connection');
      }
    } catch (e) {
      throw Exception('Connection test failed: $e');
    }
  }
}
