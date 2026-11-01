import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../app/theme/tokens.dart';
import '../../core/design/nip_icons.dart';
import '../../core/storage/storages.dart';
import '../auth/auth_screen.dart';

/// Onboarding — photo hero top, white rounded card bottom (FursaHub-style).
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _S();
}

class _S extends State<OnboardingScreen> {
  final _pg = PageController();
  int _i = 0;
  static const _pages = [
    (NipIcons.heart, 'Kutana na watu wapya', 'Gundua watu karibu nawe — mapenzi, urafiki na connections za kweli.'),
    (NipIcons.chats, 'Ongea kwa urahisi', 'Ujumbe, sauti na picha — endeleza mazungumzo yenye maana.'),
    (NipIcons.shield, 'Salama na ya kweli', 'Akaunti zimehakikiwa — NIPANGE ni ya watu wazima pekee.'),
  ];

  @override
  void initState() { super.initState(); _maybeSkip(); }
  Future<void> _maybeSkip() async { if (await Prefs.onboarded && mounted) _go(); }
  void _go() => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AuthScreen()));
  void _finish() { Prefs.setOnboarded(); _go(); }

  @override
  Widget build(BuildContext context) {
    final p = _pages[_i];
    return Scaffold(
      body: Column(children: [
        // ── photo hero ──
        Expanded(flex: 55, child: Stack(children: [
          Container(color: NipColors.surface2,
            child: Center(child: HugeIcon(icon: p.$1, color: NipColors.coral.withValues(alpha: .4), size: 120))),
          // logo top
          Positioned(top: 60, left: 0, right: 0, child: Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
            HugeIcon(icon: NipIcons.heart, color: NipColors.coral, size: 22),
            const SizedBox(width: 6),
            const Text('NIPANGE', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: NipColors.ink)),
          ]))),
        ])),
        // ── white card ──
        Expanded(flex: 45, child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
          padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.$2, style: NipText.display.copyWith(fontSize: 30, height: 1.15)),
            const SizedBox(height: 12),
            Text(p.$3, style: NipText.bodySmall.copyWith(fontSize: 15, height: 1.5)),
            const Spacer(),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(_pages.length, (i) =>
              AnimatedContainer(duration: const Duration(milliseconds: 200), margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _i == i ? 26 : 8, height: 4,
                decoration: BoxDecoration(color: _i == i ? NipColors.ink : NipColors.border, borderRadius: BorderRadius.circular(2))))),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, child: FilledButton(
              onPressed: _i == _pages.length - 1 ? _finish : () => _pg.nextPage(duration: const Duration(milliseconds: 280), curve: Curves.easeOut),
              style: FilledButton.styleFrom(backgroundColor: NipColors.ink, foregroundColor: Colors.white,
                padding: const EdgeInsets.all(20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: Text(_i == _pages.length - 1 ? 'Anza' : 'Endelea', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)))),
          ]))),
      ]));
  }
}
