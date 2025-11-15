class ChatMessage {
  final String role;
  final String content;
  final int? inputTokens;
  final int? outputTokens;
  final String? model;

  ChatMessage({
    required this.role,
    required this.content,
    this.inputTokens,
    this.outputTokens,
    this.model,
  });

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
      'inputTokens': inputTokens,
      'outputTokens': outputTokens,
      'model': model,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: json['role'] as String,
      content: json['content'] as String,
      inputTokens: json['inputTokens'] as int?,
      outputTokens: json['outputTokens'] as int?,
      model: json['model'] as String?,
    );
  }

  ChatMessage copyWith({
    String? role,
    String? content,
    int? inputTokens,
    int? outputTokens,
    String? model,
  }) {
    return ChatMessage(
      role: role ?? this.role,
      content: content ?? this.content,
      inputTokens: inputTokens ?? this.inputTokens,
      outputTokens: outputTokens ?? this.outputTokens,
      model: model ?? this.model,
    );
  }
}
