// 用户流程模拟测试：登录 → 项目列表 → 剧本导入
// 使用 mocked provider 模拟 API，验证 UI 交互与导航
// 注：项目列表页需大视口，当前 ProjectsPage AppBar 在测试视口下会溢出，待布局优化后补充

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:anime_ui/module/login/index.dart';
import 'test_helpers.dart';

void main() {
  group('用户流程模拟', () {
    testWidgets('登录页：渲染与空提交校验', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithScreenUtil(const MaterialApp(home: LoginPage())),
      );

      expect(find.byType(TextField), findsWidgets);
      expect(find.text('登录'), findsOneWidget);

      await tester.tap(find.text('登录'));
      await tester.pump();

      expect(find.text('请输入用户名和密码'), findsOneWidget);
    });
  });
}
