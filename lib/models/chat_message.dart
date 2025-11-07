class ChatMessage {
  final String role;
  final String content;
  final int? inputTokens;
  final int? outputTokens;

  ChatMessage({
    required this.role,
    required this.content,
    this.inputTokens,
    this.outputTokens,
  });

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
      'inputTokens': inputTokens,
      'outputTokens': outputTokens,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: json['role'] as String,
      content: json['content'] as String,
      inputTokens: json['inputTokens'] as int?,
      outputTokens: json['outputTokens'] as int?,
    );
  }

  ChatMessage copyWith({
    String? role,
    String? content,
    int? inputTokens,
    int? outputTokens,
  }) {
    return ChatMessage(
      role: role ?? this.role,
      content: content ?? this.content,
      inputTokens: inputTokens ?? this.inputTokens,
      outputTokens: outputTokens ?? this.outputTokens,
    );
  }
}
