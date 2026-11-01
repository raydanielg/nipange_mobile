import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme.dart';
import 'package:mobile/features/auth/auth.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});
  @override ConsumerState<CreatePostScreen> createState() => _S();
}

class _S extends ConsumerState<CreatePostScreen> {
  final _body = TextEditingController();
  String _vis = 'PUBLIC';
  bool _posting = false; String? _error;

  Future<void> _post() async {
    if (_body.text.trim().isEmpty) { setState(() => _error = 'Andika kitu kwanza'); return; }
    setState(() { _posting = true; _error = null; });
    try {
      await ref.read(apiProvider).post('/feed/posts', data: {'body': _body.text.trim(), 'visibility': _vis});
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) { setState(() => _error = e.toString()); }
    finally { if (mounted) setState(() => _posting = false); }
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: const Text('Create post'), actions: [
      Padding(padding: const EdgeInsets.only(right: 8), child: FilledButton(
        onPressed: _posting ? null : _post,
        style: FilledButton.styleFrom(backgroundColor: NipTheme.coral),
        child: _posting ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Posti'))),
    ]),
    body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      TextField(controller: _body, maxLines: null, autofocus: true,
        decoration: const InputDecoration(hintText: 'Unafikiria nini?', border: InputBorder.none),
        style: const TextStyle(fontSize: 18, color: NipTheme.ink)),
      const Spacer(),
      Row(children: [
        const Icon(Icons.public, size: 18, color: NipTheme.inkSoft), const SizedBox(width: 8),
        DropdownButton<String>(value: _vis, underline: const SizedBox(), items: const [
          DropdownMenuItem(value: 'PUBLIC', child: Text('Public')),
          DropdownMenuItem(value: 'FOLLOWERS', child: Text('Followers')),
          DropdownMenuItem(value: 'FRIENDS', child: Text('Friends')),
        ], onChanged: (v) => setState(() => _vis = v!)),
      ]),
      if (_error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_error!, style: const TextStyle(color: NipTheme.error))),
    ])),
  );
}
