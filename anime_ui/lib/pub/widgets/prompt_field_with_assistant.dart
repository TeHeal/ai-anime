import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/providers/project_provider.dart';
import 'package:anime_ui/pub/services/script_ai_svc.dart';
import 'package:anime_ui/pub/models/ai_action.dart';
import 'creation_assistant_pill_button.dart';
import 'tiny_btn.dart';
import 'prompt_field_neg.dart';
import 'prompt_field_ai_suggestion.dart';

/// 带「创作助理」和「提示词库」的提示词输入框，适用于所有需要提示词 / 反向提示词的场景。
///
/// 支持两种模式：
/// - **Controller 模式**：传入 [controller] 和 [onLibraryTap]
/// - **受控模式**：传入 [value]/[onChanged]，适用于 Provider 等状态管理
///
/// 创作助理提供与剧本块一致的文字小场景工具：润色、扩写、缩写、续写、改写，
/// 内联流式预览，无需弹窗。
class PromptFieldWithAssistant extends ConsumerStatefulWidget {
  const PromptFieldWithAssistant({
    super.key,
    this.controller,
    this.value,
    this.onChanged,
    required this.hint,
    required this.accent,
    this.onLibraryTap,
    this.onSaveToLibrary,
    this.quickPrompts = const [],
    this.maxLines = 4,
    this.decoration,
    this.negPromptController,
    this.negValue,
    this.negOnChanged,
    this.negPromptHint,
    this.label,
    this.negOnLibraryTap,
    this.negOnly = false,
  }) : assert(
         (controller != null) != (value != null && onChanged != null),
         '需提供 controller 或 (value + onChanged)',
       );

  final bool negOnly;
  final TextEditingController? controller;
  final String? value;
  final ValueChanged<String>? onChanged;
  final String hint;
  final Color accent;
  final void Function(ValueChanged<String> onSelected)? onLibraryTap;
  final Future<void> Function(
    String text,
    String name, {
    required bool isNegative,
  })?
  onSaveToLibrary;
  final String? label;
  final void Function(ValueChanged<String> onSelected)? negOnLibraryTap;
  final String? negValue;
  final ValueChanged<String>? negOnChanged;
  final List<String> quickPrompts;
  final int maxLines;
  final InputDecoration? decoration;
  final TextEditingController? negPromptController;
  final String? negPromptHint;

  @override
  ConsumerState<PromptFieldWithAssistant> createState() =>
      _PromptFieldWithAssistantState();
}

class _PromptFieldWithAssistantState
    extends ConsumerState<PromptFieldWithAssistant> {
  final _scriptAiSvc = ScriptAiService();
  TextEditingController? _mainCtrl;
  TextEditingController? _negCtrl;
  String? _aiSuggestion;
  String? _aiOriginalContent;
  bool _aiLoading = false;
  StreamSubscription<String>? _aiSub;
  TextEditingController? _aiSuggestionCtrl;
  bool _showOriginalDiff = false;

  bool get _isControlled => widget.value != null && widget.onChanged != null;
  TextEditingController get _effectiveMainCtrl =>
      widget.controller ?? _mainCtrl!;
  TextEditingController? get _effectiveNegCtrl {
    if (widget.negOnly && _negCtrl != null) return _negCtrl;
    return widget.negPromptController ?? _negCtrl;
  }

  @override
  void initState() {
    super.initState();
    if (_isControlled) {
      if (widget.negOnly) {
        _negCtrl = TextEditingController(text: widget.value ?? '');
        _negCtrl!.addListener(_syncNegFromCtrl);
      } else {
        _mainCtrl = TextEditingController(text: widget.value);
        _mainCtrl!.addListener(_syncMainFromCtrl);
        if (widget.negValue != null && widget.negOnChanged != null) {
          _negCtrl = TextEditingController(text: widget.negValue);
          _negCtrl!.addListener(_syncNegFromCtrl);
        }
      }
    }
  }

  void _syncMainFromCtrl() {
    widget.onChanged?.call(_mainCtrl!.text);
  }

  void _syncNegFromCtrl() {
    if (widget.negOnly) {
      widget.onChanged?.call(_negCtrl!.text);
    } else {
      widget.negOnChanged?.call(_negCtrl!.text);
    }
  }

  @override
  void didUpdateWidget(covariant PromptFieldWithAssistant oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isControlled) {
      if (widget.negOnly) {
        if (widget.value != null && widget.value != _negCtrl?.text) {
          _negCtrl?.text = widget.value!;
        }
      } else {
        if (widget.value != null && widget.value != _mainCtrl?.text) {
          _mainCtrl?.text = widget.value!;
        }
        if (widget.negValue != null &&
            widget.negOnChanged != null &&
            widget.negValue != _negCtrl?.text) {
          _negCtrl?.text = widget.negValue!;
        }
      }
    }
  }

  void _onAssistantAction(AiAction action) {
    _runAssistantAction(action, _effectiveMainCtrl);
  }

  void _onAssistantActionForController(AiAction action) {
    if (_effectiveNegCtrl != null) {
      _runAssistantAction(action, _effectiveNegCtrl!);
    }
  }

  void _runAssistantAction(AiAction action, TextEditingController ctrl) {
    final content = ctrl.text.trim();
    if (content.isEmpty && action != AiAction.continueWrite) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请先输入提示词内容')));
      return;
    }

    final pid = ref.read(currentProjectProvider).value?.id ?? 1;
    final stream = _scriptAiSvc.assistBlock(
      action: action.name,
      blockType: 'prompt',
      blockContent: content,
      sceneMeta: '',
      contextBlocks: [],
      projectId: pid,
    );

    _aiOriginalContent = content;
    _aiSuggestionCtrl?.dispose();
    _aiSuggestionCtrl = TextEditingController();
    _targetControllerForAi = ctrl;
    setState(() {
      _aiSuggestion = '';
      _aiLoading = true;
      _showOriginalDiff = false;
    });
    _aiSub?.cancel();
    _aiSub = stream.listen(
      (chunk) {
        if (!mounted) return;
        setState(() {
          _aiSuggestion = (_aiSuggestion ?? '') + chunk;
          _aiSuggestionCtrl?.text = _aiSuggestion!;
        });
      },
      onDone: () {
        if (mounted) setState(() => _aiLoading = false);
      },
      onError: (e) {
        if (mounted) {
          setState(() => _aiLoading = false);
          final msg = e.toString().replaceFirst('ApiException(-1): ', '');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('创作助理失败: $msg'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
    );
  }

  TextEditingController? _targetControllerForAi;

  void _acceptReplace() {
    final text = _aiSuggestionCtrl?.text ?? _aiSuggestion;
    final target = _targetControllerForAi ?? _effectiveMainCtrl;
    if (text == null || text.isEmpty) return;
    target.text = text;
    _dismissAi();
  }

  void _acceptAppend() {
    final text = _aiSuggestionCtrl?.text ?? _aiSuggestion;
    final target = _targetControllerForAi ?? _effectiveMainCtrl;
    if (text == null || text.isEmpty) return;
    final current = target.text;
    final separator = current.isNotEmpty && !current.endsWith(',') ? ', ' : '';
    target.text = '$current$separator$text';
    _dismissAi();
  }

  void _dismissAi() {
    _aiSub?.cancel();
    _aiSuggestionCtrl?.dispose();
    _aiSuggestionCtrl = null;
    setState(() {
      _aiSuggestion = null;
      _aiOriginalContent = null;
      _aiLoading = false;
      _showOriginalDiff = false;
    });
  }

  Future<void> _saveToLibrary(
    TextEditingController ctrl,
    bool isNegative,
  ) async {
    final text = ctrl.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请先输入提示词内容')));
      return;
    }
    final onSave = widget.onSaveToLibrary;
    if (onSave == null) return;

    final defaultName = text.length > 20 ? '${text.substring(0, 20)}…' : text;
    final name = await _showSaveToLibraryNameDialog(defaultName);
    if (name == null || name.isEmpty || !mounted) return;

    try {
      await onSave(text, name.trim(), isNegative: isNegative);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('已保存到提示词库'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('入库失败: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<String?> _showSaveToLibraryNameDialog(String defaultName) async {
    final ctrl = TextEditingController(text: defaultName);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceMutedDarker,
        title: Text(
          '入库',
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.mutedLight),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onPrimary),
          decoration: InputDecoration(
            labelText: '提示词名称',
            labelStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.muted,
            ),
            hintText: '输入名称便于后续查找',
            hintStyle: AppTextStyles.caption.copyWith(
              color: AppColors.mutedDarker,
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: widget.accent),
            ),
          ),
          onSubmitted: (v) =>
              Navigator.pop(ctx, v.trim().isNotEmpty ? v.trim() : defaultName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              '取消',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.muted),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              ctx,
              ctrl.text.trim().isNotEmpty ? ctrl.text.trim() : defaultName,
            ),
            style: FilledButton.styleFrom(backgroundColor: widget.accent),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _aiSub?.cancel();
    _aiSuggestionCtrl?.dispose();
    _mainCtrl?.removeListener(_syncMainFromCtrl);
    _negCtrl?.removeListener(_syncNegFromCtrl);
    if (_isControlled) {
      _mainCtrl?.dispose();
      _negCtrl?.dispose();
    }
    super.dispose();
  }

  InputDecoration _defaultInputDeco(String hintText, Color accent) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.mutedDarker),
      filled: true,
      fillColor: AppColors.surfaceMutedDarker,
      contentPadding: EdgeInsets.symmetric(
        horizontal: Spacing.md.w,
        vertical: Spacing.lg.h,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.md.r),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.md.r),
        borderSide: BorderSide(color: accent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inputDeco =
        widget.decoration ?? _defaultInputDeco(widget.hint, widget.accent);
    final negHint = widget.negPromptHint ?? '不想出现的元素，如：模糊、变形、低质量…';

    if (widget.negOnly && _effectiveNegCtrl != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NegPromptField(
            controller: _effectiveNegCtrl!,
            hint: negHint,
            accent: widget.accent,
            label: widget.label ?? '反向提示词（选填）',
            onLibraryTap: widget.onLibraryTap != null
                ? () => widget.onLibraryTap!((p) {
                    _effectiveNegCtrl!.text = p;
                    widget.onChanged?.call(p);
                  })
                : null,
            onAssistantAction: _onAssistantActionForController,
            onSaveToLibrary: widget.onSaveToLibrary != null
                ? () => _saveToLibrary(_effectiveNegCtrl!, true)
                : null,
          ),
          if (_aiSuggestion != null || _aiLoading) _buildAiSuggestion(),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.label ?? '提示词',
              style: AppTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.muted,
              ),
            ),
            const Spacer(),
            CreationAssistantPillButton<AiAction>(
              itemBuilder: (_) => AiAction.values
                  .map(
                    (a) => PopupMenuItem<AiAction>(
                      value: a,
                      height: 36.h,
                      child: Row(
                        children: [
                          Icon(
                            aiActionIcons[a],
                            size: 15.r,
                            color: widget.accent,
                          ),
                          SizedBox(width: Spacing.sm.w),
                          Text(
                            aiActionLabels[a]!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onSelected: _onAssistantAction,
            ),
            if (widget.onLibraryTap != null) ...[
              SizedBox(width: Spacing.sm.w),
              TinyBtn(
                icon: AppIcons.document,
                label: '提示词库',
                accent: widget.accent,
                onTap: () => widget.onLibraryTap!((p) {
                  _effectiveMainCtrl.text = p;
                  if (_isControlled) widget.onChanged?.call(p);
                }),
              ),
            ],
          ],
        ),
        SizedBox(height: Spacing.sm.h),

        Stack(
          clipBehavior: Clip.none,
          children: [
            TextField(
              controller: _effectiveMainCtrl,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurface,
              ),
              maxLines: widget.maxLines,
              decoration: widget.onSaveToLibrary != null
                  ? (inputDeco.copyWith(
                      contentPadding: EdgeInsets.only(
                        left: 12.w,
                        top: 10.h,
                        right: 70.w,
                        bottom: 36.h,
                      ),
                    ))
                  : inputDeco,
            ),
            if (widget.onSaveToLibrary != null)
              Positioned(
                right: 8.w,
                bottom: 8.h,
                child: TinyBtn(
                  icon: AppIcons.save,
                  label: '入库',
                  accent: widget.accent,
                  onTap: () => _saveToLibrary(_effectiveMainCtrl, false),
                ),
              ),
          ],
        ),

        if (_aiSuggestion != null || _aiLoading) _buildAiSuggestion(),

        if (widget.quickPrompts.isNotEmpty) ...[
          SizedBox(height: Spacing.sm.h),
          Wrap(
            spacing: Spacing.sm.w,
            runSpacing: Spacing.sm.h,
            children: widget.quickPrompts.map((p) {
              return GestureDetector(
                onTap: () {
                  final current = _effectiveMainCtrl.text;
                  final next = current.isEmpty ? p : '$current, $p';
                  _effectiveMainCtrl.text = next;
                  if (_isControlled) widget.onChanged!(next);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Spacing.sm.w,
                    vertical: Spacing.xs.h,
                  ),
                  decoration: BoxDecoration(
                    color: widget.accent.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
                    border: Border.all(
                      color: widget.accent.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    p,
                    style: AppTextStyles.tiny.copyWith(color: widget.accent),
                  ),
                ),
              );
            }).toList(),
          ),
        ],

        if (_effectiveNegCtrl != null) ...[
          SizedBox(height: Spacing.lg.h),
          NegPromptField(
            controller: _effectiveNegCtrl!,
            hint: negHint,
            accent: widget.accent,
            label: '反向提示词（选填）',
            onLibraryTap: widget.negOnLibraryTap != null
                ? () => widget.negOnLibraryTap!((p) {
                    _effectiveNegCtrl!.text = p;
                    widget.negOnChanged?.call(p);
                  })
                : null,
            onAssistantAction: _onAssistantActionForController,
            onSaveToLibrary: widget.onSaveToLibrary != null
                ? () => _saveToLibrary(_effectiveNegCtrl!, true)
                : null,
          ),
        ],
      ],
    );
  }

  Widget _buildAiSuggestion() {
    return PromptFieldAiSuggestion(
      suggestion: _aiSuggestion,
      loading: _aiLoading,
      originalContent: _aiOriginalContent,
      showOriginalDiff: _showOriginalDiff,
      accent: widget.accent,
      onToggleOriginalDiff: () =>
          setState(() => _showOriginalDiff = !_showOriginalDiff),
      onDismiss: _dismissAi,
      onAcceptReplace: _aiLoading ? null : _acceptReplace,
      onAcceptAppend: _aiLoading ? null : _acceptAppend,
      controller: _aiSuggestionCtrl,
    );
  }
}
