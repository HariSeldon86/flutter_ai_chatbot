import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/conversation.dart';
import '../services/chat_service.dart';
import '../services/storage_service.dart';
import '../services/model_service.dart';
import '../widgets/message_bubble.dart';
import '../widgets/conversation_sidebar.dart';
import '../widgets/conversation_settings_dialog.dart';
import '../constants/llm_models.dart';
import 'settings_screen.dart';
import 'model_info_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final StorageService _storageService = StorageService();
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  ChatService? _chatService;
  ModelService? _modelService;
  bool _isLoading = false;
  bool _isSending = false;
  String? _error;

  List<Conversation> _conversations = [];
  Conversation? _currentConversation;
  List<LLMModel> _availableModels = [];

  @override
  void initState() {
    super.initState();
    _initializeChatService();
    _loadConversations();
  }

  Future<void> _initializeChatService() async {
    setState(() => _isLoading = true);
    try {
      final apiKey = await _storageService.getApiKey();
      if (apiKey != null && apiKey.isNotEmpty) {
        _chatService = ChatService(apiKey: apiKey);
        _modelService = ModelService(apiKey: apiKey);
        setState(() => _error = null);

        // Load available models
        await _loadAvailableModels();
      } else {
        setState(
          () => _error = 'No API key found. Please configure it in Settings.',
        );
      }
    } catch (e) {
      setState(() => _error = 'Error loading API key: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadAvailableModels() async {
    try {
      if (_modelService != null) {
        final models = await _modelService!.fetchModels();
        setState(() {
          _availableModels = models;
        });
      }
    } catch (e) {
      // Show error to user - API connection required
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load models: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      debugPrint('Error loading models: $e');
    }
  }

  Future<void> _loadConversations() async {
    final conversations = await _storageService.getConversations();
    setState(() {
      _conversations = conversations;
    });
  }

  Future<void> _saveCurrentConversation() async {
    if (_currentConversation == null || _messages.isEmpty) return;

    final updatedConversation = _currentConversation!.copyWith(
      messages: List.from(_messages),
      updatedAt: DateTime.now(),
    );

    await _storageService.saveConversation(updatedConversation);
    setState(() {
      _currentConversation = updatedConversation;
    });
    await _loadConversations();
  }

  void _loadConversation(Conversation conversation) {
    setState(() {
      _currentConversation = conversation;
      _messages.clear();
      _messages.addAll(conversation.messages);
    });
    Navigator.of(context).pop(); // Close drawer
    _scrollToBottom();
  }

  Future<void> _createNewConversation({bool closeDrawer = true}) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => ConversationSettingsDialog(
        initialTitle: '',
        initialModel: 'meta-llama/Meta-Llama-3.1-8B-Instruct-Turbo',
        availableModels: _availableModels,
      ),
    );

    if (result != null) {
      final newConversation = Conversation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: result['title'] as String,
        messages: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        model: result['model'] as String,
        systemPrompt: result['systemPrompt'] as String?,
        temperature: result['temperature'] as double?,
        jsonSchema: result['jsonSchema'] as String?,
        contextLength: result['contextLength'] as int?,
      );

      setState(() {
        _currentConversation = newConversation;
        _messages.clear();
      });

      await _storageService.saveConversation(newConversation);
      await _loadConversations();

      if (mounted && closeDrawer) {
        Navigator.of(context).pop(); // Close drawer
      }
    }
  }

  Future<void> _editConversationSettings() async {
    if (_currentConversation == null) return;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => ConversationSettingsDialog(
        initialTitle: _currentConversation!.title,
        initialModel: _currentConversation!.model,
        initialSystemPrompt: _currentConversation!.systemPrompt,
        initialTemperature: _currentConversation!.temperature,
        initialJsonSchema: _currentConversation!.jsonSchema,
        initialContextLength: _currentConversation!.contextLength,
        availableModels: _availableModels,
      ),
    );

    if (result != null) {
      final updatedConversation = _currentConversation!.copyWith(
        title: result['title'] as String,
        model: result['model'] as String,
        systemPrompt: result['systemPrompt'] as String?,
        temperature: result['temperature'] as double?,
        jsonSchema: result['jsonSchema'] as String?,
        contextLength: result['contextLength'] as int?,
        updatedAt: DateTime.now(),
      );

      setState(() {
        _currentConversation = updatedConversation;
      });

      await _storageService.saveConversation(updatedConversation);
      await _loadConversations();
    }
  }

  Future<void> _deleteConversation(String conversationId) async {
    await _storageService.deleteConversation(conversationId);
    await _loadConversations();

    if (_currentConversation?.id == conversationId) {
      setState(() {
        _currentConversation = null;
        _messages.clear();
      });
    }
  }

  Future<void> _deleteAllConversations() async {
    await _storageService.deleteAllConversations();
    await _loadConversations();

    setState(() {
      _currentConversation = null;
      _messages.clear();
    });

    if (mounted) {
      Navigator.of(context).pop(); // Close drawer
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All conversations deleted')),
      );
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    if (_chatService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please configure your API key in Settings'),
        ),
      );
      return;
    }

    // Create a new conversation if none exists
    if (_currentConversation == null) {
      final firstMessage = _messageController.text.trim();
      final title = firstMessage.length > 50
          ? '${firstMessage.substring(0, 47)}...'
          : firstMessage;

      final newConversation = Conversation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        messages: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        model: 'meta-llama/Meta-Llama-3.1-8B-Instruct-Turbo',
      );

      setState(() {
        _currentConversation = newConversation;
      });
    }

    final userMessage = ChatMessage(
      role: 'user',
      content: _messageController.text.trim(),
    );

    setState(() {
      _messages.add(userMessage);
      _isSending = true;
    });

    _messageController.clear();
    _scrollToBottom();

    // Add a placeholder message for the assistant response
    final assistantMessage = ChatMessage(
      role: 'assistant',
      content: '',
      model: _currentConversation!.model,
    );
    setState(() {
      _messages.add(assistantMessage);
    });

    try {
      // Filter messages and apply context length limit
      final messagesToSend = _messages
          .where((msg) => msg.content.isNotEmpty)
          .toList();
      final contextLength = _currentConversation!.contextLength;
      final limitedMessages = contextLength != null && contextLength > 0
          ? messagesToSend.length > contextLength
                ? messagesToSend.sublist(messagesToSend.length - contextLength)
                : messagesToSend
          : messagesToSend;

      final streamResult = _chatService!.sendMessageStream(
        limitedMessages,
        model: _currentConversation!.model,
        systemPrompt: _currentConversation!.systemPrompt,
        temperature: _currentConversation!.temperature,
        jsonSchema: _currentConversation!.jsonSchema,
      );

      String fullResponse = '';

      await for (final chunk in streamResult.contentStream) {
        fullResponse += chunk;

        // Update the assistant message in place
        setState(() {
          _messages[_messages.length - 1] = ChatMessage(
            role: 'assistant',
            content: fullResponse,
            model: _currentConversation!.model,
          );
        });

        _scrollToBottom();
      }

      // Wait for token usage
      final tokenUsage = await streamResult.tokenUsage;

      // Update message with token usage
      if (tokenUsage != null) {
        setState(() {
          _messages[_messages.length - 1] = ChatMessage(
            role: 'assistant',
            content: fullResponse,
            inputTokens: tokenUsage.inputTokens,
            outputTokens: tokenUsage.outputTokens,
            model: _currentConversation!.model,
          );
        });
      }

      setState(() {
        _isSending = false;
      });

      await _saveCurrentConversation();
      _scrollToBottom();
    } catch (e) {
      // Remove the placeholder message on error
      setState(() {
        _messages.removeLast();
        _isSending = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _clearChat() async {
    if (_currentConversation == null) return;

    final updatedConversation = _currentConversation!.copyWith(
      messages: [],
      updatedAt: DateTime.now(),
    );

    await _storageService.saveConversation(updatedConversation);

    setState(() {
      _messages.clear();
      _currentConversation = updatedConversation;
    });

    await _loadConversations();
  }

  Future<void> _navigateToSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
    // Reinitialize chat service after returning from settings
    _initializeChatService();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: _currentConversation?.title != null
              // ? Text('AI Chatbot > ${_currentConversation!.title}')
              ? Text(_currentConversation!.title)
              : const Text('AI Chatbot'),
          centerTitle: false,
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            if (_messages.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: _clearChat,
                tooltip: 'Clear chat',
              ),
            if (_currentConversation != null)
              IconButton(
                icon: const Icon(Icons.tune),
                onPressed: _editConversationSettings,
                tooltip: 'Conversation Settings',
              ),
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ModelInfoScreen(models: _availableModels),
                  ),
                );
              },
              tooltip: 'Model Information',
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: _navigateToSettings,
              tooltip: 'Settings',
            ),
          ],
        ),
        drawer: ConversationSidebar(
          conversations: _conversations,
          currentConversationId: _currentConversation?.id,
          onSelectConversation: _loadConversation,
          onDeleteConversation: _deleteConversation,
          onNewConversation: () => _createNewConversation(closeDrawer: true),
          onDeleteAllConversations: _deleteAllConversations,
          availableModels: _availableModels,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _navigateToSettings,
                        icon: const Icon(Icons.settings),
                        label: const Text('Go to Settings'),
                      ),
                    ],
                  ),
                ),
              )
            : _currentConversation == null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () =>
                            _createNewConversation(closeDrawer: false),
                        icon: const Icon(Icons.add),
                        label: const Text('Start New Conversation'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Column(
                children: [
                  if (_currentConversation != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        border: Border(
                          bottom: BorderSide(color: Colors.blue.shade200),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Model: ${LLMModels.getDisplayName(_availableModels, _currentConversation!.model)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: _messages.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Start a conversation',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(8),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              // Calculate cumulative token usage up to this message
                              int cumulativeInput = 0;
                              int cumulativeOutput = 0;

                              for (int i = 0; i <= index; i++) {
                                if (_messages[i].inputTokens != null) {
                                  cumulativeInput += _messages[i].inputTokens!;
                                }
                                if (_messages[i].outputTokens != null) {
                                  cumulativeOutput +=
                                      _messages[i].outputTokens!;
                                }
                              }

                              return MessageBubble(
                                message: _messages[index],
                                cumulativeInputTokens: cumulativeInput > 0
                                    ? cumulativeInput
                                    : null,
                                cumulativeOutputTokens: cumulativeOutput > 0
                                    ? cumulativeOutput
                                    : null,
                              );
                            },
                          ),
                  ),
                  if (_isSending)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          SizedBox(width: 8),
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('AI is thinking...'),
                        ],
                      ),
                    ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 4,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: const InputDecoration(
                              hintText: 'Type a message...',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            maxLines: null,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _sendMessage(),
                            enabled: !_isSending,
                          ),
                        ),
                        const SizedBox(width: 8),
                        FloatingActionButton(
                          onPressed: _isSending ? null : _sendMessage,
                          child: const Icon(Icons.send),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
