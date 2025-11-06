import 'package:flutter/material.dart';
import '../constants/llm_models.dart';

class ConversationSettingsDialog extends StatefulWidget {
  final String initialTitle;
  final String initialModel;
  final String? initialSystemPrompt;
  final List<LLMModel> availableModels;

  const ConversationSettingsDialog({
    super.key,
    required this.initialTitle,
    required this.initialModel,
    this.initialSystemPrompt,
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
  late String _selectedModel;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _systemPromptController = TextEditingController(
      text: widget.initialSystemPrompt ?? '',
    );
    _selectedModel = widget.initialModel;
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
    super.dispose();
  }
}
