// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'resource.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Resource {

 String? get id; String? get userId; String get name; String get libraryType; String get modality; String get thumbnailUrl; String get tagsJson; String get version; String get metadataJson; String get bindingIdsJson; String get description; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of Resource
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResourceCopyWith<Resource> get copyWith => _$ResourceCopyWithImpl<Resource>(this as Resource, _$identity);

  /// Serializes this Resource to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Resource&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.libraryType, libraryType) || other.libraryType == libraryType)&&(identical(other.modality, modality) || other.modality == modality)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.tagsJson, tagsJson) || other.tagsJson == tagsJson)&&(identical(other.version, version) || other.version == version)&&(identical(other.metadataJson, metadataJson) || other.metadataJson == metadataJson)&&(identical(other.bindingIdsJson, bindingIdsJson) || other.bindingIdsJson == bindingIdsJson)&&(identical(other.description, description) || other.description == description)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,name,libraryType,modality,thumbnailUrl,tagsJson,version,metadataJson,bindingIdsJson,description,createdAt,updatedAt);

@override
String toString() {
  return 'Resource(id: $id, userId: $userId, name: $name, libraryType: $libraryType, modality: $modality, thumbnailUrl: $thumbnailUrl, tagsJson: $tagsJson, version: $version, metadataJson: $metadataJson, bindingIdsJson: $bindingIdsJson, description: $description, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ResourceCopyWith<$Res>  {
  factory $ResourceCopyWith(Resource value, $Res Function(Resource) _then) = _$ResourceCopyWithImpl;
@useResult
$Res call({
 String? id, String? userId, String name, String libraryType, String modality, String thumbnailUrl, String tagsJson, String version, String metadataJson, String bindingIdsJson, String description, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$ResourceCopyWithImpl<$Res>
    implements $ResourceCopyWith<$Res> {
  _$ResourceCopyWithImpl(this._self, this._then);

  final Resource _self;
  final $Res Function(Resource) _then;

/// Create a copy of Resource
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? userId = freezed,Object? name = null,Object? libraryType = null,Object? modality = null,Object? thumbnailUrl = null,Object? tagsJson = null,Object? version = null,Object? metadataJson = null,Object? bindingIdsJson = null,Object? description = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,libraryType: null == libraryType ? _self.libraryType : libraryType // ignore: cast_nullable_to_non_nullable
as String,modality: null == modality ? _self.modality : modality // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: null == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String,tagsJson: null == tagsJson ? _self.tagsJson : tagsJson // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,metadataJson: null == metadataJson ? _self.metadataJson : metadataJson // ignore: cast_nullable_to_non_nullable
as String,bindingIdsJson: null == bindingIdsJson ? _self.bindingIdsJson : bindingIdsJson // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Resource].
extension ResourcePatterns on Resource {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Resource value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Resource() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Resource value)  $default,){
final _that = this;
switch (_that) {
case _Resource():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Resource value)?  $default,){
final _that = this;
switch (_that) {
case _Resource() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String? userId,  String name,  String libraryType,  String modality,  String thumbnailUrl,  String tagsJson,  String version,  String metadataJson,  String bindingIdsJson,  String description,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Resource() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.libraryType,_that.modality,_that.thumbnailUrl,_that.tagsJson,_that.version,_that.metadataJson,_that.bindingIdsJson,_that.description,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String? userId,  String name,  String libraryType,  String modality,  String thumbnailUrl,  String tagsJson,  String version,  String metadataJson,  String bindingIdsJson,  String description,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Resource():
return $default(_that.id,_that.userId,_that.name,_that.libraryType,_that.modality,_that.thumbnailUrl,_that.tagsJson,_that.version,_that.metadataJson,_that.bindingIdsJson,_that.description,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String? userId,  String name,  String libraryType,  String modality,  String thumbnailUrl,  String tagsJson,  String version,  String metadataJson,  String bindingIdsJson,  String description,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Resource() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.libraryType,_that.modality,_that.thumbnailUrl,_that.tagsJson,_that.version,_that.metadataJson,_that.bindingIdsJson,_that.description,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Resource extends Resource {
  const _Resource({this.id, this.userId, this.name = '', this.libraryType = '', this.modality = '', this.thumbnailUrl = '', this.tagsJson = '', this.version = '', this.metadataJson = '', this.bindingIdsJson = '', this.description = '', this.createdAt, this.updatedAt}): super._();
  factory _Resource.fromJson(Map<String, dynamic> json) => _$ResourceFromJson(json);

@override final  String? id;
@override final  String? userId;
@override@JsonKey() final  String name;
@override@JsonKey() final  String libraryType;
@override@JsonKey() final  String modality;
@override@JsonKey() final  String thumbnailUrl;
@override@JsonKey() final  String tagsJson;
@override@JsonKey() final  String version;
@override@JsonKey() final  String metadataJson;
@override@JsonKey() final  String bindingIdsJson;
@override@JsonKey() final  String description;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of Resource
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResourceCopyWith<_Resource> get copyWith => __$ResourceCopyWithImpl<_Resource>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ResourceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Resource&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.libraryType, libraryType) || other.libraryType == libraryType)&&(identical(other.modality, modality) || other.modality == modality)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.tagsJson, tagsJson) || other.tagsJson == tagsJson)&&(identical(other.version, version) || other.version == version)&&(identical(other.metadataJson, metadataJson) || other.metadataJson == metadataJson)&&(identical(other.bindingIdsJson, bindingIdsJson) || other.bindingIdsJson == bindingIdsJson)&&(identical(other.description, description) || other.description == description)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,name,libraryType,modality,thumbnailUrl,tagsJson,version,metadataJson,bindingIdsJson,description,createdAt,updatedAt);

@override
String toString() {
  return 'Resource(id: $id, userId: $userId, name: $name, libraryType: $libraryType, modality: $modality, thumbnailUrl: $thumbnailUrl, tagsJson: $tagsJson, version: $version, metadataJson: $metadataJson, bindingIdsJson: $bindingIdsJson, description: $description, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ResourceCopyWith<$Res> implements $ResourceCopyWith<$Res> {
  factory _$ResourceCopyWith(_Resource value, $Res Function(_Resource) _then) = __$ResourceCopyWithImpl;
@override @useResult
$Res call({
 String? id, String? userId, String name, String libraryType, String modality, String thumbnailUrl, String tagsJson, String version, String metadataJson, String bindingIdsJson, String description, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$ResourceCopyWithImpl<$Res>
    implements _$ResourceCopyWith<$Res> {
  __$ResourceCopyWithImpl(this._self, this._then);

  final _Resource _self;
  final $Res Function(_Resource) _then;

/// Create a copy of Resource
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? userId = freezed,Object? name = null,Object? libraryType = null,Object? modality = null,Object? thumbnailUrl = null,Object? tagsJson = null,Object? version = null,Object? metadataJson = null,Object? bindingIdsJson = null,Object? description = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_Resource(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,libraryType: null == libraryType ? _self.libraryType : libraryType // ignore: cast_nullable_to_non_nullable
as String,modality: null == modality ? _self.modality : modality // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: null == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String,tagsJson: null == tagsJson ? _self.tagsJson : tagsJson // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,metadataJson: null == metadataJson ? _self.metadataJson : metadataJson // ignore: cast_nullable_to_non_nullable
as String,bindingIdsJson: null == bindingIdsJson ? _self.bindingIdsJson : bindingIdsJson // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
