import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/module/assets/resources/providers/provider.dart';
import 'package:anime_ui/pub/models/model_catalog.dart';
import 'package:anime_ui/pub/services/model_catalog_svc.dart';
import '../model_selector/model_selector.dart';
import 'text_gen_config.dart';
import 'text_gen_controller.dart';

class TextGenView extends StatefulWidget {
  const TextGenView({
    super.key,
    required this.config,
    required this.ref,
    this.onClose,
  });

  final TextGenConfig config;
  final WidgetRef ref;
  final VoidCallback? onClose;

  @override
  State<TextGenView> createState() => _TextGenViewState();
}

class _TextGenViewState extends State<TextGenView> {
  late final TextGenController _ctrl;
  late final TextEditingController _instructionCtrl;
  late final TextEditingController _nameCtrl;
  String _selectedLanguage = '';
  ModelCatalogItem? _selectedTargetModel;
  List<ModelCatalogItem> _imageModels = [];
  bool _loadingModels = false;

  TextGenConfig get config => widget.config;
  Color get accent => config.accentColor;

  @override
  void initState() {
    super.initState();
    _ctrl = TextGenController();
    _instructionCtrl = TextEditingController();
    _nameCtrl = TextEditingController();
    _selectedLanguage = config.language;
    _loadTargetModels();
  }

  Future<void> _loadTargetModels() async {
    setState(() => _loadingModels = true);
    try {
      _imageModels = await ModelCatalogService().list(service: 'image');
    } catch (e, st) {
      debugPrint('TextGenView._loadTargetModels: $e');
      debugPrint(st.toString());
    }
    if (mounted) setState(() => _loadingModels = false);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _instructionCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final instruction = _instructionCtrl.text.trim();
    if (instruction.isEmpty) return;

    final effectiveConfig = TextGenConfig(
      title: config.title,
      accentColor: config.accentColor,
      mode: config.mode,
      onComplete: config.onComplete,
      instructionHint: config.instructionHint,
      referenceText: config.referenceText,
      targetModel: _selectedTargetModel?.displayName ?? '',
      language: _selectedLanguage,
      maxTokens: config.maxTokens,
      quickPrompts: config.quickPrompts,
      saveToLibrary: config.saveToLibrary,
      libraryType: config.libraryType,
    );

    await _ctrl.generate(
      instruction: instruction,
      config: effectiveConfig,
      name: _nameCtrl.text.trim(),
    );
  }

  Future<void> _useResult() async {
    if (_ctrl.result.isEmpty) return;
    await config.onComplete(_ctrl.result);
    if (mounted) widget.onClose?.call();
  }

  Future<void> _saveAndUse() async {
    if (_ctrl.result.isEmpty) return;

    if (_ctrl.savedResource == null && config.saveToLibrary) {
      final notifier = widget.ref.read(resourceListProvider.notifier);
      await notifier.generatePrompt(
        name: _nameCtrl.text.trim().isNotEmpty
            ? _nameCtrl.text.trim()
            : '${config.mode.label}-${DateTime.now().millisecondsSinceEpoch}',
        instruction: _instructionCtrl.text.trim(),
        targetModel: _selectedTargetModel?.displayName ?? '',
        category: config.mode.name,
      );
    }

    await config.onComplete(_ctrl.result);
    if (mounted) widget.onClose?.call();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _ctrl,
      builder: (_, _) {
        return Dialog(
          backgroundColor: const Color(0xFF1A1A2E),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 780,
              maxHeight: 640,
              minWidth: 520,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                Flexible(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 340, child: _buildInputPanel()),
                      Container(width: 1, color: Colors.grey[850]),
                      Expanded(child: _buildResultPanel()),
                    ],
                  ),
                ),
                _buildFooter(),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Header ──────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 18, 16, 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[850]!)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(AppIcons.magicStick, size: 18, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  config.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  config.mode.label,
                  style: TextStyle(fontSize: 11, color: accent),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(AppIcons.close, size: 18, color: Colors.grey[500]),
            onPressed: widget.onClose,
          ),
        ],
      ),
    );
  }

  // ─── 左侧输入面板 ──────────────────────────────────────

  Widget _buildInputPanel() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (config.saveToLibrary) ...[
            _label('名称'),
            const SizedBox(height: 6),
            SizedBox(
              height: 38,
              child: TextField(
                controller: _nameCtrl,
                style: const TextStyle(fontSize: 13, color: Colors.white),
                decoration: _inputDeco('为该文本命名（可选）'),
              ),
            ),
            const SizedBox(height: 14),
          ],

          if (config.mode == TextGenMode.optimize &&
              config.referenceText.isNotEmpty) ...[
            _label('原始文本'),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[800]!),
              ),
              child: Text(
                config.referenceText,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[400],
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 14),
          ],

          _label('指令'),
          const SizedBox(height: 6),
          TextField(
            controller: _instructionCtrl,
            style: const TextStyle(fontSize: 13, color: Colors.white),
            maxLines: 5,
            decoration: _inputDeco(config.instructionHint),
          ),

          if (config.quickPrompts.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: config.quickPrompts.map((p) {
                return GestureDetector(
                  onTap: () {
                    final cur = _instructionCtrl.text;
                    _instructionCtrl.text =
                        cur.isEmpty ? p : '$cur，$p';
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: accent.withValues(alpha: 0.2)),
                    ),
                    child: Text(p,
                        style: TextStyle(fontSize: 11, color: accent)),
                  ),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 16),
          _buildOptions(),
        ],
      ),
    );
  }

  Widget _buildOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('选项'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildLanguageDropdown(),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ModelSelectorMini(
                models: _imageModels,
                selected: _selectedTargetModel,
                isLoading: _loadingModels,
                onChanged: (m) => setState(() => _selectedTargetModel = m),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLanguageDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('语言',
            style: TextStyle(fontSize: 11, color: Colors.grey[500])),
        const SizedBox(height: 4),
        Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[800]!),
          ),
          child: DropdownButton<String>(
            value: _selectedLanguage,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            dropdownColor: Colors.grey[900],
            style: const TextStyle(fontSize: 12, color: Colors.white),
            items: const ['', '中文', 'English', '中英混合']
                .map((v) => DropdownMenuItem(
                      value: v,
                      child: Text(v.isEmpty ? '自动' : v),
                    ))
                .toList(),
            onChanged: (v) {
              if (v != null) setState(() => _selectedLanguage = v);
            },
          ),
        ),
      ],
    );
  }

  // ─── 右侧结果面板 ──────────────────────────────────────

  Widget _buildResultPanel() {
    return Container(
      color: const Color(0xFF0F0F0F),
      child: switch (_ctrl.status) {
        TextGenStatus.idle => _buildIdlePlaceholder(),
        TextGenStatus.generating => _buildGenerating(),
        TextGenStatus.done => _buildResult(),
        TextGenStatus.error => _buildError(),
      },
    );
  }

  Widget _buildIdlePlaceholder() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.06),
              shape: BoxShape.circle,
            ),
            child: Icon(AppIcons.document,
                size: 36, color: accent.withValues(alpha: 0.3)),
          ),
          const SizedBox(height: 16),
          Text('输入指令开始生成',
              style: TextStyle(fontSize: 14, color: Colors.grey[500])),
          const SizedBox(height: 6),
          Text('AI 将根据你的描述生成文字内容',
              style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildGenerating() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
                strokeWidth: 3, color: accent),
          ),
          const SizedBox(height: 16),
          Text('正在生成…',
              style: TextStyle(fontSize: 14, color: accent)),
          const SizedBox(height: 6),
          Text('AI 正在创作中，请稍候',
              style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildResult() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Row(
            children: [
              Icon(AppIcons.checkOutline, size: 14, color: accent),
              const SizedBox(width: 6),
              Text('生成结果',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: accent)),
              const Spacer(),
              _TinyAction(
                icon: Icons.copy_rounded,
                label: '复制',
                color: accent,
                onTap: () {
                  Clipboard.setData(ClipboardData(text: _ctrl.result));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('已复制到剪贴板'),
                      backgroundColor: Colors.grey[800],
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              _TinyAction(
                icon: AppIcons.magicStick,
                label: '重新生成',
                color: Colors.grey[400]!,
                onTap: _generate,
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: accent.withValues(alpha: 0.15)),
              ),
              child: SelectableText(
                _ctrl.result,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                  height: 1.7,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.error, size: 32, color: Colors.red[400]),
          const SizedBox(height: 12),
          Text('生成失败',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.red[400])),
          if (_ctrl.errorMsg.isNotEmpty) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _ctrl.errorMsg,
                style: TextStyle(fontSize: 12, color: Colors.red[300]),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: _generate,
            icon: Icon(AppIcons.magicStick, size: 14, color: accent),
            label: Text('重试', style: TextStyle(color: accent)),
          ),
        ],
      ),
    );
  }

  // ─── Footer ──────────────────────────────────────────

  Widget _buildFooter() {
    final hasResult =
        _ctrl.status == TextGenStatus.done && _ctrl.result.isNotEmpty;
    final isGenerating = _ctrl.status == TextGenStatus.generating;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[850]!)),
      ),
      child: Row(
        children: [
          if (hasResult && config.saveToLibrary)
            Text(
              _ctrl.savedResource != null ? '已保存到素材库' : '',
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          const Spacer(),
          TextButton(
            onPressed: isGenerating ? null : widget.onClose,
            child: Text('取消',
                style: TextStyle(color: Colors.grey[400])),
          ),
          const SizedBox(width: 8),
          if (!hasResult)
            FilledButton.icon(
              onPressed:
                  isGenerating ? null : _generate,
              icon: isGenerating
                  ? SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Icon(AppIcons.magicStick, size: 14),
              label: Text(isGenerating ? '生成中…' : '生成'),
              style: FilledButton.styleFrom(backgroundColor: accent),
            )
          else ...[
            if (config.saveToLibrary && _ctrl.savedResource == null)
              OutlinedButton(
                onPressed: _saveAndUse,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: accent.withValues(alpha: 0.4)),
                ),
                child: Text('保存并使用',
                    style: TextStyle(color: accent, fontSize: 13)),
              ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: _useResult,
              style: FilledButton.styleFrom(backgroundColor: accent),
              child: const Text('使用结果'),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Helpers ─────────────────────────────────────────

  Widget _label(String text) {
    return Text(text,
        style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[400]));
  }

  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 13, color: Colors.grey[600]),
      filled: true,
      fillColor: Colors.grey[900],
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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

// ─── 小组件 ─────────────────────────────────────────────

class _TinyAction extends StatelessWidget {
  const _TinyAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 12, color: color),
      label: Text(label, style: TextStyle(fontSize: 11, color: color)),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
