import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme.dart';
import 'auth.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});
  @override
  ConsumerState<AuthScreen> createState() => _S();
}

class _S extends ConsumerState<AuthScreen> {
  final _phone = TextEditingController(text: '+255'), _pass = TextEditingController(), _otp = TextEditingController();
  String? _challengeId, _error;
  bool _loading = false, _loginMode = false;
  int _resendIn = 0;

  void _tick() {
    if (_resendIn <= 0) return;
    Future.delayed(const Duration(seconds: 1), () { if (mounted) { setState(() => _resendIn--); _tick(); } });
  }

  Future<void> _submit() async {
    setState(() { _loading = true; _error = null; });
    try {
      final auth = ref.read(authProvider.notifier);
      if (_loginMode) {
        await auth.login(_phone.text.trim(), _pass.text);
      } else {
        final cid = await auth.register(_phone.text.trim(), _pass.text);
        setState(() { _challengeId = cid; _resendIn = 60; });
        _tick();
      }
    } catch (e) { setState(() => _error = e.toString()); }
    finally { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _verify() async {
    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(authProvider.notifier).verify(_challengeId!, _otp.text.trim());
    } catch (e) { setState(() => _error = e.toString()); }
    finally { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    final otp = _challengeId != null;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const SizedBox(height: 40),
            Text('NIPANGE', style: TextStyle(color: NipTheme.coral, fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: -1)),
            const SizedBox(height: 6),
            Text(otp ? 'Ingiza namba ya kuthibitisha' : 'Karibu — jiunge au ingia', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 32),
            if (!otp) ...[
              TextField(controller: _phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Namba ya simu (+255…)', prefixIcon: Icon(Icons.phone_outlined)),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+]'))]),
              const SizedBox(height: 14),
              TextField(controller: _pass, obscureText: true, decoration: const InputDecoration(labelText: 'Nenosiri', prefixIcon: Icon(Icons.lock_outline))),
            ] else ...[
              TextField(controller: _otp, keyboardType: TextInputType.number, maxLength: 6, textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 28, letterSpacing: 8, fontWeight: FontWeight.w700),
                decoration: const InputDecoration(hintText: '——————', counterText: '')),
              const SizedBox(height: 8),
              TextButton(onPressed: _resendIn > 0 ? null : _submit,
                child: Text(_resendIn > 0 ? 'Tuma tena baada ya ${_resendIn}s' : 'Tuma namba tena')),
            ],
            if (_error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(_error!, style: const TextStyle(color: NipTheme.error))),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _loading ? null : (otp ? _verify : _submit),
              child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text(otp ? 'Thibitisha' : (_loginMode ? 'Ingia' : 'Jiunge'))),
            if (!otp) TextButton(onPressed: () => setState(() => _loginMode = !_loginMode),
              child: Text(_loginMode ? 'Huna akaunti? Jiunge' : 'Tayari una akaunti? Ingia')),
          ]),
        ),
      ),
    );
  }
}
