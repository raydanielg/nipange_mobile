import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme.dart';
import 'package:mobile/features/auth/auth.dart';
import 'socket.dart';

final meAccountProvider = FutureProvider<String?>((ref) async {
  final d = await ref.watch(apiProvider).get('/accounts/active');
  return d is Map ? d['accountId'] ?? d['id'] : null;
});

final messagesProvider = FutureProvider.family<List<Map>, String>((ref, convId) async {
  final d = await ref.watch(apiProvider).get('/messaging/conversations/$convId/messages', query: {'limit': '50'});
  final items = (d is Map ? (d['items'] ?? d['messages'] ?? d['data'] ?? []) : d) as List;
  return items.cast<Map>();
});

class ConversationScreen extends ConsumerStatefulWidget {
  const ConversationScreen({super.key, required this.convId, this.title = ''});
  final String convId, title;
  @override ConsumerState<ConversationScreen> createState() => _S();
}

class _S extends ConsumerState<ConversationScreen> {
  final _input = TextEditingController();
  bool _sending = false;
  Timer? _typingTimer;
  List<Map> _live = [];
  bool _otherTyping = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bind());
  }

  void _bind() {
    final s = ref.read(socketProvider);
    s.connect();
    s.join(widget.convId);
    s.on('message:new', (d) {
      if (d is Map && d['conversationId'] == widget.convId) {
        setState(() => _live = [..._live, Map<String, dynamic>.from(d)]);
      }
    });
    s.on('typing:update', (d) {
      if (d is Map && d['conversationId'] == widget.convId) setState(() => _otherTyping = d['typing'] == true);
    });
    // Mark conversation read on open — real backend contract.
    ref.read(apiProvider).post('/messaging/conversations/${widget.convId}/read').catchError((_) => {});
  }

  @override
  void dispose() { ref.read(socketProvider).leave(widget.convId); super.dispose(); }

  Future<void> _send() async {
    final body = _input.text.trim();
    if (body.isEmpty) return;
    setState(() => _sending = true);
    try {
      final res = await ref.read(apiProvider).post('/messaging/conversations/${widget.convId}/messages', data: {'body': body, 'type': 'TEXT'});
      _input.clear();
      if (res is Map) setState(() => _live = [..._live, Map<String, dynamic>.from(res['message'] ?? res['data'] ?? res)]);
      ref.read(socketProvider).typingStop(widget.convId);
    } catch (_) {}
    if (mounted) setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(messagesProvider(widget.convId));
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          CircleAvatar(radius: 16, backgroundColor: NipTheme.coral.withValues(alpha: .12), child: Text(widget.title.isNotEmpty ? widget.title[0].toUpperCase() : '?', style: const TextStyle(color: NipTheme.coral, fontWeight: FontWeight.w800, fontSize: 13))),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: NipTheme.ink)),
            if (_otherTyping) const Text('anaandika…', style: TextStyle(fontSize: 11, color: NipTheme.coral)),
          ]),
        ]),
      ),
      body: Column(children: [
        Expanded(child: history.when(
          loading: () => const Center(child: CircularProgressIndicator(color: NipTheme.coral)),
          error: (e, _) => Center(child: TextButton(onPressed: () => ref.refresh(messagesProvider(widget.convId)), child: const Text('Jaribu tena'))),
          data: (msgs) {
            final myId = ref.watch(meAccountProvider).value;
            final all = [...msgs, ..._live];
            if (all.isEmpty) return const Center(child: Text('Hakuna ujumbe — anzisha mazungumzo', style: TextStyle(color: NipTheme.inkSoft)));
            return ListView.builder(
              reverse: true, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              itemCount: all.length,
              itemBuilder: (_, i) => _Bubble(m: all[all.length - 1 - i], mine: all[all.length - 1 - i]['senderAccountId'] == myId),
            );
          })),
        Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 20), color: NipTheme.card,
          child: Row(children: [
            Expanded(child: TextField(controller: _input, onChanged: (_) {
                ref.read(socketProvider).typingStart(widget.convId);
                _typingTimer?.cancel();
                _typingTimer = Timer(const Duration(milliseconds: 1500), () => ref.read(socketProvider).typingStop(widget.convId));
              },
              onEditingComplete: () => ref.read(socketProvider).typingStop(widget.convId),
              decoration: InputDecoration(hintText: 'Andika ujumbe…', border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none), filled: true, fillColor: NipTheme.bg))),
            const SizedBox(width: 8),
            CircleAvatar(backgroundColor: NipTheme.coral, child: IconButton(
              icon: _sending ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.send, color: Colors.white, size: 18),
              onPressed: _sending ? null : _send)),
          ]),
        ),
      ]),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.m, required this.mine});
  final Map m; final bool mine;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => showModalBottomSheet(context: context, builder: (ctx) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(leading: const Icon(Icons.copy_outlined), title: const Text('Copy'), onTap: () { Clipboard.setData(ClipboardData(text: m['body'] ?? '')); Navigator.pop(ctx); }),
        ListTile(leading: const Icon(Icons.favorite_border), title: const Text('React'), onTap: () { Navigator.pop(ctx); _act(context, '/messaging/messages/${m['id']}/reactions', {'type': 'LIKE'}); }),
        ListTile(leading: const Icon(Icons.forward_outlined), title: const Text('Forward'), onTap: () { Navigator.pop(ctx); _act(context, '/messaging/messages/${m['id']}/forward', {}); }),
      ]))),
      child: Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .75),
        decoration: BoxDecoration(
          color: mine ? NipTheme.coral : const Color(0xFFEFECEA),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(mine ? 16 : 4), bottomRight: Radius.circular(mine ? 4 : 16))),
        child: Text(m['body'] ?? '', style: TextStyle(color: mine ? Colors.white : NipTheme.ink, fontSize: 15)),
        ),
      ),
    );
  }

  void _act(BuildContext c, String path, Map<String, dynamic> data) async {
    try { await ProviderScope.containerOf(c).read(apiProvider).post(path, data: data); } catch (_) {}
  }
}
