import 'package:flutter/material.dart';

/// 资产分类卡片
class AssetCategoryCard extends StatefulWidget {
  const AssetCategoryCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.confirmed,
    required this.total,
    this.pending = 0,
    this.nextAction,
    this.onTap,
    this.isLoading = false,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final int confirmed;
  final int total;
  final int pending;
  final String? nextAction;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  State<AssetCategoryCard> createState() => _AssetCategoryCardState();
}

class _AssetCategoryCardState extends State<AssetCategoryCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final allDone = widget.total > 0 && widget.confirmed == widget.total;
    final pending = widget.total - widget.confirmed;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _hovered
                  ? [
                      widget.iconColor.withValues(alpha: 0.08),
                      widget.iconColor.withValues(alpha: 0.03),
                    ]
                  : [
                      const Color(0xFF1E1E2E),
                      const Color(0xFF252540),
                    ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _hovered
                  ? widget.iconColor.withValues(alpha: 0.4)
                  : widget.iconColor.withValues(alpha: 0.1),
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: widget.iconColor.withValues(alpha: 0.15),
                      blurRadius: 16,
                      spreadRadius: 0,
                    ),
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: widget.iconColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child:
                        Icon(widget.icon, size: 16, color: widget.iconColor),
                  ),
                  const SizedBox(width: 10),
                  Text(widget.label,
                      style: TextStyle(
                          fontSize: 13,
                          color: _hovered
                              ? widget.iconColor
                              : Colors.grey[400],
                          fontWeight: FontWeight.w500)),
                  const Spacer(),
                  if (!widget.isLoading)
                    Text('${widget.confirmed}/${widget.total}',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                ],
              ),
              const SizedBox(height: 12),
              if (!widget.isLoading && widget.total > 0)
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: widget.confirmed / widget.total,
                    minHeight: 3,
                    backgroundColor: Colors.grey[800],
                    color: allDone
                        ? const Color(0xFF22C55E)
                        : widget.iconColor,
                  ),
                ),
              if (widget.isLoading)
                const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: widget.nextAction != null
                        ? Text.rich(
                            TextSpan(children: [
                              TextSpan(
                                  text: '下一步: ',
                                  style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 11)),
                              TextSpan(
                                  text: widget.nextAction,
                                  style: TextStyle(
                                      color: widget.iconColor
                                          .withValues(alpha: 0.9),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500)),
                            ]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : Text(
                            allDone
                                ? '✓ 全部就绪'
                                : widget.total == 0
                                    ? '暂无数据'
                                    : widget.confirmed == 0 && widget.pending > 0
                                        ? '已识别 ${widget.pending} 个，待确认'
                                        : '$pending 个待处理',
                            style: TextStyle(
                              fontSize: 11,
                              color: allDone
                                  ? const Color(0xFF22C55E)
                                  : pending > 0
                                      ? Colors.orange[300]
                                      : Colors.grey[500],
                            ),
                          ),
                  ),
                  if (widget.onTap != null)
                    Text('前往 →',
                        style: TextStyle(
                            fontSize: 11,
                            color: _hovered
                                ? widget.iconColor
                                : Colors.grey[600],
                            fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
