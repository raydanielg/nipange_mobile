import 'package:flutter/material.dart';
import 'package:mobile/core/theme.dart';
import 'package:mobile/features/chat/chat_screen.dart';
import 'package:mobile/features/create/create_sheet.dart';
import 'package:mobile/features/discover/discover_screen.dart';
import 'package:mobile/features/home/home_screen.dart';
import 'package:mobile/features/profile/profile_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _S();
}

class _S extends State<AppShell> {
  int _tab = 0;
  final _screens = const [HomeScreen(), DiscoverScreen(), SizedBox(), ChatScreen(), ProfileScreen()];
  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(index: _tab, children: _screens),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _tab, height: 68, backgroundColor: NipTheme.card,
      indicatorColor: NipTheme.coral.withValues(alpha: .14),
      onDestinationSelected: (i) {
        if (i == 2) { CreateSheet.show(context); return; } // Create → sheet, not a tab
        setState(() => _tab = i);
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home, color: NipTheme.coral), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore, color: NipTheme.coral), label: 'Discover'),
        NavigationDestination(icon: Icon(Icons.add_circle_outline, size: 28), label: 'Create'),
        NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble, color: NipTheme.coral), label: 'Chats'),
        NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person, color: NipTheme.coral), label: 'Profile'),
      ],
    ),
  );
}
