import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/models.dart';
import 'package:mobile/core/theme.dart';
import 'package:mobile/features/auth/auth.dart';
import 'conversation_screen.dart';
import 'package:mobile/features/calls/calls_screen.dart';

final convosProvider = FutureProvider<List<ConversationModel>>((ref) async {
  final d = await ref.watch(apiProvider).get('/messaging/conversations');
  final items = (d is Map ? (d['items'] ?? d['conversations'] ?? d['data'] ?? []) : d) as List;
  return items.map((e) => ConversationModel.fromJson(e)).toList();
});

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final convos = ref.watch(convosProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Chats'),
        actions: [
          IconButton(icon: const Icon(Icons.call_outlined), onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CallsScreen()))),
          IconButton(icon: const Icon(Icons.edit_square), onPressed: () {}),
        ]),
      body: convos.when(
        loading: () => const Center(child: CircularProgressIndicator(color: NipTheme.coral)),
        error: (e, _) => Center(child: TextButton(onPressed: () => ref.refresh(convosProvider), child: const Text('Jaribu tena'))),
        data: (items) => items.isEmpty
            ? const Center(child: Text('Hakuna mazungumzo bado', style: TextStyle(color: NipTheme.inkSoft)))
            : ListView.builder(
                itemCount: items.length,
                itemBuilder: (_, i) => _ConvoTile(c: items[i])),
      ),
    );
  }
}

class _ConvoTile extends StatelessWidget {
  const _ConvoTile({required this.c});
  final ConversationModel c;
  @override
  Widget build(BuildContext context) => ListTile(
    leading: CircleAvatar(radius: 24, backgroundColor: NipTheme.coral.withValues(alpha: .12),
      child: Text(c.title.isNotEmpty ? c.title[0].toUpperCase() : '?', style: const TextStyle(color: NipTheme.coral, fontWeight: FontWeight.w800))),
    title: Text(c.title, style: const TextStyle(fontWeight: FontWeight.w700, color: NipTheme.ink)),
    subtitle: Text(c.lastMessage ?? '…', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: NipTheme.inkSoft)),
    trailing: c.unread > 0 ? CircleAvatar(radius: 11, backgroundColor: NipTheme.coral, child: Text('${c.unread}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))) : null,
    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ConversationScreen(convId: c.id, title: c.title))),
  );
}
