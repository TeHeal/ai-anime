import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// 情绪向量常量 (IndexTTS2 8-dim emotion vector)
// ---------------------------------------------------------------------------

const emotionLabels = ['开心', '愤怒', '悲伤', '恐惧', '厌恶', '忧郁', '惊讶', '平静'];

const emotionColors = [
  Color(0xFFFBBF24), // 开心 - amber
  Color(0xFFEF4444), // 愤怒 - red
  Color(0xFF60A5FA), // 悲伤 - blue
  Color(0xFFA78BFA), // 恐惧 - purple
  Color(0xFF34D399), // 厌恶 - green
  Color(0xFF94A3B8), // 忧郁 - slate
  Color(0xFFF472B6), // 惊讶 - pink
  Color(0xFF67E8F9), // 平静 - cyan
];

const emotionIcons = ['😊', '😡', '😢', '😨', '🤢', '😔', '😮', '😌'];

// ---------------------------------------------------------------------------
// 情绪向量组件 (IndexTTS2 8-dim)
// ---------------------------------------------------------------------------

class EmotionVectorWidget extends StatelessWidget {
  final List<double> vector;
  final bool editing;
  final ValueChanged<List<double>> onChanged;

  const EmotionVectorWidget({
    super.key,
    required this.vector,
    required this.editing,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final dims = vector.length.clamp(0, 8);
    if (dims == 0 && !editing) {
      return Text('无数据',
          style: TextStyle(color: Colors.grey[600], fontSize: 13));
    }

    final effectiveVec =
        dims >= 8 ? vector : List.generate(8, (i) => i < dims ? vector[i] : 0.0);

    return Column(
      children: List.generate(8, (i) {
        final val = effectiveVec[i].clamp(0.0, 1.2);
        final normalized = val / 1.2;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                child: Text(emotionIcons[i],
                    style: const TextStyle(fontSize: 14)),
              ),
              SizedBox(
                width: 40,
                child: Text(
                  emotionLabels[i],
                  style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                ),
              ),
              Expanded(
                child: editing
                    ? SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 6,
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6),
                          activeTrackColor: emotionColors[i],
                          inactiveTrackColor: const Color(0xFF252535),
                          thumbColor: emotionColors[i],
                          overlayColor:
                              emotionColors[i].withValues(alpha: 0.2),
                        ),
                        child: Slider(
                          value: val,
                          min: 0,
                          max: 1.2,
                          onChanged: (v) {
                            final newVec = List<double>.from(effectiveVec);
                            newVec[i] = double.parse(v.toStringAsFixed(2));
                            onChanged(newVec);
                          },
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: SizedBox(
                          height: 8,
                          child: LinearProgressIndicator(
                            value: normalized,
                            backgroundColor: const Color(0xFF252535),
                            color: emotionColors[i],
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 32,
                child: Text(
                  val.toStringAsFixed(2),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[400],
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
