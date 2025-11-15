import 'chat_message.dart';

class Conversation {
  final String id;
  final String title;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String model;
  final String? systemPrompt;
  final double? temperature;
  final String? jsonSchema;
  final int? contextLength;

  Conversation({
    required this.id,
    required this.title,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
    this.model = 'meta-llama/Meta-Llama-3.1-8B-Instruct-Turbo',
    this.systemPrompt,
    this.temperature,
    this.jsonSchema,
    this.contextLength,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'messages': messages.map((msg) => msg.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'model': model,
      'systemPrompt': systemPrompt,
      'temperature': temperature,
      'jsonSchema': jsonSchema,
      'contextLength': contextLength,
    };
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      title: json['title'] as String,
      messages: (json['messages'] as List)
          .map((msg) => ChatMessage.fromJson(msg))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      model:
          json['model'] as String? ??
          'meta-llama/Meta-Llama-3.1-8B-Instruct-Turbo',
      systemPrompt: json['systemPrompt'] as String?,
      temperature: json['temperature'] as double?,
      jsonSchema: json['jsonSchema'] as String?,
      contextLength: json['contextLength'] as int?,
    );
  }

  Conversation copyWith({
    String? id,
    String? title,
    List<ChatMessage>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? model,
    String? systemPrompt,
    double? temperature,
    String? jsonSchema,
    int? contextLength,
  }) {
    return Conversation(
      id: id ?? this.id,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      model: model ?? this.model,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      temperature: temperature ?? this.temperature,
      jsonSchema: jsonSchema ?? this.jsonSchema,
      contextLength: contextLength ?? this.contextLength,
    );
  }
}
