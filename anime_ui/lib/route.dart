/// 路由配置（集中注册）
/// 连接后端需使用: --dart-define=API_BASE_URL=http://localhost:3737/api/v1
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:anime_ui/pub/const/routes.dart';
import 'package:anime_ui/pub/providers/storage_provider.dart';
import 'package:anime_ui/pub/services/api_svc.dart' show authToken;
import 'package:anime_ui/pub/widgets/page_transitions.dart';

import 'package:anime_ui/module/login/index.dart';
import 'package:anime_ui/module/register/index.dart';
import 'package:anime_ui/module/project/index.dart';
import 'package:anime_ui/module/dashboard/index.dart';
import 'package:anime_ui/module/layout/layout.dart';

// ① 剧本 Story
import 'package:anime_ui/module/story/index.dart';
import 'package:anime_ui/module/draft/index.dart';

// ② 资产 Assets
import 'package:anime_ui/module/assets/index.dart';

// ③ 脚本 Script
import 'package:anime_ui/module/script/index.dart';

// ④ 镜图 Shot Images
import 'package:anime_ui/module/shot_images/index.dart';

// ⑤ 镜头 Shots
import 'package:anime_ui/module/shots/index.dart';

// ⑥ 成片 Episode
import 'package:anime_ui/module/episode/index.dart';

// 任务中心
import 'package:anime_ui/module/task_center/index.dart';

/// 应用路由实例（集中注册）
final goRouter = GoRouter(
  initialLocation: Routes.projects,
  redirect: (context, state) {
    final loggedIn = authToken != null && authToken!.isNotEmpty;
    final isLoginRoute = state.uri.path == Routes.login;
    final isRegisterRoute = state.uri.path == Routes.register;
    final path = state.uri.path;
    if (!loggedIn && !isLoginRoute && !isRegisterRoute) return Routes.login;
    if (loggedIn && (isLoginRoute || isRegisterRoute)) return Routes.projects;

    // 工作区页面要求必须存在当前项目上下文。
    // 例外：剧本导入页 /story/import 是「新建项目」入口，无项目时也应允许进入。
    final isStoryImportPath = path == Routes.storyImport;
    final isWorkspacePath = Routes.objectPaths.any(
      (objectPath) => path == objectPath || path.startsWith('$objectPath/'),
    );
    final hasCurrentProject =
        ProviderScope.containerOf(
          context,
        ).read(storageServiceProvider).currentProjectId !=
        null;
    if (loggedIn &&
        !hasCurrentProject &&
        !isStoryImportPath &&
        (isWorkspacePath || path == Routes.dashboard || path == Routes.tasks)) {
      return Routes.projects;
    }

    // 一级对象路径重定向到默认子路由
    final defaultRoute = Routes.objectDefaults[path];
    if (defaultRoute != null) return defaultRoute;

    return null;
  },
  routes: [
    GoRoute(
      path: Routes.login,
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: LoginPage()),
    ),
    GoRoute(
      path: Routes.register,
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: RegisterPage()),
    ),
    GoRoute(
      path: Routes.projects,
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: ProjectsPage()),
    ),
    // ── 主工作区（对象驱动导航） ──
    ShellRoute(
      builder: (context, state, child) =>
          MainLayout(currentPath: state.uri.path, child: child),
      routes: [
        GoRoute(
          path: Routes.dashboard,
          pageBuilder: (context, state) =>
              sharedAxisPage(child: const DashboardPage(), state: state),
        ),
        GoRoute(
          path: Routes.tasks,
          pageBuilder: (context, state) =>
              sharedAxisPage(child: const TaskCenterPage(), state: state),
        ),
        // ① 剧本 Story
        ShellRoute(
          builder: (context, state, child) => StoryPage(child: child),
          routes: [
            GoRoute(
              path: Routes.storyImport,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: StoryImportPage()),
            ),
            GoRoute(
              path: Routes.storyPreview,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: StoryPreviewPage()),
            ),
            GoRoute(
              path: Routes.storyEdit,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: StoryEditPage()),
            ),
            GoRoute(
              path: Routes.storyConfirm,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: StoryConfirmPage()),
            ),
          ],
        ),

        // ② 资产 Assets
        ShellRoute(
          builder: (context, state, child) => AssetsObjectPage(child: child),
          routes: [
            GoRoute(
              path: Routes.assetsOverview,
              pageBuilder: (context, state) => sharedAxisPage(
                child: const AssetOverviewPage(),
                state: state,
              ),
            ),
            GoRoute(
              path: Routes.assetsResources,
              pageBuilder: (context, state) => sharedAxisPage(
                child: const AssetsResourcesPage(),
                state: state,
              ),
            ),
            GoRoute(
              path: Routes.assetsCharacters,
              pageBuilder: (context, state) => sharedAxisPage(
                child: const AssetsCharactersPage(),
                state: state,
              ),
            ),
            GoRoute(
              path: Routes.assetsEnvironments,
              pageBuilder: (context, state) => sharedAxisPage(
                child: const AssetsLocationsPage(),
                state: state,
              ),
            ),
            GoRoute(
              path: Routes.assetsProps,
              pageBuilder: (context, state) =>
                  sharedAxisPage(child: const AssetsPropsPage(), state: state),
            ),
            GoRoute(
              path: Routes.assetsVersions,
              pageBuilder: (context, state) => sharedAxisPage(
                child: const AssetsVersionsPage(),
                state: state,
              ),
            ),
          ],
        ),

        // ③ 脚本 Script (4 Tab: 结构 / 生成中心 / 审核编辑 / 锁定)
        ShellRoute(
          builder: (context, state, child) => ScriptObjectPage(child: child),
          routes: [
            GoRoute(
              path: Routes.scriptStructure,
              pageBuilder: (context, state) => sharedAxisPage(
                child: const ScriptStructurePage(),
                state: state,
              ),
            ),
            GoRoute(
              path: Routes.scriptCenter,
              pageBuilder: (context, state) =>
                  sharedAxisPage(child: const ScriptCenterPage(), state: state),
            ),
            GoRoute(
              path: Routes.scriptReview,
              pageBuilder: (context, state) =>
                  sharedAxisPage(child: const ScriptReviewPage(), state: state),
            ),
            GoRoute(
              path: Routes.scriptFreeze,
              pageBuilder: (context, state) =>
                  sharedAxisPage(child: const ScriptFreezePage(), state: state),
            ),
          ],
        ),

        // ④ 镜图 Shot Images (2 Tab: 生成中心 / 审核编辑)
        ShellRoute(
          builder: (context, state, child) => ShotImagesPage(child: child),
          routes: [
            GoRoute(
              path: Routes.shotImagesCenter,
              pageBuilder: (context, state) => sharedAxisPage(
                child: const ShotImageCenterPage(),
                state: state,
              ),
            ),
            GoRoute(
              path: Routes.shotImagesReview,
              pageBuilder: (context, state) => sharedAxisPage(
                child: const ShotImageReviewPage(),
                state: state,
              ),
            ),
          ],
        ),

        // ⑤ 镜头 Shots (2 Tab: 生成中心 / 审核编辑)
        ShellRoute(
          builder: (context, state, child) => ShotsObjectPage(child: child),
          routes: [
            GoRoute(
              path: Routes.shotsCenter,
              pageBuilder: (context, state) =>
                  sharedAxisPage(child: const ShotsCenterPage(), state: state),
            ),
            GoRoute(
              path: Routes.shotsReview,
              pageBuilder: (context, state) =>
                  sharedAxisPage(child: const ShotsReviewPage(), state: state),
            ),
          ],
        ),

        // ⑥ 成片 Episode
        ShellRoute(
          builder: (context, state, child) => EpisodeObjectPage(child: child),
          routes: [
            GoRoute(
              path: Routes.episodeTimeline,
              pageBuilder: (context, state) => sharedAxisPage(
                child: const CompositeTimelineWithPreview(),
                state: state,
              ),
            ),
            GoRoute(
              path: Routes.episodeAudio,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: AudioSubtitlePage(),
              ),
            ),
            GoRoute(
              path: Routes.episodeVersions,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: EpisodePlaceholderPage(
                  title: '版本管理',
                  subtitle: '查看和管理成片版本',
                ),
              ),
            ),
            GoRoute(
              path: Routes.episodeExport,
              pageBuilder: (context, state) => sharedAxisPage(
                child: const CompositeExportPage(),
                state: state,
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);
