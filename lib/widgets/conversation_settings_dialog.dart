import 'package:flutter/material.dart';
import '../constants/llm_models.dart';

class ConversationSettingsDialog extends StatefulWidget {
  final String initialTitle;
  final String initialModel;
  final String? initialSystemPrompt;
  final double? initialTemperature;
  final String? initialJsonSchema;
  final int? initialContextLength;
  final List<LLMModel> availableModels;

  const ConversationSettingsDialog({
    super.key,
    required this.initialTitle,
    required this.initialModel,
    this.initialSystemPrompt,
    this.initialTemperature,
    this.initialJsonSchema,
    this.initialContextLength,
    required this.availableModels,
  });

  @override
  State<ConversationSettingsDialog> createState() =>
      _ConversationSettingsDialogState();
}

class _ConversationSettingsDialogState
    extends State<ConversationSettingsDialog> {
  late TextEditingController _titleController;
  late TextEditingController _systemPromptController;
  late TextEditingController _jsonSchemaController;
  late String _selectedModel;
  late double _temperature;
  late int? _contextLength;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _systemPromptController = TextEditingController(
      text: widget.initialSystemPrompt ?? '',
    );
    _jsonSchemaController = TextEditingController(
      text: widget.initialJsonSchema ?? '',
    );
    _selectedModel = widget.initialModel;
    _temperature = widget.initialTemperature ?? 0.7;
    _contextLength = widget.initialContextLength;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Conversation Settings'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            const Text(
              'LLM Model',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedModel,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.smart_toy),
              ),
              isExpanded: true,
              items: widget.availableModels.map((model) {
                return DropdownMenuItem(
                  value: model.id,
                  child: FittedBox(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          model.displayName,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                        // Text(
                        //   " • ${model.description}",
                        //   style: TextStyle(
                        //     // fontSize: 12,
                        //     color: Colors.grey.shade500,
                        //   ),
                        //   overflow: TextOverflow.ellipsis,
                        // ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedModel = value);
                }
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'System Prompt (Optional)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _systemPromptController,
              decoration: const InputDecoration(
                labelText: 'System Prompt',
                hintText:
                    'e.g., You are a helpful assistant that speaks like a pirate',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.psychology),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 8),
            Text(
              'System prompts help define the AI\'s behavior and personality',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Temperature',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _temperature,
                    min: 0.0,
                    max: 2.0,
                    divisions: 20,
                    label: _temperature.toStringAsFixed(1),
                    onChanged: (value) {
                      setState(() => _temperature = value);
                    },
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: Text(
                    _temperature.toStringAsFixed(1),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            Text(
              'Lower values make output more focused and deterministic, higher values more creative and random',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Context Length',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: (_contextLength ?? 0).toDouble(),
                    min: 0,
                    max: 50,
                    divisions: 50,
                    label: _contextLength == null || _contextLength == 0
                        ? 'All messages'
                        : '$_contextLength messages',
                    onChanged: (value) {
                      setState(() => _contextLength = value.toInt());
                    },
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    _contextLength == null || _contextLength == 0
                        ? 'All'
                        : '$_contextLength',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            Text(
              'Number of recent messages to include in API request. Set to 0 or leave empty for all messages.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'JSON Schema (Optional - for Structured Outputs)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _jsonSchemaController,
              decoration: const InputDecoration(
                labelText: 'JSON Schema',
                hintText: '{"properties": {...}, "required": [...]}',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.code),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 8),
            Text(
              'Define a JSON schema for structured outputs. The model will return responses matching this schema.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_titleController.text.trim().isNotEmpty) {
              Navigator.of(context).pop({
                'title': _titleController.text.trim(),
                'model': _selectedModel,
                'systemPrompt': _systemPromptController.text.trim().isEmpty
                    ? null
                    : _systemPromptController.text.trim(),
                'temperature': _temperature,
                'jsonSchema': _jsonSchemaController.text.trim().isEmpty
                    ? null
                    : _jsonSchemaController.text.trim(),
                'contextLength': _contextLength == 0 ? null : _contextLength,
              });
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _systemPromptController.dispose();
    _jsonSchemaController.dispose();
    super.dispose();
  }
}
