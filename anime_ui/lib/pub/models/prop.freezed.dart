// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'prop.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Prop {

@JsonKey(fromJson: _nullableIdFromJson) String? get id;@JsonKey(fromJson: _nullableIdFromJson, name: 'projectId') String? get projectId; String get name; String get appearance; bool get isKeyProp; String get style; bool get styleOverride; String get referenceImagesJson; String get imageUrl; String get usedByJson; String get scenesJson; String get status; String get source;
/// Create a copy of Prop
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PropCopyWith<Prop> get copyWith => _$PropCopyWithImpl<Prop>(this as Prop, _$identity);

  /// Serializes this Prop to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Prop&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.name, name) || other.name == name)&&(identical(other.appearance, appearance) || other.appearance == appearance)&&(identical(other.isKeyProp, isKeyProp) || other.isKeyProp == isKeyProp)&&(identical(other.style, style) || other.style == style)&&(identical(other.styleOverride, styleOverride) || other.styleOverride == styleOverride)&&(identical(other.referenceImagesJson, referenceImagesJson) || other.referenceImagesJson == referenceImagesJson)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.usedByJson, usedByJson) || other.usedByJson == usedByJson)&&(identical(other.scenesJson, scenesJson) || other.scenesJson == scenesJson)&&(identical(other.status, status) || other.status == status)&&(identical(other.source, source) || other.source == source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,projectId,name,appearance,isKeyProp,style,styleOverride,referenceImagesJson,imageUrl,usedByJson,scenesJson,status,source);

@override
String toString() {
  return 'Prop(id: $id, projectId: $projectId, name: $name, appearance: $appearance, isKeyProp: $isKeyProp, style: $style, styleOverride: $styleOverride, referenceImagesJson: $referenceImagesJson, imageUrl: $imageUrl, usedByJson: $usedByJson, scenesJson: $scenesJson, status: $status, source: $source)';
}


}

/// @nodoc
abstract mixin class $PropCopyWith<$Res>  {
  factory $PropCopyWith(Prop value, $Res Function(Prop) _then) = _$PropCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: _nullableIdFromJson) String? id,@JsonKey(fromJson: _nullableIdFromJson, name: 'projectId') String? projectId, String name, String appearance, bool isKeyProp, String style, bool styleOverride, String referenceImagesJson, String imageUrl, String usedByJson, String scenesJson, String status, String source
});




}
/// @nodoc
class _$PropCopyWithImpl<$Res>
    implements $PropCopyWith<$Res> {
  _$PropCopyWithImpl(this._self, this._then);

  final Prop _self;
  final $Res Function(Prop) _then;

/// Create a copy of Prop
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? projectId = freezed,Object? name = null,Object? appearance = null,Object? isKeyProp = null,Object? style = null,Object? styleOverride = null,Object? referenceImagesJson = null,Object? imageUrl = null,Object? usedByJson = null,Object? scenesJson = null,Object? status = null,Object? source = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,appearance: null == appearance ? _self.appearance : appearance // ignore: cast_nullable_to_non_nullable
as String,isKeyProp: null == isKeyProp ? _self.isKeyProp : isKeyProp // ignore: cast_nullable_to_non_nullable
as bool,style: null == style ? _self.style : style // ignore: cast_nullable_to_non_nullable
as String,styleOverride: null == styleOverride ? _self.styleOverride : styleOverride // ignore: cast_nullable_to_non_nullable
as bool,referenceImagesJson: null == referenceImagesJson ? _self.referenceImagesJson : referenceImagesJson // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,usedByJson: null == usedByJson ? _self.usedByJson : usedByJson // ignore: cast_nullable_to_non_nullable
as String,scenesJson: null == scenesJson ? _self.scenesJson : scenesJson // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Prop].
extension PropPatterns on Prop {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Prop value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Prop() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Prop value)  $default,){
final _that = this;
switch (_that) {
case _Prop():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Prop value)?  $default,){
final _that = this;
switch (_that) {
case _Prop() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _nullableIdFromJson)  String? id, @JsonKey(fromJson: _nullableIdFromJson, name: 'projectId')  String? projectId,  String name,  String appearance,  bool isKeyProp,  String style,  bool styleOverride,  String referenceImagesJson,  String imageUrl,  String usedByJson,  String scenesJson,  String status,  String source)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Prop() when $default != null:
return $default(_that.id,_that.projectId,_that.name,_that.appearance,_that.isKeyProp,_that.style,_that.styleOverride,_that.referenceImagesJson,_that.imageUrl,_that.usedByJson,_that.scenesJson,_that.status,_that.source);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _nullableIdFromJson)  String? id, @JsonKey(fromJson: _nullableIdFromJson, name: 'projectId')  String? projectId,  String name,  String appearance,  bool isKeyProp,  String style,  bool styleOverride,  String referenceImagesJson,  String imageUrl,  String usedByJson,  String scenesJson,  String status,  String source)  $default,) {final _that = this;
switch (_that) {
case _Prop():
return $default(_that.id,_that.projectId,_that.name,_that.appearance,_that.isKeyProp,_that.style,_that.styleOverride,_that.referenceImagesJson,_that.imageUrl,_that.usedByJson,_that.scenesJson,_that.status,_that.source);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: _nullableIdFromJson)  String? id, @JsonKey(fromJson: _nullableIdFromJson, name: 'projectId')  String? projectId,  String name,  String appearance,  bool isKeyProp,  String style,  bool styleOverride,  String referenceImagesJson,  String imageUrl,  String usedByJson,  String scenesJson,  String status,  String source)?  $default,) {final _that = this;
switch (_that) {
case _Prop() when $default != null:
return $default(_that.id,_that.projectId,_that.name,_that.appearance,_that.isKeyProp,_that.style,_that.styleOverride,_that.referenceImagesJson,_that.imageUrl,_that.usedByJson,_that.scenesJson,_that.status,_that.source);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Prop extends Prop {
  const _Prop({@JsonKey(fromJson: _nullableIdFromJson) this.id, @JsonKey(fromJson: _nullableIdFromJson, name: 'projectId') this.projectId, this.name = '', this.appearance = '', this.isKeyProp = false, this.style = '', this.styleOverride = false, this.referenceImagesJson = '', this.imageUrl = '', this.usedByJson = '', this.scenesJson = '', this.status = 'draft', this.source = 'manual'}): super._();
  factory _Prop.fromJson(Map<String, dynamic> json) => _$PropFromJson(json);

@override@JsonKey(fromJson: _nullableIdFromJson) final  String? id;
@override@JsonKey(fromJson: _nullableIdFromJson, name: 'projectId') final  String? projectId;
@override@JsonKey() final  String name;
@override@JsonKey() final  String appearance;
@override@JsonKey() final  bool isKeyProp;
@override@JsonKey() final  String style;
@override@JsonKey() final  bool styleOverride;
@override@JsonKey() final  String referenceImagesJson;
@override@JsonKey() final  String imageUrl;
@override@JsonKey() final  String usedByJson;
@override@JsonKey() final  String scenesJson;
@override@JsonKey() final  String status;
@override@JsonKey() final  String source;

/// Create a copy of Prop
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PropCopyWith<_Prop> get copyWith => __$PropCopyWithImpl<_Prop>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PropToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Prop&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.name, name) || other.name == name)&&(identical(other.appearance, appearance) || other.appearance == appearance)&&(identical(other.isKeyProp, isKeyProp) || other.isKeyProp == isKeyProp)&&(identical(other.style, style) || other.style == style)&&(identical(other.styleOverride, styleOverride) || other.styleOverride == styleOverride)&&(identical(other.referenceImagesJson, referenceImagesJson) || other.referenceImagesJson == referenceImagesJson)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.usedByJson, usedByJson) || other.usedByJson == usedByJson)&&(identical(other.scenesJson, scenesJson) || other.scenesJson == scenesJson)&&(identical(other.status, status) || other.status == status)&&(identical(other.source, source) || other.source == source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,projectId,name,appearance,isKeyProp,style,styleOverride,referenceImagesJson,imageUrl,usedByJson,scenesJson,status,source);

@override
String toString() {
  return 'Prop(id: $id, projectId: $projectId, name: $name, appearance: $appearance, isKeyProp: $isKeyProp, style: $style, styleOverride: $styleOverride, referenceImagesJson: $referenceImagesJson, imageUrl: $imageUrl, usedByJson: $usedByJson, scenesJson: $scenesJson, status: $status, source: $source)';
}


}

/// @nodoc
abstract mixin class _$PropCopyWith<$Res> implements $PropCopyWith<$Res> {
  factory _$PropCopyWith(_Prop value, $Res Function(_Prop) _then) = __$PropCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: _nullableIdFromJson) String? id,@JsonKey(fromJson: _nullableIdFromJson, name: 'projectId') String? projectId, String name, String appearance, bool isKeyProp, String style, bool styleOverride, String referenceImagesJson, String imageUrl, String usedByJson, String scenesJson, String status, String source
});




}
/// @nodoc
class __$PropCopyWithImpl<$Res>
    implements _$PropCopyWith<$Res> {
  __$PropCopyWithImpl(this._self, this._then);

  final _Prop _self;
  final $Res Function(_Prop) _then;

/// Create a copy of Prop
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? projectId = freezed,Object? name = null,Object? appearance = null,Object? isKeyProp = null,Object? style = null,Object? styleOverride = null,Object? referenceImagesJson = null,Object? imageUrl = null,Object? usedByJson = null,Object? scenesJson = null,Object? status = null,Object? source = null,}) {
  return _then(_Prop(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,appearance: null == appearance ? _self.appearance : appearance // ignore: cast_nullable_to_non_nullable
as String,isKeyProp: null == isKeyProp ? _self.isKeyProp : isKeyProp // ignore: cast_nullable_to_non_nullable
as bool,style: null == style ? _self.style : style // ignore: cast_nullable_to_non_nullable
as String,styleOverride: null == styleOverride ? _self.styleOverride : styleOverride // ignore: cast_nullable_to_non_nullable
as bool,referenceImagesJson: null == referenceImagesJson ? _self.referenceImagesJson : referenceImagesJson // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,usedByJson: null == usedByJson ? _self.usedByJson : usedByJson // ignore: cast_nullable_to_non_nullable
as String,scenesJson: null == scenesJson ? _self.scenesJson : scenesJson // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
