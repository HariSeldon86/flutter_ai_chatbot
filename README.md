# Flutter AI Chatbot

A Flutter application that integrates with Together AI's API to provide an AI-powered chatbot experience using Meta-Llama-3.1-8B-Instruct-Turbo model.

## Features

- 🤖 AI-powered chat using Together AI API
- 🔐 Secure API key storage using flutter_secure_storage
- 💬 Clean and intuitive chat interface
- 📚 Conversation history with persistent storage
- 🗂️ Sidebar to manage and navigate conversations
- ➕ Create new conversations with custom titles
- 🔄 Continue previous conversations with full context
- 🗑️ Delete conversations with swipe gesture
- ⚙️ Easy settings management
- 🎨 Material Design 3 UI

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── models/                      # Data models
│   ├── chat_message.dart       # Chat message model
│   ├── chat_response.dart      # API response model
│   └── conversation.dart       # Conversation model with persistence
├── services/                    # Business logic & API
│   ├── chat_service.dart       # Together AI API integration
│   └── storage_service.dart    # Secure storage for API key & conversations
├── screens/                     # UI screens
│   ├── chat_screen.dart        # Main chat interface with history
│   └── settings_screen.dart    # API key configuration
└── widgets/                     # Reusable components
    ├── message_bubble.dart     # Chat message bubble widget
    └── conversation_sidebar.dart # Conversation history sidebar
```

## Setup

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Get Your Together AI API Key

1. Visit [Together AI](https://api.together.xyz)
2. Sign up or log in
3. Generate an API key

### 3. Run the App

```bash
flutter run
```

### 4. Configure API Key

1. Open the app
2. Tap the settings icon (⚙️) in the top-right corner
3. Enter your Together AI API key
4. Tap "Save"

## Dependencies

- **dio**: ^5.9.0 - HTTP client for API requests
- **flutter_secure_storage**: ^9.2.4 - Secure storage for API key and conversations
- **intl**: ^0.19.0 - Internationalization and date formatting

## Usage

### Starting a New Conversation

1. **Quick Start**: Just type a message and send - a conversation will be created automatically with your first message as the title
2. **Custom Title**: Tap the "New Chat" floating button or use the sidebar menu to create a conversation with a custom title

### Managing Conversations

1. **View History**: Tap the menu icon (☰) to open the sidebar and see all your conversations
2. **Load Conversation**: Tap any conversation in the sidebar to load it and continue chatting
3. **Delete Conversation**: Swipe left on any conversation in the sidebar and confirm deletion
4. **Current Conversation**: The active conversation is highlighted in the sidebar

### Chat Features

- All messages in a conversation are preserved and loaded when you reopen the app
- The AI maintains context from previous messages in the conversation
- Conversations show message count and last update time
- The app bar displays the current conversation title

## API Integration

The app uses Together AI's Chat Completions API:

- **Endpoint**: `https://api.together.xyz/v1/chat/completions`
- **Model**: `meta-llama/Meta-Llama-3.1-8B-Instruct-Turbo`
- **Authentication**: Bearer token (API key)

### Example API Request

```bash
curl -X POST "https://api.together.xyz/v1/chat/completions" \
     -H "Authorization: Bearer $TOGETHER_API_KEY" \
     -H "Content-Type: application/json" \
     -d '{
       "model": "meta-llama/Meta-Llama-3.1-8B-Instruct-Turbo",
       "messages": [
         {"role": "user", "content": "What are some fun things to do in New York?"}
       ]
     }'
```

## Architecture

### Models
- **ChatMessage**: Represents a single message in the conversation (user or assistant)
- **ChatResponse**: Parses API responses from Together AI
- **Conversation**: Represents a complete conversation with metadata (id, title, messages, timestamps)

### Services
- **ChatService**: Handles API communication with Together AI
- **StorageService**: Manages secure storage of the API key and conversation history using flutter_secure_storage

### Screens
- **ChatScreen**: Main chat interface with message list, input field, and conversation management
- **SettingsScreen**: API key configuration and management

### Widgets
- **MessageBubble**: Reusable chat bubble component for displaying messages
- **ConversationSidebar**: Drawer widget showing conversation history with navigation and deletion

## Data Persistence

All conversations are stored securely on the device using `flutter_secure_storage`:

- **API Key**: Encrypted storage for authentication
- **Conversations**: JSON-encoded conversation history including:
  - Unique conversation ID
  - User-defined title
  - Complete message history
  - Creation and update timestamps

Data persists across app restarts and is automatically loaded when the app launches.

## Security

- API keys are stored securely using `flutter_secure_storage`
- Keys are encrypted on device
- API key input field can be obscured for privacy
- Conversation data is stored locally on the device

## License

This project is licensed under the MIT License.
