import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme.dart';
import 'package:mobile/features/auth/auth.dart';

final notificationsProvider = FutureProvider<List<Map>>((ref) async {
  final d = await ref.watch(apiProvider).get('/communications/notifications', query: {'limit': '50'});
  final items = (d is Map ? (d['items'] ?? d['notifications'] ?? d['data'] ?? []) : d) as List;
  return items.cast<Map>();
});

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifs = ref.watch(notificationsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Arifa'), actions: [
        TextButton(onPressed: () => ref.read(apiProvider).patch('/communications/notifications/read-all').then((_) => ref.refresh(notificationsProvider)),
          child: const Text('Soma zote', style: TextStyle(color: NipTheme.coral))),
      ]),
      body: RefreshIndicator(
        color: NipTheme.coral,
        onRefresh: () => ref.refresh(notificationsProvider.future),
        child: notifs.when(
          loading: () => const Center(child: CircularProgressIndicator(color: NipTheme.coral)),
          error: (e, _) => Center(child: TextButton(onPressed: () => ref.refresh(notificationsProvider), child: const Text('Jaribu tena'))),
          data: (items) => items.isEmpty
              ? const Center(child: Text('Hakuna arifa bado', style: TextStyle(color: NipTheme.inkSoft)))
              : ListView.builder(itemCount: items.length, itemBuilder: (_, i) => _N(n: items[i]))),
      ),
    );
  }
}

class _N extends ConsumerWidget {
  const _N({required this.n});
  final Map n;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final read = n['readAt'] != null || n['read'] == true;
    final type = n['type']?.toString() ?? '';
    return Container(
      color: read ? NipTheme.card : NipTheme.coral.withValues(alpha: .06),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: NipTheme.coral.withValues(alpha: .12), child: Icon(_icon(type), color: NipTheme.coral, size: 20)),
        title: Text(n['title'] ?? _title(type), style: TextStyle(fontWeight: read ? FontWeight.w600 : FontWeight.w800, color: NipTheme.ink)),
        subtitle: Text(n['body'] ?? n['message'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: NipTheme.inkSoft, fontSize: 13)),
        trailing: read ? null : const CircleAvatar(radius: 5, backgroundColor: NipTheme.coral),
        onTap: () {
          if (!read && n['id'] != null) {
            ref.read(apiProvider).patch('/communications/notifications/${n['id']}/read').then((_) => ref.refresh(notificationsProvider));
          }
        },
      ),
    );
  }

  IconData _icon(String t) => switch (t) {
    'like' || 'reaction' => Icons.favorite,
    'comment' => Icons.chat_bubble_outline,
    'follow' => Icons.person_add_alt,
    'match' => Icons.favorite_border,
    'message' => Icons.message_outlined,
    'gift' => Icons.card_giftcard_outlined,
    _ => Icons.notifications_outlined,
  };
  String _title(String t) => switch (t) {
    'like' => 'Alikuipenda post yako', 'comment' => 'Ali-comment', 'follow' => 'Alikufuata',
    'match' => 'Match mpya!', 'message' => 'Ujumbe mpya', 'gift' => 'Zawadi', _ => 'Arifa',
  };
}
