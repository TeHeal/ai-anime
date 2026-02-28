import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/theme/colors.dart';
import 'package:anime_ui/pub/ai/services/ai_svc.dart';

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
          _messages.last = _ChatMsg(
            role: 'assistant',
            content: '出错了: $e',
          );
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      height: 480,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, -4)),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[800]!)),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          const Text('AI 助手', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
          const Spacer(),
          IconButton(
            icon: Icon(Icons.close, color: Colors.grey[400], size: 18),
            onPressed: widget.onClose,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
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
            Icon(Icons.auto_awesome, size: 48, color: Colors.grey[700]),
            const SizedBox(height: 12),
            Text('有什么可以帮助你的？', style: TextStyle(color: Colors.grey[500], fontSize: 14)),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      itemCount: _messages.length,
      itemBuilder: (_, i) {
        final msg = _messages[i];
        final isUser = msg.role == 'user';
        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            constraints: const BoxConstraints(maxWidth: 280),
            decoration: BoxDecoration(
              color: isUser ? AppColors.primary.withValues(alpha: 0.2) : Colors.grey[850],
              borderRadius: BorderRadius.circular(10),
            ),
            child: msg.content.isEmpty && _loading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.grey[400]),
                  )
                : SelectableText(
                    msg.content,
                    style: TextStyle(color: Colors.grey[200], fontSize: 13, height: 1.5),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[800]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              onSubmitted: (_) => _send(),
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: '输入消息...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                filled: true,
                fillColor: Colors.grey[850],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[700]!),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.send, color: _loading ? Colors.grey[600] : AppColors.primary),
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
