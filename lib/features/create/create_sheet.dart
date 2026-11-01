import 'package:flutter/material.dart';
import 'package:mobile/core/theme.dart';

/// Creation action sheet — slides up over the current tab.
class CreateSheet extends StatelessWidget {
  const CreateSheet({super.key});
  static Future<void> show(BuildContext c) => showModalBottomSheet(
    context: c, isScrollControlled: true, backgroundColor: Colors.transparent,
    builder: (_) => const CreateSheet());

  @override
  Widget build(BuildContext context) => Material(
    color: NipTheme.card,
    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
    child: Padding(
    padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 36, height: 4, decoration: BoxDecoration(color: const Color(0xFFDDD8D4), borderRadius: BorderRadius.circular(2))),
      const SizedBox(height: 20),
      const Text('Tengeneza', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: NipTheme.ink)),
      const SizedBox(height: 16),
      _opt(context, Icons.edit_note, 'Post ya maandishi', () {}),
      _opt(context, Icons.photo_library_outlined, 'Picha', () {}),
      _opt(context, Icons.play_circle_outline, 'Reel', () {}),
      _opt(context, Icons.auto_stories_outlined, 'Story', () {}),
      _opt(context, Icons.poll_outlined, 'Poll', () {}),
    ]),
  ),
  );

  Widget _opt(BuildContext c, IconData i, String t, VoidCallback onTap) => ListTile(
    leading: CircleAvatar(backgroundColor: NipTheme.coral.withValues(alpha: .12), child: Icon(i, color: NipTheme.coral)),
    title: Text(t, style: const TextStyle(fontWeight: FontWeight.w600, color: NipTheme.ink)),
    onTap: () { Navigator.pop(c); onTap(); }, contentPadding: EdgeInsets.zero);
}
