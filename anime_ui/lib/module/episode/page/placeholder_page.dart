import 'package:flutter/material.dart';

/// 成片子页占位
class EpisodePlaceholderPage extends StatelessWidget {
  const EpisodePlaceholderPage({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(subtitle)),
    );
  }
}
