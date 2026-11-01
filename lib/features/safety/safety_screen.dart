import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme.dart';
import 'package:mobile/features/auth/auth.dart';

final blockedProvider = FutureProvider<List<Map>>((ref) async {
  final d = await ref.watch(apiProvider).get('/safety/blocks');
  return ((d is Map ? (d['items'] ?? d['blocks'] ?? d['data'] ?? []) : d) as List).cast<Map>();
});
final reportCatsProvider = FutureProvider<List<Map>>((ref) async {
  final d = await ref.watch(apiProvider).get('/safety/report-categories');
  return ((d is Map ? (d['items'] ?? d['categories'] ?? d['data'] ?? []) : d) as List).cast<Map>();
});

/// Safety Centre — blocked accounts, unblock, report categories.
class SafetyScreen extends ConsumerWidget {
  const SafetyScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(appBar: AppBar(title: const Text('Safety')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _sec('Ripoti'),
        _entry(context, ref, Icons.report_outlined, 'Ripoti akaunti', () => _reportSheet(context, ref)),
        _entry(context, ref, Icons.flag_outlined, 'Ripoti maudhui', () => _reportSheet(context, ref)),
        _entry(context, ref, Icons.gpp_bad_outlined, 'Ripoti matukio', () => _reportSheet(context, ref)),
        const SizedBox(height: 16),
        _sec('Walioblockiwa'),
        _blocked(ref),
        const SizedBox(height: 16),
        _sec('Rasilimali'),
        _entry(context, ref, Icons.shield_outlined, 'Miongozo ya usalama', () {}),
        _entry(context, ref, Icons.help_outline, 'Msaada', () {}),
      ]));
  }

  Widget _sec(String t) => Padding(padding: const EdgeInsets.only(bottom: 6, top: 4), child: Text(t.toUpperCase(), style: const TextStyle(color: NipTheme.inkSoft, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1)));
  Widget _entry(BuildContext c, WidgetRef r, IconData i, String t, VoidCallback onTap) => ListTile(
    leading: CircleAvatar(backgroundColor: NipTheme.coral.withValues(alpha: .12), child: Icon(i, color: NipTheme.coral, size: 20)),
    title: Text(t, style: const TextStyle(fontWeight: FontWeight.w600, color: NipTheme.ink)),
    trailing: const Icon(Icons.chevron_right, color: NipTheme.inkSoft), onTap: onTap, contentPadding: EdgeInsets.zero);

  Widget _blocked(WidgetRef ref) {
    final blocked = ref.watch(blockedProvider);
    return blocked.when(
      loading: () => const Center(child: CircularProgressIndicator(color: NipTheme.coral)),
      error: (e, _) => const SizedBox(),
      data: (items) => items.isEmpty
          ? const Text('Hakuna walioblockiwa', style: TextStyle(color: NipTheme.inkSoft))
          : Column(children: items.map((b) => ListTile(contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(backgroundColor: NipTheme.error.withValues(alpha: .12), child: const Icon(Icons.block, color: NipTheme.error, size: 18)),
              title: Text(b['target']?['name'] ?? b['targetName'] ?? '', style: const TextStyle(color: NipTheme.ink)),
              trailing: TextButton(onPressed: () => ref.read(apiProvider).del('/safety/blocks/${b['targetId'] ?? b['id']}').then((_) => ref.refresh(blockedProvider)),
                child: const Text('Ondoa')))).toList()));
  }

  void _reportSheet(BuildContext ctx, WidgetRef ref) {
    final cats = ref.read(reportCatsProvider).value ?? [];
    final reason = TextEditingController();
    showModalBottomSheet(context: ctx, isScrollControlled: true, builder: (c) => Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(c).viewInsets.bottom + 20),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Ripoti', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: NipTheme.ink)),
        const SizedBox(height: 14),
        if (cats.isEmpty) const Text('Inapakia aina za ripoti…', style: TextStyle(color: NipTheme.inkSoft))
        else ...cats.map((cat) => ListTile(dense: true, title: Text(cat['label'] ?? cat['name'] ?? ''), onTap: () async {
          Navigator.pop(c);
          try { await ref.read(apiProvider).post('/safety/reports', data: {'categoryId': cat['id'], 'reason': reason.text}); } catch (_) {}
        })),
      ])));
  }
}
