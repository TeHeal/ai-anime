import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';
import 'text_gen_controller.dart';

/// AI 文字生成 - 右侧结果面板（含 idle / generating / done / error 四种状态）
class TextGenResultPanel extends StatelessWidget {
  final TextGenController controller;
  final Color accent;
  final VoidCallback onGenerate;

  const TextGenResultPanel({
    super.key,
    required this.controller,
    required this.accent,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0F0F0F),
      child: switch (controller.status) {
        TextGenStatus.idle => _buildIdlePlaceholder(),
        TextGenStatus.generating => _buildGenerating(),
        TextGenStatus.done => _buildResult(context),
        TextGenStatus.error => _buildError(),
      },
    );
  }

  Widget _buildIdlePlaceholder() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.06),
              shape: BoxShape.circle,
            ),
            child: Icon(AppIcons.document,
                size: 36, color: accent.withValues(alpha: 0.3)),
          ),
          const SizedBox(height: 16),
          Text('输入指令开始生成',
              style: TextStyle(fontSize: 14, color: Colors.grey[500])),
          const SizedBox(height: 6),
          Text('AI 将根据你的描述生成文字内容',
              style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildGenerating() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
                strokeWidth: 3, color: accent),
          ),
          const SizedBox(height: 16),
          Text('正在生成…',
              style: TextStyle(fontSize: 14, color: accent)),
          const SizedBox(height: 6),
          Text('AI 正在创作中，请稍候',
              style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildResult(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Row(
            children: [
              Icon(AppIcons.checkOutline, size: 14, color: accent),
              const SizedBox(width: 6),
              Text('生成结果',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: accent)),
              const Spacer(),
              TinyAction(
                icon: Icons.copy_rounded,
                label: '复制',
                color: accent,
                onTap: () {
                  Clipboard.setData(ClipboardData(text: controller.result));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('已复制到剪贴板'),
                      backgroundColor: Colors.grey[800],
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              TinyAction(
                icon: AppIcons.magicStick,
                label: '重新生成',
                color: Colors.grey[400]!,
                onTap: onGenerate,
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: accent.withValues(alpha: 0.15)),
              ),
              child: SelectableText(
                controller.result,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                  height: 1.7,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.error, size: 32, color: Colors.red[400]),
          const SizedBox(height: 12),
          Text('生成失败',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.red[400])),
          if (controller.errorMsg.isNotEmpty) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                controller.errorMsg,
                style: TextStyle(fontSize: 12, color: Colors.red[300]),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: onGenerate,
            icon: Icon(AppIcons.magicStick, size: 14, color: accent),
            label: Text('重试', style: TextStyle(color: accent)),
          ),
        ],
      ),
    );
  }
}

/// 小型操作按钮（复制、重新生成等）
class TinyAction extends StatelessWidget {
  const TinyAction({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 12, color: color),
      label: Text(label, style: TextStyle(fontSize: 11, color: color)),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
