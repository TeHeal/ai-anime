// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'style.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Style {

 int? get id; int? get projectId; String get name; String get description; String get negativePrompt; String get referenceImagesJson; String get thumbnailUrl; bool get isPreset; bool get isProjectDefault; DateTime? get createdAt;
/// Create a copy of Style
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StyleCopyWith<Style> get copyWith => _$StyleCopyWithImpl<Style>(this as Style, _$identity);

  /// Serializes this Style to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Style&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.negativePrompt, negativePrompt) || other.negativePrompt == negativePrompt)&&(identical(other.referenceImagesJson, referenceImagesJson) || other.referenceImagesJson == referenceImagesJson)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.isPreset, isPreset) || other.isPreset == isPreset)&&(identical(other.isProjectDefault, isProjectDefault) || other.isProjectDefault == isProjectDefault)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,projectId,name,description,negativePrompt,referenceImagesJson,thumbnailUrl,isPreset,isProjectDefault,createdAt);

@override
String toString() {
  return 'Style(id: $id, projectId: $projectId, name: $name, description: $description, negativePrompt: $negativePrompt, referenceImagesJson: $referenceImagesJson, thumbnailUrl: $thumbnailUrl, isPreset: $isPreset, isProjectDefault: $isProjectDefault, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $StyleCopyWith<$Res>  {
  factory $StyleCopyWith(Style value, $Res Function(Style) _then) = _$StyleCopyWithImpl;
@useResult
$Res call({
 int? id, int? projectId, String name, String description, String negativePrompt, String referenceImagesJson, String thumbnailUrl, bool isPreset, bool isProjectDefault, DateTime? createdAt
});




}
/// @nodoc
class _$StyleCopyWithImpl<$Res>
    implements $StyleCopyWith<$Res> {
  _$StyleCopyWithImpl(this._self, this._then);

  final Style _self;
  final $Res Function(Style) _then;

/// Create a copy of Style
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? projectId = freezed,Object? name = null,Object? description = null,Object? negativePrompt = null,Object? referenceImagesJson = null,Object? thumbnailUrl = null,Object? isPreset = null,Object? isProjectDefault = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as int?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,negativePrompt: null == negativePrompt ? _self.negativePrompt : negativePrompt // ignore: cast_nullable_to_non_nullable
as String,referenceImagesJson: null == referenceImagesJson ? _self.referenceImagesJson : referenceImagesJson // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: null == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String,isPreset: null == isPreset ? _self.isPreset : isPreset // ignore: cast_nullable_to_non_nullable
as bool,isProjectDefault: null == isProjectDefault ? _self.isProjectDefault : isProjectDefault // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Style].
extension StylePatterns on Style {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Style value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Style() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Style value)  $default,){
final _that = this;
switch (_that) {
case _Style():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Style value)?  $default,){
final _that = this;
switch (_that) {
case _Style() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  int? projectId,  String name,  String description,  String negativePrompt,  String referenceImagesJson,  String thumbnailUrl,  bool isPreset,  bool isProjectDefault,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Style() when $default != null:
return $default(_that.id,_that.projectId,_that.name,_that.description,_that.negativePrompt,_that.referenceImagesJson,_that.thumbnailUrl,_that.isPreset,_that.isProjectDefault,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  int? projectId,  String name,  String description,  String negativePrompt,  String referenceImagesJson,  String thumbnailUrl,  bool isPreset,  bool isProjectDefault,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _Style():
return $default(_that.id,_that.projectId,_that.name,_that.description,_that.negativePrompt,_that.referenceImagesJson,_that.thumbnailUrl,_that.isPreset,_that.isProjectDefault,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  int? projectId,  String name,  String description,  String negativePrompt,  String referenceImagesJson,  String thumbnailUrl,  bool isPreset,  bool isProjectDefault,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Style() when $default != null:
return $default(_that.id,_that.projectId,_that.name,_that.description,_that.negativePrompt,_that.referenceImagesJson,_that.thumbnailUrl,_that.isPreset,_that.isProjectDefault,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Style extends Style {
  const _Style({this.id, this.projectId, this.name = '', this.description = '', this.negativePrompt = '', this.referenceImagesJson = '', this.thumbnailUrl = '', this.isPreset = false, this.isProjectDefault = false, this.createdAt}): super._();
  factory _Style.fromJson(Map<String, dynamic> json) => _$StyleFromJson(json);

@override final  int? id;
@override final  int? projectId;
@override@JsonKey() final  String name;
@override@JsonKey() final  String description;
@override@JsonKey() final  String negativePrompt;
@override@JsonKey() final  String referenceImagesJson;
@override@JsonKey() final  String thumbnailUrl;
@override@JsonKey() final  bool isPreset;
@override@JsonKey() final  bool isProjectDefault;
@override final  DateTime? createdAt;

/// Create a copy of Style
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StyleCopyWith<_Style> get copyWith => __$StyleCopyWithImpl<_Style>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StyleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Style&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.negativePrompt, negativePrompt) || other.negativePrompt == negativePrompt)&&(identical(other.referenceImagesJson, referenceImagesJson) || other.referenceImagesJson == referenceImagesJson)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.isPreset, isPreset) || other.isPreset == isPreset)&&(identical(other.isProjectDefault, isProjectDefault) || other.isProjectDefault == isProjectDefault)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,projectId,name,description,negativePrompt,referenceImagesJson,thumbnailUrl,isPreset,isProjectDefault,createdAt);

@override
String toString() {
  return 'Style(id: $id, projectId: $projectId, name: $name, description: $description, negativePrompt: $negativePrompt, referenceImagesJson: $referenceImagesJson, thumbnailUrl: $thumbnailUrl, isPreset: $isPreset, isProjectDefault: $isProjectDefault, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$StyleCopyWith<$Res> implements $StyleCopyWith<$Res> {
  factory _$StyleCopyWith(_Style value, $Res Function(_Style) _then) = __$StyleCopyWithImpl;
@override @useResult
$Res call({
 int? id, int? projectId, String name, String description, String negativePrompt, String referenceImagesJson, String thumbnailUrl, bool isPreset, bool isProjectDefault, DateTime? createdAt
});




}
/// @nodoc
class __$StyleCopyWithImpl<$Res>
    implements _$StyleCopyWith<$Res> {
  __$StyleCopyWithImpl(this._self, this._then);

  final _Style _self;
  final $Res Function(_Style) _then;

/// Create a copy of Style
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? projectId = freezed,Object? name = null,Object? description = null,Object? negativePrompt = null,Object? referenceImagesJson = null,Object? thumbnailUrl = null,Object? isPreset = null,Object? isProjectDefault = null,Object? createdAt = freezed,}) {
  return _then(_Style(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as int?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,negativePrompt: null == negativePrompt ? _self.negativePrompt : negativePrompt // ignore: cast_nullable_to_non_nullable
as String,referenceImagesJson: null == referenceImagesJson ? _self.referenceImagesJson : referenceImagesJson // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: null == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String,isPreset: null == isPreset ? _self.isPreset : isPreset // ignore: cast_nullable_to_non_nullable
as bool,isProjectDefault: null == isProjectDefault ? _self.isProjectDefault : isProjectDefault // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
