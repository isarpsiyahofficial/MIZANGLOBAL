import 'dart:async';

import 'core/localized_material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'controllers/mizan_controller.dart';
import 'core/theme.dart';
import 'global/global_catalog.dart';
import 'screens/dashboard_screen.dart';
import 'screens/expenses_screen.dart';
import 'screens/global_setup_screen.dart';
import 'screens/people_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/settings_screen.dart';
import 'services/local_store.dart';
import 'services/notification_service.dart';
import 'widgets/responsive_scaffold.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final catalog = await GlobalCatalogRepository.load();
  final controller = MizanController(
    LocalStore(),
    scheduler: LocalNotificationService(),
  );
  await controller.load();
  runApp(MizanApp(controller: controller, catalog: catalog));
}

class MizanApp extends StatefulWidget {
  const MizanApp({required this.controller, this.catalog, super.key});
  final MizanController controller;
  final GlobalCatalog? catalog;

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
    _previousLanguageChanged?.call();
    if (!mounted) return;
    setState(() => _restartGeneration++);
  }

  @override
  void dispose() {
    widget.controller.onLanguageChanged = _previousLanguageChanged;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) {
      final languageTag = MizanI18n.normalizeLanguageTag(
        widget.controller.state.appLanguageTag,
      );
      MizanI18n.setProfile(
        languageTag: languageTag,
        currencyCode: widget.controller.state.defaultCurrencyCode,
      );
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
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: MizanTheme.light(),
        home: MizanHome(
          key: ValueKey<int>(_restartGeneration),
          controller: widget.controller,
          catalog: widget.catalog,
        ),
      );
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

class _MizanHomeState extends State<MizanHome> with WidgetsBindingObserver {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(widget.controller.synchronizeNotificationsAfterSystemResume());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
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
        final pages = [
          DashboardScreen(controller: widget.controller),
          PeopleScreen(controller: widget.controller),
          ExpensesScreen(controller: widget.controller),
          ReportsScreen(controller: widget.controller),
          SettingsScreen(
            controller: widget.controller,
            catalog: widget.catalog,
          ),
        ];
        return Stack(
          children: [
            ResponsiveScaffold(
              selectedIndex: selectedIndex,
              onSelected: (value) => setState(() => selectedIndex = value),
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
                MizanDestination(
                  icon: Icons.settings_outlined,
                  label: 'Ayarlar',
                ),
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
}
