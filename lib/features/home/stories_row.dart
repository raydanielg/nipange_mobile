import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme.dart';
import 'package:mobile/features/auth/auth.dart';

final storiesProvider = FutureProvider<List<Map>>((ref) async {
  final d = await ref.watch(apiProvider).get('/stories/feed');
  final items = (d is Map ? (d['items'] ?? d['stories'] ?? []) : d) as List;
  return items.cast<Map>();
});

/// Real stories row — pulls /stories/feed; Add-Story always first.
class StoriesRow extends ConsumerWidget {
  const StoriesRow({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stories = ref.watch(storiesProvider);
    return SizedBox(height: 92, child: ListView(
      scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      children: [
        _AddStory(),
        ...stories.when(
          loading: () => List.generate(4, (_) => const _Stub()),
          error: (e, st) => <Widget>[],
          data: (items) => items.map((s) => _Bubble(s)).toList()),
      ]));
  }
}

class _AddStory extends StatelessWidget { @override
  Widget build(BuildContext c) => Padding(padding: const EdgeInsets.only(right: 12), child: Column(children: [
    Stack(children: [
      const CircleAvatar(radius: 28, backgroundColor: Color(0xFFEFECEA), child: Icon(Icons.person, color: NipTheme.inkSoft)),
      Positioned(right: 0, bottom: 0, child: CircleAvatar(radius: 10, backgroundColor: NipTheme.coral, child: const Icon(Icons.add, color: Colors.white, size: 14))),
    ]),
    const SizedBox(height: 4), const Text('Yangu', style: TextStyle(fontSize: 11, color: NipTheme.inkSoft)),
  ])); }

class _Bubble extends StatelessWidget { _Bubble(this.s); final Map s;
  @override
  Widget build(BuildContext c) => Padding(padding: const EdgeInsets.only(right: 12), child: Column(children: [
    Container(decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: NipTheme.coral, width: 2)),
      child: CircleAvatar(radius: 26, backgroundColor: NipTheme.coral.withValues(alpha: .12), child: Text('${(s['author']?['name'] ?? s['authorName'] ?? '?').toString().characters.first.toUpperCase()}', style: const TextStyle(color: NipTheme.coral, fontWeight: FontWeight.w800)))),
    const SizedBox(height: 4), Text((s['author']?['username'] ?? s['authorName'] ?? '').toString().split(' ').first, style: const TextStyle(fontSize: 11, color: NipTheme.inkSoft), overflow: TextOverflow.ellipsis),
  ])); }

class _Stub extends StatelessWidget { const _Stub();
  @override
  Widget build(BuildContext c) => const Padding(padding: EdgeInsets.only(right: 12), child: Column(children: [
    CircleAvatar(radius: 28, backgroundColor: Color(0xFFEFECEA)), SizedBox(height: 4),
    SizedBox(width: 40, height: 10, child: ColoredBox(color: Color(0xFFEFECEA))) ])); }
