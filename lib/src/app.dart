import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'models/models.dart';
import 'state/app_controller.dart';
import 'ui/screens.dart';
import 'ui/theme.dart';

enum AppVisualMode { light, dark, gamification }

class LexoraApp extends StatefulWidget {
  const LexoraApp({super.key, required this.controller});

  final AppController controller;

  @override
  State<LexoraApp> createState() => _LexoraAppState();
}

class _LexoraAppState extends State<LexoraApp> {
  AppVisualMode mode = AppVisualMode.light;

  void setVisualMode(AppVisualMode nextMode) {
    setState(() {
      mode = nextMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      controller: widget.controller,
      setVisualMode: setVisualMode,
      visualMode: mode,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: widget.controller.t('app_name'),
        theme: _themeForMode(mode),
        darkTheme: AppTheme.dark(),
        themeMode: mode == AppVisualMode.dark ? ThemeMode.dark : ThemeMode.light,
        locale: _localeForLanguage(widget.controller.language),
        supportedLocales: const [Locale('ru'), Locale('kk'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: const RootFlow(),
      ),
    );
  }

  Locale _localeForLanguage(AppLanguage language) {
    switch (language) {
      case AppLanguage.ru:
        return const Locale('ru');
      case AppLanguage.kz:
        return const Locale('kk');
      case AppLanguage.en:
        return const Locale('en');
    }
  }

  ThemeData _themeForMode(AppVisualMode mode) {
    switch (mode) {
      case AppVisualMode.light:
        return AppTheme.light();
      case AppVisualMode.dark:
        return AppTheme.dark();
      case AppVisualMode.gamification:
        return AppTheme.gamification();
    }
  }
}

class AppScope extends InheritedNotifier<AppController> {
  const AppScope({
    super.key,
    required AppController controller,
    required this.setVisualMode,
    required this.visualMode,
    required super.child,
  }) : super(notifier: controller);

  final ValueChanged<AppVisualMode> setVisualMode;
  final AppVisualMode visualMode;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in widget tree');
    return scope!;
  }

  AppController get controller => notifier!;
}
