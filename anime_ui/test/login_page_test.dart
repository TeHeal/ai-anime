// 登录页 Widget 测试

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:anime_ui/module/login/page.dart';

void main() {
  testWidgets('LoginPage 渲染用户名和密码输入框', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginPage(),
      ),
    );

    expect(find.byType(TextField), findsWidgets);
    expect(find.text('登录'), findsOneWidget);
  });

  testWidgets('LoginPage 空提交显示错误', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginPage(),
      ),
    );

    await tester.tap(find.text('登录'));
    await tester.pump();

    expect(find.text('请输入用户名和密码'), findsOneWidget);
  });
}
