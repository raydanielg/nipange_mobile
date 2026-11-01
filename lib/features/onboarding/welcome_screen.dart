import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/app/theme/tokens.dart';
import 'package:mobile/core/config/settings.dart';
import 'register_flow.dart';
import 'package:mobile/features/auth/auth_screen.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(NipSpace.lg),
          child: Column(children: [
            Align(alignment: Alignment.topRight, child: _LangToggle()),
            const Spacer(),
            Container(
              width: 96, height: 96,
              decoration: BoxDecoration(color: NipColors.coral.withValues(alpha: .12), borderRadius: BorderRadius.circular(28)),
              child: const Icon(Icons.favorite, color: NipColors.coral, size: 48),
            ),
            const SizedBox(height: NipSpace.lg),
            const Text('NIPANGE', style: TextStyle(color: NipColors.coral, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -1)),
            const SizedBox(height: 8),
            Text('Kuungana • Kupendana • Kugundua', style: Theme.of(context).textTheme.bodyMedium),
            const Spacer(),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterFlow())),
              child: const Text('Fungua akaunti')),
            const SizedBox(height: NipSpace.sm),
            OutlinedButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AuthScreen())),
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50), side: const BorderSide(color: NipColors.coral), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NipRadius.md))),
              child: const Text('Ingia', style: TextStyle(color: NipColors.coral, fontWeight: FontWeight.w700))),
            const SizedBox(height: NipSpace.md),
            Wrap(alignment: WrapAlignment.center, spacing: 12, children: const [
              _LegalLink('Terms'), _LegalLink('Privacy'), _LegalLink('Guidelines'),
            ]),
          ]),
        ),
      ),
    );
  }
}

class _LangToggle extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    return SegmentedButton<String>(
      segments: const [ButtonSegment(value: 'en', label: Text('EN')), ButtonSegment(value: 'sw', label: Text('SW'))],
      selected: {locale?.languageCode ?? 'en'},
      onSelectionChanged: (s) => ref.read(localeProvider.notifier).set(Locale(s.first)),
      style: ButtonStyle(visualDensity: VisualDensity.compact),
    );
  }
}

class _LegalLink extends StatelessWidget {
  const _LegalLink(this.t);
  final String t;
  @override
  Widget build(BuildContext c) => InkWell(onTap: () {}, child: Text(t, style: const TextStyle(color: NipColors.inkSoft, fontSize: 12, decoration: TextDecoration.underline)));
}
