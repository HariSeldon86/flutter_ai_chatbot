class ChatStreamResponse {
  final String id;
  final List<StreamChoice> choices;
  final String? finishReason;
  final String? generatedText;
  final int created;
  final String object;
  final StreamUsage? usage;

  ChatStreamResponse({
    required this.id,
    required this.choices,
    this.finishReason,
    this.generatedText,
    required this.created,
    required this.object,
    this.usage,
  });

  factory ChatStreamResponse.fromJson(Map<String, dynamic> json) {
    return ChatStreamResponse(
      id: json['id'] as String,
      choices: (json['choices'] as List)
          .map((choice) => StreamChoice.fromJson(choice))
          .toList(),
      finishReason: json['finish_reason'] as String?,
      generatedText: json['generated_text'] as String?,
      created: json['created'] as int,
      object: json['object'] as String,
      usage: json['usage'] != null ? StreamUsage.fromJson(json['usage']) : null,
    );
  }
}

class StreamChoice {
  final int index;
  final Delta delta;
  final String? finishReason;

  StreamChoice({required this.index, required this.delta, this.finishReason});

  factory StreamChoice.fromJson(Map<String, dynamic> json) {
    return StreamChoice(
      index: json['index'] as int,
      delta: Delta.fromJson(json['delta']),
      finishReason: json['finish_reason'] as String?,
    );
  }
}

class Delta {
  final String? role;
  final String? content;

  Delta({this.role, this.content});

  factory Delta.fromJson(Map<String, dynamic> json) {
    return Delta(
      role: json['role'] as String?,
      content: json['content'] as String?,
    );
  }
}

class StreamUsage {
  final int promptTokens;
  final int completionTokens;
  final int totalTokens;

  StreamUsage({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });

  factory StreamUsage.fromJson(Map<String, dynamic> json) {
    return StreamUsage(
      promptTokens: json['prompt_tokens'] as int,
      completionTokens: json['completion_tokens'] as int,
      totalTokens: json['total_tokens'] as int,
    );
  }
}
