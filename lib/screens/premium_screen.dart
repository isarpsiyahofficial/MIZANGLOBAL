import 'dart:async';

import 'package:flutter/material.dart';

import '../legal/legal_acceptance_store.dart';
import '../legal/legal_documents.dart';
import '../l10n/mizan_i18n.dart';
import '../monetization/monetization_config.dart';
import '../monetization/monetization_controller.dart';
import '../monetization/pro_branding.dart';
import 'legal_document_screen.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({required this.controller, super.key});

  final MonetizationController controller;

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  final _promoController = TextEditingController();
  bool _rewardBusy = false;

  String _t(String key) =>
      ProBranding.monetizationText(MizanI18n.languageTag, key);

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  String _remaining(Duration duration) {
    final totalSeconds = duration.inSeconds.clamp(0, 999999999).toInt();
    final days = totalSeconds ~/ 86400;
    final hours = (totalSeconds % 86400) ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    final clock =
        '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
    return days > 0 ? '$days · $clock' : clock;
  }

  String _promoMessage(String? code) => switch (code) {
    'accepted' => _t('promoAccepted'),
    'already_used' => _t('promoAlreadyUsed'),
    'invalid_code' || 'unknown_code' || 'rejected' => _t('promoInvalid'),
    _ => '',
  };

  Future<void> _redeemPromo() async {
    final result = await widget.controller.redeemPromo(_promoController.text);
    if (!mounted) return;
    if (result.accepted) _promoController.clear();
    final message = _promoMessage(result.messageCode);
    if (message.isNotEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _watchReward() async {
    if (_rewardBusy || widget.controller.rewardFlowBusy) return;
    setState(() => _rewardBusy = true);
    await widget.controller.watchRewardedForDailyPremium();
    if (!mounted) return;
    setState(() => _rewardBusy = false);
  }

  Future<void> _buy() async {
    if (widget.controller.purchaseService.product == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_t('purchaseUnavailable'))));
      return;
    }

    final accepted =
        await LegalAcceptanceStore.hasAcceptedCurrentPurchaseTerms();
    if (!accepted) {
      if (!mounted) return;
      final didRead = await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) => const LegalDocumentScreen(
            type: LegalDocumentType.purchase,
            requireReadToEnd: true,
          ),
        ),
      );
      if (didRead != true) return;
      final recorded = await LegalAcceptanceStore.acceptCurrentPurchaseTerms();
      if (!recorded) return;
    }

    final started = await widget.controller.buyPermanentPremium();
    if (!mounted || started) return;
    final error = widget.controller.purchaseService.lastError;
    final message = error == 'product_unavailable'
        ? _t('purchaseUnavailable')
        : _t('internetRequired');
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _openLegal(LegalDocumentType type) {
    unawaited(
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => LegalDocumentScreen(type: type),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) {
      final controller = widget.controller;
      final product = controller.purchaseService.product;
      final permanent = controller.isPermanentPremium;
      final temporary = controller.isTemporaryPremium;
      final canBuyLifetime =
          product != null && !controller.purchaseService.isPurchasing;
      final statusTitle = permanent
          ? _t('lifetimePremium')
          : temporary
          ? _t('temporaryPremium')
          : _t('freePlan');
      final statusValue = permanent
          ? _t('lifetime')
          : temporary
          ? _remaining(controller.temporaryPremiumRemaining)
          : _t('premiumSubtitle');
      final statusKey = permanent
          ? 'premium-status-permanent'
          : temporary
          ? 'premium-status-temporary'
          : 'premium-status-free';

      return Scaffold(
        appBar: AppBar(title: Text(_t('premium'))),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              key: ValueKey(statusKey),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          permanent || temporary
                              ? Icons.workspace_premium_rounded
                              : Icons.workspace_premium_outlined,
                          size: 34,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                statusTitle,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 4),
                              Text(statusValue),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (temporary) ...[
                      const SizedBox(height: 14),
                      LinearProgressIndicator(
                        value:
                            controller.temporaryPremiumRemaining.inSeconds <= 0
                            ? 0
                            : null,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              key: const ValueKey('premium-active-benefits'),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BenefitRow(icon: Icons.block, label: _t('benefitNoAds')),
                    const SizedBox(height: 12),
                    _BenefitRow(
                      icon: Icons.wifi_off,
                      label: _t('benefitOffline'),
                    ),
                    const SizedBox(height: 12),
                    _BenefitRow(
                      icon: Icons.picture_as_pdf_outlined,
                      label: _t('benefitPdf'),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      key: const ValueKey('premium-lifetime-benefits'),
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _t('lifetimePremium'),
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 8),
                          _BenefitRow(
                            icon: Icons.backup_outlined,
                            label: MizanI18n.text('CSV yedekleme'),
                          ),
                          const SizedBox(height: 8),
                          _BenefitRow(
                            icon: Icons.download_outlined,
                            label: MizanI18n.text('CSV yedeğini dışa aktar'),
                          ),
                          const SizedBox(height: 8),
                          _BenefitRow(
                            icon: Icons.merge_type_outlined,
                            label: MizanI18n.text(
                              'CSV yedeğini mevcut verilerle birleştir',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (!permanent)
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          key: const ValueKey('premium-lifetime-purchase'),
                          onPressed: canBuyLifetime ? _buy : null,
                          icon: controller.purchaseService.isPurchasing
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.shopping_bag_outlined),
                          label: Text(
                            product == null
                                ? _t('buyLifetime')
                                : '${_t('buyLifetime')} · ${product.price}',
                          ),
                        ),
                      ),
                    if (!permanent && product == null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _t('purchaseUnavailable'),
                        key: const ValueKey(
                          'premium-lifetime-purchase-unavailable',
                        ),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    const SizedBox(height: 10),
                    Text(
                      _t('playPrice'),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _t('restoreInfo'),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TextButton.icon(
                        onPressed: () => _openLegal(LegalDocumentType.purchase),
                        icon: const Icon(Icons.receipt_long_outlined),
                        label: Text(_t('purchaseTerms')),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (controller.shouldShowRewardedPremium) ...[
              const SizedBox(height: 12),
              Card(
                key: const ValueKey('premium-reward-offer'),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _t('rewardTitle'),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 6),
                      Text(_t('rewardSubtitle')),
                      const SizedBox(height: 14),
                      Text(
                        '${_t('rewardProgress')}: '
                        '${controller.rewardedViewsToday}/'
                        '${MonetizationConfig.rewardedViewsRequiredForDailyPremium}',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value:
                            controller.rewardedViewsToday /
                            MonetizationConfig
                                .rewardedViewsRequiredForDailyPremium,
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed:
                              _rewardBusy ||
                                  controller.rewardFlowBusy ||
                                  !controller.isOnline
                              ? null
                              : _watchReward,
                          icon: _rewardBusy || controller.rewardFlowBusy
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.ondemand_video_outlined),
                          label: Text(_t('watchReward')),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (!permanent) ...[
              const SizedBox(height: 12),
              Card(
                key: const ValueKey('premium-promo-offer'),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _t('promoTitle'),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _promoController,
                        textCapitalization: TextCapitalization.characters,
                        autocorrect: false,
                        enableSuggestions: false,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: _t('promoHint'),
                        ),
                        onSubmitted: (_) => _redeemPromo(),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.tonal(
                          onPressed: controller.redeemingPromo
                              ? null
                              : _redeemPromo,
                          child: controller.redeemingPromo
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(_t('promoApply')),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined),
                    title: Text(_t('privacyPolicy')),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _openLegal(LegalDocumentType.privacy),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.gavel_outlined),
                    title: Text(_t('terms')),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _openLegal(LegalDocumentType.terms),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.receipt_long_outlined),
                    title: Text(_t('purchaseTerms')),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _openLegal(LegalDocumentType.purchase),
                  ),
                ],
              ),
            ),
            if (controller.privacyOptionsRequired) ...[
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.ads_click_outlined),
                  title: Text(_t('privacyOptions')),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: controller.showPrivacyOptions,
                ),
              ),
            ],
          ],
        ),
      );
    },
  );
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 21),
      const SizedBox(width: 10),
      Expanded(child: Text(label)),
    ],
  );
}
