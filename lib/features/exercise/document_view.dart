import 'package:material_ui/material_ui.dart';

import '../../data/exercises/models.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/l10n_labels.dart';

/// Renders one document with a look adapted to its type (e-mail, SMS, ad, chat...).
/// [spanBuilder] replaces the plain text, e.g. to show the blanks of Part 6.
class DocumentView extends StatelessWidget {
  const DocumentView({super.key, required this.document, this.spanBuilder});

  final ExerciseDocument document;
  final TextSpan Function(TextStyle? base)? spanBuilder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final type = document.type;
    final l10n = AppLocalizations.of(context);

    TextStyle? style = theme.textTheme.bodyLarge;
    if (const {DocumentType.invoice, DocumentType.schedule, DocumentType.form}.contains(type)) {
      style = theme.textTheme.bodyMedium?.copyWith(fontFamily: 'monospace');
    } else if (const {DocumentType.letter, DocumentType.article}.contains(type)) {
      style = style?.copyWith(fontFamily: 'serif');
    }

    Widget body() => SelectableText.rich(
          spanBuilder?.call(style) ?? TextSpan(text: document.text, style: style),
        );

    Widget boxed(Widget child, {Color? color, Color? border, double radius = 12}) => DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(radius),
            border: border == null ? null : Border.all(color: border, width: 1.5),
          ),
          child: Padding(padding: const EdgeInsets.all(16), child: child),
        );

    final title = document.title;
    final Widget content = switch (type) {
      DocumentType.textMessage => Align(
          alignment: Alignment.centerLeft,
          child: boxed(body(), color: scheme.secondaryContainer, radius: 20),
        ),
      DocumentType.onlineChat when spanBuilder == null => _ChatBubbles(text: document.text),
      DocumentType.advertisement || DocumentType.jobAd =>
        boxed(body(), color: scheme.primaryContainer),
      DocumentType.notice => boxed(body(), border: scheme.error),
      DocumentType.memo => boxed(body(), color: scheme.surfaceContainerHighest, radius: 4),
      DocumentType.invoice || DocumentType.schedule || DocumentType.form =>
        boxed(body(), color: scheme.surfaceContainerHighest, border: scheme.outlineVariant, radius: 4),
      DocumentType.webPage => Column(children: [
          boxed(
            Row(children: [
              Icon(Icons.lock_outline, size: 16, color: scheme.outline),
              const SizedBox(width: 8),
              Expanded(child: Text(title ?? l10n.documentTypeName(type), overflow: TextOverflow.ellipsis)),
            ]),
            color: scheme.surfaceContainerHighest,
            radius: 24,
          ),
          const SizedBox(height: 12),
          body(),
        ]),
      DocumentType.review => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            for (var i = 0; i < 5; i++) Icon(Icons.star, size: 18, color: scheme.primary),
          ]),
          const SizedBox(height: 8),
          body(),
        ]),
      _ => body(),
    };

    // The title is the subject line of an e-mail/memo, otherwise a heading.
    final showTitle = title != null && type != DocumentType.webPage;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(_iconFor(type), size: 20, color: scheme.primary),
              const SizedBox(width: 8),
              Text(l10n.documentTypeName(type), style: theme.textTheme.labelLarge),
            ]),
            if (showTitle) ...[
              const SizedBox(height: 8),
              Text(title, style: theme.textTheme.titleMedium),
            ],
            const Divider(height: 24),
            content,
          ],
        ),
      ),
    );
  }

  static IconData _iconFor(DocumentType type) => switch (type) {
        DocumentType.email => Icons.email_outlined,
        DocumentType.letter => Icons.mail_outline,
        DocumentType.memo => Icons.sticky_note_2_outlined,
        DocumentType.notice => Icons.campaign_outlined,
        DocumentType.advertisement => Icons.local_offer_outlined,
        DocumentType.article => Icons.article_outlined,
        DocumentType.textMessage => Icons.sms_outlined,
        DocumentType.onlineChat => Icons.forum_outlined,
        DocumentType.form => Icons.assignment_outlined,
        DocumentType.invoice => Icons.receipt_long_outlined,
        DocumentType.schedule => Icons.calendar_month_outlined,
        DocumentType.jobAd => Icons.work_outline,
        DocumentType.webPage => Icons.language,
        DocumentType.review => Icons.star_outline,
      };
}

/// Online chat: each "Name: message" line becomes a bubble, one side per speaker.
/// Lines without a speaker are glued to the previous message.
class _ChatBubbles extends StatelessWidget {
  const _ChatBubbles({required this.text});

  final String text;

  static final _speaker = RegExp(r'^([^:\n]{1,30}?)\s*(?:\([^)]*\))?:\s*(.*)$');

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final messages = <(String?, String)>[];
    for (final line in text.split('\n').where((l) => l.trim().isNotEmpty)) {
      final match = _speaker.firstMatch(line);
      if (match != null) {
        messages.add((match.group(1), match.group(2)!));
      } else if (messages.isNotEmpty) {
        messages.last = (messages.last.$1, '${messages.last.$2}\n$line');
      } else {
        messages.add((null, line));
      }
    }
    final speakers = <String?>[];
    return Column(children: [
      for (final (speaker, message) in messages)
        Builder(builder: (context) {
          if (!speakers.contains(speaker)) speakers.add(speaker);
          final mine = speakers.indexOf(speaker).isOdd;
          return Align(
            alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              constraints: const BoxConstraints(maxWidth: 420),
              decoration: BoxDecoration(
                color: mine ? scheme.primaryContainer : scheme.secondaryContainer,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (speaker != null)
                  Text(speaker, style: Theme.of(context).textTheme.labelMedium),
                SelectableText(message),
              ]),
            ),
          );
        }),
    ]);
  }
}

/// Shows the documents of an exercise: tabs when narrow, side by side when the
/// available width allows it. A single document is shown alone.
class DocumentsPane extends StatelessWidget {
  const DocumentsPane({super.key, required this.documents, this.spanBuilder});

  final List<ExerciseDocument> documents;

  /// Optional replacement text for a single document (Part 6 blanks).
  final TextSpan Function(TextStyle? base)? spanBuilder;

  /// Width from which several documents are shown side by side.
  static const double sideBySideMinWidth = 700;

  @override
  Widget build(BuildContext context) {
    if (documents.length == 1) {
      return SingleChildScrollView(
        child: DocumentView(document: documents.single, spanBuilder: spanBuilder),
      );
    }

    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth >= sideBySideMinWidth) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final document in documents)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: SingleChildScrollView(child: DocumentView(document: document)),
                ),
              ),
          ],
        );
      }

      final l10n = AppLocalizations.of(context);
      return DefaultTabController(
        length: documents.length,
        child: Column(
          children: [
            TabBar(tabs: [
              for (var i = 0; i < documents.length; i++)
                Tab(text: documents[i].title ?? l10n.documentTab(i + 1)),
            ]),
            Expanded(
              child: TabBarView(children: [
                for (final document in documents)
                  SingleChildScrollView(
                    padding: const EdgeInsets.only(top: 12),
                    child: DocumentView(document: document),
                  ),
              ]),
            ),
          ],
        ),
      );
    });
  }
}
