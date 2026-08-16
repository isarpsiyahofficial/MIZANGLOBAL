import 'package:flutter/material.dart';

import '../l10n/mizan_i18n.dart';
import 'monetization_controller.dart';
import 'offline_gate_strings.dart';
import 'pro_branding.dart';

class FreeOfflineGate extends StatelessWidget {
  const FreeOfflineGate({required this.controller, super.key});

  final MonetizationController controller;

  @override
  Widget build(BuildContext context) {
    final languageTag = MizanI18n.languageTag;
    String visible(String raw) => ProBranding.visibleText(languageTag, raw);
    return Positioned.fill(
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.wifi_off_rounded,
                      size: 56,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      visible(OfflineGateStrings.title(languageTag)),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      visible(OfflineGateStrings.body(languageTag)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: controller.refreshInternetNow,
                      icon: const Icon(Icons.refresh),
                      label: Text(visible(OfflineGateStrings.retry(languageTag))),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
