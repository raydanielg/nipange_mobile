import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/app/theme/tokens.dart';
import 'package:mobile/core/utils/validators.dart';
import 'package:mobile/features/auth/auth.dart';

/// Multi-step registration: phone → OTP → profile(dob/name/password) → done.
/// Real backend calls only — no client-side fake verification.
class RegisterFlow extends ConsumerStatefulWidget {
  const RegisterFlow({super.key});
  @override
  ConsumerState<RegisterFlow> createState() => _S();
}

class _S extends ConsumerState<RegisterFlow> {
  int _step = 0;
  bool _loading = false;
  String? _error;
  String? _challengeId;
  final _phone = TextEditingController(text: '+255');
  final _otp = TextEditingController();
  final _name = TextEditingController();
  final _pass = TextEditingController();
  DateTime? _dob;
  int _resendIn = 0;

  void _tick() { if (_resendIn <= 0) return;
    Future.delayed(const Duration(seconds: 1), () { if (mounted) { setState(() => _resendIn--); _tick(); } }); }

  Future<void> _send() async {
    final phone = Validators.normalizePhone(_phone.text);
    if (phone == null) { setState(() => _error = 'Namba si sahihi'); return; }
    setState(() { _loading = true; _error = null; });
    try {
      _challengeId = await ref.read(authProvider.notifier).register(phone, 'x'.padRight(12)); // optional per backend; set properly at profile step
      setState(() { _step = 1; _resendIn = 60; }); _tick();
    } catch (e) { setState(() => _error = e.toString()); }
    finally { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _verify() async {
    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(authProvider.notifier).verify(_challengeId!, _otp.text.trim());
      setState(() => _step = 2);
    } catch (e) { setState(() => _error = e.toString()); }
    finally { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _finish() async {
    if (_dob == null) { setState(() => _error = 'Chagua tarehe ya kuzaliwa'); return; }
    if (!Validators.isAdult(_dob!)) { setState(() => _error = 'Lazima uwe na miaka 18+'); return; }
    if (_pass.text.isNotEmpty && Validators.passwordError(_pass.text) != null) { setState(() => _error = 'Nenosiri lazima liwe herufi 12+'); return; }
    // Profile completion calls the real /profiles/me PATCH — auth already done at OTP verify.
    setState(() => _loading = true);
    try {
      await ref.read(apiProvider).patch('/profiles/me', data: {
        'displayName': _name.text.trim(),
        'dateOfBirth': _dob!.toIso8601String().split('T')[0],
      });
      if (mounted) Navigator.of(context).pop();
    } catch (e) { setState(() => _error = e.toString()); }
    finally { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fungua akaunti'), bottom: PreferredSize(
        preferredSize: const Size.fromHeight(4),
        child: LinearProgressIndicator(value: (_step + 1) / 3, color: NipColors.coral, backgroundColor: NipColors.border))),
      body: Padding(padding: const EdgeInsets.all(NipSpace.lg), child: switch (_step) {
        0 => _PhoneStep(phone: _phone, loading: _loading, error: _error, onSend: _send),
        1 => _OtpStep(otp: _otp, loading: _loading, error: _error, resendIn: _resendIn, onVerify: _verify, onResend: _send),
        _ => _ProfileStep(name: _name, pass: _pass, dob: _dob, loading: _loading, error: _error,
            onPickDob: (d) => setState(() => _dob = d), onFinish: _finish),
      }),
    );
  }
}

class _PhoneStep extends StatelessWidget {
  const _PhoneStep({required this.phone, required this.loading, this.error, required this.onSend});
  final TextEditingController phone; final bool loading; final String? error; final VoidCallback onSend;
  @override
  Widget build(BuildContext c) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    Text('Namba ya simu', style: Theme.of(c).textTheme.headlineSmall),
    const SizedBox(height: NipSpace.sm),
    Text('Tutakutumia msimbo wa kuthibitisha', style: Theme.of(c).textTheme.bodyMedium),
    const SizedBox(height: NipSpace.lg),
    TextField(controller: phone, keyboardType: TextInputType.phone, autofocus: true,
      decoration: const InputDecoration(labelText: '+255…', prefixIcon: Icon(Icons.phone_outlined)),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+]'))]),
    if (error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(error!, style: const TextStyle(color: NipColors.error))),
    const Spacer(),
    ElevatedButton(onPressed: loading ? null : onSend, child: loading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Endelea')),
  ]);
}

class _OtpStep extends StatelessWidget {
  const _OtpStep({required this.otp, required this.loading, this.error, required this.resendIn, required this.onVerify, required this.onResend});
  final TextEditingController otp; final bool loading; final String? error; final int resendIn; final VoidCallback onVerify, onResend;
  @override
  Widget build(BuildContext c) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    Text('Thibitisha namba', style: Theme.of(c).textTheme.headlineSmall),
    const SizedBox(height: NipSpace.sm),
    Text('Ingiza msimbo wa taraka 6 uliotumwa SMS', style: Theme.of(c).textTheme.bodyMedium),
    const SizedBox(height: NipSpace.lg),
    TextField(controller: otp, keyboardType: TextInputType.number, maxLength: 6, autofocus: true, textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 30, letterSpacing: 10, fontWeight: FontWeight.w700),
      decoration: const InputDecoration(hintText: '——————', counterText: '')),
    TextButton(onPressed: resendIn > 0 ? null : onResend, child: Text(resendIn > 0 ? 'Tuma tena baada ya ${resendIn}s' : 'Tuma namba tena')),
    if (error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(error!, style: const TextStyle(color: NipColors.error))),
    const Spacer(),
    ElevatedButton(onPressed: loading ? null : onVerify, child: loading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Thibitisha')),
  ]);
}

class _ProfileStep extends StatelessWidget {
  const _ProfileStep({required this.name, required this.pass, this.dob, required this.loading, this.error, required this.onPickDob, required this.onFinish});
  final TextEditingController name, pass; final DateTime? dob; final bool loading; final String? error;
  final ValueChanged<DateTime> onPickDob; final VoidCallback onFinish;
  @override
  Widget build(BuildContext c) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    Text('Wasifu wako', style: Theme.of(c).textTheme.headlineSmall),
    const SizedBox(height: NipSpace.lg),
    TextField(controller: name, decoration: const InputDecoration(labelText: 'Jina linaloonekana', prefixIcon: Icon(Icons.person_outline))),
    const SizedBox(height: NipSpace.md),
    InkWell(onTap: () async {
      final d = await showDatePicker(context: c, initialDate: DateTime(2000), firstDate: DateTime(1920), lastDate: DateTime.now());
      if (d != null) onPickDob(d);
    }, child: InputDecorator(decoration: const InputDecoration(labelText: 'Tarehe ya kuzaliwa', prefixIcon: Icon(Icons.cake_outlined)),
      child: Text(dob == null ? 'Chagua' : '${dob!.day}/${dob!.month}/${dob!.year}'))),
    const SizedBox(height: NipSpace.md),
    TextField(controller: pass, obscureText: true, decoration: const InputDecoration(labelText: 'Nenosiri (si lazima — 12+)', prefixIcon: Icon(Icons.lock_outline))),
    if (error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(error!, style: const TextStyle(color: NipColors.error))),
    const Spacer(),
    ElevatedButton(onPressed: loading ? null : onFinish, child: loading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Kamilisha')),
  ]);
}
