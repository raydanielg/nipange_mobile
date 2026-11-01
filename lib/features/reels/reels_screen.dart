import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme.dart';
import 'package:mobile/core/config/env.dart';
import 'package:mobile/core/storage/storages.dart';
import 'package:mobile/features/auth/auth.dart';
import 'package:video_player/video_player.dart';

final reelsFeedProvider = FutureProvider<List<Map>>((ref) async {
  final d = await ref.watch(apiProvider).get('/reels/feed/for-you', query: {'limit': '20'});
  final items = (d is Map ? (d['items'] ?? d['reels'] ?? d['data'] ?? []) : d) as List;
  return items.cast<Map>();
});

/// Full-screen vertical reels — only the active page holds a VideoPlayerController.
class ReelsScreen extends ConsumerStatefulWidget {
  const ReelsScreen({super.key});
  @override ConsumerState<ReelsScreen> createState() => _S();
}

class _S extends ConsumerState<ReelsScreen> {
  final _page = PageController();
  int _active = 0;
  VideoPlayerController? _ctrl;
  final List<Map> _reels = [];

  @override
  void dispose() { _ctrl?.dispose(); _page.dispose(); super.dispose(); }

  /// Stream URL — the backend enforces visibility; auth header carried by player.
  String? _videoUrl(Map r) => r['id'] != null ? '${Env.apiUrl}/reels/${r['id']}/stream' : null;

  Future<void> _activate(int i) async {
    if (i >= _reels.length) return;
    _active = i;
    final url = _videoUrl(_reels[i]);
    if (url == null) { setState(() {}); return; }
    await _ctrl?.dispose();
    final token = await SecureStore.access;
    _ctrl = VideoPlayerController.networkUrl(Uri.parse(url), httpHeaders: {'authorization': 'Bearer $token'});
    try {
      await _ctrl!.initialize();
      await _ctrl!.setLooping(true);
      await _ctrl!.play();
    } catch (_) {}
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(reelsFeedProvider);
    return Scaffold(
      backgroundColor: Colors.black,
      body: feed.when(
        loading: () => const Center(child: CircularProgressIndicator(color: NipTheme.coral)),
        error: (e, _) => Center(child: TextButton(onPressed: () => ref.refresh(reelsFeedProvider), child: const Text('Jaribu tena', style: TextStyle(color: Colors.white)))),
        data: (items) {
          if (items.isEmpty) return const Center(child: Text('Hakuna reels bado', style: TextStyle(color: Colors.white70)));
          if (_reels.isEmpty) { _reels.addAll(items); WidgetsBinding.instance.addPostFrameCallback((_) => _activate(0)); }
          return PageView.builder(
            controller: _page,
            scrollDirection: Axis.vertical,
            itemCount: _reels.length,
            onPageChanged: _activate,
            itemBuilder: (_, i) => _ReelPage(reel: _reels[i], ctrl: i == _active ? _ctrl : null, active: i == _active),
          );
        }),
    );
  }
}

class _ReelPage extends ConsumerWidget {
  const _ReelPage({required this.reel, this.ctrl, required this.active});
  final Map reel; final VideoPlayerController? ctrl; final bool active;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ready = active && ctrl != null && ctrl!.value.isInitialized;
    final author = reel['author'] as Map? ?? {};
    final likes = reel['_count']?['likes'] ?? 0;
    final comments = reel['_count']?['comments'] ?? 0;
    final saves = reel['_count']?['saves'] ?? 0;

    return Stack(children: [
      // video / unavailable
      Positioned.fill(child: ready
        ? Center(child: AspectRatio(aspectRatio: ctrl!.value.aspectRatio, child: VideoPlayer(ctrl!)))
        : Container(color: Colors.black, child: Center(child: active
            ? (reel['videoUrl'] ?? reel['playbackUrl']) == null
                ? const Text('Video haipatikani bado', style: TextStyle(color: Colors.white54))
                : const CircularProgressIndicator(color: NipTheme.coral)
            : null))),

      // tap to play/pause
      Positioned.fill(child: GestureDetector(onTap: () {
        if (ctrl == null || !ctrl!.value.isInitialized) return;
        ctrl!.value.isPlaying ? ctrl!.pause() : ctrl!.play();
      })),

      // creator + caption (bottom-left)
      Positioned(left: 14, right: 80, bottom: 24, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(radius: 18, backgroundColor: NipTheme.coral.withValues(alpha: .2), child: Text('${author['name'] ?? '?'}'[0].toUpperCase(), style: const TextStyle(color: NipTheme.coral, fontWeight: FontWeight.w800))),
          const SizedBox(width: 8),
          Flexible(child: Text('@${author['username'] ?? ''}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 8),
          OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact, side: const BorderSide(color: Colors.white70)), child: const Text('Fuata', style: TextStyle(color: Colors.white, fontSize: 12))),
        ]),
        if (reel['caption'] != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(reel['caption'], style: const TextStyle(color: Colors.white, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis)),
      ])),

      // action rail (right)
      Positioned(right: 10, bottom: 30, child: Column(children: [
        _act(Icons.favorite_border, '$likes', () => ref.read(apiProvider).post('/reels/${reel['id']}/like')),
        const SizedBox(height: 16),
        _act(Icons.chat_bubble_outline, '$comments', () {}),
        const SizedBox(height: 16),
        _act(Icons.bookmark_border, '$saves', () => ref.read(apiProvider).post('/reels/${reel['id']}/save')),
        const SizedBox(height: 16),
        _act(Icons.share_outlined, '', () {}),
        const SizedBox(height: 16),
        _act(Icons.more_vert, '', () {}),
      ])),
    ]);
  }

  Widget _act(IconData i, String label, VoidCallback onTap) => Column(children: [
    IconButton(icon: Icon(i, color: Colors.white, size: 28), onPressed: onTap),
    if (label.isNotEmpty) Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
  ]);
}
