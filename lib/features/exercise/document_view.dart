import 'package:material_ui/material_ui.dart';

import '../../data/exercises/models.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/l10n_labels.dart';

/// Renders one document with a look adapted to its type (e-mail, SMS, ad...).
/// SKELETON: styling is a first pass, to be refined.
class DocumentView extends StatelessWidget {
  const DocumentView({super.key, required this.document});

  final ExerciseDocument document;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final type = document.type;
    final body = SelectableText(
      document.text,
      style: switch (type) {
        DocumentType.invoice || DocumentType.schedule || DocumentType.form =>
          theme.textTheme.bodyMedium?.copyWith(fontFamily: 'monospace'),
        _ => theme.textTheme.bodyLarge,
      },
    );

    final Widget content = switch (type) {
      DocumentType.textMessage || DocumentType.onlineChat => Align(
          alignment: Alignment.centerLeft,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.secondaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(padding: const EdgeInsets.all(16), child: body),
          ),
        ),
      DocumentType.advertisement || DocumentType.jobAd => DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(padding: const EdgeInsets.all(16), child: body),
        ),
      _ => body,
    };

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
              Text(AppLocalizations.of(context).documentTypeName(type),
                  style: theme.textTheme.labelLarge),
            ]),
            if (document.title != null) ...[
              const SizedBox(height: 8),
              Text(document.title!, style: theme.textTheme.titleMedium),
            ],
            const SizedBox(height: 12),
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

/// Shows the documents of an exercise: tabs on phones, side by side on wide screens.
/// A single document is shown alone.
class DocumentsPane extends StatelessWidget {
  const DocumentsPane({super.key, required this.documents});

  final List<ExerciseDocument> documents;

  /// Width from which documents are shown side by side.
  static const double sideBySideMinWidth = 700;

  @override
  Widget build(BuildContext context) {
    if (documents.length == 1) {
      return SingleChildScrollView(child: DocumentView(document: documents.single));
    }

    if (MediaQuery.sizeOf(context).width >= sideBySideMinWidth) {
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
  }
}
