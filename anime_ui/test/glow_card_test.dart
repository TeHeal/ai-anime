// GlowCard 通用组件测试

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:anime_ui/pub/widgets/glow_card.dart';

void main() {
  testWidgets('GlowCard 渲染子组件', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GlowCard(
            child: Text('测试内容'),
          ),
        ),
      ),
    );

    expect(find.text('测试内容'), findsOneWidget);
  });

  testWidgets('GlowCard 点击回调', (WidgetTester tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GlowCard(
            onTap: () => tapped = true,
            child: const Text('可点击'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('可点击'));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
