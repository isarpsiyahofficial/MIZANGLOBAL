import 'dart:async';

import 'core/localized_material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'controllers/mizan_controller.dart';
import 'core/theme.dart';
import 'global/global_catalog.dart';
import 'legal/legal_acceptance_store.dart';
import 'monetization/free_offline_gate.dart';
import 'monetization/monetization_aware_store.dart';
import 'monetization/monetization_controller.dart';
import 'monetization/monetization_scope.dart';
import 'screens/dashboard_screen.dart';
import 'screens/expenses_screen.dart';
import 'screens/global_setup_screen.dart';
import 'screens/legal_consent_screen.dart';
import 'screens/people_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/settings_screen.dart';
import 'services/local_store.dart';
import 'widgets/responsive_scaffold.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MizanBootstrapApp());
}

class MizanBootstrapApp extends StatefulWidget {
  const MizanBootstrapApp({super.key});

  @override
  State<MizanBootstrapApp> createState() => _MizanBootstrapAppState();
}

class _MizanBootstrapAppState extends State<MizanBootstrapApp> {
  MizanController? _controller;
  GlobalCatalog? _catalog;
  MonetizationController? _monetization;
  bool _starting = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    unawaited(_bootstrap());
  }

  Future<void> _bootstrap() async {
    if (_starting) return;
    setState(() {
      _starting = true;
      _failed = false;
    });

    MonetizationController? candidateMonetization;
    try {
      final catalog = await GlobalCatalogRepository.load();
      candidateMonetization = MonetizationController();
      final controller = MizanController(
        MonetizationAwareStore(
          delegate: LocalStore(),
          onDurableMutation:
              candidateMonetization.recordMeaningfulCompletedAction,
        ),
      );
      await controller.load();

      var legalAccepted = false;
      try {
        legalAccepted =
            await LegalAcceptanceStore.hasAcceptedCurrentLegalBundle();
      } on Object {
        legalAccepted = false;
      }
      await candidateMonetization.initialize(legalAccessGranted: legalAccepted);

      if (!mounted) {
        candidateMonetization.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _catalog = catalog;
        _monetization = candidateMonetization;
        _starting = false;
      });
    } on Object {
      candidateMonetization?.dispose();
      if (!mounted) return;
      setState(() {
        _starting = false;
        _failed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller != null) {
      return MizanApp(
        controller: controller,
        catalog: _catalog,
        monetization: _monetization,
      );
    }
    return MaterialApp(
      title: 'LEFFERION PRIME - MIZAN',
      debugShowCheckedModeBanner: false,
      theme: MizanTheme.light(),
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/brand/lefferion-prime-logo.png',
                    width: 112,
                    height: 112,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 22),
                  if (_starting) const CircularProgressIndicator(),
                  if (_failed)
                    IconButton.filled(
                      onPressed: _bootstrap,
                      icon: const Icon(Icons.refresh_rounded),
                      tooltip: 'Yeniden dene',
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MizanApp extends StatefulWidget {
  const MizanApp({
    required this.controller,
    this.monetization,
    this.catalog,
    super.key,
  });

  final MizanController controller;
  final GlobalCatalog? catalog;
  final MonetizationController? monetization;

  @override
  State<MizanApp> createState() => _MizanAppState();
}

class _MizanAppState extends State<MizanApp> {
  int _restartGeneration = 0;
  VoidCallback? _previousLanguageChanged;

  @override
  void initState() {
    super.initState();
    _bindController(widget.controller);
  }

  @override
  void didUpdateWidget(covariant MizanApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.controller, widget.controller)) {
      oldWidget.controller.onLanguageChanged = _previousLanguageChanged;
      _bindController(widget.controller);
    }
  }

  void _bindController(MizanController controller) {
    _previousLanguageChanged = controller.onLanguageChanged;
    controller.onLanguageChanged = _restartAfterLanguageChange;
  }

  void _restartAfterLanguageChange() {
    widget.controller.clearMessages();
    _previousLanguageChanged?.call();
    if (!mounted) return;
    setState(() => _restartGeneration++);
  }

  @override
  void dispose() {
    widget.controller.onLanguageChanged = _previousLanguageChanged;
    widget.monetization?.dispose();
    super.dispose();
  }

  Widget _buildMaterialApp() {
    final languageTag = MizanI18n.normalizeLanguageTag(
      widget.controller.state.appLanguageTag,
    );
    MizanI18n.setProfile(
      languageTag: languageTag,
      currencyCode: widget.controller.state.defaultCurrencyCode,
    );
    final monetization = widget.monetization;
    return MaterialApp(
      key: ValueKey<int>(_restartGeneration),
      title: 'LEFFERION PRIME - MIZAN',
      debugShowCheckedModeBanner: false,
      locale: switch (languageTag) {
        'pt-BR' => const Locale('pt', 'BR'),
        'pt-PT' => const Locale('pt', 'PT'),
        'de' => const Locale('de', 'DE'),
        'it' => const Locale('it', 'IT'),
        'nl' => const Locale('nl', 'NL'),
        'pl' => const Locale('pl', 'PL'),
        'ro' => const Locale('ro', 'RO'),
        'el' => const Locale('el', 'GR'),
        'ru' => const Locale('ru', 'RU'),
        'uk' => const Locale('uk', 'UA'),
        'ar' => const Locale('ar', 'SA'),
        'fa' => const Locale('fa', 'IR'),
        'he' => const Locale('he', 'IL'),
        'hi' => const Locale('hi', 'IN'),
        'bn' => const Locale('bn', 'BD'),
        'ur' => const Locale('ur', 'PK'),
        'id' => const Locale('id', 'ID'),
        'ms' => const Locale('ms', 'MY'),
        'fil' => const Locale('fil', 'PH'),
        'ko' => const Locale('ko', 'KR'),
        'ja' => const Locale('ja', 'JP'),
        'zh' => const Locale('zh', 'CN'),
        'vi' => const Locale('vi', 'VN'),
        'th' => const Locale('th', 'TH'),
        'sw' => const Locale('sw', 'TZ'),
        _ => Locale(languageTag),
      },
      supportedLocales: const [
        Locale('tr'),
        Locale('en'),
        Locale('es'),
        Locale('pt', 'BR'),
        Locale('pt', 'PT'),
        Locale('fr'),
        Locale('de', 'DE'),
        Locale('it', 'IT'),
        Locale('nl', 'NL'),
        Locale('pl', 'PL'),
        Locale('ro', 'RO'),
        Locale('el', 'GR'),
        Locale('ru', 'RU'),
        Locale('uk', 'UA'),
        Locale('ar', 'SA'),
        Locale('fa', 'IR'),
        Locale('he', 'IL'),
        Locale('hi', 'IN'),
        Locale('bn', 'BD'),
        Locale('ur', 'PK'),
        Locale('id', 'ID'),
        Locale('ms', 'MY'),
        Locale('fil', 'PH'),
        Locale('ko', 'KR'),
        Locale('ja', 'JP'),
        Locale('zh', 'CN'),
        Locale('vi', 'VN'),
        Locale('th', 'TH'),
        Locale('sw', 'TZ'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: MizanTheme.light(),
      home: monetization == null
          ? MizanHome(
              key: ValueKey<int>(_restartGeneration),
              controller: widget.controller,
              catalog: widget.catalog,
            )
          : Builder(
              builder: (context) => Stack(
                children: [
                  MizanHome(
                    key: ValueKey<int>(_restartGeneration),
                    controller: widget.controller,
                    catalog: widget.catalog,
                  ),
                  if (!MonetizationScope.of(context).canUseApp)
                    FreeOfflineGate(controller: MonetizationScope.of(context)),
                ],
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) {
      final app = _buildMaterialApp();
      final monetization = widget.monetization;
      if (monetization == null) return app;
      return MonetizationScope(controller: monetization, child: app);
    },
  );
}

class MizanHome extends StatefulWidget {
  const MizanHome({required this.controller, this.catalog, super.key});

  final MizanController controller;
  final GlobalCatalog? catalog;

  @override
  State<MizanHome> createState() => _MizanHomeState();
}

class _MizanHomeState extends State<MizanHome> {
  int selectedIndex = 0;
  bool? _legalAccepted;

  @override
  void initState() {
    super.initState();
    unawaited(_loadLegalAcceptance());
  }

  Future<void> _loadLegalAcceptance() async {
    var accepted = false;
    try {
      accepted = await LegalAcceptanceStore.hasAcceptedCurrentLegalBundle();
    } on Object {
      accepted = false;
    }
    if (!mounted) return;
    setState(() => _legalAccepted = accepted);
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) {
      if (!widget.controller.state.setupCompleted) {
        final catalog = widget.catalog;
        if (catalog == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return GlobalSetupScreen(
          controller: widget.controller,
          catalog: catalog,
        );
      }
      if (_legalAccepted == null) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      if (_legalAccepted == false) {
        return LegalConsentScreen(
          onAccepted: () {
            if (!mounted) return;
            final monetization = MonetizationScope.maybeOf(context);
            if (monetization != null) {
              unawaited(monetization.activateAfterLegalAcceptance());
            }
            setState(() => _legalAccepted = true);
          },
        );
      }
      final pages = [
        DashboardScreen(controller: widget.controller),
        PeopleScreen(controller: widget.controller),
        ExpensesScreen(controller: widget.controller),
        ReportsScreen(controller: widget.controller),
        SettingsScreen(controller: widget.controller, catalog: widget.catalog),
      ];
      return Stack(
        children: [
          ResponsiveScaffold(
            selectedIndex: selectedIndex,
            onSelected: (value) {
              final changed = value != selectedIndex;
              setState(() => selectedIndex = value);
              final monetization = MonetizationScope.maybeOf(context);
              if (changed && monetization != null) {
                unawaited(monetization.onNaturalAdBreak());
              }
            },
            destinations: const [
              MizanDestination(
                icon: Icons.space_dashboard_outlined,
                label: 'Ana sayfa',
              ),
              MizanDestination(
                icon: Icons.people_alt_outlined,
                label: 'Kayıtlar',
              ),
              MizanDestination(
                icon: Icons.shopping_bag_outlined,
                label: 'Giderler',
              ),
              MizanDestination(
                icon: Icons.bar_chart_outlined,
                label: 'Raporlar',
              ),
              MizanDestination(icon: Icons.settings_outlined, label: 'Ayarlar'),
            ],
            child: pages[selectedIndex],
          ),
          if (widget.controller.isBusy)
            const Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: LinearProgressIndicator(minHeight: 3),
            ),
          if (widget.controller.lastError != null ||
              widget.controller.loadMessage != null)
            Positioned(
              left: 12,
              right: 12,
              top: MediaQuery.paddingOf(context).top + 8,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(14),
                color: widget.controller.lastError != null
                    ? Theme.of(context).colorScheme.errorContainer
                    : Theme.of(context).colorScheme.secondaryContainer,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.controller.lastError ??
                              widget.controller.loadMessage!,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      IconButton(
                        tooltip: MizanI18n.text('Kapat'),
                        onPressed: widget.controller.clearMessages,
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      );
    },
  );
}
