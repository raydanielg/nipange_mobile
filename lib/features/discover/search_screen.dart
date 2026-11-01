import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme.dart';
import 'package:mobile/features/auth/auth.dart';

final trendingProvider = FutureProvider<List<Map>>((ref) async {
  final d = await ref.watch(apiProvider).get('/search/trending');
  return ((d is Map ? (d['items'] ?? d['trending'] ?? d['data'] ?? []) : d) as List).cast<Map>();
});
final searchHistoryProvider = FutureProvider<List<Map>>((ref) async {
  final d = await ref.watch(apiProvider).get('/search/history');
  return ((d is Map ? (d['items'] ?? d['history'] ?? d['data'] ?? []) : d) as List).cast<Map>();
});
final autocompleteProvider = FutureProvider.family<List<String>, String>((ref, q) async {
  if (q.trim().length < 2) return [];
  final d = await ref.watch(apiProvider).get('/search/autocomplete', query: {'q': q});
  final items = (d is Map ? (d['items'] ?? d['suggestions'] ?? d['data'] ?? []) : d) as List;
  return items.map((e) => e is Map ? (e['text'] ?? e['query'] ?? '').toString() : e.toString()).toList();
});
final resultsProvider = FutureProvider.family<List<Map>, ({String q, String type})>((ref, arg) async {
  if (arg.q.trim().length < 2) return [];
  final d = await ref.watch(apiProvider).get('/search', query: {'q': arg.q, 'type': arg.type, 'limit': '30'});
  return ((d is Map ? (d['results'] ?? d['items'] ?? d['data'] ?? []) : d) as List).cast<Map>();
});

const _cats = [('all', 'Zote'), ('people', 'Watu'), ('posts', 'Posts'), ('reels', 'Reels'), ('hashtags', 'Hashtags')];

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});
  @override ConsumerState<SearchScreen> createState() => _S();
}

class _S extends ConsumerState<SearchScreen> {
  final _c = TextEditingController();
  String _q = '', _type = 'all';
  Timer? _debounce;

  void _onChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => _q = v.trim());
    });
    setState(() {});
  }

  @override
  void dispose() { _debounce?.cancel(); _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final searching = _q.length >= 2;
    return Scaffold(
      appBar: AppBar(title: TextField(
        controller: _c, autofocus: true, onChanged: _onChanged,
        decoration: InputDecoration(hintText: 'Tafuta NIPANGE…', border: InputBorder.none,
          suffixIcon: _c.text.isNotEmpty ? IconButton(icon: const Icon(Icons.close), onPressed: () { _c.clear(); _onChanged(''); }) : null)),
        bottom: searching ? PreferredSize(preferredSize: const Size.fromHeight(44), child: SizedBox(height: 44, child: ListView(
          scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 12),
          children: _cats.map((cat) => Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(
            label: Text(cat.$2), selected: _type == cat.$1,
            selectedColor: NipTheme.coral.withValues(alpha: .15), labelStyle: TextStyle(color: _type == cat.$1 ? NipTheme.coral : NipTheme.ink),
            onSelected: (_) => setState(() => _type = cat.$1)))).toList()))) : null),
      body: searching ? _results() : _explore(),
    );
  }

  Widget _results() {
    final res = ref.watch(resultsProvider((q: _q, type: _type)));
    return res.when(
      loading: () => const Center(child: CircularProgressIndicator(color: NipTheme.coral)),
      error: (e, _) => Center(child: Text('Hitilafu: $e')),
      data: (items) => items.isEmpty
          ? const Center(child: Text('Hakuna matokeo', style: TextStyle(color: NipTheme.inkSoft)))
          : ListView.builder(itemCount: items.length, itemBuilder: (_, i) => _Result(r: items[i])),
    );
  }

  Widget _explore() {
    final trending = ref.watch(trendingProvider).value ?? [];
    final history = ref.watch(searchHistoryProvider).value ?? [];
    final ac = _q.isNotEmpty ? (ref.watch(autocompleteProvider(_q)).value ?? []) : <String>[];
    return ListView(padding: const EdgeInsets.all(16), children: [
      if (ac.isNotEmpty) ...[
        const Text('Mapendekezo', style: TextStyle(fontWeight: FontWeight.w800, color: NipTheme.ink)),
        ...ac.map((s) => ListTile(dense: true, leading: const Icon(Icons.search, color: NipTheme.inkSoft, size: 20), title: Text(s), onTap: () { _c.text = s; _onChanged(s); })),
        const Divider(),
      ],
      if (history.isNotEmpty) ...[
        Row(children: [
          const Expanded(child: Text('Hivi karibuni', style: TextStyle(fontWeight: FontWeight.w800, color: NipTheme.ink))),
          TextButton(onPressed: () => ref.read(apiProvider).del('/search/history').then((_) => ref.refresh(searchHistoryProvider)), child: const Text('Futa')),
        ]),
        ...history.map((h) => ListTile(dense: true, leading: const Icon(Icons.history, color: NipTheme.inkSoft, size: 20),
          title: Text(h['query'] ?? h['text'] ?? ''),
          trailing: h['id'] != null ? IconButton(icon: const Icon(Icons.close, size: 16), onPressed: () => ref.read(apiProvider).del('/search/history/${h['id']}').then((_) => ref.refresh(searchHistoryProvider))) : null,
          onTap: () { _c.text = h['query'] ?? h['text'] ?? ''; _onChanged(_c.text); })),
        const Divider(),
      ],
      if (trending.isNotEmpty) ...[
        const Text('Yanayovuma', style: TextStyle(fontWeight: FontWeight.w800, color: NipTheme.ink)),
        const SizedBox(height: 8),
        ...trending.map((t) => ListTile(dense: true, leading: const Icon(Icons.trending_up, color: NipTheme.coral, size: 20), title: Text(t['query'] ?? t['text'] ?? t['tag'] ?? ''), onTap: () { _c.text = t['query'] ?? t['text'] ?? ''; _onChanged(_c.text); })),
      ],
    ]);
  }
}

class _Result extends StatelessWidget {
  const _Result({required this.r});
  final Map r;
  @override
  Widget build(BuildContext c) => ListTile(
    leading: CircleAvatar(backgroundColor: NipTheme.coral.withValues(alpha: .12), child: Icon(_icon(r['type']), color: NipTheme.coral, size: 20)),
    title: Text(r['title'] ?? r['name'] ?? r['displayName'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, color: NipTheme.ink)),
    subtitle: Text(r['subtitle'] ?? r['username'] ?? r['type'] ?? '', style: const TextStyle(color: NipTheme.inkSoft, fontSize: 12)),
  );
  IconData _icon(String? t) => switch (t) {
    'creator' => Icons.star, 'person' || 'people' => Icons.person, 'post' => Icons.article_outlined,
    'reel' => Icons.play_circle_outline, 'hashtag' => Icons.tag, _ => Icons.search,
  };
}
