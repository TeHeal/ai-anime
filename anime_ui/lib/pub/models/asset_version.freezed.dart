// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'asset_version.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AssetVersion {

 String? get id; String? get projectId; int get version; String get action; String get statsJson; String get deltaJson; String get note; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of AssetVersion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssetVersionCopyWith<AssetVersion> get copyWith => _$AssetVersionCopyWithImpl<AssetVersion>(this as AssetVersion, _$identity);

  /// Serializes this AssetVersion to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AssetVersion&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.version, version) || other.version == version)&&(identical(other.action, action) || other.action == action)&&(identical(other.statsJson, statsJson) || other.statsJson == statsJson)&&(identical(other.deltaJson, deltaJson) || other.deltaJson == deltaJson)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,projectId,version,action,statsJson,deltaJson,note,createdAt,updatedAt);

@override
String toString() {
  return 'AssetVersion(id: $id, projectId: $projectId, version: $version, action: $action, statsJson: $statsJson, deltaJson: $deltaJson, note: $note, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $AssetVersionCopyWith<$Res>  {
  factory $AssetVersionCopyWith(AssetVersion value, $Res Function(AssetVersion) _then) = _$AssetVersionCopyWithImpl;
@useResult
$Res call({
 String? id, String? projectId, int version, String action, String statsJson, String deltaJson, String note, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$AssetVersionCopyWithImpl<$Res>
    implements $AssetVersionCopyWith<$Res> {
  _$AssetVersionCopyWithImpl(this._self, this._then);

  final AssetVersion _self;
  final $Res Function(AssetVersion) _then;

/// Create a copy of AssetVersion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? projectId = freezed,Object? version = null,Object? action = null,Object? statsJson = null,Object? deltaJson = null,Object? note = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String?,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,statsJson: null == statsJson ? _self.statsJson : statsJson // ignore: cast_nullable_to_non_nullable
as String,deltaJson: null == deltaJson ? _self.deltaJson : deltaJson // ignore: cast_nullable_to_non_nullable
as String,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [AssetVersion].
extension AssetVersionPatterns on AssetVersion {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AssetVersion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AssetVersion() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AssetVersion value)  $default,){
final _that = this;
switch (_that) {
case _AssetVersion():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AssetVersion value)?  $default,){
final _that = this;
switch (_that) {
case _AssetVersion() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String? projectId,  int version,  String action,  String statsJson,  String deltaJson,  String note,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AssetVersion() when $default != null:
return $default(_that.id,_that.projectId,_that.version,_that.action,_that.statsJson,_that.deltaJson,_that.note,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String? projectId,  int version,  String action,  String statsJson,  String deltaJson,  String note,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _AssetVersion():
return $default(_that.id,_that.projectId,_that.version,_that.action,_that.statsJson,_that.deltaJson,_that.note,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String? projectId,  int version,  String action,  String statsJson,  String deltaJson,  String note,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _AssetVersion() when $default != null:
return $default(_that.id,_that.projectId,_that.version,_that.action,_that.statsJson,_that.deltaJson,_that.note,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AssetVersion extends AssetVersion {
  const _AssetVersion({this.id, this.projectId, this.version = 0, this.action = '', this.statsJson = '', this.deltaJson = '', this.note = '', this.createdAt, this.updatedAt}): super._();
  factory _AssetVersion.fromJson(Map<String, dynamic> json) => _$AssetVersionFromJson(json);

@override final  String? id;
@override final  String? projectId;
@override@JsonKey() final  int version;
@override@JsonKey() final  String action;
@override@JsonKey() final  String statsJson;
@override@JsonKey() final  String deltaJson;
@override@JsonKey() final  String note;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of AssetVersion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AssetVersionCopyWith<_AssetVersion> get copyWith => __$AssetVersionCopyWithImpl<_AssetVersion>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AssetVersionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AssetVersion&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.version, version) || other.version == version)&&(identical(other.action, action) || other.action == action)&&(identical(other.statsJson, statsJson) || other.statsJson == statsJson)&&(identical(other.deltaJson, deltaJson) || other.deltaJson == deltaJson)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,projectId,version,action,statsJson,deltaJson,note,createdAt,updatedAt);

@override
String toString() {
  return 'AssetVersion(id: $id, projectId: $projectId, version: $version, action: $action, statsJson: $statsJson, deltaJson: $deltaJson, note: $note, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$AssetVersionCopyWith<$Res> implements $AssetVersionCopyWith<$Res> {
  factory _$AssetVersionCopyWith(_AssetVersion value, $Res Function(_AssetVersion) _then) = __$AssetVersionCopyWithImpl;
@override @useResult
$Res call({
 String? id, String? projectId, int version, String action, String statsJson, String deltaJson, String note, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$AssetVersionCopyWithImpl<$Res>
    implements _$AssetVersionCopyWith<$Res> {
  __$AssetVersionCopyWithImpl(this._self, this._then);

  final _AssetVersion _self;
  final $Res Function(_AssetVersion) _then;

/// Create a copy of AssetVersion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? projectId = freezed,Object? version = null,Object? action = null,Object? statsJson = null,Object? deltaJson = null,Object? note = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_AssetVersion(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String?,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,statsJson: null == statsJson ? _self.statsJson : statsJson // ignore: cast_nullable_to_non_nullable
as String,deltaJson: null == deltaJson ? _self.deltaJson : deltaJson // ignore: cast_nullable_to_non_nullable
as String,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
