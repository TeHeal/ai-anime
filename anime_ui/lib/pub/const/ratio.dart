/// 画面比例
enum VideoRatio {
  r1x1('1:1'),
  r3x4('3:4'),
  r4x3('4:3'),
  r9x16('9:16'),
  r16x9('16:9');

  const VideoRatio(this.label);
  final String label;
}
