import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/services/ai_svc.dart';

class AiChatPanel extends ConsumerStatefulWidget {
  const AiChatPanel({super.key, this.onClose});
  final VoidCallback? onClose;

  @override
  ConsumerState<AiChatPanel> createState() => _AiChatPanelState();
}

class _AiChatPanelState extends ConsumerState<AiChatPanel> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <_ChatMsg>[];
  bool _loading = false;
  StreamSubscription<String>? _streamSub;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _streamSub?.cancel();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _loading) return;

    _controller.clear();
    setState(() {
      _messages.add(_ChatMsg(role: 'user', content: text));
      _messages.add(_ChatMsg(role: 'assistant', content: ''));
      _loading = true;
    });
    _scrollToBottom();

    final apiMessages = _messages
        .where((m) => m.content.isNotEmpty)
        .map((m) => {'role': m.role, 'content': m.content})
        .toList();

    try {
      final stream = AiService().chatStream(
        model: 'deepseek-chat',
        messages: apiMessages,
      );

      await for (final chunk in stream) {
        if (!mounted) return;
        setState(() {
          _messages.last = _ChatMsg(
            role: 'assistant',
            content: _messages.last.content + chunk,
          );
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.last = _ChatMsg(role: 'assistant', content: '出错了: $e');
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360.w,
      height: 480.h,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowOverlay.withValues(alpha: 0.4),
            blurRadius: 16.r,
            offset: Offset(0, -4.h),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildMessageList()),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.lg.w,
        vertical: Spacing.md.h,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Icon(AppIcons.autoAwesome, color: AppColors.primary, size: 20.r),
          SizedBox(width: Spacing.sm.w),
          Text(
            'AI 助手',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(AppIcons.close, color: AppColors.muted, size: 18.r),
            onPressed: widget.onClose,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(minWidth: 28.w, minHeight: 28.h),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              AppIcons.autoAwesome,
              size: 48.r,
              color: AppColors.surfaceMuted,
            ),
            SizedBox(height: Spacing.md.h),
            Text(
              '有什么可以帮助你的？',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.mutedDark,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(Spacing.md.r),
      itemCount: _messages.length,
      itemBuilder: (_, i) {
        final msg = _messages[i];
        final isUser = msg.role == 'user';
        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: EdgeInsets.only(bottom: Spacing.sm.h),
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.md.w,
              vertical: Spacing.sm.h,
            ),
            constraints: BoxConstraints(maxWidth: 280.w),
            decoration: BoxDecoration(
              color: isUser
                  ? AppColors.primary.withValues(alpha: 0.2)
                  : AppColors.surfaceMutedDarker,
              borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
            ),
            child: msg.content.isEmpty && _loading
                ? SizedBox(
                    width: Spacing.mid.w,
                    height: Spacing.mid.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.r,
                      color: AppColors.muted,
                    ),
                  )
                : SelectableText(
                    msg.content,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSurface,
                      height: 1.5,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildInput() {
    return Container(
      padding: EdgeInsets.all(Spacing.md.r),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              onSubmitted: (_) => _send(),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurface,
              ),
              decoration: InputDecoration(
                hintText: '输入消息...',
                hintStyle: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.mutedDark,
                ),
                filled: true,
                fillColor: AppColors.surfaceMutedDarker,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(RadiusTokens.md.r),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: Spacing.md.w,
                  vertical: Spacing.lg.h,
                ),
              ),
            ),
          ),
          SizedBox(width: Spacing.sm.w),
          IconButton(
            icon: Icon(
              AppIcons.send,
              color: _loading ? AppColors.mutedDarker : AppColors.primary,
            ),
            onPressed: _loading ? null : _send,
          ),
        ],
      ),
    );
  }
}

class _ChatMsg {
  _ChatMsg({required this.role, required this.content});
  final String role;
  final String content;
}
