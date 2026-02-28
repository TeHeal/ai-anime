import 'package:flutter/material.dart';

/// 段落间插入按钮 — 默认居中短横线，hover 向两侧延伸 + 居中胶囊按钮
class InsertHandle extends StatefulWidget {
  const InsertHandle({super.key, required this.onInsert});

  final VoidCallback onInsert;

  @override
  State<InsertHandle> createState() => _InsertHandleState();
}

class _InsertHandleState extends State<InsertHandle> {
  bool _hovered = false;

  static const _lineColor = Color(0xFF2E2E40);
  static const _accent = Color(0xFF8B5CF6);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onInsert,
        child: SizedBox(
          height: 32,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final fullWidth = constraints.maxWidth;
              return Stack(
                alignment: Alignment.center,
                children: [
                  // 横线：默认 100px，hover 延伸到全宽
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeInOut,
                    width: _hovered ? fullWidth : 100,
                    height: _hovered ? 1.5 : 6,
                    decoration: BoxDecoration(
                      color: _lineColor,
                      borderRadius: BorderRadius.circular(_hovered ? 1 : 3),
                    ),
                  ),
                  // 胶囊按钮
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 220),
                    opacity: _hovered ? 1.0 : 0.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: _accent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_circle_outline_rounded,
                              size: 14, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            '新增内容',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
