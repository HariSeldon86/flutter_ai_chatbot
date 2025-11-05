import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/conversation.dart';

class StorageService {
  static const String _apiKeyKey = 'TOGETHER_API_KEY';
  static const String _conversationsKey = 'CONVERSATIONS';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // API Key methods
  Future<void> saveApiKey(String apiKey) async {
    await _storage.write(key: _apiKeyKey, value: apiKey);
  }

  Future<String?> getApiKey() async {
    return await _storage.read(key: _apiKeyKey);
  }

  Future<void> deleteApiKey() async {
    await _storage.delete(key: _apiKeyKey);
  }

  Future<bool> hasApiKey() async {
    final apiKey = await getApiKey();
    return apiKey != null && apiKey.isNotEmpty;
  }

  // Conversation methods
  Future<void> saveConversations(List<Conversation> conversations) async {
    final conversationsJson = conversations.map((c) => c.toJson()).toList();
    await _storage.write(
      key: _conversationsKey,
      value: jsonEncode(conversationsJson),
    );
  }

  Future<List<Conversation>> getConversations() async {
    final conversationsString = await _storage.read(key: _conversationsKey);
    if (conversationsString == null || conversationsString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> conversationsJson = jsonDecode(conversationsString);
      return conversationsJson
          .map((json) => Conversation.fromJson(json))
          .toList();
    } catch (e) {
      // If there's an error parsing, return empty list
      return [];
    }
  }

  Future<void> saveConversation(Conversation conversation) async {
    final conversations = await getConversations();
    final existingIndex = conversations.indexWhere(
      (c) => c.id == conversation.id,
    );

    if (existingIndex >= 0) {
      conversations[existingIndex] = conversation;
    } else {
      conversations.insert(0, conversation);
    }

    await saveConversations(conversations);
  }

  Future<void> deleteConversation(String conversationId) async {
    final conversations = await getConversations();
    conversations.removeWhere((c) => c.id == conversationId);
    await saveConversations(conversations);
  }

  Future<void> deleteAllConversations() async {
    await _storage.delete(key: _conversationsKey);
  }
}
