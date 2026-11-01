import 'package:flutter/material.dart';
import '../../app/theme/tokens.dart';

/// Reusable component library — theme-aware, single responsibility.

class NipButton extends StatelessWidget {
  const NipButton({super.key, required this.label, this.onPressed, this.outline = false, this.loading = false});
  final String label; final VoidCallback? onPressed; final bool outline, loading;
  @override
  Widget build(BuildContext c) => outline
      ? OutlinedButton(onPressed: loading ? null : onPressed, style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50), side: const BorderSide(color: NipColors.coral), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NipRadius.md))), child: Text(label, style: const TextStyle(color: NipColors.coral, fontWeight: FontWeight.w700)))
      : ElevatedButton(onPressed: loading ? null : onPressed, child: loading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text(label));
}

class NipTextField extends StatelessWidget {
  const NipTextField({super.key, this.controller, this.label, this.hint, this.icon, this.obscure = false, this.keyboard});
  final TextEditingController? controller; final String? label, hint; final IconData? icon; final bool obscure; final TextInputType? keyboard;
  @override
  Widget build(BuildContext c) => TextField(controller: controller, obscureText: obscure, keyboardType: keyboard,
      decoration: InputDecoration(labelText: label, hintText: hint, prefixIcon: icon == null ? null : Icon(icon)));
}

class NipAvatar extends StatelessWidget {
  const NipAvatar({super.key, this.name = '', this.size = 40, this.imageUrl});
  final String name; final String? imageUrl; final double size;
  @override
  Widget build(BuildContext c) => CircleAvatar(radius: size / 2, backgroundColor: NipColors.coral.withValues(alpha: .12),
      child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: TextStyle(color: NipColors.coral, fontWeight: FontWeight.w800, fontSize: size * .4)));
}

class NipEmpty extends StatelessWidget {
  const NipEmpty({super.key, required this.message, this.icon = Icons.inbox_outlined, this.action});
  final String message; final IconData icon; final Widget? action;
  @override
  Widget build(BuildContext c) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 48, color: NipColors.inkSoft), const SizedBox(height: 8),
    Text(message, style: const TextStyle(color: NipColors.inkSoft)),
    if (action != null) Padding(padding: const EdgeInsets.only(top: 12), child: action!),
  ]));
}

class NipSkeleton extends StatelessWidget {
  const NipSkeleton({super.key, this.width = double.infinity, this.height = 12});
  final double width, height;
  @override
  Widget build(BuildContext c) => Container(width: width, height: height, decoration: BoxDecoration(color: const Color(0xFFEFECEA), borderRadius: BorderRadius.circular(NipRadius.sm)));
}

class NipCard extends StatelessWidget {
  const NipCard({super.key, required this.child, this.padding = const EdgeInsets.all(NipSpace.md)});
  final Widget child; final EdgeInsets padding;
  @override
  Widget build(BuildContext c) => Card(margin: EdgeInsets.zero, child: Padding(padding: padding, child: child));
}
