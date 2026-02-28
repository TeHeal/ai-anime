import 'package:freezed_annotation/freezed_annotation.dart';

part 'asset.freezed.dart';
part 'asset.g.dart';

@freezed
abstract class Asset with _$Asset {
  const Asset._();

  const factory Asset({
    String? id,
    String? projectId,
    @Default('scene') String type,
    @Default('') String name,
    @Default('') String desc,
    @Default('') String imageUrl,
    @Default('') String tags,
    @Default(false) bool shared,
  }) = _Asset;

  factory Asset.fromJson(Map<String, dynamic> json) => _$AssetFromJson(json);

  List<String> get tagList =>
      tags.isEmpty ? [] : tags.split(',').map((e) => e.trim()).toList();
}
