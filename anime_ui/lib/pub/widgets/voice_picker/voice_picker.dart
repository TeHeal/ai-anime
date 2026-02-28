import 'package:flutter/material.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/models/resource.dart';
import 'package:anime_ui/pub/services/audio_playback_svc.dart';

/// Unified voice picker dialog used across config page, edit page, etc.
///
/// Usage:
/// ```dart
/// final selected = await VoicePicker.show(context, voices: voiceResources);
/// ```
class VoicePicker extends StatefulWidget {
  const VoicePicker({
    super.key,
    required this.voices,
    required this.accentColor,
    this.selectedId,
    this.onSelected,
  });

  final List<Resource> voices;
  final Color accentColor;
  final String? selectedId;
  final ValueChanged<Resource>? onSelected;

  static Future<Resource?> show(
    BuildContext context, {
    required List<Resource> voices,
    Color accentColor = const Color(0xFF3B82F6),
    String? selectedId,
  }) {
    return showDialog<Resource>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480, maxHeight: 560),
          child: VoicePicker(
            voices: voices,
            accentColor: accentColor,
            selectedId: selectedId,
            onSelected: (v) => Navigator.pop(context, v),
          ),
        ),
      ),
    );
  }

  @override
  State<VoicePicker> createState() => _VoicePickerState();
}

class _VoicePickerState extends State<VoicePicker> {
  String _search = '';
  String _genderFilter = '';

  Color get accent => widget.accentColor;

  List<Resource> get _filtered {
    var list = widget.voices;
    if (_genderFilter.isNotEmpty) {
      list = list.where((v) {
        final gender = v.metadata['gender'] as String? ?? '';
        return gender == _genderFilter;
      }).toList();
    }
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      list = list.where((v) =>
          v.name.toLowerCase().contains(q) ||
          v.tags.any((t) => t.toLowerCase().contains(q))).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(),
        _buildFilters(),
        Flexible(
          child: items.isEmpty
              ? _buildEmpty()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  itemCount: items.length,
                  itemBuilder: (_, i) => _VoicePickerItem(
                    voice: items[i],
                    accent: accent,
                    isSelected: items[i].id == widget.selectedId,
                    onTap: () => widget.onSelected?.call(items[i]),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
      child: Row(
        children: [
          Icon(AppIcons.mic, size: 18, color: accent),
          const SizedBox(width: 8),
          const Text(
            '选择音色',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(AppIcons.close, size: 16, color: Colors.grey[500]),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        children: [
          SizedBox(
            height: 36,
            child: TextField(
              style: const TextStyle(fontSize: 13, color: Colors.white),
              decoration: InputDecoration(
                hintText: '搜索音色…',
                hintStyle: TextStyle(fontSize: 13, color: Colors.grey[600]),
                prefixIcon: Icon(AppIcons.search, size: 16, color: Colors.grey[500]),
                filled: true,
                fillColor: Colors.grey[900],
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[800]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: accent),
                ),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _filterChip('全部', ''),
              const SizedBox(width: 6),
              _filterChip('男声', 'male'),
              const SizedBox(width: 6),
              _filterChip('女声', 'female'),
              const SizedBox(width: 6),
              _filterChip('中性', 'neutral'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    final selected = _genderFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _genderFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0.15) : Colors.grey[900],
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected ? accent.withValues(alpha: 0.4) : Colors.grey[800]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: selected ? accent : Colors.grey[400],
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.mic, size: 32, color: Colors.grey[700]),
          const SizedBox(height: 10),
          Text('暂无可用音色', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
        ],
      ),
    );
  }
}

class _VoicePickerItem extends StatelessWidget {
  const _VoicePickerItem({
    required this.voice,
    required this.accent,
    required this.isSelected,
    required this.onTap,
  });

  final Resource voice;
  final Color accent;
  final bool isSelected;
  final VoidCallback onTap;

  String? get _audioUrl {
    final url = voice.metadata['audio_url'] as String?;
    if (url != null && url.isNotEmpty) return url;
    if (voice.thumbnailUrl.isNotEmpty &&
        (voice.thumbnailUrl.endsWith('.mp3') ||
            voice.thumbnailUrl.endsWith('.wav'))) {
      return voice.thumbnailUrl;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final meta = voice.metadata;
    final gender = meta['gender'] as String? ?? '';
    final model = meta['model'] as String? ?? '';
    final hasAudio = _audioUrl != null;
    final playback = AudioPlaybackService.instance;

    return ListenableBuilder(
      listenable: playback,
      builder: (_, _) {
        final isPlaying = hasAudio && playback.isPlayingUrl(_audioUrl!);

        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? accent.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: isSelected
                      ? Border.all(color: accent.withValues(alpha: 0.3))
                      : null,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: hasAudio
                          ? () => playback.play(_audioUrl!)
                          : null,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: hasAudio
                              ? accent.withValues(alpha: isPlaying ? 0.25 : 0.1)
                              : Colors.grey[850],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isPlaying
                              ? Icons.stop_rounded
                              : Icons.play_arrow_rounded,
                          size: 18,
                          color: hasAudio ? accent : Colors.grey[600],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            voice.name,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? accent : Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (voice.description.isNotEmpty)
                            Text(
                              voice.description,
                              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    if (gender.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Icon(
                          gender == 'female' || gender == '女'
                              ? Icons.female_rounded
                              : Icons.male_rounded,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    if (model.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            model,
                            style: TextStyle(
                                fontSize: 10,
                                color: accent.withValues(alpha: 0.7)),
                          ),
                        ),
                      ),
                    if (isSelected)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Icon(AppIcons.check, size: 16, color: accent),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
