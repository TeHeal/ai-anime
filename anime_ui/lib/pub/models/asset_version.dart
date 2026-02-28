import 'package:freezed_annotation/freezed_annotation.dart';

part 'asset_version.freezed.dart';
part 'asset_version.g.dart';

@freezed
abstract class AssetVersion with _$AssetVersion {
  const AssetVersion._();

  const factory AssetVersion({
    int? id,
    int? projectId,
    @Default(0) int version,
    @Default('') String action,
    @Default('') String statsJson,
    @Default('') String deltaJson,
    @Default('') String note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _AssetVersion;

  factory AssetVersion.fromJson(Map<String, dynamic> json) =>
      _$AssetVersionFromJson(json);

  String get actionLabel => switch (action) {
        'freeze' => '冻结',
        'merge' => '合并',
        'rollback' => '回滚',
        'manual' => '手动',
        _ => action,
      };
}
