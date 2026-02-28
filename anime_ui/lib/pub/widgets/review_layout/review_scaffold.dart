import 'package:flutter/material.dart';

/// Three-column review layout: left nav + center editor + right panel.
///
/// Accepts builders so each module can supply its own content while sharing
/// the structural skeleton (dividers, widths, background colours).
class ReviewScaffold extends StatelessWidget {
  final Widget leftNav;
  final Widget center;
  final Widget rightPanel;
  final Widget? topBar;
  final double leftWidth;
  final double rightWidth;

  const ReviewScaffold({
    super.key,
    required this.leftNav,
    required this.center,
    required this.rightPanel,
    this.topBar,
    this.leftWidth = 240,
    this.rightWidth = 260,
  });

  static const _dividerColor = Color(0xFF2A2A3C);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (topBar != null) topBar!,  // ignore: use_null_aware_elements
        Expanded(
          child: Row(
            children: [
              SizedBox(width: leftWidth, child: leftNav),
              const VerticalDivider(
                  width: 1, thickness: 1, color: _dividerColor),
              Expanded(child: center),
              const VerticalDivider(
                  width: 1, thickness: 1, color: _dividerColor),
              SizedBox(width: rightWidth, child: rightPanel),
            ],
          ),
        ),
      ],
    );
  }
}
