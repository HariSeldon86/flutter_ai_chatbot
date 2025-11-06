import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/chat_message.dart';
import '../models/chat_response.dart';
import '../models/chat_stream_response.dart';

class ChatService {
  final Dio _dio;
  final String apiKey;

  ChatService({required this.apiKey})
    : _dio = Dio(
        // initializer list
        BaseOptions(
          baseUrl: 'https://api.together.xyz/v1',
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ),
      );

  Stream<String> sendMessageStream(
    List<ChatMessage> messages, {
    String model = 'meta-llama/Meta-Llama-3.1-8B-Instruct-Turbo',
    String? systemPrompt,
  }) async* {
    try {
      // Build messages list with optional system prompt
      final messagesList = <Map<String, dynamic>>[];

      if (systemPrompt != null && systemPrompt.isNotEmpty) {
        messagesList.add({'role': 'system', 'content': systemPrompt});
      }

      messagesList.addAll(messages.map((msg) => msg.toJson()).toList());

      final response = await _dio.post<ResponseBody>(
        '/chat/completions',
        data: {'model': model, 'messages': messagesList, 'stream': true},
        options: Options(responseType: ResponseType.stream),
      );

      final stream = response.data?.stream;
      if (stream == null) {
        throw Exception('No stream available from response');
      }

      final stringStream = stream
          .cast<List<int>>()
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      await for (final line in stringStream) {
        if (line.isEmpty || !line.startsWith('data: ')) continue;

        final data = line.substring(6); // Remove 'data: ' prefix

        if (data.trim() == '[DONE]') {
          break;
        }

        try {
          final json = jsonDecode(data);
          final streamResponse = ChatStreamResponse.fromJson(json);

          if (streamResponse.choices.isNotEmpty) {
            final content = streamResponse.choices.first.delta.content;
            if (content != null && content.isNotEmpty) {
              yield content;
            }
          }
        } catch (e) {
          // Skip invalid JSON chunks
          continue;
        }
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

  Future<String> sendMessage(
    List<ChatMessage> messages, {
    String model = 'meta-llama/Meta-Llama-3.1-8B-Instruct-Turbo',
    String? systemPrompt,
  }) async {
    try {
      // Build messages list with optional system prompt
      final messagesList = <Map<String, dynamic>>[];

      if (systemPrompt != null && systemPrompt.isNotEmpty) {
        messagesList.add({'role': 'system', 'content': systemPrompt});
      }

      messagesList.addAll(messages.map((msg) => msg.toJson()).toList());

      final response = await _dio.post(
        '/chat/completions',
        data: {'model': model, 'messages': messagesList},
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
