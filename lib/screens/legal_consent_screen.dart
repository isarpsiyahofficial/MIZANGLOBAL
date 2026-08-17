import 'package:flutter/material.dart';

import '../l10n/mizan_i18n.dart';
import '../legal/legal_acceptance_store.dart';
import '../legal/legal_consent_strings.dart';
import '../legal/legal_documents.dart';
import 'legal_document_screen.dart';

class LegalConsentScreen extends StatefulWidget {
  const LegalConsentScreen({required this.onAccepted, super.key});

  final VoidCallback onAccepted;

  @override
  State<LegalConsentScreen> createState() => _LegalConsentScreenState();
}

class _LegalConsentScreenState extends State<LegalConsentScreen> {
  final Set<LegalDocumentType> _read = <LegalDocumentType>{};
  bool _saving = false;

  String get _languageTag => MizanI18n.languageTag;
  String _t(String key) => LegalConsentStrings.text(_languageTag, key);

  Future<void> _open(LegalDocumentType type) async {
    final didRead = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => LegalDocumentScreen(
          type: type,
          requireReadToEnd: true,
        ),
      ),
    );
    if (!mounted || didRead != true) return;
    setState(() => _read.add(type));
  }

  Future<void> _accept() async {
    if (_saving || _read.length != LegalDocumentType.values.length) return;
    setState(() => _saving = true);
    await LegalAcceptanceStore.acceptCurrentLegalBundle();
    if (!mounted) return;
    widget.onAccepted();
  }

  Widget _documentTile(
    LegalDocumentType type,
    String label,
    IconData icon,
  ) {
    final read = _read.contains(type);
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        subtitle: read ? Text(_t('readDone')) : null,
        trailing: Icon(
          read ? Icons.check_circle_rounded : Icons.chevron_right_rounded,
        ),
        onTap: () => _open(type),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canAccept = _read.length == LegalDocumentType.values.length;
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(_t('title')),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                _t('intro'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(_t('masterNotice')),
              const SizedBox(height: 18),
              _documentTile(
                LegalDocumentType.privacy,
                _t('privacy'),
                Icons.privacy_tip_outlined,
              ),
              _documentTile(
                LegalDocumentType.terms,
                _t('terms'),
                Icons.gavel_outlined,
              ),
              _documentTile(
                LegalDocumentType.purchase,
                _t('purchase'),
                Icons.receipt_long_outlined,
              ),
              const SizedBox(height: 10),
              if (!canAccept)
                Text(
                  _t('blocked'),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: canAccept && !_saving ? _accept : null,
                  icon: _saving
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.verified_user_outlined),
                  label: Text(_t('accept')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
