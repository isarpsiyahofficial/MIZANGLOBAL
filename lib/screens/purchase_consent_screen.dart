import 'package:flutter/material.dart';

import '../legal/legal_acceptance_store.dart';
import '../legal/legal_consent_strings.dart';
import '../legal/legal_documents.dart';
import '../l10n/mizan_i18n.dart';
import '../monetization/pro_branding.dart';
import 'legal_document_screen.dart';

class PurchaseConsentScreen extends StatefulWidget {
  const PurchaseConsentScreen({super.key});

  @override
  State<PurchaseConsentScreen> createState() => _PurchaseConsentScreenState();
}

class _PurchaseConsentScreenState extends State<PurchaseConsentScreen> {
  static const _documents = <LegalDocumentType>[LegalDocumentType.purchase];

  final Set<LegalDocumentType> _read = <LegalDocumentType>{};
  bool _saving = false;

  String get _languageTag => MizanI18n.languageTag;
  String _t(String key) => LegalConsentStrings.text(_languageTag, key);
  String _pro(String key) => ProBranding.monetizationText(_languageTag, key);

  Future<void> _open(LegalDocumentType type) async {
    final didRead = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => LegalDocumentScreen(
          type: type,
          requireReadToEnd: true,
          completionIsAcceptance: false,
        ),
      ),
    );
    if (!mounted || didRead != true) return;
    setState(() => _read.add(type));
  }

  Future<void> _accept() async {
    if (_saving || !_documents.every(_read.contains)) return;
    setState(() => _saving = true);
    final recorded = await LegalAcceptanceStore.acceptCurrentPurchaseTerms();
    if (!mounted) return;
    if (!recorded) {
      setState(() => _saving = false);
      return;
    }
    Navigator.of(context).pop(true);
  }

  String _label(LegalDocumentType type) => switch (type) {
    LegalDocumentType.privacy => _t('privacy'),
    LegalDocumentType.terms => _t('terms'),
    LegalDocumentType.purchase => _t('purchase'),
  };

  IconData _icon(LegalDocumentType type) => switch (type) {
    LegalDocumentType.privacy => Icons.privacy_tip_outlined,
    LegalDocumentType.terms => Icons.gavel_outlined,
    LegalDocumentType.purchase => Icons.receipt_long_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final canAccept = _documents.every(_read.contains);
    final scheme = Theme.of(context).colorScheme;
    return PopScope(
      canPop: !_saving,
      child: Scaffold(
        appBar: AppBar(title: Text(_pro('purchaseTerms'))),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: scheme.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            color: scheme.onPrimary,
                            size: 34,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            _pro('lifetimePremium'),
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: scheme.onPrimary,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _pro('purchaseModel'),
                            style: TextStyle(
                              color: scheme.onPrimary.withValues(alpha: .9),
                              fontWeight: FontWeight.w700,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(_t('masterNotice')),
                    const SizedBox(height: 16),
                    for (final type in _documents) ...[
                      Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                          leading: Icon(_icon(type)),
                          title: Text(
                            _label(type),
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          subtitle: _read.contains(type)
                              ? Text(_t('readDone'))
                              : null,
                          trailing: Icon(
                            _read.contains(type)
                                ? Icons.check_circle_rounded
                                : Icons.chevron_right_rounded,
                            color: _read.contains(type) ? Colors.green : null,
                          ),
                          onTap: _saving ? null : () => _open(type),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    key: const ValueKey('purchase-bundle-accept'),
                    onPressed: canAccept && !_saving ? _accept : null,
                    icon: _saving
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            canAccept
                                ? Icons.check_circle_outline
                                : Icons.lock_outline,
                          ),
                    label: Text(_t('accept')),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
