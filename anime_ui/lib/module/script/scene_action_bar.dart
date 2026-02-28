import 'package:flutter/material.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';

/// 场景保存状态
enum SaveStatus { clean, unsaved, saving, saved, error }

/// 场景编辑器底部操作栏：保存按钮 + 保存状态指示器
class SceneActionBar extends StatelessWidget {
  const SceneActionBar({
    super.key,
    required this.saveStatus,
    required this.saving,
    required this.readOnly,
    required this.onSave,
  });

  final SaveStatus saveStatus;
  final bool saving;
  final bool readOnly;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF232336))),
      ),
      child: Row(
        children: [
          _buildSaveStatusIndicator(),
          const Spacer(),
          FilledButton.icon(
            onPressed: (saving || readOnly) ? null : onSave,
            icon: saving
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(AppIcons.save, size: 15),
            label: Text(saving ? '保存中…' : '保存'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
              textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildSaveStatusIndicator() {
    IconData icon;
    String text;
    Color color;
    switch (saveStatus) {
      case SaveStatus.clean:
      case SaveStatus.saved:
        icon = AppIcons.checkCircleOutline;
        text = '已保存';
        color = const Color(0xFF22C55E);
      case SaveStatus.unsaved:
        icon = AppIcons.circleOutline;
        text = '未保存';
        color = const Color(0xFFF59E0B);
      case SaveStatus.saving:
        icon = AppIcons.sync;
        text = '自动保存中…';
        color = const Color(0xFF3B82F6);
      case SaveStatus.error:
        icon = AppIcons.errorOutline;
        text = '保存失败';
        color = const Color(0xFFEF4444);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 12, color: color)),
      ],
    );
  }
}
