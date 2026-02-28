import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/colors.dart';
import 'package:anime_ui/pub/models/storyboard_script.dart';
import 'package:anime_ui/module/script/page/review_ui_provider.dart';
import 'package:anime_ui/module/script/page/script_provider.dart';

// ---------------------------------------------------------------------------
// 右栏：操作面板 (260px)
// ---------------------------------------------------------------------------

class ReviewRightPanel extends ConsumerWidget {
  final ShotV4? shot;
  final List<ShotV4> allShots;

  const ReviewRightPanel({
    super.key,
    required this.shot,
    required this.allShots,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiState = ref.watch(reviewUiProvider);
    final uiNotifier = ref.read(reviewUiProvider.notifier);

    return Container(
      color: const Color(0xFF15152A),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 审核状态
            const Text('审核状态',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
            const SizedBox(height: 12),
            if (shot != null) ...[
              _reviewRadio(
                  'pending', '待审核', Colors.grey, shot!.reviewStatus),
              _reviewRadio(
                  'approved', '确认通过', Colors.green, shot!.reviewStatus),
              _reviewRadio('needsRevision', '需修改', Colors.orange,
                  shot!.reviewStatus),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: shot!.reviewStatus == 'approved'
                      ? null
                      : () => uiNotifier.setReview(
                          shot!.shotNumber, 'approved'),
                  icon: const Icon(AppIcons.check, size: 16),
                  label: const Text('确认通过'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    textStyle: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: shot!.reviewStatus == 'needsRevision'
                      ? null
                      : () => uiNotifier.setReview(
                          shot!.shotNumber, 'needsRevision'),
                  icon: const Icon(AppIcons.warning,
                      size: 16, color: Colors.orange),
                  label: const Text('标记需修改',
                      style: TextStyle(color: Colors.orange)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.orange),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    textStyle: const TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ],

            const Divider(height: 24, color: Color(0xFF2A2A3C)),

            // 审核备注
            const Text('审核备注',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
            const SizedBox(height: 8),
            TextField(
              maxLines: 3,
              style: const TextStyle(fontSize: 12, color: Colors.white),
              decoration: InputDecoration(
                hintText: '记录审核意见...',
                hintStyle: TextStyle(fontSize: 12, color: Colors.grey[600]),
                isDense: true,
                contentPadding: const EdgeInsets.all(10),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[800]!)),
              ),
            ),

            const Divider(height: 24, color: Color(0xFF2A2A3C)),

            // 生成任务
            const Text('生成任务',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
            const SizedBox(height: 8),
            if (shot != null)
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: ['图像', '视频', 'TTS', 'BGM', '音效', '转场']
                    .map((task) => _taskChip(
                        task, shot!.generateTasks.contains(task)))
                    .toList(),
              ),

            const Divider(height: 24, color: Color(0xFF2A2A3C)),

            // 依赖关系
            const Text('依赖关系',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
            const SizedBox(height: 8),
            if (shot?.dependencies != null) ...[
              Text(
                '前置镜头: ${shot!.dependencies!.before.isEmpty ? "无" : shot!.dependencies!.before.map((n) => "#$n").join(", ")}',
                style: TextStyle(fontSize: 12, color: Colors.grey[400]),
              ),
              const SizedBox(height: 4),
              Text(
                '后置镜头: ${shot!.dependencies!.after.isEmpty ? "无" : shot!.dependencies!.after.map((n) => "#$n").join(", ")}',
                style: TextStyle(fontSize: 12, color: Colors.grey[400]),
              ),
            ] else
              Text('无',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),

            const Divider(height: 24, color: Color(0xFF2A2A3C)),

            // 批量操作
            const Text('批量操作',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed:
                    allShots.isEmpty || uiState.selectedEpisodeId == null
                        ? null
                        : () {
                            ref
                                .read(episodeShotsMapProvider.notifier)
                                .approveAll(uiState.selectedEpisodeId!);
                            _toast(context, '本集全部镜头已确认通过');
                          },
                icon: const Icon(AppIcons.check, size: 16),
                label: const Text('一键全部通过'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  textStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: allShots.isEmpty
                    ? null
                    : () {
                        final pending = allShots
                            .where((s) => s.reviewStatus == 'pending')
                            .map((s) => s.shotNumber)
                            .toList();
                        if (pending.isEmpty) {
                          _toast(context, '没有待审核的镜头');
                          return;
                        }
                        if (uiState.selectedEpisodeId != null) {
                          ref
                              .read(episodeShotsMapProvider.notifier)
                              .batchApprove(
                                  uiState.selectedEpisodeId!, pending);
                        }
                        _toast(
                            context, '${pending.length} 个待审核镜头已确认通过');
                      },
                icon: const Icon(AppIcons.check, size: 16),
                label: const Text('通过全部待审核'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  textStyle: const TextStyle(fontSize: 12),
                ),
              ),
            ),

            const Divider(height: 24, color: Color(0xFF2A2A3C)),

            // 删除
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: shot == null || uiState.selectedEpisodeId == null
                    ? null
                    : () => _confirmDeleteShot(
                        context, ref, shot!, uiState),
                icon:
                    Icon(AppIcons.delete, size: 14, color: Colors.red[300]),
                label: Text('删除镜头',
                    style: TextStyle(color: Colors.red[300])),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.red[800]!),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  textStyle: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 私有辅助
// ---------------------------------------------------------------------------

void _toast(BuildContext context, String msg, {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg),
    backgroundColor: isError ? Colors.red[700] : Colors.green[700],
    behavior: SnackBarBehavior.floating,
  ));
}

void _confirmDeleteShot(
    BuildContext context, WidgetRef ref, ShotV4 shot, ReviewUiState uiState) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('确认删除'),
      content: Text('确定要删除镜头 #${shot.shotNumber} 吗？此操作不可撤销。'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(ctx);
            ref
                .read(episodeShotsMapProvider.notifier)
                .deleteShot(uiState.selectedEpisodeId!, shot.shotNumber);
            ref.read(reviewUiProvider.notifier).selectShot(null);
            _toast(context, '已删除镜头 #${shot.shotNumber}');
          },
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('删除'),
        ),
      ],
    ),
  );
}

Widget _reviewRadio(
    String value, String label, Color color, String current) {
  final isActive = current == value;
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? color : Colors.transparent,
            border: Border.all(
                color: isActive ? color : Colors.grey[600]!, width: 2),
          ),
        ),
        const SizedBox(width: 8),
        Text(label,
            style: TextStyle(
                fontSize: 12,
                color: isActive ? color : Colors.grey[500])),
      ],
    ),
  );
}

Widget _taskChip(String label, bool active) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: active
          ? AppColors.primary.withValues(alpha: 0.15)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: active
            ? AppColors.primary.withValues(alpha: 0.5)
            : Colors.grey[700]!,
      ),
    ),
    child: Text(label,
        style: TextStyle(
            fontSize: 11,
            color: active ? AppColors.primary : Colors.grey[500],
            fontWeight: active ? FontWeight.w600 : FontWeight.normal)),
  );
}
