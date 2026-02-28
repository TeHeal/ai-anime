// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'prompt_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PromptRecord {

 String? get id; String get projectId; String get userId; String? get episodeId; String? get sceneId; String? get shotId; String? get characterId; String? get locationId; String get type; String get inputText; String get fullPrompt; String get negativePrompt; String get provider; String get model; String get paramsJson; String get createdBy; String get assetIds; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of PromptRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PromptRecordCopyWith<PromptRecord> get copyWith => _$PromptRecordCopyWithImpl<PromptRecord>(this as PromptRecord, _$identity);

  /// Serializes this PromptRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PromptRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.episodeId, episodeId) || other.episodeId == episodeId)&&(identical(other.sceneId, sceneId) || other.sceneId == sceneId)&&(identical(other.shotId, shotId) || other.shotId == shotId)&&(identical(other.characterId, characterId) || other.characterId == characterId)&&(identical(other.locationId, locationId) || other.locationId == locationId)&&(identical(other.type, type) || other.type == type)&&(identical(other.inputText, inputText) || other.inputText == inputText)&&(identical(other.fullPrompt, fullPrompt) || other.fullPrompt == fullPrompt)&&(identical(other.negativePrompt, negativePrompt) || other.negativePrompt == negativePrompt)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.model, model) || other.model == model)&&(identical(other.paramsJson, paramsJson) || other.paramsJson == paramsJson)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.assetIds, assetIds) || other.assetIds == assetIds)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,projectId,userId,episodeId,sceneId,shotId,characterId,locationId,type,inputText,fullPrompt,negativePrompt,provider,model,paramsJson,createdBy,assetIds,createdAt,updatedAt]);

@override
String toString() {
  return 'PromptRecord(id: $id, projectId: $projectId, userId: $userId, episodeId: $episodeId, sceneId: $sceneId, shotId: $shotId, characterId: $characterId, locationId: $locationId, type: $type, inputText: $inputText, fullPrompt: $fullPrompt, negativePrompt: $negativePrompt, provider: $provider, model: $model, paramsJson: $paramsJson, createdBy: $createdBy, assetIds: $assetIds, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $PromptRecordCopyWith<$Res>  {
  factory $PromptRecordCopyWith(PromptRecord value, $Res Function(PromptRecord) _then) = _$PromptRecordCopyWithImpl;
@useResult
$Res call({
 String? id, String projectId, String userId, String? episodeId, String? sceneId, String? shotId, String? characterId, String? locationId, String type, String inputText, String fullPrompt, String negativePrompt, String provider, String model, String paramsJson, String createdBy, String assetIds, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$PromptRecordCopyWithImpl<$Res>
    implements $PromptRecordCopyWith<$Res> {
  _$PromptRecordCopyWithImpl(this._self, this._then);

  final PromptRecord _self;
  final $Res Function(PromptRecord) _then;

/// Create a copy of PromptRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? projectId = null,Object? userId = null,Object? episodeId = freezed,Object? sceneId = freezed,Object? shotId = freezed,Object? characterId = freezed,Object? locationId = freezed,Object? type = null,Object? inputText = null,Object? fullPrompt = null,Object? negativePrompt = null,Object? provider = null,Object? model = null,Object? paramsJson = null,Object? createdBy = null,Object? assetIds = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,episodeId: freezed == episodeId ? _self.episodeId : episodeId // ignore: cast_nullable_to_non_nullable
as String?,sceneId: freezed == sceneId ? _self.sceneId : sceneId // ignore: cast_nullable_to_non_nullable
as String?,shotId: freezed == shotId ? _self.shotId : shotId // ignore: cast_nullable_to_non_nullable
as String?,characterId: freezed == characterId ? _self.characterId : characterId // ignore: cast_nullable_to_non_nullable
as String?,locationId: freezed == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,inputText: null == inputText ? _self.inputText : inputText // ignore: cast_nullable_to_non_nullable
as String,fullPrompt: null == fullPrompt ? _self.fullPrompt : fullPrompt // ignore: cast_nullable_to_non_nullable
as String,negativePrompt: null == negativePrompt ? _self.negativePrompt : negativePrompt // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,paramsJson: null == paramsJson ? _self.paramsJson : paramsJson // ignore: cast_nullable_to_non_nullable
as String,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,assetIds: null == assetIds ? _self.assetIds : assetIds // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [PromptRecord].
extension PromptRecordPatterns on PromptRecord {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PromptRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PromptRecord() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PromptRecord value)  $default,){
final _that = this;
switch (_that) {
case _PromptRecord():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PromptRecord value)?  $default,){
final _that = this;
switch (_that) {
case _PromptRecord() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String projectId,  String userId,  String? episodeId,  String? sceneId,  String? shotId,  String? characterId,  String? locationId,  String type,  String inputText,  String fullPrompt,  String negativePrompt,  String provider,  String model,  String paramsJson,  String createdBy,  String assetIds,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PromptRecord() when $default != null:
return $default(_that.id,_that.projectId,_that.userId,_that.episodeId,_that.sceneId,_that.shotId,_that.characterId,_that.locationId,_that.type,_that.inputText,_that.fullPrompt,_that.negativePrompt,_that.provider,_that.model,_that.paramsJson,_that.createdBy,_that.assetIds,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String projectId,  String userId,  String? episodeId,  String? sceneId,  String? shotId,  String? characterId,  String? locationId,  String type,  String inputText,  String fullPrompt,  String negativePrompt,  String provider,  String model,  String paramsJson,  String createdBy,  String assetIds,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _PromptRecord():
return $default(_that.id,_that.projectId,_that.userId,_that.episodeId,_that.sceneId,_that.shotId,_that.characterId,_that.locationId,_that.type,_that.inputText,_that.fullPrompt,_that.negativePrompt,_that.provider,_that.model,_that.paramsJson,_that.createdBy,_that.assetIds,_that.createdAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String projectId,  String userId,  String? episodeId,  String? sceneId,  String? shotId,  String? characterId,  String? locationId,  String type,  String inputText,  String fullPrompt,  String negativePrompt,  String provider,  String model,  String paramsJson,  String createdBy,  String assetIds,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _PromptRecord() when $default != null:
return $default(_that.id,_that.projectId,_that.userId,_that.episodeId,_that.sceneId,_that.shotId,_that.characterId,_that.locationId,_that.type,_that.inputText,_that.fullPrompt,_that.negativePrompt,_that.provider,_that.model,_that.paramsJson,_that.createdBy,_that.assetIds,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PromptRecord extends PromptRecord {
  const _PromptRecord({this.id, required this.projectId, required this.userId, this.episodeId, this.sceneId, this.shotId, this.characterId, this.locationId, this.type = '', this.inputText = '', this.fullPrompt = '', this.negativePrompt = '', this.provider = '', this.model = '', this.paramsJson = '', this.createdBy = 'ai', this.assetIds = '', this.createdAt, this.updatedAt}): super._();
  factory _PromptRecord.fromJson(Map<String, dynamic> json) => _$PromptRecordFromJson(json);

@override final  String? id;
@override final  String projectId;
@override final  String userId;
@override final  String? episodeId;
@override final  String? sceneId;
@override final  String? shotId;
@override final  String? characterId;
@override final  String? locationId;
@override@JsonKey() final  String type;
@override@JsonKey() final  String inputText;
@override@JsonKey() final  String fullPrompt;
@override@JsonKey() final  String negativePrompt;
@override@JsonKey() final  String provider;
@override@JsonKey() final  String model;
@override@JsonKey() final  String paramsJson;
@override@JsonKey() final  String createdBy;
@override@JsonKey() final  String assetIds;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of PromptRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PromptRecordCopyWith<_PromptRecord> get copyWith => __$PromptRecordCopyWithImpl<_PromptRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PromptRecordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PromptRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.episodeId, episodeId) || other.episodeId == episodeId)&&(identical(other.sceneId, sceneId) || other.sceneId == sceneId)&&(identical(other.shotId, shotId) || other.shotId == shotId)&&(identical(other.characterId, characterId) || other.characterId == characterId)&&(identical(other.locationId, locationId) || other.locationId == locationId)&&(identical(other.type, type) || other.type == type)&&(identical(other.inputText, inputText) || other.inputText == inputText)&&(identical(other.fullPrompt, fullPrompt) || other.fullPrompt == fullPrompt)&&(identical(other.negativePrompt, negativePrompt) || other.negativePrompt == negativePrompt)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.model, model) || other.model == model)&&(identical(other.paramsJson, paramsJson) || other.paramsJson == paramsJson)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.assetIds, assetIds) || other.assetIds == assetIds)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,projectId,userId,episodeId,sceneId,shotId,characterId,locationId,type,inputText,fullPrompt,negativePrompt,provider,model,paramsJson,createdBy,assetIds,createdAt,updatedAt]);

@override
String toString() {
  return 'PromptRecord(id: $id, projectId: $projectId, userId: $userId, episodeId: $episodeId, sceneId: $sceneId, shotId: $shotId, characterId: $characterId, locationId: $locationId, type: $type, inputText: $inputText, fullPrompt: $fullPrompt, negativePrompt: $negativePrompt, provider: $provider, model: $model, paramsJson: $paramsJson, createdBy: $createdBy, assetIds: $assetIds, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$PromptRecordCopyWith<$Res> implements $PromptRecordCopyWith<$Res> {
  factory _$PromptRecordCopyWith(_PromptRecord value, $Res Function(_PromptRecord) _then) = __$PromptRecordCopyWithImpl;
@override @useResult
$Res call({
 String? id, String projectId, String userId, String? episodeId, String? sceneId, String? shotId, String? characterId, String? locationId, String type, String inputText, String fullPrompt, String negativePrompt, String provider, String model, String paramsJson, String createdBy, String assetIds, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$PromptRecordCopyWithImpl<$Res>
    implements _$PromptRecordCopyWith<$Res> {
  __$PromptRecordCopyWithImpl(this._self, this._then);

  final _PromptRecord _self;
  final $Res Function(_PromptRecord) _then;

/// Create a copy of PromptRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? projectId = null,Object? userId = null,Object? episodeId = freezed,Object? sceneId = freezed,Object? shotId = freezed,Object? characterId = freezed,Object? locationId = freezed,Object? type = null,Object? inputText = null,Object? fullPrompt = null,Object? negativePrompt = null,Object? provider = null,Object? model = null,Object? paramsJson = null,Object? createdBy = null,Object? assetIds = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_PromptRecord(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,episodeId: freezed == episodeId ? _self.episodeId : episodeId // ignore: cast_nullable_to_non_nullable
as String?,sceneId: freezed == sceneId ? _self.sceneId : sceneId // ignore: cast_nullable_to_non_nullable
as String?,shotId: freezed == shotId ? _self.shotId : shotId // ignore: cast_nullable_to_non_nullable
as String?,characterId: freezed == characterId ? _self.characterId : characterId // ignore: cast_nullable_to_non_nullable
as String?,locationId: freezed == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,inputText: null == inputText ? _self.inputText : inputText // ignore: cast_nullable_to_non_nullable
as String,fullPrompt: null == fullPrompt ? _self.fullPrompt : fullPrompt // ignore: cast_nullable_to_non_nullable
as String,negativePrompt: null == negativePrompt ? _self.negativePrompt : negativePrompt // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,paramsJson: null == paramsJson ? _self.paramsJson : paramsJson // ignore: cast_nullable_to_non_nullable
as String,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,assetIds: null == assetIds ? _self.assetIds : assetIds // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
