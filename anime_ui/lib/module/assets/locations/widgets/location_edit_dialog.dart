import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/models/location.dart';
import 'package:anime_ui/pub/widgets/asset_form_shell.dart';
import 'package:anime_ui/pub/widgets/asset_input_field.dart';

import 'package:anime_ui/pub/widgets/asset_upload_area.dart';

/// 场景新建/编辑对话框
class LocationEditDialog extends StatefulWidget {
  const LocationEditDialog({
    super.key,
    required this.title,
    this.initial,
    required this.onSave,
  });

  final String title;
  final Location? initial;
  final void Function(Location) onSave;

  @override
  State<LocationEditDialog> createState() => _LocationEditDialogState();
}

class _LocationEditDialogState extends State<LocationEditDialog> {
  late final TextEditingController _name;
  late final TextEditingController _time;
  late final TextEditingController _ie;
  late final TextEditingController _atmosphere;
  late final TextEditingController _colorTone;
  late final TextEditingController _styleNote;
  String _imageUrl = '';

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    _name = TextEditingController(text: i?.name ?? '');
    _time = TextEditingController(text: i?.time ?? '');
    _ie = TextEditingController(text: i?.interiorExterior ?? '');
    _atmosphere = TextEditingController(text: i?.atmosphere ?? '');
    _colorTone = TextEditingController(text: i?.colorTone ?? '');
    _styleNote = TextEditingController(text: i?.styleNote ?? '');
    _imageUrl = i?.imageUrl ?? '';
  }

  @override
  void dispose() {
    _name.dispose();
    _time.dispose();
    _ie.dispose();
    _atmosphere.dispose();
    _colorTone.dispose();
    _styleNote.dispose();
    super.dispose();
  }

  void _submit() {
    if (_name.text.trim().isEmpty) return;
    widget.onSave(
      Location(
        id: widget.initial?.id,
        projectId: widget.initial?.projectId,
        name: _name.text.trim(),
        time: _time.text.trim(),
        interiorExterior: _ie.text.trim(),
        atmosphere: _atmosphere.text.trim(),
        colorTone: _colorTone.text.trim(),
        styleNote: _styleNote.text.trim(),
        imageUrl: _imageUrl,
        taskId: widget.initial?.taskId ?? '',
        imageStatus: widget.initial?.imageStatus ?? 'none',
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AssetFormShell(
      title: widget.title,
      icon: AppIcons.landscape,
      primaryLabel: widget.initial != null ? '保存' : '创建',
      onPrimary: _submit,
      maxWidth: 480.w,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: Spacing.xl.w,
          vertical: Spacing.lg.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AssetUploadArea(
              fileType: UploadFileType.image,
              currentUrl: _imageUrl,
              onUploaded: (url) => setState(() => _imageUrl = url),
              onFileNameChanged: (fileName) {
                if (_name.text.isEmpty) {
                  setState(() => _name.text = fileName);
                }
              },
              uploadCategory: 'location',
              label: _imageUrl.isEmpty ? '上传场景参考图' : '点击替换参考图',
              height: 160.h,
            ),
            SizedBox(height: Spacing.md.h),
            AssetInputField(
              label: '场景名称',
              controller: _name,
              required: true,
            ),
            SizedBox(height: Spacing.md.h),
            AssetInputField(
              label: '时间',
              controller: _time,
              hint: '白天 / 夜晚 / 黄昏…',
            ),
            SizedBox(height: Spacing.md.h),
            AssetInputField(
              label: '内外景',
              controller: _ie,
              hint: '内景 / 外景 / 内外结合',
            ),
            SizedBox(height: Spacing.md.h),
            AssetInputField(
              label: '氛围',
              controller: _atmosphere,
              hint: '温馨、紧张、压抑…',
            ),
            SizedBox(height: Spacing.md.h),
            AssetInputField(
              label: '色调',
              controller: _colorTone,
              hint: '暖色调 / 冷色调 / 灰蓝…',
            ),
            SizedBox(height: Spacing.md.h),
            AssetInputField(
              label: '风格备注',
              controller: _styleNote,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}
