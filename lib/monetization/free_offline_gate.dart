import 'package:flutter/material.dart';

import '../l10n/mizan_i18n.dart';
import 'monetization_controller.dart';

class FreeOfflineGate extends StatelessWidget {
  const FreeOfflineGate({required this.controller, super.key});

  final MonetizationController controller;

  @override
  Widget build(BuildContext context) {
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
                      MizanI18n.text('İnternet bağlantısı gerekli'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      MizanI18n.text(
                        'Ücretsiz sürüm çevrimiçi çalışır. Premium kullanıcılar uygulamayı internetsiz de kullanabilir.',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: controller.refreshInternetNow,
                      icon: const Icon(Icons.refresh),
                      label: Text(MizanI18n.text('Bağlantıyı yeniden kontrol et')),
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
