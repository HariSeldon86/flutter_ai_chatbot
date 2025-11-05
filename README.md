# Flutter AI Chatbot

A Flutter application that integrates with Together AI's API to provide an AI-powered chatbot experience using Meta-Llama-3.1-8B-Instruct-Turbo model.

## Features

- 🤖 AI-powered chat using Together AI API
- 🔐 Secure API key storage using flutter_secure_storage
- 💬 Clean and intuitive chat interface
- ⚙️ Easy settings management
- 🎨 Material Design 3 UI

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── models/                      # Data models
│   ├── chat_message.dart       # Chat message model
│   └── chat_response.dart      # API response model
├── services/                    # Business logic & API
│   ├── chat_service.dart       # Together AI API integration
│   └── storage_service.dart    # Secure storage for API key
├── screens/                     # UI screens
│   ├── chat_screen.dart        # Main chat interface
│   └── settings_screen.dart    # API key configuration
└── widgets/                     # Reusable components
    └── message_bubble.dart     # Chat message bubble widget
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
- **flutter_secure_storage**: ^9.2.4 - Secure storage for API key

## Usage

1. **Configure API Key**: Navigate to Settings and enter your Together AI API key
2. **Start Chatting**: Return to the chat screen and type your message
3. **Send Message**: Press the send button or hit enter
4. **View Response**: The AI will respond to your message

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

### Services
- **ChatService**: Handles API communication with Together AI
- **StorageService**: Manages secure storage of the API key using flutter_secure_storage

### Screens
- **ChatScreen**: Main chat interface with message list and input field
- **SettingsScreen**: API key configuration and management

### Widgets
- **MessageBubble**: Reusable chat bubble component for displaying messages

## Security

- API keys are stored securely using `flutter_secure_storage`
- Keys are encrypted on device
- API key input field can be obscured for privacy

## License

This project is licensed under the MIT License.
