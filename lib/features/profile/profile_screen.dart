import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme.dart';
import 'package:mobile/features/auth/auth.dart';
import 'package:mobile/features/wallet/wallet_screen.dart';
import 'package:mobile/features/settings/settings_screen.dart';
import 'package:mobile/features/safety/safety_screen.dart';

final meProvider = FutureProvider<Map<String, dynamic>>((ref) async =>
    Map<String, dynamic>.from(await ref.watch(apiProvider).get('/profiles/me') as Map));

final statsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  try {
    final d = await ref.watch(apiProvider).get('/graph/me/counts');
    return Map<String, dynamic>.from(d as Map);
  } catch (_) { return {}; }
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(meProvider);
    final stats = ref.watch(statsProvider).value ?? {};
    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), actions: [
        IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen()))),
      ]),
      body: me.when(
        loading: () => const Center(child: CircularProgressIndicator(color: NipTheme.coral)),
        error: (e, _) => Center(child: TextButton(onPressed: () => ref.refresh(meProvider), child: const Text('Jaribu tena'))),
        data: (p) => ListView(padding: const EdgeInsets.all(20), children: [
          Row(children: [
            CircleAvatar(radius: 38, backgroundColor: NipTheme.coral.withValues(alpha: .12),
              child: Text((p['displayName'] ?? p['name'] ?? '?').toString().characters.first.toUpperCase(),
                  style: const TextStyle(color: NipTheme.coral, fontSize: 30, fontWeight: FontWeight.w800))),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Flexible(child: Text(p['displayName'] ?? p['name'] ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: NipTheme.ink), overflow: TextOverflow.ellipsis)),
                if (p['isVerified'] == true || p['verified'] == true) const Padding(padding: EdgeInsets.only(left: 4), child: Icon(Icons.verified, color: NipTheme.coral, size: 18)),
              ]),
              Text('@${p['username'] ?? ''}', style: const TextStyle(color: NipTheme.inkSoft)),
              if (p['bio'] != null && (p['bio'] as String).isNotEmpty)
                Padding(padding: const EdgeInsets.only(top: 4), child: Text(p['bio'], style: const TextStyle(color: NipTheme.ink, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis)),
            ])),
          ]),
          const SizedBox(height: 18),
          Row(children: [
            _stat('Posts', stats['posts'] ?? p['postCount'] ?? 0),
            _stat('Followers', stats['followers'] ?? p['followerCount'] ?? 0),
            _stat('Following', stats['following'] ?? p['followingCount'] ?? 0),
          ]),
          const SizedBox(height: 18),
          SizedBox(width: double.infinity, child: OutlinedButton.icon(
            onPressed: () => _edit(context, ref, p),
            icon: const Icon(Icons.edit_outlined, size: 18, color: NipTheme.ink),
            label: const Text('Hariri profile', style: TextStyle(color: NipTheme.ink)),
            style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFEAE7E2))),
          )),
          const SizedBox(height: 18),
          _tile(Icons.account_balance_wallet_outlined, 'Wallet', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WalletScreen()))),
          _tile(Icons.block_outlined, 'Walioblockiwa', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SafetyScreen()))),
          _tile(Icons.notifications_outlined, 'Arifa', () {}),
          _tile(Icons.privacy_tip_outlined, 'Privacy', () {}),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () => ref.read(authProvider.notifier).logout(),
            icon: const Icon(Icons.logout, color: NipTheme.error),
            label: const Text('Logout', style: TextStyle(color: NipTheme.error)),
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48), side: const BorderSide(color: NipTheme.error))),
        ]),
      ),
    );
  }

  Widget _stat(String l, Object v) => Expanded(child: Column(children: [
    Text('$v', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: NipTheme.ink)),
    Text(l, style: const TextStyle(color: NipTheme.inkSoft, fontSize: 12)),
  ]));

  Widget _tile(IconData i, String t, VoidCallback onTap) => ListTile(
    leading: Icon(i, color: NipTheme.inkSoft), title: Text(t, style: const TextStyle(color: NipTheme.ink, fontWeight: FontWeight.w600)),
    trailing: const Icon(Icons.chevron_right, color: NipTheme.inkSoft), onTap: onTap, contentPadding: EdgeInsets.zero);

  void _edit(BuildContext c, WidgetRef ref, Map<String, dynamic> p) {
    final name = TextEditingController(text: p['displayName'] ?? '');
    final bio = TextEditingController(text: p['bio'] ?? '');
    bool saving = false;
    showModalBottomSheet(context: c, isScrollControlled: true, builder: (ctx) => StatefulBuilder(builder: (_, setS) => Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Hariri profile', style: TextStyle(fontWeight: FontWeight.w800, color: NipTheme.ink, fontSize: 17)),
        const SizedBox(height: 14),
        TextField(controller: name, decoration: const InputDecoration(labelText: 'Jina linaloonekana')),
        const SizedBox(height: 12),
        TextField(controller: bio, maxLines: 3, decoration: const InputDecoration(labelText: 'Bio')),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, child: ElevatedButton(
          onPressed: saving ? null : () async {
            setS(() => saving = true);
            try {
              await ref.read(apiProvider).patch('/profiles/me', data: {'displayName': name.text.trim(), 'bio': bio.text.trim()});
              ref.invalidate(meProvider);
              if (ctx.mounted) Navigator.pop(ctx);
            } catch (_) { setS(() => saving = false); }
          },
          child: saving ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Hifadhi'))),
      ]))));
  }
}
