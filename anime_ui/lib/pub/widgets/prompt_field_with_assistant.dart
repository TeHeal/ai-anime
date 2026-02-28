import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/providers/project_provider.dart';
import 'package:anime_ui/pub/services/script_ai_svc.dart';
import 'package:anime_ui/pub/models/ai_action.dart';
import 'ai_suggestion_panel.dart';
import 'creation_assistant_pill_button.dart';
import 'neg_prompt_field.dart';
import 'tiny_btn.dart';

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

  /// 仅显示反向提示词区块（用于单独配置时）
  final bool negOnly;

  /// Controller 模式：主输入框控制器
  final TextEditingController? controller;

  /// 受控模式：主输入框值
  final String? value;

  /// 受控模式：主输入框变更回调
  final ValueChanged<String>? onChanged;

  final String hint;
  final Color accent;

  /// 提示词库回调。点击「提示词库」时调用，传入 [onSelected] 以接收用户选择的文本。
  final void Function(ValueChanged<String> onSelected)? onLibraryTap;

  /// 入库回调。点击「入库」时调用，将当前输入保存到提示词库。
  /// [text] 为提示词内容，[name] 为用户输入的名称，[isNegative] 表示是否为反向提示词。
  final Future<void> Function(String text, String name, {required bool isNegative})? onSaveToLibrary;

  /// 主输入框标签，默认「提示词」
  final String? label;

  /// 反向提示词区域的提示词库回调
  final void Function(ValueChanged<String> onSelected)? negOnLibraryTap;

  /// 受控模式：反向提示词值
  final String? negValue;

  /// 受控模式：反向提示词变更回调
  final ValueChanged<String>? negOnChanged;

  /// 快捷提示词芯片
  final List<String> quickPrompts;

  /// 主输入框行数
  final int maxLines;

  /// 自定义输入框装饰，若为 null 则使用默认深色风格
  final InputDecoration? decoration;

  /// 反向提示词控制器，若提供则渲染反向提示词区块
  final TextEditingController? negPromptController;

  /// 反向提示词占位
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先输入提示词内容')),
      );
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
              backgroundColor: Colors.red[700],
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

  Future<void> _saveToLibrary(TextEditingController ctrl, bool isNegative) async {
    final text = ctrl.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先输入提示词内容')),
      );
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
            backgroundColor: Color(0xFF22C55E),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('入库失败: $e'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    }
  }

  Future<String?> _showSaveToLibraryNameDialog(String defaultName) async {
    final ctrl = TextEditingController(text: defaultName);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('入库', style: TextStyle(color: Colors.grey[300], fontSize: 15)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            labelText: '提示词名称',
            labelStyle: TextStyle(color: Colors.grey[400]),
            hintText: '输入名称便于后续查找',
            hintStyle: TextStyle(color: Colors.grey[600], fontSize: 12),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[700]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: widget.accent),
            ),
          ),
          onSubmitted: (v) => Navigator.pop(ctx, v.trim().isNotEmpty ? v.trim() : defaultName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('取消', style: TextStyle(color: Colors.grey[400])),
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
        // 标签行：标签 + 创作助理 + 提示词库
        Row(
          children: [
            Text(
              widget.label ?? '提示词',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[400],
              ),
            ),
            const Spacer(),
            CreationAssistantPillButton<AiAction>(
              itemBuilder: (_) => AiAction.values
                  .map((a) => PopupMenuItem<AiAction>(
                        value: a,
                        height: 36,
                        child: Row(
                          children: [
                            Icon(aiActionIcons[a],
                                size: 15, color: widget.accent),
                            const SizedBox(width: 8),
                            Text(
                              aiActionLabels[a]!,
                              style: const TextStyle(
                                  fontSize: 13, color: Color(0xFFE4E4E7)),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
              onSelected: _onAssistantAction,
            ),
            if (widget.onLibraryTap != null) ...[
              const SizedBox(width: 6),
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
        const SizedBox(height: 6),

        // 主输入框（入库按钮置于输入框内右下角）
        Stack(
          clipBehavior: Clip.none,
          children: [
            TextField(
              controller: _effectiveMainCtrl,
              style: const TextStyle(fontSize: 13, color: Colors.white),
              maxLines: widget.maxLines,
              decoration: widget.onSaveToLibrary != null
                  ? (inputDeco.copyWith(
                      contentPadding: const EdgeInsets.only(
                        left: 12,
                        top: 10,
                        right: 70,
                        bottom: 36,
                      ),
                    ))
                  : inputDeco,
            ),
            if (widget.onSaveToLibrary != null)
              Positioned(
                right: 8,
                bottom: 8,
                child: TinyBtn(
                  icon: AppIcons.save,
                  label: '入库',
                  accent: widget.accent,
                  onTap: () => _saveToLibrary(_effectiveMainCtrl, false),
                ),
              ),
          ],
        ),

        // AI 建议内联区
        if (_aiSuggestion != null || _aiLoading) _buildAiSuggestion(),

        // 快捷芯片
        if (widget.quickPrompts.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: widget.quickPrompts.map((p) {
              return GestureDetector(
                onTap: () {
                  final current = _effectiveMainCtrl.text;
                  final next = current.isEmpty ? p : '$current, $p';
                  _effectiveMainCtrl.text = next;
                  if (_isControlled) widget.onChanged!(next);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: widget.accent.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: widget.accent.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                      p, style: TextStyle(fontSize: 11, color: widget.accent)),
                ),
              );
            }).toList(),
          ),
        ],

        // 反向提示词（可选）
        if (_effectiveNegCtrl != null) ...[
          const SizedBox(height: 10),
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
    return AiSuggestionPanel(
      accent: widget.accent,
      aiLoading: _aiLoading,
      aiSuggestion: _aiSuggestion,
      aiOriginalContent: _aiOriginalContent,
      showOriginalDiff: _showOriginalDiff,
      aiSuggestionCtrl: _aiSuggestionCtrl,
      onToggleDiff: () => setState(() => _showOriginalDiff = !_showOriginalDiff),
      onDismiss: _dismissAi,
      onAppend: _acceptAppend,
      onReplace: _acceptReplace,
    );
  }

  InputDecoration _defaultInputDeco(String hintText, Color accent) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(fontSize: 13, color: Colors.grey[600]),
      filled: true,
      fillColor: Colors.grey[900],
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[800]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: accent),
      ),
    );
  }
}
