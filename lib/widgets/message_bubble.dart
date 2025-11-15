import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;
import '../models/chat_message.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final int? cumulativeInputTokens;
  final int? cumulativeOutputTokens;

  const MessageBubble({
    super.key,
    required this.message,
    this.cumulativeInputTokens,
    this.cumulativeOutputTokens,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * (isUser ? 0.75 : 0.95),
        ),
        decoration: BoxDecoration(
          color: isUser
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isUser
                ? SelectableText(
                    message.content,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  )
                : SelectionArea(
                    child: MarkdownBody(
                      data: message.content,
                      selectable: false,
                      shrinkWrap: true,
                      builders: {'code': CodeBlockBuilder(context)},
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSecondaryContainer,
                        ),
                        code: TextStyle(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          color: Theme.of(context).colorScheme.onSurface,
                          fontFamily: 'monospace',
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                        codeblockDecoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.outline.withValues(alpha: 0.2),
                          ),
                        ),
                        codeblockPadding: const EdgeInsets.all(12),
                        blockquote: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer
                              .withValues(alpha: 0.7),
                          fontStyle: FontStyle.italic,
                        ),
                        blockquoteDecoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 4,
                            ),
                          ),
                        ),
                        h1: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSecondaryContainer,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        h2: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSecondaryContainer,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        h3: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSecondaryContainer,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        listBullet: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                  ),
            // Token usage display
            if (message.inputTokens != null || message.outputTokens != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 1,
                      color:
                          (isUser
                                  ? Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer
                                  : Theme.of(
                                      context,
                                    ).colorScheme.onSecondaryContainer)
                              .withValues(alpha: 0.2),
                    ),
                    const SizedBox(height: 6),
                    if (message.model != null) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.memory,
                            size: 12,
                            color:
                                (isUser
                                        ? Theme.of(
                                            context,
                                          ).colorScheme.onPrimaryContainer
                                        : Theme.of(
                                            context,
                                          ).colorScheme.onSecondaryContainer)
                                    .withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Model: ${message.model}',
                            style: TextStyle(
                              fontSize: 10,
                              color:
                                  (isUser
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.onPrimaryContainer
                                          : Theme.of(
                                              context,
                                            ).colorScheme.onSecondaryContainer)
                                      .withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                    ],
                    Row(
                      children: [
                        Icon(
                          Icons.data_usage,
                          size: 12,
                          color:
                              (isUser
                                      ? Theme.of(
                                          context,
                                        ).colorScheme.onPrimaryContainer
                                      : Theme.of(
                                          context,
                                        ).colorScheme.onSecondaryContainer)
                                  .withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'In: ${message.inputTokens ?? 0} • Out: ${message.outputTokens ?? 0}',
                          style: TextStyle(
                            fontSize: 11,
                            color:
                                (isUser
                                        ? Theme.of(
                                            context,
                                          ).colorScheme.onPrimaryContainer
                                        : Theme.of(
                                            context,
                                          ).colorScheme.onSecondaryContainer)
                                    .withValues(alpha: 0.7),
                          ),
                        ),
                        if (cumulativeInputTokens != null &&
                            cumulativeOutputTokens != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            '• Total: ${cumulativeInputTokens! + cumulativeOutputTokens!}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color:
                                  (isUser
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.onPrimaryContainer
                                          : Theme.of(
                                              context,
                                            ).colorScheme.onSecondaryContainer)
                                      .withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class CodeBlockBuilder extends MarkdownElementBuilder {
  final BuildContext context;

  CodeBlockBuilder(this.context);

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    // Code blocks have a 'class' attribute starting with 'language-'
    // or are multi-line. Inline code doesn't have these attributes.
    // We check if this is a code block by looking for the language class
    // or checking if it contains newlines
    final isCodeBlock =
        element.attributes.containsKey('class') ||
        element.textContent.contains('\n');

    // Return null to use default rendering for inline code
    if (!isCodeBlock) {
      return null;
    }

    final String textContent = element.textContent;
    final language =
        element.attributes['class']?.replaceFirst('language-', '') ?? '';

    return Container(
      // margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (language.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Text(
                language,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(12),
            child: SelectableText(
              textContent,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
