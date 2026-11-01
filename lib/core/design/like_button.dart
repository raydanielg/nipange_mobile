import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../app/theme/tokens.dart';
import 'nip_icons.dart';

/// Premium like — 160ms scale pulse + light haptic + coral when liked.
class NipLikeButton extends StatefulWidget {
  const NipLikeButton({super.key, this.liked = false, this.count = 0, this.onLike, this.size = 22});
  final bool liked; final int count; final double size; final Future<void> Function()? onLike;
  @override State<NipLikeButton> createState() => _S();
}
class _S extends State<NipLikeButton> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 160), lowerBound: .8, upperBound: 1.15, value: 1.0);
  bool _busy = false;
  Future<void> _tap() async {
    if (_busy || widget.onLike == null) return;
    _busy = true; HapticFeedback.lightImpact();
    await _c.forward(from: .8); await _c.reverse();
    try { await widget.onLike!(); } catch (_) {}
    if (mounted) _busy = false;
  }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: _tap, child: Row(children: [
    ScaleTransition(scale: _c, child: HugeIcon(icon: NipIcons.heart, color: widget.liked ? NipColors.coral : NipColors.inkSoft, size: widget.size)),
    if (widget.count > 0) Padding(padding: const EdgeInsets.only(left: 4), child: Text('${widget.count}', style: NipText.caption)),
  ]));
}
