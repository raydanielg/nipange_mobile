import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme.dart';
import 'package:mobile/features/auth/auth.dart';
import 'package:mobile/features/reels/reels_screen.dart';

final searchProvider = FutureProvider.family<List<dynamic>, String>((ref, q) async {
  if (q.trim().length < 2) return [];
  final d = await ref.watch(apiProvider).get('/search', query: {'q': q, 'type': 'all', 'limit': '20'});
  return (d is Map ? (d['results'] ?? []) : []) as List;
});

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});
  @override
  ConsumerState<DiscoverScreen> createState() => _S();
}

class _S extends ConsumerState<DiscoverScreen> {
  final _q = TextEditingController();
  String _query = '';
  @override
  Widget build(BuildContext context) {
    final res = ref.watch(searchProvider(_query));
    return Scaffold(
      appBar: AppBar(title: const Text('Discover')),
      body: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 8), child: TextField(
          controller: _q, onChanged: (v) => setState(() => _query = v),
          decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: 'Tafuta watu, hashtags, reels…',
            suffixIcon: _query.isNotEmpty ? IconButton(icon: const Icon(Icons.close), onPressed: () { _q.clear(); setState(() => _query = ''); }) : null),
        )),
        Expanded(child: _query.length < 2
          ? ListView(padding: const EdgeInsets.all(16), children: [
              const _Section('Dating', Icons.favorite_outline, 'Kutana na watu wapya — 18+'),
              const _Section('People', Icons.people_outline, 'Watumiaji wa NIPANGE'),
              _Section('Reels', Icons.play_circle_outline, 'Video fupi', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReelsScreen()))),
              const _Section('Creators', Icons.star_outline, 'Watayarishi wa maudhui'),
              const _Section('Trending', Icons.trending_up, 'Yanayovuma sasa'),
            ])
          : res.when(
              loading: () => const Center(child: CircularProgressIndicator(color: NipTheme.coral)),
              error: (e, _) => Center(child: Text('Hitilafu: $e')),
              data: (items) => items.isEmpty
                  ? const Center(child: Text('Hakuna matokeo', style: TextStyle(color: NipTheme.inkSoft)))
                  : ListView.builder(itemCount: items.length, itemBuilder: (_, i) {
                      final r = items[i] as Map;
                      return ListTile(
                        leading: CircleAvatar(backgroundColor: NipTheme.coral.withValues(alpha: .12),
                          child: Icon(_icon(r['type']), color: NipTheme.coral, size: 20)),
                        title: Text(r['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, color: NipTheme.ink)),
                        subtitle: Text(r['subtitle'] ?? r['type'] ?? '', style: const TextStyle(color: NipTheme.inkSoft, fontSize: 12)),
                      );
                    }),
            )),
      ]),
    );
  }

  IconData _icon(String? t) => switch (t) {
    'creator' => Icons.star, 'person' => Icons.person, 'post' => Icons.article,
    'reel' => Icons.play_circle_outline, 'hashtag' => Icons.tag, _ => Icons.search,
  };
}

class _Section extends StatelessWidget {
  const _Section(this.t, this.i, this.s, {this.onTap});
  final String t, s; final IconData i; final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => ListTile(
    leading: CircleAvatar(backgroundColor: NipTheme.coral.withValues(alpha: .12), child: Icon(i, color: NipTheme.coral)),
    title: Text(t, style: const TextStyle(fontWeight: FontWeight.w700, color: NipTheme.ink)),
    subtitle: Text(s, style: const TextStyle(color: NipTheme.inkSoft)),
    trailing: const Icon(Icons.chevron_right, color: NipTheme.inkSoft), contentPadding: EdgeInsets.zero,
    onTap: onTap);
}
