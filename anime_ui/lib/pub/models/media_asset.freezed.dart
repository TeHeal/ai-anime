// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'media_asset.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MediaAsset {

 int? get id; int get projectId; int get userId; int? get episodeId; int? get sceneId; int? get shotId; int? get characterId; int? get locationId; String get type; String get subType; String get name; String get fileUrl; String get filePath; int get fileSize; String get fileHash; String get mimeType; int get width; int get height; double get duration; String get source; int? get promptId; String get taskId; String get provider; String get model; int get version; int? get parentId; String get status; String get roleIds; String get tags; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of MediaAsset
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MediaAssetCopyWith<MediaAsset> get copyWith => _$MediaAssetCopyWithImpl<MediaAsset>(this as MediaAsset, _$identity);

  /// Serializes this MediaAsset to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MediaAsset&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.episodeId, episodeId) || other.episodeId == episodeId)&&(identical(other.sceneId, sceneId) || other.sceneId == sceneId)&&(identical(other.shotId, shotId) || other.shotId == shotId)&&(identical(other.characterId, characterId) || other.characterId == characterId)&&(identical(other.locationId, locationId) || other.locationId == locationId)&&(identical(other.type, type) || other.type == type)&&(identical(other.subType, subType) || other.subType == subType)&&(identical(other.name, name) || other.name == name)&&(identical(other.fileUrl, fileUrl) || other.fileUrl == fileUrl)&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.fileSize, fileSize) || other.fileSize == fileSize)&&(identical(other.fileHash, fileHash) || other.fileHash == fileHash)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.source, source) || other.source == source)&&(identical(other.promptId, promptId) || other.promptId == promptId)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.model, model) || other.model == model)&&(identical(other.version, version) || other.version == version)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.status, status) || other.status == status)&&(identical(other.roleIds, roleIds) || other.roleIds == roleIds)&&(identical(other.tags, tags) || other.tags == tags)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,projectId,userId,episodeId,sceneId,shotId,characterId,locationId,type,subType,name,fileUrl,filePath,fileSize,fileHash,mimeType,width,height,duration,source,promptId,taskId,provider,model,version,parentId,status,roleIds,tags,createdAt,updatedAt]);

@override
String toString() {
  return 'MediaAsset(id: $id, projectId: $projectId, userId: $userId, episodeId: $episodeId, sceneId: $sceneId, shotId: $shotId, characterId: $characterId, locationId: $locationId, type: $type, subType: $subType, name: $name, fileUrl: $fileUrl, filePath: $filePath, fileSize: $fileSize, fileHash: $fileHash, mimeType: $mimeType, width: $width, height: $height, duration: $duration, source: $source, promptId: $promptId, taskId: $taskId, provider: $provider, model: $model, version: $version, parentId: $parentId, status: $status, roleIds: $roleIds, tags: $tags, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $MediaAssetCopyWith<$Res>  {
  factory $MediaAssetCopyWith(MediaAsset value, $Res Function(MediaAsset) _then) = _$MediaAssetCopyWithImpl;
@useResult
$Res call({
 int? id, int projectId, int userId, int? episodeId, int? sceneId, int? shotId, int? characterId, int? locationId, String type, String subType, String name, String fileUrl, String filePath, int fileSize, String fileHash, String mimeType, int width, int height, double duration, String source, int? promptId, String taskId, String provider, String model, int version, int? parentId, String status, String roleIds, String tags, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$MediaAssetCopyWithImpl<$Res>
    implements $MediaAssetCopyWith<$Res> {
  _$MediaAssetCopyWithImpl(this._self, this._then);

  final MediaAsset _self;
  final $Res Function(MediaAsset) _then;

/// Create a copy of MediaAsset
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? projectId = null,Object? userId = null,Object? episodeId = freezed,Object? sceneId = freezed,Object? shotId = freezed,Object? characterId = freezed,Object? locationId = freezed,Object? type = null,Object? subType = null,Object? name = null,Object? fileUrl = null,Object? filePath = null,Object? fileSize = null,Object? fileHash = null,Object? mimeType = null,Object? width = null,Object? height = null,Object? duration = null,Object? source = null,Object? promptId = freezed,Object? taskId = null,Object? provider = null,Object? model = null,Object? version = null,Object? parentId = freezed,Object? status = null,Object? roleIds = null,Object? tags = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as int,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int,episodeId: freezed == episodeId ? _self.episodeId : episodeId // ignore: cast_nullable_to_non_nullable
as int?,sceneId: freezed == sceneId ? _self.sceneId : sceneId // ignore: cast_nullable_to_non_nullable
as int?,shotId: freezed == shotId ? _self.shotId : shotId // ignore: cast_nullable_to_non_nullable
as int?,characterId: freezed == characterId ? _self.characterId : characterId // ignore: cast_nullable_to_non_nullable
as int?,locationId: freezed == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as int?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,subType: null == subType ? _self.subType : subType // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,fileUrl: null == fileUrl ? _self.fileUrl : fileUrl // ignore: cast_nullable_to_non_nullable
as String,filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,fileSize: null == fileSize ? _self.fileSize : fileSize // ignore: cast_nullable_to_non_nullable
as int,fileHash: null == fileHash ? _self.fileHash : fileHash // ignore: cast_nullable_to_non_nullable
as String,mimeType: null == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as double,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,promptId: freezed == promptId ? _self.promptId : promptId // ignore: cast_nullable_to_non_nullable
as int?,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,roleIds: null == roleIds ? _self.roleIds : roleIds // ignore: cast_nullable_to_non_nullable
as String,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [MediaAsset].
extension MediaAssetPatterns on MediaAsset {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MediaAsset value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MediaAsset() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MediaAsset value)  $default,){
final _that = this;
switch (_that) {
case _MediaAsset():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MediaAsset value)?  $default,){
final _that = this;
switch (_that) {
case _MediaAsset() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  int projectId,  int userId,  int? episodeId,  int? sceneId,  int? shotId,  int? characterId,  int? locationId,  String type,  String subType,  String name,  String fileUrl,  String filePath,  int fileSize,  String fileHash,  String mimeType,  int width,  int height,  double duration,  String source,  int? promptId,  String taskId,  String provider,  String model,  int version,  int? parentId,  String status,  String roleIds,  String tags,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MediaAsset() when $default != null:
return $default(_that.id,_that.projectId,_that.userId,_that.episodeId,_that.sceneId,_that.shotId,_that.characterId,_that.locationId,_that.type,_that.subType,_that.name,_that.fileUrl,_that.filePath,_that.fileSize,_that.fileHash,_that.mimeType,_that.width,_that.height,_that.duration,_that.source,_that.promptId,_that.taskId,_that.provider,_that.model,_that.version,_that.parentId,_that.status,_that.roleIds,_that.tags,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  int projectId,  int userId,  int? episodeId,  int? sceneId,  int? shotId,  int? characterId,  int? locationId,  String type,  String subType,  String name,  String fileUrl,  String filePath,  int fileSize,  String fileHash,  String mimeType,  int width,  int height,  double duration,  String source,  int? promptId,  String taskId,  String provider,  String model,  int version,  int? parentId,  String status,  String roleIds,  String tags,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _MediaAsset():
return $default(_that.id,_that.projectId,_that.userId,_that.episodeId,_that.sceneId,_that.shotId,_that.characterId,_that.locationId,_that.type,_that.subType,_that.name,_that.fileUrl,_that.filePath,_that.fileSize,_that.fileHash,_that.mimeType,_that.width,_that.height,_that.duration,_that.source,_that.promptId,_that.taskId,_that.provider,_that.model,_that.version,_that.parentId,_that.status,_that.roleIds,_that.tags,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  int projectId,  int userId,  int? episodeId,  int? sceneId,  int? shotId,  int? characterId,  int? locationId,  String type,  String subType,  String name,  String fileUrl,  String filePath,  int fileSize,  String fileHash,  String mimeType,  int width,  int height,  double duration,  String source,  int? promptId,  String taskId,  String provider,  String model,  int version,  int? parentId,  String status,  String roleIds,  String tags,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _MediaAsset() when $default != null:
return $default(_that.id,_that.projectId,_that.userId,_that.episodeId,_that.sceneId,_that.shotId,_that.characterId,_that.locationId,_that.type,_that.subType,_that.name,_that.fileUrl,_that.filePath,_that.fileSize,_that.fileHash,_that.mimeType,_that.width,_that.height,_that.duration,_that.source,_that.promptId,_that.taskId,_that.provider,_that.model,_that.version,_that.parentId,_that.status,_that.roleIds,_that.tags,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MediaAsset extends MediaAsset {
  const _MediaAsset({this.id, required this.projectId, required this.userId, this.episodeId, this.sceneId, this.shotId, this.characterId, this.locationId, this.type = '', this.subType = '', this.name = '', this.fileUrl = '', this.filePath = '', this.fileSize = 0, this.fileHash = '', this.mimeType = '', this.width = 0, this.height = 0, this.duration = 0.0, this.source = 'ai', this.promptId, this.taskId = '', this.provider = '', this.model = '', this.version = 1, this.parentId, this.status = 'active', this.roleIds = '', this.tags = '', this.createdAt, this.updatedAt}): super._();
  factory _MediaAsset.fromJson(Map<String, dynamic> json) => _$MediaAssetFromJson(json);

@override final  int? id;
@override final  int projectId;
@override final  int userId;
@override final  int? episodeId;
@override final  int? sceneId;
@override final  int? shotId;
@override final  int? characterId;
@override final  int? locationId;
@override@JsonKey() final  String type;
@override@JsonKey() final  String subType;
@override@JsonKey() final  String name;
@override@JsonKey() final  String fileUrl;
@override@JsonKey() final  String filePath;
@override@JsonKey() final  int fileSize;
@override@JsonKey() final  String fileHash;
@override@JsonKey() final  String mimeType;
@override@JsonKey() final  int width;
@override@JsonKey() final  int height;
@override@JsonKey() final  double duration;
@override@JsonKey() final  String source;
@override final  int? promptId;
@override@JsonKey() final  String taskId;
@override@JsonKey() final  String provider;
@override@JsonKey() final  String model;
@override@JsonKey() final  int version;
@override final  int? parentId;
@override@JsonKey() final  String status;
@override@JsonKey() final  String roleIds;
@override@JsonKey() final  String tags;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of MediaAsset
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MediaAssetCopyWith<_MediaAsset> get copyWith => __$MediaAssetCopyWithImpl<_MediaAsset>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MediaAssetToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MediaAsset&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.episodeId, episodeId) || other.episodeId == episodeId)&&(identical(other.sceneId, sceneId) || other.sceneId == sceneId)&&(identical(other.shotId, shotId) || other.shotId == shotId)&&(identical(other.characterId, characterId) || other.characterId == characterId)&&(identical(other.locationId, locationId) || other.locationId == locationId)&&(identical(other.type, type) || other.type == type)&&(identical(other.subType, subType) || other.subType == subType)&&(identical(other.name, name) || other.name == name)&&(identical(other.fileUrl, fileUrl) || other.fileUrl == fileUrl)&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.fileSize, fileSize) || other.fileSize == fileSize)&&(identical(other.fileHash, fileHash) || other.fileHash == fileHash)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.source, source) || other.source == source)&&(identical(other.promptId, promptId) || other.promptId == promptId)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.model, model) || other.model == model)&&(identical(other.version, version) || other.version == version)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.status, status) || other.status == status)&&(identical(other.roleIds, roleIds) || other.roleIds == roleIds)&&(identical(other.tags, tags) || other.tags == tags)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,projectId,userId,episodeId,sceneId,shotId,characterId,locationId,type,subType,name,fileUrl,filePath,fileSize,fileHash,mimeType,width,height,duration,source,promptId,taskId,provider,model,version,parentId,status,roleIds,tags,createdAt,updatedAt]);

@override
String toString() {
  return 'MediaAsset(id: $id, projectId: $projectId, userId: $userId, episodeId: $episodeId, sceneId: $sceneId, shotId: $shotId, characterId: $characterId, locationId: $locationId, type: $type, subType: $subType, name: $name, fileUrl: $fileUrl, filePath: $filePath, fileSize: $fileSize, fileHash: $fileHash, mimeType: $mimeType, width: $width, height: $height, duration: $duration, source: $source, promptId: $promptId, taskId: $taskId, provider: $provider, model: $model, version: $version, parentId: $parentId, status: $status, roleIds: $roleIds, tags: $tags, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$MediaAssetCopyWith<$Res> implements $MediaAssetCopyWith<$Res> {
  factory _$MediaAssetCopyWith(_MediaAsset value, $Res Function(_MediaAsset) _then) = __$MediaAssetCopyWithImpl;
@override @useResult
$Res call({
 int? id, int projectId, int userId, int? episodeId, int? sceneId, int? shotId, int? characterId, int? locationId, String type, String subType, String name, String fileUrl, String filePath, int fileSize, String fileHash, String mimeType, int width, int height, double duration, String source, int? promptId, String taskId, String provider, String model, int version, int? parentId, String status, String roleIds, String tags, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$MediaAssetCopyWithImpl<$Res>
    implements _$MediaAssetCopyWith<$Res> {
  __$MediaAssetCopyWithImpl(this._self, this._then);

  final _MediaAsset _self;
  final $Res Function(_MediaAsset) _then;

/// Create a copy of MediaAsset
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? projectId = null,Object? userId = null,Object? episodeId = freezed,Object? sceneId = freezed,Object? shotId = freezed,Object? characterId = freezed,Object? locationId = freezed,Object? type = null,Object? subType = null,Object? name = null,Object? fileUrl = null,Object? filePath = null,Object? fileSize = null,Object? fileHash = null,Object? mimeType = null,Object? width = null,Object? height = null,Object? duration = null,Object? source = null,Object? promptId = freezed,Object? taskId = null,Object? provider = null,Object? model = null,Object? version = null,Object? parentId = freezed,Object? status = null,Object? roleIds = null,Object? tags = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_MediaAsset(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as int,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int,episodeId: freezed == episodeId ? _self.episodeId : episodeId // ignore: cast_nullable_to_non_nullable
as int?,sceneId: freezed == sceneId ? _self.sceneId : sceneId // ignore: cast_nullable_to_non_nullable
as int?,shotId: freezed == shotId ? _self.shotId : shotId // ignore: cast_nullable_to_non_nullable
as int?,characterId: freezed == characterId ? _self.characterId : characterId // ignore: cast_nullable_to_non_nullable
as int?,locationId: freezed == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as int?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,subType: null == subType ? _self.subType : subType // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,fileUrl: null == fileUrl ? _self.fileUrl : fileUrl // ignore: cast_nullable_to_non_nullable
as String,filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,fileSize: null == fileSize ? _self.fileSize : fileSize // ignore: cast_nullable_to_non_nullable
as int,fileHash: null == fileHash ? _self.fileHash : fileHash // ignore: cast_nullable_to_non_nullable
as String,mimeType: null == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as double,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,promptId: freezed == promptId ? _self.promptId : promptId // ignore: cast_nullable_to_non_nullable
as int?,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,roleIds: null == roleIds ? _self.roleIds : roleIds // ignore: cast_nullable_to_non_nullable
as String,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$MediaAssetStats {

 int get total; Map<String, TypeStats> get byType; Map<String, int> get byStatus; int get totalFileSize;
/// Create a copy of MediaAssetStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MediaAssetStatsCopyWith<MediaAssetStats> get copyWith => _$MediaAssetStatsCopyWithImpl<MediaAssetStats>(this as MediaAssetStats, _$identity);

  /// Serializes this MediaAssetStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MediaAssetStats&&(identical(other.total, total) || other.total == total)&&const DeepCollectionEquality().equals(other.byType, byType)&&const DeepCollectionEquality().equals(other.byStatus, byStatus)&&(identical(other.totalFileSize, totalFileSize) || other.totalFileSize == totalFileSize));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,total,const DeepCollectionEquality().hash(byType),const DeepCollectionEquality().hash(byStatus),totalFileSize);

@override
String toString() {
  return 'MediaAssetStats(total: $total, byType: $byType, byStatus: $byStatus, totalFileSize: $totalFileSize)';
}


}

/// @nodoc
abstract mixin class $MediaAssetStatsCopyWith<$Res>  {
  factory $MediaAssetStatsCopyWith(MediaAssetStats value, $Res Function(MediaAssetStats) _then) = _$MediaAssetStatsCopyWithImpl;
@useResult
$Res call({
 int total, Map<String, TypeStats> byType, Map<String, int> byStatus, int totalFileSize
});




}
/// @nodoc
class _$MediaAssetStatsCopyWithImpl<$Res>
    implements $MediaAssetStatsCopyWith<$Res> {
  _$MediaAssetStatsCopyWithImpl(this._self, this._then);

  final MediaAssetStats _self;
  final $Res Function(MediaAssetStats) _then;

/// Create a copy of MediaAssetStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? total = null,Object? byType = null,Object? byStatus = null,Object? totalFileSize = null,}) {
  return _then(_self.copyWith(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,byType: null == byType ? _self.byType : byType // ignore: cast_nullable_to_non_nullable
as Map<String, TypeStats>,byStatus: null == byStatus ? _self.byStatus : byStatus // ignore: cast_nullable_to_non_nullable
as Map<String, int>,totalFileSize: null == totalFileSize ? _self.totalFileSize : totalFileSize // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MediaAssetStats].
extension MediaAssetStatsPatterns on MediaAssetStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MediaAssetStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MediaAssetStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MediaAssetStats value)  $default,){
final _that = this;
switch (_that) {
case _MediaAssetStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MediaAssetStats value)?  $default,){
final _that = this;
switch (_that) {
case _MediaAssetStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int total,  Map<String, TypeStats> byType,  Map<String, int> byStatus,  int totalFileSize)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MediaAssetStats() when $default != null:
return $default(_that.total,_that.byType,_that.byStatus,_that.totalFileSize);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int total,  Map<String, TypeStats> byType,  Map<String, int> byStatus,  int totalFileSize)  $default,) {final _that = this;
switch (_that) {
case _MediaAssetStats():
return $default(_that.total,_that.byType,_that.byStatus,_that.totalFileSize);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int total,  Map<String, TypeStats> byType,  Map<String, int> byStatus,  int totalFileSize)?  $default,) {final _that = this;
switch (_that) {
case _MediaAssetStats() when $default != null:
return $default(_that.total,_that.byType,_that.byStatus,_that.totalFileSize);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MediaAssetStats implements MediaAssetStats {
  const _MediaAssetStats({this.total = 0, final  Map<String, TypeStats> byType = const {}, final  Map<String, int> byStatus = const {}, this.totalFileSize = 0}): _byType = byType,_byStatus = byStatus;
  factory _MediaAssetStats.fromJson(Map<String, dynamic> json) => _$MediaAssetStatsFromJson(json);

@override@JsonKey() final  int total;
 final  Map<String, TypeStats> _byType;
@override@JsonKey() Map<String, TypeStats> get byType {
  if (_byType is EqualUnmodifiableMapView) return _byType;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_byType);
}

 final  Map<String, int> _byStatus;
@override@JsonKey() Map<String, int> get byStatus {
  if (_byStatus is EqualUnmodifiableMapView) return _byStatus;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_byStatus);
}

@override@JsonKey() final  int totalFileSize;

/// Create a copy of MediaAssetStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MediaAssetStatsCopyWith<_MediaAssetStats> get copyWith => __$MediaAssetStatsCopyWithImpl<_MediaAssetStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MediaAssetStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MediaAssetStats&&(identical(other.total, total) || other.total == total)&&const DeepCollectionEquality().equals(other._byType, _byType)&&const DeepCollectionEquality().equals(other._byStatus, _byStatus)&&(identical(other.totalFileSize, totalFileSize) || other.totalFileSize == totalFileSize));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,total,const DeepCollectionEquality().hash(_byType),const DeepCollectionEquality().hash(_byStatus),totalFileSize);

@override
String toString() {
  return 'MediaAssetStats(total: $total, byType: $byType, byStatus: $byStatus, totalFileSize: $totalFileSize)';
}


}

/// @nodoc
abstract mixin class _$MediaAssetStatsCopyWith<$Res> implements $MediaAssetStatsCopyWith<$Res> {
  factory _$MediaAssetStatsCopyWith(_MediaAssetStats value, $Res Function(_MediaAssetStats) _then) = __$MediaAssetStatsCopyWithImpl;
@override @useResult
$Res call({
 int total, Map<String, TypeStats> byType, Map<String, int> byStatus, int totalFileSize
});




}
/// @nodoc
class __$MediaAssetStatsCopyWithImpl<$Res>
    implements _$MediaAssetStatsCopyWith<$Res> {
  __$MediaAssetStatsCopyWithImpl(this._self, this._then);

  final _MediaAssetStats _self;
  final $Res Function(_MediaAssetStats) _then;

/// Create a copy of MediaAssetStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? total = null,Object? byType = null,Object? byStatus = null,Object? totalFileSize = null,}) {
  return _then(_MediaAssetStats(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,byType: null == byType ? _self._byType : byType // ignore: cast_nullable_to_non_nullable
as Map<String, TypeStats>,byStatus: null == byStatus ? _self._byStatus : byStatus // ignore: cast_nullable_to_non_nullable
as Map<String, int>,totalFileSize: null == totalFileSize ? _self.totalFileSize : totalFileSize // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$TypeStats {

 int get total; int get active; int get deprecated;
/// Create a copy of TypeStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TypeStatsCopyWith<TypeStats> get copyWith => _$TypeStatsCopyWithImpl<TypeStats>(this as TypeStats, _$identity);

  /// Serializes this TypeStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TypeStats&&(identical(other.total, total) || other.total == total)&&(identical(other.active, active) || other.active == active)&&(identical(other.deprecated, deprecated) || other.deprecated == deprecated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,total,active,deprecated);

@override
String toString() {
  return 'TypeStats(total: $total, active: $active, deprecated: $deprecated)';
}


}

/// @nodoc
abstract mixin class $TypeStatsCopyWith<$Res>  {
  factory $TypeStatsCopyWith(TypeStats value, $Res Function(TypeStats) _then) = _$TypeStatsCopyWithImpl;
@useResult
$Res call({
 int total, int active, int deprecated
});




}
/// @nodoc
class _$TypeStatsCopyWithImpl<$Res>
    implements $TypeStatsCopyWith<$Res> {
  _$TypeStatsCopyWithImpl(this._self, this._then);

  final TypeStats _self;
  final $Res Function(TypeStats) _then;

/// Create a copy of TypeStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? total = null,Object? active = null,Object? deprecated = null,}) {
  return _then(_self.copyWith(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as int,deprecated: null == deprecated ? _self.deprecated : deprecated // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TypeStats].
extension TypeStatsPatterns on TypeStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TypeStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TypeStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TypeStats value)  $default,){
final _that = this;
switch (_that) {
case _TypeStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TypeStats value)?  $default,){
final _that = this;
switch (_that) {
case _TypeStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int total,  int active,  int deprecated)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TypeStats() when $default != null:
return $default(_that.total,_that.active,_that.deprecated);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int total,  int active,  int deprecated)  $default,) {final _that = this;
switch (_that) {
case _TypeStats():
return $default(_that.total,_that.active,_that.deprecated);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int total,  int active,  int deprecated)?  $default,) {final _that = this;
switch (_that) {
case _TypeStats() when $default != null:
return $default(_that.total,_that.active,_that.deprecated);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TypeStats implements TypeStats {
  const _TypeStats({this.total = 0, this.active = 0, this.deprecated = 0});
  factory _TypeStats.fromJson(Map<String, dynamic> json) => _$TypeStatsFromJson(json);

@override@JsonKey() final  int total;
@override@JsonKey() final  int active;
@override@JsonKey() final  int deprecated;

/// Create a copy of TypeStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TypeStatsCopyWith<_TypeStats> get copyWith => __$TypeStatsCopyWithImpl<_TypeStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TypeStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TypeStats&&(identical(other.total, total) || other.total == total)&&(identical(other.active, active) || other.active == active)&&(identical(other.deprecated, deprecated) || other.deprecated == deprecated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,total,active,deprecated);

@override
String toString() {
  return 'TypeStats(total: $total, active: $active, deprecated: $deprecated)';
}


}

/// @nodoc
abstract mixin class _$TypeStatsCopyWith<$Res> implements $TypeStatsCopyWith<$Res> {
  factory _$TypeStatsCopyWith(_TypeStats value, $Res Function(_TypeStats) _then) = __$TypeStatsCopyWithImpl;
@override @useResult
$Res call({
 int total, int active, int deprecated
});




}
/// @nodoc
class __$TypeStatsCopyWithImpl<$Res>
    implements _$TypeStatsCopyWith<$Res> {
  __$TypeStatsCopyWithImpl(this._self, this._then);

  final _TypeStats _self;
  final $Res Function(_TypeStats) _then;

/// Create a copy of TypeStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? total = null,Object? active = null,Object? deprecated = null,}) {
  return _then(_TypeStats(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as int,deprecated: null == deprecated ? _self.deprecated : deprecated // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
