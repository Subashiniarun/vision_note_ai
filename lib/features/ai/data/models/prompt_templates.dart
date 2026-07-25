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
{text}

Summary:
''';

  static const String actionItems = '''
Extract action items from the following meeting notes or document text. For each action item, identify:
1. Task description
2. Assignee (if mentioned — use "Unassigned" if not)
3. Priority (High/Medium/Low — infer from context)

Format as a markdown table with columns: Task | Assignee | Priority

Text:
{text}

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

Text:
{text}

Flashcards:
''';

  static const String mindMap = '''
Generate a mind map from the following text in Mermaid.js format.

Rules:
- Start with root \`mindmap\` element
- Identify the central topic as root
- Create hierarchical branches for subtopics
- Use indentation for nesting levels
- Maximum 3 levels deep

Text:
{text}

Mermaid mindmap:
''';

  static const String translation = '''
Translate the following text from {source_language} to {target_language}.

Rules:
- Preserve the original meaning and tone
- Keep formatting (bullet points, numbering, paragraphs)
- Do not add or remove content

Text:
{text}

Translation:
''';

  static const String grammarFix = '''
Fix grammar, spelling, and OCR errors in the following text. This text was extracted via OCR and may contain recognition errors.

Rules:
- Correct misspelled words
- Fix punctuation and capitalization
- Preserve original meaning and formatting
- Output only the corrected text, nothing else

Text:
{text}

Corrected:
''';

  static const String qaSystemPrompt = '''
You are a helpful assistant answering questions about a document. You have been given the full text of the document.

Rules:
- Answer ONLY based on the document content
- If the answer cannot be found, say "I cannot find information about this in the document."
- Be concise and direct
- Quote relevant parts when helpful

Document:
{document_text}

Now answer the user's question.
''';
}
