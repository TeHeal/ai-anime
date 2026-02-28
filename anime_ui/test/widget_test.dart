// 基础 Flutter 组件测试

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:anime_ui/app.dart';

void main() {
  testWidgets('App 启动烟雾测试', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
