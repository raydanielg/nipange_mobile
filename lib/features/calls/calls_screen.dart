import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme.dart';
import 'package:mobile/features/auth/auth.dart';

final callHistoryProvider = FutureProvider<List<Map>>((ref) async {
  final d = await ref.watch(apiProvider).get('/calls/history', query: {'limit': '50'});
  final items = (d is Map ? (d['items'] ?? d['calls'] ?? d['data'] ?? []) : d) as List;
  return items.cast<Map>();
});

class CallsScreen extends ConsumerWidget {
  const CallsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(callHistoryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Calls')),
      body: history.when(
        loading: () => const Center(child: CircularProgressIndicator(color: NipTheme.coral)),
        error: (e, _) => Center(child: TextButton(onPressed: () => ref.refresh(callHistoryProvider), child: const Text('Jaribu tena'))),
        data: (items) => items.isEmpty
            ? const Center(child: Text('Hakuna calls bado', style: TextStyle(color: NipTheme.inkSoft)))
            : ListView.builder(itemCount: items.length, itemBuilder: (_, i) {
                final c = items[i];
                final missed = c['status'] == 'MISSED' || c['missed'] == true;
                return ListTile(
                  leading: CircleAvatar(backgroundColor: missed ? NipTheme.error.withValues(alpha: .12) : NipTheme.coral.withValues(alpha: .12),
                    child: Icon(c['type'] == 'VIDEO' ? Icons.videocam_outlined : Icons.call_outlined, color: missed ? NipTheme.error : NipTheme.coral)),
                  title: Text(c['peer']?['name'] ?? c['peerName'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700, color: NipTheme.ink)),
                  subtitle: Text('${c['status'] ?? ''} · ${c['type'] == 'VIDEO' ? 'Video' : 'Voice'}', style: TextStyle(color: missed ? NipTheme.error : NipTheme.inkSoft, fontSize: 12)),
                  trailing: Text(_fmt(c['startedAt'] ?? c['createdAt']), style: const TextStyle(color: NipTheme.inkSoft, fontSize: 11)),
                  onTap: () => _showCall(context, ref, c),
                );
              })),
      floatingActionButton: FloatingActionButton(backgroundColor: NipTheme.coral, onPressed: () {},
        child: const Icon(Icons.add_call, color: Colors.white)),
    );
  }

  void _showCall(BuildContext ctx, WidgetRef ref, Map c) {
    showModalBottomSheet(context: ctx, builder: (_) => Container(
      padding: const EdgeInsets.all(24), width: double.infinity,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Call back', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: NipTheme.ink)),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _btn(ctx, ref, Icons.call, 'Voice', () => _start(ctx, ref, c, 'VOICE')),
          _btn(ctx, ref, Icons.videocam, 'Video', () => _start(ctx, ref, c, 'VIDEO')),
        ]),
      ]),
    ));
  }

  Widget _btn(BuildContext ctx, WidgetRef ref, IconData i, String l, VoidCallback onTap) => Column(children: [
    CircleAvatar(radius: 28, backgroundColor: NipTheme.coral.withValues(alpha: .12), child: Icon(i, color: NipTheme.coral)),
    TextButton(onPressed: onTap, child: Text(l)),
  ]);

  Future<void> _start(BuildContext ctx, WidgetRef ref, Map peer, String type) async {
    Navigator.pop(ctx);
    // Real backend contract — creates a ringing call session.
    try {
      final res = await ref.read(apiProvider).post('/calls', data: {
        'peerAccountId': peer['peerAccountId'] ?? peer['peer']?['id'],
        'type': type,
      });
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Call ringing — ${res?['status'] ?? 'initiated'}')));
      }
    } catch (e) {
      if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Call failed: $e')));
    }
  }

  String _fmt(dynamic t) {
    if (t == null) return '';
    try { final d = DateTime.parse(t.toString()); return '${d.hour}:${d.minute.toString().padLeft(2, '0')}'; } catch (_) { return ''; }
  }
}
