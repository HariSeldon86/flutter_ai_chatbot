class LLMModel {
  final String id;
  final String displayName;
  final String organization;
  final String type;
  final int contextLength;
  final String? license;
  final DateTime created;
  final ModelPricing? pricing;
  final String? link;

  const LLMModel({
    required this.id,
    required this.displayName,
    required this.organization,
    required this.type,
    required this.contextLength,
    this.license,
    required this.created,
    this.pricing,
    this.link,
  });

  factory LLMModel.fromJson(Map<String, dynamic> json) {
    return LLMModel(
      id: json['id'] as String,
      displayName: json['display_name'] as String? ?? json['id'] as String,
      organization: json['organization'] as String? ?? 'Unknown',
      type: json['type'] as String? ?? 'chat',
      contextLength: json['context_length'] as int? ?? 0,
      license: json['license'] as String?,
      created: DateTime.fromMillisecondsSinceEpoch(
        (json['created'] as int) * 1000,
      ),
      pricing: json['pricing'] != null
          ? ModelPricing.fromJson(json['pricing'])
          : null,
      link: json['link'] as String?,
    );
  }

  // Helper to get a short description
  String get description {
    final contextKb = (contextLength / 1024).toStringAsFixed(0);
    return '$organization • ${contextKb}K context';
  }
}

class ModelPricing {
  final double input;
  final double output;
  final double hourly;
  final double base;
  final double finetune;

  const ModelPricing({
    required this.input,
    required this.output,
    required this.hourly,
    required this.base,
    required this.finetune,
  });

  factory ModelPricing.fromJson(Map<String, dynamic> json) {
    return ModelPricing(
      input: (json['input'] as num?)?.toDouble() ?? 0.0,
      output: (json['output'] as num?)?.toDouble() ?? 0.0,
      hourly: (json['hourly'] as num?)?.toDouble() ?? 0.0,
      base: (json['base'] as num?)?.toDouble() ?? 0.0,
      finetune: (json['finetune'] as num?)?.toDouble() ?? 0.0,
    );
  }

  String get inputPriceFormatted => '\$${input.toStringAsFixed(2)} / 1M tokens';
  String get outputPriceFormatted =>
      '\$${output.toStringAsFixed(2)} / 1M tokens';
}

class LLMModels {
  // Fallback models in case API is unavailable
  static const List<Map<String, dynamic>> _fallbackModels = [
    {
      'id': 'meta-llama/Meta-Llama-3.1-8B-Instruct-Turbo',
      'display_name': 'Llama 3.1 8B Turbo',
      'organization': 'Meta',
      'type': 'chat',
      'context_length': 8192,
      'created': 1692896905,
    },
    {
      'id': 'meta-llama/Meta-Llama-3.1-70B-Instruct-Turbo',
      'display_name': 'Llama 3.1 70B Turbo',
      'organization': 'Meta',
      'type': 'chat',
      'context_length': 8192,
      'created': 1692896905,
    },
    {
      'id': 'mistralai/Mistral-7B-Instruct-v0.3',
      'display_name': 'Mistral 7B v0.3',
      'organization': 'Mistral AI',
      'type': 'chat',
      'context_length': 8192,
      'created': 1692896905,
    },
  ];

  static List<LLMModel> getFallbackModels() {
    return _fallbackModels.map((json) => LLMModel.fromJson(json)).toList();
  }

  static LLMModel? findById(List<LLMModel> models, String id) {
    try {
      return models.firstWhere((model) => model.id == id);
    } catch (e) {
      return null;
    }
  }

  static String getDisplayName(List<LLMModel> models, String id) {
    final model = findById(models, id);
    return model?.displayName ?? id;
  }
}
