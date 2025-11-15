import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/conversation.dart';

class StorageService {
  static const String _apiKeyKey = 'TOGETHER_API_KEY';
  static const String _conversationsKey = 'CONVERSATIONS';

  // Android options to prevent issues with secure storage
  static const AndroidOptions _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
  );

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: _androidOptions,
  );

  // API Key methods
  Future<void> saveApiKey(String apiKey) async {
    try {
      await _storage.write(key: _apiKeyKey, value: apiKey);
    } catch (e) {
      throw Exception('Failed to save API key: $e');
    }
  }

  Future<String?> getApiKey() async {
    try {
      return await _storage.read(key: _apiKeyKey);
    } catch (e) {
      throw Exception('Failed to read API key: $e');
    }
  }

  Future<void> deleteApiKey() async {
    try {
      await _storage.delete(key: _apiKeyKey);
    } catch (e) {
      throw Exception('Failed to delete API key: $e');
    }
  }

  Future<bool> hasApiKey() async {
    try {
      final apiKey = await getApiKey();
      return apiKey != null && apiKey.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Conversation methods
  Future<void> saveConversations(List<Conversation> conversations) async {
    try {
      final conversationsJson = conversations.map((c) => c.toJson()).toList();
      await _storage.write(
        key: _conversationsKey,
        value: jsonEncode(conversationsJson),
      );
    } catch (e) {
      throw Exception('Failed to save conversations: $e');
    }
  }

  Future<List<Conversation>> getConversations() async {
    try {
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
    } catch (e) {
      // If there's an error reading from storage, return empty list
      return [];
    }
  }

  Future<void> saveConversation(Conversation conversation) async {
    try {
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
    } catch (e) {
      throw Exception('Failed to save conversation: $e');
    }
  }

  Future<void> deleteConversation(String conversationId) async {
    try {
      final conversations = await getConversations();
      conversations.removeWhere((c) => c.id == conversationId);
      await saveConversations(conversations);
    } catch (e) {
      throw Exception('Failed to delete conversation: $e');
    }
  }

  Future<void> deleteAllConversations() async {
    try {
      await _storage.delete(key: _conversationsKey);
    } catch (e) {
      throw Exception('Failed to delete all conversations: $e');
    }
  }
}
