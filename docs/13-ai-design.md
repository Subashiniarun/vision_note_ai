# VisionNote AI — AI Design Document

**Version:** 1.0  
**Date:** 2026-07-25  
**Author:** AI Solutions Architect

---

## 1. AI Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                   AI FEATURE LAYER                        │
│                                                           │
│  Summary     Action Items    Flashcards    Mind Map       │
│  Translation  Grammar Fix    Q&A Chat                    │
│                                                           │
│  All features use the same IAIRepository interface        │
└─────────────────────────┬─────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│                  AI REPOSITORY LAYER                      │
│                                                           │
│  ┌──────────────────────────────────────────────────┐    │
│  │              AIRepository                         │    │
│  │  (Dart implementation, handles prompt building,    │    │
│  │   response parsing, error handling, caching)       │    │
│  └──────────────────────┬───────────────────────────┘    │
│                         │                                  │
│                         ▼                                  │
│  ┌──────────────────────────────────────────────────┐    │
│  │              AI Provider (Abstract)               │    │
│  │  IAIClient { sendPrompt(prompt, options) }        │    │
│  └──────────────────────┬───────────────────────────┘    │
│                         │                                  │
│            ┌────────────┴────────────┐                    │
│            ▼                         ▼                    │
│  ┌──────────────────┐    ┌──────────────────┐            │
│  │  GeminiClient     │    │  OpenAIClient    │            │
│  │  (REST/HTTP)      │    │  (REST/HTTP)     │            │
│  └──────────────────┘    └──────────────────┘            │
└─────────────────────────────────────────────────────────┘
```

## 2. Provider Abstraction

### 2.1 Interface

```dart
abstract class IAIClient {
  Future<AIResponse> sendPrompt(AIRequest request);

  String get providerName;
  bool get requiresApiKey;
  Map<String, String> get availableModels;
}

class AIRequest {
  final String systemPrompt;
  final String userPrompt;
  final String? model;
  final double temperature;
  final int maxTokens;
  final ResponseFormat format; // text or json
}

class AIResponse {
  final String text;
  final String provider;
  final String model;
  final int promptTokens;
  final int completionTokens;
  final Duration latency;
}
```

### 2.2 GeminiClient Implementation

```dart
@Injectable(as: IAIClient, env: ['gemini'])
class GeminiClient implements IAIClient {
  final http.Client _http;
  final FlutterSecureStorage _secureStorage;

  @override
  Future<AIResponse> sendPrompt(AIRequest request) async {
    final apiKey = await _secureStorage.read(key: 'gemini_api_key');
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/'
      '${request.model ?? 'gemini-1.5-pro'}:generateContent?key=$apiKey'
    );

    final response = await _http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {'role': 'user', 'parts': [{'text': '${request.systemPrompt}\n\n${request.userPrompt}'}]}
        ],
        'generationConfig': {
          'temperature': request.temperature,
          'maxOutputTokens': request.maxTokens,
        }
      }),
    );

    final data = jsonDecode(response.body);
    return AIResponse(
      text: data['candidates'][0]['content']['parts'][0]['text'],
      provider: 'gemini',
      model: data['modelVersion'] ?? request.model,
      promptTokens: data['usageMetadata']['promptTokenCount'],
      completionTokens: data['usageMetadata']['candidatesTokenCount'],
      latency: Duration.zero, // measured externally
    );
  }
}
```

### 2.3 OpenAIClient Implementation

```dart
@Injectable(as: IAIClient, env: ['openai'])
class OpenAIClient implements IAIClient {
  final http.Client _http;
  final FlutterSecureStorage _secureStorage;

  @override
  Future<AIResponse> sendPrompt(AIRequest request) async {
    final apiKey = await _secureStorage.read(key: 'openai_api_key');
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');

    final response = await _http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': request.model ?? 'gpt-4o-mini',
        'messages': [
          {'role': 'system', 'content': request.systemPrompt},
          {'role': 'user', 'content': request.userPrompt},
        ],
        'temperature': request.temperature,
        'max_tokens': request.maxTokens,
      }),
    );

    final data = jsonDecode(response.body);
    return AIResponse(
      text: data['choices'][0]['message']['content'],
      provider: 'openai',
      model: data['model'],
      promptTokens: data['usage']['prompt_tokens'],
      completionTokens: data['usage']['completion_tokens'],
      latency: Duration.zero,
    );
  }
}
```

---

## 3. Prompt Engineering

### 3.1 Prompt Templates Repository

```dart
class PromptTemplates {
  static const String summary = '''
You are a precise text summarization assistant. Given OCR-extracted text from a document, produce a concise summary.

Rules:
- Identify the main topic and key points
- Use bullet points for clarity
- Keep each bullet to 1-2 sentences
- Maintain the original language
- If the text is unreadable, state "Unable to extract meaningful content"

Text to summarize:
{ttext}

Summary:
''';

  static const String actionItems = '''
Extract action items from the following meeting notes or document text. For each action item, identify:
1. Task description
2. Assignee (if mentioned — use "Unassigned" if not)
3. Priority (High/Medium/Low — infer from context)
4. Deadline (if mentioned — use "No deadline" if not)

Format as a markdown table with columns: Task | Assignee | Priority | Deadline

Text:
{ttext}

Action Items:
''';

  static const String flashcards = '''
Create study flashcards from the following text. Each flashcard should have a clear question and answer pair.

Rules:
- Focus on key concepts, definitions, facts, and relationships
- Make questions specific and answerable
- Generate 5-10 flashcards depending on content length
- Format as markdown:

## Flashcard 1
**Q:** [question]
**A:** [answer]

## Flashcard 2
...

Text:
{ttext}

Flashcards:
''';

  static const String mindMap = '''
Generate a mind map from the following text in Mermaid.js format.

Rules:
- Start with root `mindmap` element
- Identify the central topic as root
- Create hierarchical branches for subtopics
- Use indentation for nesting levels
- Maximum 3 levels deep
- Ensure the mindmap is valid Mermaid.js syntax

Text:
{ttext}

Mermaid mindmap:
''';

  static const String translation = '''
Translate the following text from {source_language} to {target_language}.

Rules:
- Preserve the original meaning and tone
- Keep formatting (bullet points, numbering, paragraphs)
- Do not add or remove content
- If the text appears to already be in {target_language}, return it unchanged

Text:
{ttext}

Translation:
''';

  static const String grammarFix = '''
Fix grammar, spelling, and OCR errors in the following text. This text was extracted via OCR and may contain recognition errors.

Rules:
- Correct misspelled words
- Fix punctuation and capitalization
- Preserve original meaning
- Preserve formatting (paragraphs, lists)
- Do not rewrite — only correct errors
- Output only the corrected text, nothing else

Text:
{ttext}

Corrected:
''';

  static const String qaSystemPrompt = '''
You are a helpful assistant answering questions about a document. You have been given the full text of the document.

Rules:
- Answer ONLY based on the document content
- If the answer cannot be found in the document, say "I cannot find information about this in the document."
- Do not use external knowledge
- Be concise and direct
- Quote relevant parts when helpful

Document:
{document_text}

Now answer the user's question.
''';
}
```

### 3.2 JSON Mode (for deterministic parsing)

```dart
class AIJsonPrompts {
  static const String summaryJson = '''
${PromptTemplates.summary}

Return your response as JSON in this exact format:
{"summary": "your summary here", "key_points": ["point 1", "point 2", ...]}
''';

  static const String actionItemsJson = '''
${PromptTemplates.actionItems}

Return your response as JSON in this exact format:
{"action_items": [
  {"task": "...", "assignee": "...", "priority": "High", "deadline": "..."}
]}
''';

  static const String flashcardsJson = '''
${PromptTemplates.flashcards}

Return your response as JSON in this exact format:
{"flashcards": [
  {"question": "...", "answer": "..."}
]}
''';
}
```

---

## 4. AI Repository Implementation

```dart
@Injectable(as: IAIRepository)
class AIRepository implements IAIRepository {
  final IAIClient _aiClient;
  final HiveCache _cache;
  final SettingsRepository _settings;

  AIRepository(this._aiClient, this._cache, this._settings);

  @override
  Future<AISummary> generateSummary(String text) async {
    final request = AIRequest(
      systemPrompt: PromptTemplates.summary,
      userPrompt: text,
      temperature: 0.3,
      maxTokens: 1024,
    );
    final response = await _aiClient.sendPrompt(request);
    return AISummary(
      summary: response.text.trim(),
      actionItems: null,
      flashcards: null,
      mindMap: null,
    );
  }

  @override
  Future<List<ActionItem>> generateActionItems(String text) async {
    if (_settings.useJsonMode) {
      final request = AIRequest(
        systemPrompt: AIJsonPrompts.actionItemsJson,
        userPrompt: text,
        temperature: 0.2,
        maxTokens: 2048,
      );
      final response = await _aiClient.sendPrompt(request);
      final json = jsonDecode(response.text);
      return (json['action_items'] as List)
          .map((item) => ActionItem(
                task: item['task'],
                assignee: item['assignee'],
                priority: item['priority'],
              ))
          .toList();
    } else {
      // Parse markdown response
      final request = AIRequest(
        systemPrompt: PromptTemplates.actionItems,
        userPrompt: text,
        temperature: 0.2,
        maxTokens: 2048,
      );
      final response = await _aiClient.sendPrompt(request);
      return _parseActionItemsFromMarkdown(response.text);
    }
  }

  @override
  Future<List<Flashcard>> generateFlashcards(String text) async {
    final request = AIRequest(
      systemPrompt: PromptTemplates.flashcards,
      userPrompt: text,
      temperature: 0.4,
      maxTokens: 2048,
    );
    final response = await _aiClient.sendPrompt(request);
    return _parseFlashcardsFromMarkdown(response.text);
  }

  @override
  Future<String> generateMindMap(String text) async {
    final request = AIRequest(
      systemPrompt: PromptTemplates.mindMap,
      userPrompt: text,
      temperature: 0.3,
      maxTokens: 2048,
    );
    final response = await _aiClient.sendPrompt(request);
    return response.text.trim();
  }

  @override
  Future<String> translate(String text, String targetLanguage) async {
    final request = AIRequest(
      systemPrompt: PromptTemplates.translation
          .replaceAll('{source_language}', _detectLanguage(text))
          .replaceAll('{target_language}', targetLanguage),
      userPrompt: text,
      temperature: 0.1, // low temperature for translation
      maxTokens: 4096,
    );
    final response = await _aiClient.sendPrompt(request);
    return response.text.trim();
  }

  @override
  Future<String> fixGrammar(String text) async {
    final request = AIRequest(
      systemPrompt: PromptTemplates.grammarFix,
      userPrompt: text,
      temperature: 0.1,
      maxTokens: 4096,
    );
    final response = await _aiClient.sendPrompt(request);
    return response.text.trim();
  }

  @override
  Future<String> askQuestion(String context, String question) async {
    final request = AIRequest(
      systemPrompt: PromptTemplates.qaSystemPrompt
          .replaceAll('{document_text}', context),
      userPrompt: question,
      temperature: 0.2,
      maxTokens: 1024,
    );
    final response = await _aiClient.sendPrompt(request);
    return response.text.trim();
  }

  // Private parsers for markdown responses
  List<ActionItem> _parseActionItemsFromMarkdown(String text) { /* ... */ }
  List<Flashcard> _parseFlashcardsFromMarkdown(String text) { /* ... */ }
}
```

---

## 5. AI Provider Switching

```dart
// In SettingsRepository
Future<IAIClient> getActiveAIClient() async {
  final provider = await _cache.get('ai_provider', defaultValue: 'gemini');
  switch (provider) {
    case 'gemini':
      return getIt<GeminiClient>();
    case 'openai':
      return getIt<OpenAIClient>();
    default:
      return getIt<GeminiClient>();
  }
}
```

## 6. Error Handling & Retry

```dart
class AIRepository {
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  Future<AIResponse> _executeWithRetry(AIRequest request) async {
    int attempts = 0;
    while (attempts < _maxRetries) {
      try {
        return await _aiClient.sendPrompt(request);
      } on SocketException {
        attempts++;
        if (attempts >= _maxRetries) {
          throw AIOfflineException('No internet connection');
        }
        await Future.delayed(_retryDelay);
      } on HttpException catch (e) {
        if (e.statusCode == 429) {
          // Rate limited
          await Future.delayed(Duration(seconds: 5));
          continue;
        }
        throw AIException('API error: ${e.statusCode}');
      }
    }
    throw AIException('Max retries exceeded');
  }
}
```

## 7. Cost & Token Budgeting

| Feature | Avg Input Tokens | Avg Output Tokens | Cost (GPT-4o-mini) |
|---|---|---|---|
| Summary (500 words) | ~700 | ~200 | ~$0.001 |
| Action Items (500 words) | ~700 | ~150 | ~$0.0008 |
| Flashcards (500 words) | ~700 | ~500 | ~$0.002 |
| Mind Map (500 words) | ~700 | ~300 | ~$0.0015 |
| Translation (500 words) | ~700 | ~500 | ~$0.002 |
| Grammar Fix (500 words) | ~700 | ~500 | ~$0.002 |
| Q&A | ~1500 | ~200 | ~$0.002 |

## 8. Offline Handling

```dart
class ConnectivityObserver {
  final BehaviorSubject<bool> _isOnline = BehaviorSubject.seeded(true);
  Stream<bool> get isOnline => _isOnline.stream;

  ConnectivityObserver() {
    Connectivity().onConnectivityChanged.listen((result) {
      _isOnline.add(result != ConnectivityResult.none);
    });
  }
}
```

When offline:
- AI features show a banner: "Connect to the internet for AI features"
- All AI buttons remain visible but are disabled with a tooltip
- The Q&A chat shows a message: "AI chat is unavailable offline"
