import 'package:go_router/go_router.dart';

import 'package:anime_ui/pub/const/routes.dart';
import 'package:anime_ui/main.dart';
import 'package:anime_ui/pub/services/api.dart';

import 'package:anime_ui/module/login/page.dart';
import 'package:anime_ui/module/project/page.dart';
import 'package:anime_ui/module/dashboard/page.dart';
import 'package:anime_ui/module/layout/layout.dart';

// ① 剧本 Story
import 'package:anime_ui/module/story/story_page.dart';
import 'package:anime_ui/module/story/import_page.dart';
import 'package:anime_ui/module/story/edit_page.dart';
import 'package:anime_ui/module/story/confirm_page.dart';
import 'package:anime_ui/module/draft/preview_page.dart';

// ② 资产 Assets
import 'package:anime_ui/module/assets/assets_page.dart';
import 'package:anime_ui/module/assets/overview/overview_page.dart';
import 'package:anime_ui/module/assets/characters/characters_page.dart';
import 'package:anime_ui/module/assets/locations/locations_page.dart';
import 'package:anime_ui/module/assets/props/props_page.dart';
import 'package:anime_ui/module/assets/resources/resources_page.dart';
import 'package:anime_ui/module/assets/versions_page.dart';

// ③ 脚本 Script
import 'package:anime_ui/module/script/page.dart';
import 'package:anime_ui/module/script/view/script_page.dart';
import 'package:anime_ui/module/script/view/center_page.dart';
import 'package:anime_ui/module/script/view/review_page.dart';
import 'package:anime_ui/module/script/view/freeze_page.dart';

// ④ 镜图 Shot Images
import 'package:anime_ui/module/shot_images/shot_images_page.dart';
import 'package:anime_ui/module/shot_images/view/center_page.dart';
import 'package:anime_ui/module/shot_images/view/review_page.dart';

// ⑤ 镜头 Shots
import 'package:anime_ui/module/shots/shots_page.dart';
import 'package:anime_ui/module/shots/view/center_page.dart';
import 'package:anime_ui/module/shots/view/review_page.dart';

// ⑥ 成片 Episode
import 'package:anime_ui/module/episode/episode_page.dart';
import 'package:anime_ui/module/episode/composite_timeline_page.dart';
import 'package:anime_ui/module/episode/composite_export_page.dart';
import 'package:anime_ui/module/episode/placeholder_page.dart';

// 任务中心
import 'package:anime_ui/module/task_center/task_center_page.dart';

final goRouter = GoRouter(
  initialLocation: Routes.projects,
  redirect: (context, state) {
    final loggedIn = authToken != null && authToken!.isNotEmpty;
    final isLoginRoute = state.uri.path == Routes.login;
    final path = state.uri.path;
    if (!loggedIn && !isLoginRoute) return Routes.login;
    if (loggedIn && isLoginRoute) return Routes.projects;

    // 工作区页面要求必须存在当前项目上下文。
    // 例外：剧本导入页 /story/import 是「新建项目」入口，无项目时也应允许进入。
    final isStoryImportPath = path == Routes.storyImport;
    final isWorkspacePath = Routes.objectPaths.any(
      (objectPath) => path == objectPath || path.startsWith('$objectPath/'),
    );
    final hasCurrentProject = storageService.currentProjectId != null;
    if (loggedIn &&
        !hasCurrentProject &&
        !isStoryImportPath &&
        (isWorkspacePath ||
            path == Routes.dashboard ||
            path == Routes.tasks)) {
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
      path: Routes.projects,
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: ProjectsPage()),
    ),
    // ── 主工作区（对象驱动导航） ──
    ShellRoute(
      builder: (context, state, child) => MainLayout(
        currentPath: state.uri.path,
        child: child,
      ),
      routes: [
        GoRoute(
          path: Routes.dashboard,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: DashboardPage()),
        ),
        GoRoute(
          path: Routes.tasks,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: TaskCenterPage()),
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
                  const NoTransitionPage(child: ScriptPreviewPage()),
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
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: AssetOverviewPage()),
            ),
            GoRoute(
              path: Routes.assetsResources,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: AssetsResourcesPage()),
            ),
            GoRoute(
              path: Routes.assetsCharacters,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: AssetsCharactersPage()),
            ),
            GoRoute(
              path: Routes.assetsEnvironments,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: AssetsEnvironmentsPage()),
            ),
            GoRoute(
              path: Routes.assetsProps,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: AssetsPropsPage()),
            ),
            GoRoute(
              path: Routes.assetsVersions,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: AssetsVersionsPage()),
            ),
          ],
        ),

        // ③ 脚本 Script (4 Tab: 结构 / 生成中心 / 审核编辑 / 锁定)
        ShellRoute(
          builder: (context, state, child) =>
              ScriptObjectPage(child: child),
          routes: [
            GoRoute(
              path: Routes.scriptStructure,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: ScriptStructurePage()),
            ),
            GoRoute(
              path: Routes.scriptCenter,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: ScriptCenterPage()),
            ),
            GoRoute(
              path: Routes.scriptReview,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: ScriptReviewPage()),
            ),
            GoRoute(
              path: Routes.scriptFreeze,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: ScriptFreezePage()),
            ),
          ],
        ),

        // ④ 镜图 Shot Images (2 Tab: 生成中心 / 审核编辑)
        ShellRoute(
          builder: (context, state, child) =>
              ShotImagesPage(child: child),
          routes: [
            GoRoute(
              path: Routes.shotImagesCenter,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: ShotImageCenterPage()),
            ),
            GoRoute(
              path: Routes.shotImagesReview,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: ShotImageReviewPage()),
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
                  const NoTransitionPage(child: ShotsCenterPage()),
            ),
            GoRoute(
              path: Routes.shotsReview,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: ShotsReviewPage()),
            ),
          ],
        ),

        // ⑥ 成片 Episode
        ShellRoute(
          builder: (context, state, child) =>
              EpisodeObjectPage(child: child),
          routes: [
            GoRoute(
              path: Routes.episodeTimeline,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: CompositeTimelinePage(),
              ),
            ),
            GoRoute(
              path: Routes.episodeAudio,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: EpisodePlaceholderPage(
                    title: '音频 / 字幕', subtitle: '旁白、音乐、字幕管理'),
              ),
            ),
            GoRoute(
              path: Routes.episodeVersions,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: EpisodePlaceholderPage(
                    title: '版本管理', subtitle: '查看和管理成片版本'),
              ),
            ),
            GoRoute(
              path: Routes.episodeExport,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: CompositeExportPage(),
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);
