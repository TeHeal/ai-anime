import 'package:flutter/material.dart';

import 'package:anime_ui/pub/models/dashboard.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/colors.dart';
import 'step_progress_bar.dart';

/// 集卡片：状态、标题、进度条
class EpisodeCard extends StatefulWidget {
  const EpisodeCard({
    super.key,
    required this.episode,
    required this.onTap,
    this.compact = false,
  });

  final DashboardEpisode episode;
  final VoidCallback onTap;
  final bool compact;

  @override
  State<EpisodeCard> createState() => _EpisodeCardState();
}

class _EpisodeCardState extends State<EpisodeCard> {
  bool _hovered = false;

  DashboardEpisode get ep => widget.episode;

  @override
  Widget build(BuildContext context) {
    return widget.compact ? _buildCompact() : _buildFull();
  }

  Widget _buildFull() {
    final statusInfo = _statusInfo(ep.status);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _hovered
                ? AppColors.surface.withValues(alpha: 0.9)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _hovered
                  ? AppColors.primary.withValues(alpha: 0.5)
                  : Colors.grey[800]!.withValues(alpha: 0.5),
              width: _hovered ? 1.5 : 1,
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(statusInfo),
              const SizedBox(height: 14),
              _buildTitle(),
              if (ep.summary.isNotEmpty) ...[
                const SizedBox(height: 6),
                _buildSummary(),
              ],
              const SizedBox(height: 16),
              _buildStepIndicator(),
              const SizedBox(height: 14),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompact() {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _hovered
                ? AppColors.surface.withValues(alpha: 0.9)
                : AppColors.surface.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _hovered
                  ? AppColors.primary.withValues(alpha: 0.4)
                  : Colors.grey[800]!.withValues(alpha: 0.4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    '第${ep.sortIndex + 1}集',
                    style: TextStyle(color: Colors.grey[500], fontSize: 11),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      ep.title.isNotEmpty ? ep.title : '第${ep.sortIndex + 1}集',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (ep.sceneCount > 0)
                    Text(
                      '${ep.sceneCount}场',
                      style: TextStyle(color: Colors.grey[600], fontSize: 11),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              _buildStepIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(_StatusInfo info) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: info.color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(info.icon, size: 13, color: info.color),
              const SizedBox(width: 5),
              Text(
                info.label,
                style: TextStyle(
                  color: info.color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Text(
          '第${ep.sortIndex + 1}集',
          style: TextStyle(color: Colors.grey[500], fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      ep.title.isNotEmpty ? ep.title : '第${ep.sortIndex + 1}集',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildSummary() {
    return Text(
      ep.summary,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
          color: Colors.grey[400], fontSize: 13, height: 1.4),
    );
  }

  Widget _buildStepIndicator() {
    final prog = ep.progress;
    final percentages = prog != null
        ? [
            prog.assetsPct,
            prog.scriptPct,
            prog.storyboardPct,
            prog.shotsPct,
            prog.episodePct,
          ]
        : null;
    return StepProgressBar(
      currentStep: ep.currentStep,
      percentages: percentages,
      compact: widget.compact,
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        if (ep.sceneCount > 0) ...[
          Icon(AppIcons.list, size: 13, color: Colors.grey[500]),
          const SizedBox(width: 4),
          Text(
            '${ep.sceneCount}场',
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
          const SizedBox(width: 12),
        ],
        if (ep.characterNames.isNotEmpty) ...[
          Icon(AppIcons.person, size: 13, color: Colors.grey[500]),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              ep.characterNames.take(3).join('、'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ),
        ],
        if (ep.characterNames.isEmpty) const Spacer(),
        if (_hovered)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '进入',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
            ),
          ),
      ],
    );
  }

  static _StatusInfo _statusInfo(String status) {
    switch (status) {
      case 'in_progress':
        return _StatusInfo(
            '进行中', AppIcons.inProgress, const Color(0xFF3B82F6));
      case 'completed':
        return _StatusInfo('已完成', AppIcons.check, const Color(0xFF22C55E));
      default:
        return _StatusInfo('未开始', AppIcons.circleOutline, Colors.grey[500]!);
    }
  }
}

class _StatusInfo {
  const _StatusInfo(this.label, this.icon, this.color);
  final String label;
  final IconData icon;
  final Color color;
}
