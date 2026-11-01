import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme.dart';
import 'package:mobile/features/auth/auth.dart';

final walletProvider = FutureProvider<Map>((ref) async {
  final d = await ref.watch(apiProvider).get('/monetization/wallet');
  return Map<String, dynamic>.from(d as Map);
});
final txnsProvider = FutureProvider<List<Map>>((ref) async {
  final d = await ref.watch(apiProvider).get('/monetization/wallet/transactions');
  return ((d is Map ? (d['items'] ?? d['transactions'] ?? []) : d) as List).cast<Map>();
});
final packagesProvider = FutureProvider<List<Map>>((ref) async {
  final d = await ref.watch(apiProvider).get('/monetization/coins/packages');
  return ((d is Map ? (d['items'] ?? d['packages'] ?? d['data'] ?? []) : d) as List).cast<Map>();
});
final giftsProvider = FutureProvider<List<Map>>((ref) async {
  final d = await ref.watch(apiProvider).get('/monetization/gifts');
  return ((d is Map ? (d['items'] ?? d['gifts'] ?? d['data'] ?? []) : d) as List).cast<Map>();
});
final plansProvider = FutureProvider<List<Map>>((ref) async {
  final d = await ref.watch(apiProvider).get('/subscriptions/plans');
  return ((d is Map ? (d['items'] ?? d['plans'] ?? d['data'] ?? []) : d) as List).cast<Map>();
});

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final w = ref.watch(walletProvider);
    return Scaffold(appBar: AppBar(title: const Text('Wallet')),
      body: w.when(
        loading: () => const Center(child: CircularProgressIndicator(color: NipTheme.coral)),
        error: (e, _) => Center(child: TextButton(onPressed: () => ref.refresh(walletProvider), child: const Text('Jaribu tena'))),
        data: (wallet) => ListView(padding: const EdgeInsets.all(20), children: [
          Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: NipTheme.coral, borderRadius: BorderRadius.circular(20)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Coin balance', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 4),
              Text('${wallet['balance'] ?? wallet['coinBalance'] ?? 0}', style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w900)),
              Text('${wallet['currency'] ?? 'COINS'}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ])),
          const SizedBox(height: 16),
          _entry(context, Icons.shopping_bag_outlined, 'Buy coins', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CoinsScreen()))),
          _entry(context, Icons.card_giftcard_outlined, 'Zawadi (gifts)', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GiftsScreen()))),
          _entry(context, Icons.workspace_premium_outlined, 'Premium', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PremiumScreen()))),
          const SizedBox(height: 20),
          const Text('Miamala', style: TextStyle(fontWeight: FontWeight.w800, color: NipTheme.ink, fontSize: 17)),
          const SizedBox(height: 8),
          ref.watch(txnsProvider).when(
            loading: () => const Center(child: CircularProgressIndicator(color: NipTheme.coral)),
            error: (e, _) => const SizedBox(),
            data: (txns) => txns.isEmpty
                ? const Text('Hakuna miamala bado', style: TextStyle(color: NipTheme.inkSoft))
                : Column(children: txns.take(10).map((t) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(backgroundColor: NipTheme.coral.withValues(alpha: .12), child: const Icon(Icons.receipt_outlined, color: NipTheme.coral, size: 18)),
                    title: Text(t['description'] ?? t['type'] ?? '', style: const TextStyle(color: NipTheme.ink, fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: Text(t['status'] ?? '', style: const TextStyle(color: NipTheme.inkSoft, fontSize: 11)),
                    trailing: Text('${t['amount'] ?? ''} ${t['currency'] ?? ''}', style: TextStyle(fontWeight: FontWeight.w700, color: (t['amount'] ?? 0) < 0 ? NipTheme.error : NipTheme.success)),
                  )).toList())),
        ])));
  }
  Widget _entry(BuildContext c, IconData i, String t, VoidCallback onTap) => ListTile(
    leading: CircleAvatar(backgroundColor: NipTheme.coral.withValues(alpha: .12), child: Icon(i, color: NipTheme.coral)),
    title: Text(t, style: const TextStyle(fontWeight: FontWeight.w700, color: NipTheme.ink)),
    trailing: const Icon(Icons.chevron_right, color: NipTheme.inkSoft), onTap: onTap, contentPadding: EdgeInsets.zero);
}

class CoinsScreen extends ConsumerWidget {
  const CoinsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pkgs = ref.watch(packagesProvider);
    return Scaffold(appBar: AppBar(title: const Text('Buy coins')),
      body: pkgs.when(
        loading: () => const Center(child: CircularProgressIndicator(color: NipTheme.coral)),
        error: (e, _) => Center(child: TextButton(onPressed: () => ref.refresh(packagesProvider), child: const Text('Jaribu tena'))),
        data: (items) => items.isEmpty
            ? const Center(child: Text('Hakuna packages bado', style: TextStyle(color: NipTheme.inkSoft)))
            : GridView.builder(padding: const EdgeInsets.all(16), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: .82, crossAxisSpacing: 12, mainAxisSpacing: 12),
                itemCount: items.length, itemBuilder: (_, i) => _Pkg(p: items[i]))));
  }
}
class _Pkg extends ConsumerWidget {
  const _Pkg({required this.p}); final Map p;
  @override
  Widget build(BuildContext context, WidgetRef ref) => Container(
    padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: NipTheme.card, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFEAE7E2))),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.monetization_on, color: NipTheme.coral, size: 34),
      const SizedBox(height: 6),
      Text('${p['coins'] ?? p['coinAmount'] ?? 0}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: NipTheme.ink)),
      Text('${p['price'] ?? ''} ${p['currency'] ?? 'TZS'}', style: const TextStyle(color: NipTheme.inkSoft, fontSize: 13)),
      const SizedBox(height: 12),
      SizedBox(width: double.infinity, child: ElevatedButton(
        style: ElevatedButton.styleFrom(minimumSize: const Size(0, 38), textStyle: const TextStyle(fontSize: 13)),
        onPressed: () => _buy(context, ref), child: const Text('Nunua'))),
    ]));
  Future<void> _buy(BuildContext c, WidgetRef ref) async {
    try {
      final res = await ref.read(apiProvider).post('/monetization/coins/purchases', data: {'packageId': p['id']});
      if (c.mounted) ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text('Payment: ${res?['status'] ?? 'initiated'}')));
    } catch (e) { if (c.mounted) ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text('Imeshindikana: $e'))); }
  }
}

class GiftsScreen extends ConsumerWidget {
  const GiftsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gifts = ref.watch(giftsProvider);
    return Scaffold(appBar: AppBar(title: const Text('Zawadi')),
      body: gifts.when(
        loading: () => const Center(child: CircularProgressIndicator(color: NipTheme.coral)),
        error: (e, _) => Center(child: TextButton(onPressed: () => ref.refresh(giftsProvider), child: const Text('Jaribu tena'))),
        data: (items) => items.isEmpty
            ? const Center(child: Text('Hakuna zawadi bado', style: TextStyle(color: NipTheme.inkSoft)))
            : GridView.builder(padding: const EdgeInsets.all(16), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: .8, crossAxisSpacing: 10, mainAxisSpacing: 10),
                itemCount: items.length, itemBuilder: (_, i) => _G(g: items[i]))));
  }
}
class _G extends ConsumerWidget {
  const _G({required this.g}); final Map g;
  @override
  Widget build(BuildContext context, WidgetRef ref) => Container(
    padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: NipTheme.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFEAE7E2))),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.card_giftcard, color: NipTheme.coral, size: 30),
      const SizedBox(height: 6),
      Text(g['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700, color: NipTheme.ink, fontSize: 12), textAlign: TextAlign.center),
      Text('${g['coinPrice'] ?? g['price'] ?? 0} coins', style: const TextStyle(color: NipTheme.inkSoft, fontSize: 11)),
    ]));
}

class PremiumScreen extends ConsumerWidget {
  const PremiumScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = ref.watch(plansProvider);
    return Scaffold(appBar: AppBar(title: const Text('Premium')),
      body: plans.when(
        loading: () => const Center(child: CircularProgressIndicator(color: NipTheme.coral)),
        error: (e, _) => Center(child: TextButton(onPressed: () => ref.refresh(plansProvider), child: const Text('Jaribu tena'))),
        data: (items) => items.isEmpty
            ? const Center(child: Text('Hakuna plans bado', style: TextStyle(color: NipTheme.inkSoft)))
            : ListView(padding: const EdgeInsets.all(16), children: items.map((p) => _Plan(p: p)).toList())));
  }
}
class _Plan extends ConsumerWidget {
  const _Plan({required this.p}); final Map p;
  @override
  Widget build(BuildContext context, WidgetRef ref) => Container(
    margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: NipTheme.card, borderRadius: BorderRadius.circular(18), border: Border.all(color: NipTheme.coral.withValues(alpha: .4))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Icon(Icons.workspace_premium, color: NipTheme.coral), const SizedBox(width: 8),
        Text(p['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w800, color: NipTheme.ink, fontSize: 17)),
      ]),
      const SizedBox(height: 8),
      Text('${p['price'] ?? ''} ${p['currency'] ?? 'TZS'} / ${p['interval'] ?? p['period'] ?? 'month'}', style: const TextStyle(color: NipTheme.inkSoft)),
      const SizedBox(height: 12),
      SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () {}, child: const Text('Jiunge'))),
    ]));
}
