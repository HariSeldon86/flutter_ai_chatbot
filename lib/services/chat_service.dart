import 'package:dio/dio.dart';
import '../models/chat_message.dart';
import '../models/chat_response.dart';

class ChatService {
  final Dio _dio;
  final String apiKey;

  ChatService({required this.apiKey})
    : _dio = Dio( // initializer list
        BaseOptions(
          baseUrl: 'https://api.together.xyz/v1',
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ),
      );

  Future<String> sendMessage(List<ChatMessage> messages) async {
    try {
      final response = await _dio.post(
        '/chat/completions',
        data: {
          'model': 'meta-llama/Meta-Llama-3.1-8B-Instruct-Turbo', // TODO generalize model as user input ?
          'messages': messages.map((msg) => msg.toJson()).toList(), // TODO add system prompt as user input ?
        },
      );

      final chatResponse = ChatResponse.fromJson(response.data);

      if (chatResponse.choices.isNotEmpty) {
        return chatResponse.choices.first.message.content;
      } else {
        throw Exception('No response from API');
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
      throw Exception('Unexpected Error: $e');
    }
  }
}
