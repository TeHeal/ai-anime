/// JSON 中 id 字段解析工具
///
/// 后端使用 UUID 字符串，兼容历史数据可能返回的 int。
/// 用法：@JsonKey(fromJson: nullableIdFromJson) String? id
String? nullableIdFromJson(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toInt().toString();
  return v.toString();
}
