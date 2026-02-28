import 'package:flutter/material.dart';

/// 任务中心页占位（待迁移完整实现）
class TaskCenterPage extends StatelessWidget {
  const TaskCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('任务中心')),
      body: const Center(child: Text('任务中心页占位')),
    );
  }
}
