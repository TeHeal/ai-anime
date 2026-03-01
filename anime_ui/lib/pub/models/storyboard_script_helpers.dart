part of 'storyboard_script.dart';

// ---------------------------------------------------------------------------
// JSON 解析辅助
// ---------------------------------------------------------------------------

List<String> _strList(dynamic v) =>
    (v as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];

List<int> _intList(dynamic v) =>
    (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? [];

List<double> _doubleList(dynamic v) =>
    (v as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList() ?? [];
