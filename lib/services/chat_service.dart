import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/chat_message.dart';
import '../models/chat_response.dart';
import '../models/chat_stream_response.dart';

class ChatStreamResult {
  final Stream<String> contentStream;
  final Future<TokenUsage?> tokenUsage;

  ChatStreamResult({required this.contentStream, required this.tokenUsage});
}

class TokenUsage {
  final int inputTokens;
  final int outputTokens;

  TokenUsage({required this.inputTokens, required this.outputTokens});
}

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

  ChatStreamResult sendMessageStream(
    List<ChatMessage> messages, {
    String model = 'meta-llama/Meta-Llama-3.1-8B-Instruct-Turbo',
    String? systemPrompt,
    double? temperature,
    String? jsonSchema,
  }) {
    final StreamController<String> contentController =
        StreamController<String>();
    final Completer<TokenUsage?> usageCompleter = Completer<TokenUsage?>();

    _performStreamRequest(
      messages,
      model,
      systemPrompt,
      temperature,
      jsonSchema,
      contentController,
      usageCompleter,
    );

    return ChatStreamResult(
      contentStream: contentController.stream,
      tokenUsage: usageCompleter.future,
    );
  }

  Future<void> _performStreamRequest(
    List<ChatMessage> messages,
    String model,
    String? systemPrompt,
    double? temperature,
    String? jsonSchema,
    StreamController<String> contentController,
    Completer<TokenUsage?> usageCompleter,
  ) async {
    try {
      // Build messages list with optional system prompt
      final messagesList = <Map<String, dynamic>>[];

      if (systemPrompt != null && systemPrompt.isNotEmpty) {
        messagesList.add({'role': 'system', 'content': systemPrompt});
      }

      messagesList.addAll(messages.map((msg) => msg.toJson()).toList());

      final requestData = {
        'model': model,
        'messages': messagesList,
        'stream': true,
        'stream_options': {'include_usage': true},
      };

      if (temperature != null) {
        requestData['temperature'] = temperature;
      }

      if (jsonSchema != null && jsonSchema.isNotEmpty) {
        try {
          final schema = jsonDecode(jsonSchema);
          requestData['response_format'] = {
            'type': 'json_object',
            'schema': schema,
          };
        } catch (e) {
          // Invalid JSON schema, skip it
        }
      }

      final response = await _dio.post<ResponseBody>(
        '/chat/completions',
        data: requestData,
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

      TokenUsage? finalUsage;

      await for (final line in stringStream) {
        if (line.isEmpty || !line.startsWith('data: ')) continue;

        final data = line.substring(6); // Remove 'data: ' prefix

        if (data.trim() == '[DONE]') {
          break;
        }

        try {
          final json = jsonDecode(data);
          final streamResponse = ChatStreamResponse.fromJson(json);

          // Check for usage information
          if (streamResponse.usage != null) {
            finalUsage = TokenUsage(
              inputTokens: streamResponse.usage!.promptTokens,
              outputTokens: streamResponse.usage!.completionTokens,
            );
          }

          if (streamResponse.choices.isNotEmpty) {
            final content = streamResponse.choices.first.delta.content;
            if (content != null && content.isNotEmpty) {
              contentController.add(content);
            }
          }
        } catch (e) {
          // Skip invalid JSON chunks
          continue;
        }
      }

      contentController.close();
      usageCompleter.complete(finalUsage);
    } on DioException catch (e) {
      contentController.addError(
        e.response != null
            ? Exception(
                'API Error: ${e.response?.statusCode} - ${e.response?.data}',
              )
            : Exception('Network Error: ${e.message}'),
      );
      contentController.close();
      usageCompleter.completeError(e);
    } catch (e) {
      contentController.addError(Exception('Unexpected Error: $e'));
      contentController.close();
      usageCompleter.completeError(e);
    }
  }

  Future<ChatMessage> sendMessage(
    List<ChatMessage> messages, {
    String model = 'meta-llama/Meta-Llama-3.1-8B-Instruct-Turbo',
    String? systemPrompt,
    double? temperature,
    String? jsonSchema,
  }) async {
    try {
      // Build messages list with optional system prompt
      final messagesList = <Map<String, dynamic>>[];

      if (systemPrompt != null && systemPrompt.isNotEmpty) {
        messagesList.add({'role': 'system', 'content': systemPrompt});
      }

      messagesList.addAll(messages.map((msg) => msg.toJson()).toList());

      final requestData = {'model': model, 'messages': messagesList};

      if (temperature != null) {
        requestData['temperature'] = temperature;
      }

      if (jsonSchema != null && jsonSchema.isNotEmpty) {
        try {
          final schema = jsonDecode(jsonSchema);
          requestData['response_format'] = {
            'type': 'json_object',
            'schema': schema,
          };
        } catch (e) {
          // Invalid JSON schema, skip it
        }
      }

      final response = await _dio.post('/chat/completions', data: requestData);

      final chatResponse = ChatResponse.fromJson(response.data);

      if (chatResponse.choices.isNotEmpty) {
        return ChatMessage(
          role: 'assistant',
          content: chatResponse.choices.first.message.content,
          inputTokens: chatResponse.usage?.promptTokens,
          outputTokens: chatResponse.usage?.completionTokens,
        );
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
