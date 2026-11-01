import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme.dart';
import 'package:mobile/features/auth/auth.dart';

final privacyProvider = FutureProvider<Map>((ref) async {
  try { final d = await ref.watch(apiProvider).get('/safety/privacy'); return Map<String, dynamic>.from(d as Map); } catch (_) { return {}; }
});
final notifPrefsProvider = FutureProvider<Map>((ref) async {
  try { final d = await ref.watch(apiProvider).get('/communications/preferences'); return Map<String, dynamic>.from(d as Map); } catch (_) { return {}; }
});
final sessionsProvider = FutureProvider<List<Map>>((ref) async {
  try { final d = await ref.watch(apiProvider).get('/auth/sessions'); return ((d is Map ? (d['items'] ?? d['sessions'] ?? d['data'] ?? []) : d) as List).cast<Map>(); } catch (_) { return []; }
});

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(appBar: AppBar(title: const Text('Mipangilio')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _sec('Akaunti'),
        _entry(Icons.person_outline, 'Taarifa za akaunti', () {}),
        _entry(Icons.lock_outline, 'Nenosiri', () {}),
        _entry(Icons.verified_outlined, 'Uthibitisho', () {}),
        _sessions(ref),
        const SizedBox(height: 16),
        _sec('Privacy'),
        _privacy(ref),
        const SizedBox(height: 16),
        _sec('Arifa'),
        _notifPrefs(ref),
        const SizedBox(height: 16),
        _sec('Hatari'),
        ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.logout, color: NipTheme.error),
          title: const Text('Toka kwenye vifaa vyote', style: TextStyle(color: NipTheme.error)),
          onTap: () => _confirm(context, 'Toka kwenye vifaa vyote?', () => ref.read(apiProvider).post('/auth/logout-all').then((_) => ref.read(authProvider.notifier).logout()))),
        ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.pause_circle_outlined, color: NipTheme.warn),
          title: const Text('Zima akaunti (deactivate)', style: TextStyle(color: NipTheme.warn)),
          onTap: () => _confirm(context, 'Akaunti itazimwa kwa muda — unaendelea?', () async {
            try {
              final me = await ref.read(apiProvider).get('/accounts/active');
              await ref.read(apiProvider).post('/accounts/${me['accountId'] ?? me['id']}/deactivate');
            } catch (_) {}
          })),
        ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.delete_forever_outlined, color: NipTheme.error),
          title: const Text('Futa akaunti', style: TextStyle(color: NipTheme.error)),
          onTap: () => _confirm(context, 'Hii ni hatua ya kudumu. Futa akaunti?', () async {
            try {
              final me = await ref.read(apiProvider).get('/accounts/active');
              await ref.read(apiProvider).post('/accounts/${me['accountId'] ?? me['id']}/delete-request');
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ombi la kufuta limetumwa')));
            } catch (_) {}
          })),
      ]));
  }

  Widget _sec(String t) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(t.toUpperCase(), style: const TextStyle(color: NipTheme.inkSoft, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1)));
  Widget _entry(IconData i, String t, VoidCallback onTap) => ListTile(contentPadding: EdgeInsets.zero,
    leading: Icon(i, color: NipTheme.inkSoft), title: Text(t, style: const TextStyle(color: NipTheme.ink, fontWeight: FontWeight.w600)),
    trailing: const Icon(Icons.chevron_right, color: NipTheme.inkSoft), onTap: onTap);

  Widget _sessions(WidgetRef ref) {
    final s = ref.watch(sessionsProvider).value ?? [];
    if (s.isEmpty) return const SizedBox();
    return Column(children: s.map((sess) => ListTile(dense: true, contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.devices, color: NipTheme.inkSoft, size: 20),
      title: Text(sess['device'] ?? sess['deviceName'] ?? 'Device', style: const TextStyle(fontSize: 13, color: NipTheme.ink)),
      trailing: sess['current'] == true ? const Text('Hii', style: TextStyle(color: NipTheme.success, fontSize: 12)) : null)).toList());
  }

  Widget _privacy(WidgetRef ref) {
    final p = ref.watch(privacyProvider).value ?? {};
    if (p.isEmpty) return const Text('Mipangilio haipatikani', style: TextStyle(color: NipTheme.inkSoft));
    return Column(children: [
      _toggle(ref, 'Onyesha wasifu kwa umma', p['profileVisibility'] == 'PUBLIC', (v) => ref.read(apiProvider).patch('/safety/privacy', data: {'profileVisibility': v ? 'PUBLIC' : 'PRIVATE'}).then((_) => ref.refresh(privacyProvider))),
      _toggle(ref, 'Onyesha online status', p['showOnline'] == true, (v) => ref.read(apiProvider).patch('/safety/privacy', data: {'showOnline': v}).then((_) => ref.refresh(privacyProvider))),
    ]);
  }

  Widget _notifPrefs(WidgetRef ref) {
    final p = ref.watch(notifPrefsProvider).value ?? {};
    if (p.isEmpty) return const Text('Mipangilio haipatikani', style: TextStyle(color: NipTheme.inkSoft));
    return Column(children: [
      _toggle(ref, 'Arifa za ujumbe', p['messages'] != false, (v) => ref.read(apiProvider).patch('/communications/preferences', data: {'messages': v}).then((_) => ref.refresh(notifPrefsProvider))),
      _toggle(ref, 'Arifa za likes', p['likes'] != false, (v) => ref.read(apiProvider).patch('/communications/preferences', data: {'likes': v}).then((_) => ref.refresh(notifPrefsProvider))),
    ]);
  }

  Widget _toggle(WidgetRef ref, String label, bool val, ValueChanged<bool> onChanged) => SwitchListTile(
    contentPadding: EdgeInsets.zero, title: Text(label, style: const TextStyle(color: NipTheme.ink, fontSize: 14)),
    value: val, activeThumbColor: NipTheme.coral, onChanged: onChanged);

  void _confirm(BuildContext c, String msg, VoidCallback onYes) => showDialog(context: c, builder: (ctx) => AlertDialog(
    content: Text(msg),
    actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Ghairi')),
      TextButton(onPressed: () { Navigator.pop(ctx); onYes(); }, child: const Text('Ndio', style: TextStyle(color: NipTheme.error)))]));
}
