import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/app/shell.dart';
import 'package:mobile/app/theme/app_theme.dart';
import 'package:mobile/core/config/env.dart';
import 'package:mobile/core/config/settings.dart';
import 'package:mobile/features/auth/auth.dart';
import 'package:mobile/features/onboarding/onboarding_screen.dart';
import 'package:mobile/features/auth/auth_screen.dart';
import 'package:mobile/l10n/app_localizations.dart';

void main() {
  Env.validate();
  runApp(const ProviderScope(child: NipangeApp()));
}

class NipangeApp extends ConsumerWidget {
  const NipangeApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    return MaterialApp(
      title: 'NIPANGE',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ref.watch(themeProvider),
      locale: ref.watch(localeProvider),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: switch (auth) {
        AuthState.unknown => const Scaffold(body: Center(child: CircularProgressIndicator())),
        AuthState.unauthenticated => const OnboardingScreen(),
        _ => const AppShell(),
      },
    );
  }
}
