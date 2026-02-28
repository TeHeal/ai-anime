import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';
import '../image_gen_controller.dart';

/// 参考图网格：支持 0~N 张，点击添加，长按拖拽排序，点击已有图片可删除
class RefImageGrid extends StatelessWidget {
  const RefImageGrid({
    super.key,
    required this.controller,
    required this.maxImages,
    required this.accent,
  });

  final ImageGenController controller;
  final int maxImages;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final images = controller.refImages;
    final canAdd = images.length < maxImages;

    if (maxImages == 0) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '参考图',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '(${images.length}/$maxImages)',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
            if (images.isNotEmpty) ...[
              const Spacer(),
              GestureDetector(
                onTap: () {
                  for (int i = images.length - 1; i >= 0; i--) {
                    controller.removeRefImage(i);
                  }
                },
                child: Text(
                  '清除全部',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        ReorderableWrap(
          images: images,
          canAdd: canAdd,
          accent: accent,
          onAdd: () => _pickImage(context),
          onRemove: (i) => controller.removeRefImage(i),
          onReorder: (o, n) => controller.reorderRefImages(o, n),
        ),
      ],
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null) return;
    try {
      await controller.addRefImage(file.bytes!, file.name);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('上传失败：$e'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    }
  }
}

class ReorderableWrap extends StatelessWidget {
  const ReorderableWrap({
    super.key,
    required this.images,
    required this.canAdd,
    required this.accent,
    required this.onAdd,
    required this.onRemove,
    required this.onReorder,
  });

  final List<String> images;
  final bool canAdd;
  final Color accent;
  final VoidCallback onAdd;
  final void Function(int index) onRemove;
  final void Function(int oldIndex, int newIndex) onReorder;

  static const _size = 72.0;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...images.asMap().entries.map((e) {
          final index = e.key;
          final url = e.value;
          return _ImageThumb(
            key: ValueKey(url),
            url: url,
            accent: accent,
            size: _size,
            onRemove: () => onRemove(index),
          );
        }),
        if (canAdd)
          _AddButton(
            accent: accent,
            size: _size,
            onTap: onAdd,
          ),
      ],
    );
  }
}

class _ImageThumb extends StatefulWidget {
  const _ImageThumb({
    super.key,
    required this.url,
    required this.accent,
    required this.size,
    required this.onRemove,
  });

  final String url;
  final Color accent;
  final double size;
  final VoidCallback onRemove;

  @override
  State<_ImageThumb> createState() => _ImageThumbState();
}

class _ImageThumbState extends State<_ImageThumb> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                widget.url,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: Colors.grey[800],
                  child: Icon(AppIcons.gallery, size: 24, color: Colors.grey[600]),
                ),
              ),
            ),
            if (_hovered)
              GestureDetector(
                onTap: widget.onRemove,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(AppIcons.close, size: 20, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AddButton extends StatefulWidget {
  const _AddButton({
    required this.accent,
    required this.size,
    required this.onTap,
  });

  final Color accent;
  final double size;
  final VoidCallback onTap;

  @override
  State<_AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<_AddButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: _hovered
                ? widget.accent.withValues(alpha: 0.1)
                : widget.accent.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.accent.withValues(alpha: _hovered ? 0.4 : 0.2),
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(AppIcons.add, size: 20, color: widget.accent.withValues(alpha: 0.6)),
              const SizedBox(height: 2),
              Text(
                '添加',
                style: TextStyle(
                  fontSize: 10,
                  color: widget.accent.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
