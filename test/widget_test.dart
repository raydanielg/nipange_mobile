import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme.dart';
import 'package:mobile/features/create/create_sheet.dart';

void main() {
  test('theme has coral accent + dark mode variant', () {
    expect(NipTheme.coral.toARGB32(), 0xFFFF5C5C);
    expect(NipTheme.dark().brightness, Brightness.dark);
  });
  testWidgets('create sheet builds option list', (t) async {
    await t.pumpWidget(const MaterialApp(home: Scaffold(body: SingleChildScrollView(child: CreateSheet()))));
    await t.pumpAndSettle();
    expect(find.byType(ListTile), findsWidgets);
    expect(find.byIcon(Icons.play_circle_outline), findsOneWidget);
  });
}
