import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/conversation.dart';
import '../services/chat_service.dart';
import '../services/storage_service.dart';
import '../widgets/message_bubble.dart';
import '../widgets/conversation_sidebar.dart';
import 'settings_screen.dart';

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
  bool _isLoading = false;
  bool _isSending = false;
  String? _error;

  List<Conversation> _conversations = [];
  Conversation? _currentConversation;

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
        setState(() => _error = null);
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
    final titleController = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Conversation'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: 'Conversation Title',
            hintText: 'Enter a title for this conversation',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (titleController.text.trim().isNotEmpty) {
                Navigator.of(context).pop(titleController.text.trim());
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (title != null && title.isNotEmpty) {
      final newConversation = Conversation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        messages: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
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

    try {
      final response = await _chatService!.sendMessage(_messages);

      setState(() {
        _messages.add(ChatMessage(role: 'assistant', content: response));
        _isSending = false;
      });

      await _saveCurrentConversation();
      _scrollToBottom();
    } catch (e) {
      setState(() => _isSending = false);

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

  void _clearChat() {
    setState(() {
      _messages.clear();
      _currentConversation = null;
    });
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
    return Scaffold(
      appBar: AppBar(
        title: _currentConversation?.title != null
            ? Text('AI Chatbot > ${_currentConversation!.title}')
            : const Text('AI Chatbot'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _clearChat,
              tooltip: 'Clear chat',
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
                    const SizedBox(height: 16),
                    Text(
                      "Start a new conversation",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                      ),
                    ),
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
                            return MessageBubble(message: _messages[index]);
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
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
