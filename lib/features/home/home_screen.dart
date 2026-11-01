import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/api.dart';
import 'package:mobile/core/models.dart';
import 'package:mobile/core/theme.dart';
import 'package:mobile/features/auth/auth.dart';
import 'comments_sheet.dart';
import 'package:mobile/features/notifications/notifications_screen.dart';
import 'package:mobile/features/discover/search_screen.dart';
import 'create_post_screen.dart';
import 'stories_row.dart';

/// Cursor-paginated feed state.
class FeedState {
  FeedState({this.items = const [], this.cursor, this.loading = false, this.exhausted = false, this.error});
  final List<PostModel> items; final String? cursor; final bool loading, exhausted; final String? error;
  FeedState copy({List<PostModel>? items, String? cursor, bool? loading, bool? exhausted, String? error}) =>
      FeedState(items: items ?? this.items, cursor: cursor ?? this.cursor, loading: loading ?? this.loading, exhausted: exhausted ?? this.exhausted, error: error);
}

class FeedNotifier extends Notifier<FeedState> {
  @override FeedState build() { _load(); return FeedState(loading: true); }
  ApiClient get _api => ref.read(apiProvider);

  Future<void> _load() async {
    try {
      final d = await _api.get('/feed/explore', query: {'limit': '20', if (state.cursor != null) 'cursor': state.cursor});
      final items = ((d is Map ? (d['items'] ?? d['posts'] ?? []) : d) as List).map((e) => PostModel.fromJson(e)).toList();
      final seen = state.items.map((p) => p.id).toSet();
      final fresh = items.where((p) => !seen.contains(p.id)).toList();
      state = state.copy(
        items: [...state.items, ...fresh], loading: false,
        cursor: (d is Map ? d['nextCursor'] ?? d['cursor'] : null) as String?,
        exhausted: fresh.isEmpty || (d is Map && (d['nextCursor'] ?? d['cursor']) == null),
      );
    } catch (e) { state = state.copy(loading: false, error: e.toString()); }
  }

  Future<void> refresh() async { state = FeedState(loading: true); await _load(); }
  Future<void> next() { if (state.loading || state.exhausted) return Future.value(); state = state.copy(loading: true); return _load(); }
  Future<void> like(PostModel p) async {
    await _api.post('/feed/posts/${p.id}/reactions', data: {'type': 'LIKE'});
    state = state.copy(items: [for (final i in state.items) i.id == p.id ? PostModel.fromJson({..._toJson(i), 'likeCount': i.likeCount + 1}) : i]);
  }
  Map<String, dynamic> _toJson(PostModel p) => {'id': p.id, 'authorAccountId': p.authorId, 'author': {'name': p.authorName, 'username': p.authorUsername}, 'body': p.body, 'visibility': p.visibility, 'likeCount': p.likeCount, 'commentCount': p.commentCount, 'createdAt': p.createdAt?.toIso8601String()};
}
final feedProvider = NotifierProvider<FeedNotifier, FeedState>(FeedNotifier.new);
final unreadProvider = FutureProvider<int>((ref) async {
  final d = await ref.watch(apiProvider).get('/communications/notifications/unread-count');
  return (d is Map ? (d['count'] ?? d['unread'] ?? 0) : d) as int;
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(feedProvider);
    final unread = ref.watch(unreadProvider).value ?? 0;
    return Scaffold(
      appBar: AppBar(title: const Text('NIPANGE', style: TextStyle(color: NipTheme.coral, fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -1)),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SearchScreen()))),
          Stack(children: [
            IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
            if (unread > 0) Positioned(right: 8, top: 8, child: CircleAvatar(radius: 8, backgroundColor: NipTheme.coral, child: Text('$unread', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)))),
          ]),
        ]),
      body: RefreshIndicator(
        color: NipTheme.coral,
        onRefresh: () => ref.read(feedProvider.notifier).refresh(),
        child: NotificationListener<ScrollNotification>(
          onNotification: (n) {
            if (n is ScrollEndNotification && n.metrics.extentAfter < 400) { ref.read(feedProvider.notifier).next(); }
            return false;
          },
          child: _body(context, ref, feed),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: NipTheme.coral,
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreatePostScreen())).then((_) => ref.read(feedProvider.notifier).refresh()),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _body(BuildContext c, WidgetRef ref, FeedState f) {
    if (f.items.isEmpty && f.loading) return ListView(children: [const StoriesRow(), ...List.generate(3, (_) => const _Skeleton())]);
    if (f.items.isEmpty && f.error != null) return _err(c, ref);
    return ListView.builder(
      itemCount: f.items.length + 2,
      itemBuilder: (_, i) {
        if (i == 0) return const StoriesRow();
        if (i == f.items.length + 1) return f.loading ? const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator(color: NipTheme.coral))) : const SizedBox(height: 60);
        return PostCard(post: f.items[i - 1]);
      },
    );
  }

  Widget _err(BuildContext c, WidgetRef ref) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    const Icon(Icons.cloud_off_outlined, size: 48, color: NipTheme.inkSoft),
    const SizedBox(height: 8),
    const Text('Imeshindikana kupakia feed'),
    TextButton(onPressed: () => ref.read(feedProvider.notifier).refresh(), child: const Text('Jaribu tena')),
  ]));
}

class PostCard extends ConsumerWidget {
  const PostCard({super.key, required this.post});
  final PostModel post;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: NipTheme.card,
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(radius: 18, backgroundColor: NipTheme.coral.withValues(alpha: .12), child: Text(post.authorName.isNotEmpty ? post.authorName[0].toUpperCase() : '?', style: const TextStyle(color: NipTheme.coral, fontWeight: FontWeight.w800))),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(post.authorName, style: const TextStyle(fontWeight: FontWeight.w700, color: NipTheme.ink)),
            Text('@${post.authorUsername}', style: const TextStyle(color: NipTheme.inkSoft, fontSize: 12)),
          ])),
          if (post.createdAt != null) Text(_ago(post.createdAt!), style: const TextStyle(color: NipTheme.inkSoft, fontSize: 12)),
        ]),
        if (post.body != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(post.body!, style: const TextStyle(color: NipTheme.ink, fontSize: 15, height: 1.4))),
        const SizedBox(height: 10),
        Row(children: [
          _a(Icons.favorite_border, '${post.likeCount}', () => ref.read(feedProvider.notifier).like(post)),
          _a(Icons.chat_bubble_outline, '${post.commentCount}', () => CommentsSheet.show(context, post.id)),
          _a(Icons.share_outlined, '', () {}),
        ]),
      ]),
    );
  }

  Widget _a(IconData i, String l, VoidCallback onTap) => Padding(padding: const EdgeInsets.only(right: 20), child: InkWell(onTap: onTap, child: Row(children: [Icon(i, size: 20, color: NipTheme.inkSoft), if (l.isNotEmpty) Text('  $l', style: const TextStyle(color: NipTheme.inkSoft, fontSize: 13))])));

  String _ago(DateTime t) { final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'sasa'; if (d.inHours < 1) return '${d.inMinutes}m'; if (d.inDays < 1) return '${d.inHours}h'; return '${d.inDays}d'; }
}

class _Skeleton extends StatelessWidget { const _Skeleton();
  @override Widget build(BuildContext c) => Container(color: NipTheme.card, padding: const EdgeInsets.all(14), margin: const EdgeInsets.only(bottom: 8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [const CircleAvatar(radius: 18, backgroundColor: Color(0xFFEFECEA)), const SizedBox(width: 10), Container(width: 120, height: 12, color: const Color(0xFFEFECEA))]),
    const SizedBox(height: 12), Container(height: 12, width: double.infinity, color: const Color(0xFFEFECEA)),
  ])); }
