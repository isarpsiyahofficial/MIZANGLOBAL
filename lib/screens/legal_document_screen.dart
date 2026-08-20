import 'package:flutter/material.dart';

import '../l10n/mizan_i18n.dart';
import '../legal/legal_consent_strings.dart';
import '../legal/legal_documents.dart';
import '../legal/legal_turkish_documents.dart';

class LegalDocumentScreen extends StatefulWidget {
  const LegalDocumentScreen({
    required this.type,
    this.requireReadToEnd = false,
    super.key,
  });

  final LegalDocumentType type;
  final bool requireReadToEnd;

  @override
  State<LegalDocumentScreen> createState() => _LegalDocumentScreenState();
}

class _LegalDocumentScreenState extends State<LegalDocumentScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _reachedEnd = false;

  String get _languageTag => MizanI18n.languageTag;
  String _t(String key) => LegalConsentStrings.text(_languageTag, key);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
  }

  void _onScroll() {
    if (_reachedEnd || !_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.maxScrollExtent <= 0 ||
        position.pixels >= position.maxScrollExtent) {
      if (mounted) setState(() => _reachedEnd = true);
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  String get _title => switch (widget.type) {
    LegalDocumentType.privacy => _t('privacy'),
    LegalDocumentType.terms => _t('terms'),
    LegalDocumentType.purchase => _t('purchase'),
  };

  @override
  Widget build(BuildContext context) {
    final englishMaster = MizanLegalDocuments.document(
      widget.type,
      _languageTag,
    ).englishMaster.trim();
    final turkishMaster = LegalTurkishDocuments.forType(widget.type).trim();
    final canComplete = !widget.requireReadToEnd || _reachedEnd;
    final purchaseAcceptance =
        widget.requireReadToEnd && widget.type == LegalDocumentType.purchase;

    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Türkçe',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            turkishMaster,
                            style: const TextStyle(height: 1.55),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'English',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            englishMaster,
                            style: const TextStyle(height: 1.55),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (widget.requireReadToEnd)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: canComplete
                        ? () => Navigator.of(context).pop(true)
                        : null,
                    icon: Icon(
                      canComplete
                          ? Icons.check_circle_outline
                          : Icons.lock_outline,
                    ),
                    label: Text(
                      purchaseAcceptance ? _t('accept') : _t('readDone'),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
