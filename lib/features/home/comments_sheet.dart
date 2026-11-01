import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme.dart';
import 'package:mobile/features/auth/auth.dart';

final commentsProvider = FutureProvider.family<List<Map>, String>((ref, postId) async {
  final d = await ref.watch(apiProvider).get('/feed/posts/$postId/comments');
  final items = (d is Map ? (d['items'] ?? d['comments'] ?? []) : d) as List;
  return items.cast<Map>();
});

class CommentsSheet extends ConsumerStatefulWidget {
  const CommentsSheet({super.key, required this.postId});
  final String postId;
  static Future<void> show(BuildContext c, String postId) => showModalBottomSheet(
    context: c, isScrollControlled: true, backgroundColor: Colors.transparent,
    builder: (_) => Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(c).viewInsets.bottom), child: CommentsSheet(postId: postId)));

  @override
  ConsumerState<CommentsSheet> createState() => _S();
}

class _S extends ConsumerState<CommentsSheet> {
  final _c = TextEditingController(); bool _sending = false;
  Future<void> _send() async {
    if (_c.text.trim().isEmpty) return;
    setState(() => _sending = true);
    try {
      await ref.read(apiProvider).post('/feed/posts/${widget.postId}/comments', data: {'body': _c.text.trim()});
      _c.clear(); ref.invalidate(commentsProvider(widget.postId));
    } catch (_) {}
    if (mounted) setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    final comments = ref.watch(commentsProvider(widget.postId));
    return Container(
      height: MediaQuery.of(context).size.height * .72,
      decoration: const BoxDecoration(color: NipTheme.card, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(children: [
        const SizedBox(height: 8), Container(width: 36, height: 4, decoration: BoxDecoration(color: const Color(0xFFDDD8D4), borderRadius: BorderRadius.circular(2))),
        const Padding(padding: EdgeInsets.all(14), child: Text('Comments', style: TextStyle(fontWeight: FontWeight.w800, color: NipTheme.ink))),
        Expanded(child: comments.when(
          loading: () => const Center(child: CircularProgressIndicator(color: NipTheme.coral)),
          error: (e, x) => Center(child: Text('$e', style: const TextStyle(color: NipTheme.error))),
          data: (items) => items.isEmpty
              ? const Center(child: Text('Hakuna comments — kuwa wa kwanza!', style: TextStyle(color: NipTheme.inkSoft)))
              : ListView.builder(itemCount: items.length, itemBuilder: (_, i) {
                  final c = items[i];
                  return ListTile(
                    leading: CircleAvatar(radius: 16, backgroundColor: NipTheme.coral.withValues(alpha: .12), child: Text('${(c['author']?['name'] ?? '?').toString().characters.first.toUpperCase()}', style: const TextStyle(color: NipTheme.coral, fontSize: 12))),
                    title: Text(c['author']?['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700, color: NipTheme.ink, fontSize: 13)),
                    subtitle: Text(c['body'] ?? '', style: const TextStyle(color: NipTheme.ink)),
                  );
                }))),
        Container(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 20), color: NipTheme.card,
          child: Row(children: [
            Expanded(child: TextField(controller: _c, decoration: InputDecoration(hintText: 'Andika comment…', border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none), filled: true, fillColor: NipTheme.bg))),
            const SizedBox(width: 8),
            CircleAvatar(backgroundColor: NipTheme.coral, child: IconButton(icon: _sending ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.send, color: Colors.white, size: 18), onPressed: _sending ? null : _send)),
          ]),
        ),
      ]),
    );
  }
}
