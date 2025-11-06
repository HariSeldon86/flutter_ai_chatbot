# Flutter AI Chatbot

A Flutter application that integrates with Together AI's API to provide an AI-powered chatbot experience using Meta-Llama-3.1-8B-Instruct-Turbo model.

## Features

- 🤖 AI-powered chat using Together AI API
- ⚡ **Real-time streaming responses** - See AI responses appear word-by-word as they're generated
- 🔐 Secure API key storage using flutter_secure_storage
- 💬 Clean and intuitive chat interface
- 📚 Conversation history with persistent storage
- 🗂️ Sidebar to manage and navigate conversations
- ➕ Create new conversations with custom titles
- 🎯 **Dynamic LLM model loading from Together AI API**
- 📊 **Model information page** with detailed specs (context length, pricing, etc.)
- 🎭 **Custom system prompts** for each conversation
- 🔄 Continue previous conversations with full context
- 🗑️ Delete conversations with swipe gesture
- ⚙️ Easy settings management
- ✏️ Edit conversation settings (title, model, system prompt)
- 🎨 Material Design 3 UI

## Project Structure

```
lib/
├── main.dart                           # App entry point
├── constants/                          # App constants
│   └── llm_models.dart                # LLM model data structures
├── models/                             # Data models
│   ├── chat_message.dart              # Chat message model
│   ├── chat_response.dart             # API response model
│   ├── chat_stream_response.dart      # Streaming API response model
│   └── conversation.dart              # Conversation model with persistence
├── services/                           # Business logic & API
│   ├── chat_service.dart              # Together AI API integration with streaming support
│   ├── model_service.dart             # Fetch available models from API
│   └── storage_service.dart           # Secure storage for API key & conversations
├── screens/                            # UI screens
│   ├── chat_screen.dart               # Main chat interface with history
│   ├── settings_screen.dart           # API key configuration
│   └── model_info_screen.dart         # Detailed model information page
└── widgets/                            # Reusable components
    ├── message_bubble.dart            # Chat message bubble widget
    ├── conversation_sidebar.dart      # Conversation history sidebar
    └── conversation_settings_dialog.dart # Dialog for conversation settings
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
2. **Custom Configuration**: 
   - Tap the "New Chat" floating button or use the sidebar menu
   - Enter a conversation title
   - Select an LLM model from the dropdown
   - (Optional) Add a system prompt to customize the AI's behavior
   - Tap "Save" to create the conversation

### Available LLM Models

Models are **dynamically loaded** from the Together AI API. The app fetches:
- Model name and display name
- Organization/creator
- Context length (token capacity)
- Pricing information (input/output costs)
- License type
- Creation date

Common models include:
- **Llama 3.1/3.2** series (Meta) - Various sizes from 3B to 405B
- **Mistral/Mixtral** series (Mistral AI) - Efficient and high-quality
- **Qwen** series - Strong multilingual support
- **Gemma** (Google) - Open models
- And many more!

**Fallback models** are available if the API is temporarily unavailable.

### Viewing Model Information

1. Tap the info icon (ℹ️) in the app bar
2. Browse models grouped by organization
3. Expand any model to see detailed information:
   - Model ID and display name
   - Organization and type
   - Context length capacity
   - License information
   - Pricing (input/output per 1M tokens)
   - Creation date

### Using System Prompts

System prompts help define the AI's behavior and personality. Examples:
- "You are a helpful coding assistant that provides clear explanations"
- "You are a creative writer who speaks in poetic language"
- "You are a professional technical support agent"
- "You always respond in the style of Shakespeare"

### Editing Conversation Settings

1. Open a conversation
2. Tap the tune icon (⚙️) in the app bar
3. Modify the title, model, or system prompt
4. Tap "Save" to apply changes

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

The app uses Together AI's Chat Completions API with **streaming support**:

- **Endpoint**: `https://api.together.xyz/v1/chat/completions`
- **Model**: `meta-llama/Meta-Llama-3.1-8B-Instruct-Turbo` (default, customizable)
- **Authentication**: Bearer token (API key)
- **Streaming**: Enabled by default for real-time responses

### Streaming Feature

The app implements real-time streaming responses using Server-Sent Events (SSE):

- Responses appear word-by-word as they're generated
- Provides immediate feedback and better user experience
- Uses `stream: true` parameter in API requests
- Parses SSE events with `data:` prefixes
- Updates UI in real-time as chunks arrive

### Example API Request (Streaming)

```bash
curl -X POST "https://api.together.xyz/v1/chat/completions" \
     -H "Authorization: Bearer $TOGETHER_API_KEY" \
     -H "Content-Type: application/json" \
     -d '{
       "model": "meta-llama/Meta-Llama-3.1-8B-Instruct-Turbo",
       "messages": [
         {"role": "user", "content": "What are some fun things to do in New York?"}
       ],
       "stream": true
     }'
```

### Streaming Response Format

The API returns Server-Sent Events with JSON payloads:

```
data: {"choices":[{"index":0,"delta":{"content":" A"}}],"id":"85ffbb8a6d2c4340-EWR","finish_reason":null,...}
data: {"choices":[{"index":0,"delta":{"content":":"}}],"id":"85ffbb8a6d2c4340-EWR","finish_reason":null,...}
data: {"choices":[{"index":0,"delta":{"content":" Sure"}}],"id":"85ffbb8a6d2c4340-EWR","finish_reason":null,...}
data: [DONE]
```

## Architecture

### Models
- **ChatMessage**: Represents a single message in the conversation (user or assistant)
- **ChatResponse**: Parses standard API responses from Together AI
- **ChatStreamResponse**: Parses streaming Server-Sent Events (SSE) responses
- **Conversation**: Represents a complete conversation with metadata (id, title, messages, timestamps, model, system prompt)
- **LLMModel**: Defines available language models with descriptions

### Services
- **ChatService**: Handles API communication with Together AI
  - `sendMessageStream()`: Streams responses in real-time using SSE
  - `sendMessage()`: Standard non-streaming API call (for backward compatibility)
  - Supports multiple models and custom system prompts
- **ModelService**: Fetches available models from Together AI API
- **StorageService**: Manages secure storage of the API key and conversation history using flutter_secure_storage

### Screens
- **ChatScreen**: Main chat interface with message list, input field, and conversation management
- **SettingsScreen**: API key configuration and management
- **ModelInfoScreen**: Detailed information page showing all available models with specs

### Widgets
- **MessageBubble**: Reusable chat bubble component for displaying messages
- **ConversationSidebar**: Drawer widget showing conversation history with navigation and deletion
- **ConversationSettingsDialog**: Dialog for creating/editing conversation settings (title, model, system prompt)

## Data Persistence

All conversations are stored securely on the device using `flutter_secure_storage`:

- **API Key**: Encrypted storage for authentication
- **Conversations**: JSON-encoded conversation history including:
  - Unique conversation ID
  - User-defined title
  - Complete message history
  - Creation and update timestamps
  - Selected LLM model
  - Custom system prompt (optional)

Data persists across app restarts and is automatically loaded when the app launches.

## Security

- API keys are stored securely using `flutter_secure_storage`
- Keys are encrypted on device
- API key input field can be obscured for privacy
- Conversation data is stored locally on the device

## License

This project is licensed under the MIT License.
