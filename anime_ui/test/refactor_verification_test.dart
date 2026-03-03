// 重构验证测试：剧本/脚本/草稿模块
// 验证：1) story 统一编辑入口 2) script 仅 3 Tab 3) draft 并入 story

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:anime_ui/module/story/page/import_page.dart';
import 'package:anime_ui/module/story/page/story_page.dart';
import 'package:anime_ui/module/story/page/draft_page.dart';
import 'package:anime_ui/module/script/page/script_page.dart';
import 'package:anime_ui/pub/const/routes.dart';
import 'package:anime_ui/pub/providers/lock_provider.dart';
import 'package:anime_ui/pub/models/lock_status.dart';
import 'test_helpers.dart';

void main() {
  group('重构验证：剧本/脚本/草稿', () {
    testWidgets('StoryImportPage 未锁定时渲染 DraftPage', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            lockProvider.overrideWith(() => _MockLockNotifier(false)),
          ],
          child: wrapWithScreenUtil(
            MaterialApp(
              home: Scaffold(
                body: StoryImportPage(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(DraftPage), findsOneWidget);
    });

    testWidgets('StoryImportPage 锁定后显示锁定提示', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            lockProvider.overrideWith(() => _MockLockNotifier(true)),
          ],
          child: wrapWithScreenUtil(
            MaterialApp(
              home: Scaffold(
                body: StoryImportPage(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('剧本已锁定，无法重新导入'), findsOneWidget);
      expect(find.byType(DraftPage), findsNothing);
    });

    test('StoryPage 有 4 个 Tab：导入/预览/编辑/锁定', () {
      expect(StoryPage.tabs.length, 4);
      final labels = StoryPage.tabs.map((t) => t.label).toList();
      expect(labels, contains('导入'));
      expect(labels, contains('预览'));
      expect(labels, contains('编辑'));
      expect(labels, contains('锁定'));
    });

    test('ScriptObjectPage 仅 3 个 Tab：生成中心/审核编辑/锁定', () {
      expect(ScriptObjectPage.tabs.length, 3);
      final labels = ScriptObjectPage.tabs.map((t) => t.label).toList();
      expect(labels, contains('生成中心'));
      expect(labels, contains('审核编辑'));
      expect(labels, contains('锁定'));
      expect(labels, isNot(contains('结构')));
    });

    test('路由常量：script 默认指向 scriptCenter', () {
      expect(Routes.objectDefaults[Routes.script], Routes.scriptCenter);
    });
  });
}

class _MockLockNotifier extends LockNotifier {
  _MockLockNotifier(this.locked);
  final bool locked;

  @override
  LockStatus build() => LockStatus(storyLocked: locked);
}
