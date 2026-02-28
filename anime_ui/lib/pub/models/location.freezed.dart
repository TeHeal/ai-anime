// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'location.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Location {

@JsonKey(fromJson: _nullableIdFromJson) String? get id;@JsonKey(fromJson: _nullableIdFromJson, name: 'projectId') String? get projectId; String get name; String get time; String get interiorExterior; String get atmosphere; String get colorTone; String get layout; String get style; bool get styleOverride; String get styleNote; String get imageUrl; String get referenceImagesJson; String get taskId; String get imageStatus; String get status; String get source;
/// Create a copy of Location
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocationCopyWith<Location> get copyWith => _$LocationCopyWithImpl<Location>(this as Location, _$identity);

  /// Serializes this Location to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Location&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.name, name) || other.name == name)&&(identical(other.time, time) || other.time == time)&&(identical(other.interiorExterior, interiorExterior) || other.interiorExterior == interiorExterior)&&(identical(other.atmosphere, atmosphere) || other.atmosphere == atmosphere)&&(identical(other.colorTone, colorTone) || other.colorTone == colorTone)&&(identical(other.layout, layout) || other.layout == layout)&&(identical(other.style, style) || other.style == style)&&(identical(other.styleOverride, styleOverride) || other.styleOverride == styleOverride)&&(identical(other.styleNote, styleNote) || other.styleNote == styleNote)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.referenceImagesJson, referenceImagesJson) || other.referenceImagesJson == referenceImagesJson)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.imageStatus, imageStatus) || other.imageStatus == imageStatus)&&(identical(other.status, status) || other.status == status)&&(identical(other.source, source) || other.source == source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,projectId,name,time,interiorExterior,atmosphere,colorTone,layout,style,styleOverride,styleNote,imageUrl,referenceImagesJson,taskId,imageStatus,status,source);

@override
String toString() {
  return 'Location(id: $id, projectId: $projectId, name: $name, time: $time, interiorExterior: $interiorExterior, atmosphere: $atmosphere, colorTone: $colorTone, layout: $layout, style: $style, styleOverride: $styleOverride, styleNote: $styleNote, imageUrl: $imageUrl, referenceImagesJson: $referenceImagesJson, taskId: $taskId, imageStatus: $imageStatus, status: $status, source: $source)';
}


}

/// @nodoc
abstract mixin class $LocationCopyWith<$Res>  {
  factory $LocationCopyWith(Location value, $Res Function(Location) _then) = _$LocationCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: _nullableIdFromJson) String? id,@JsonKey(fromJson: _nullableIdFromJson, name: 'projectId') String? projectId, String name, String time, String interiorExterior, String atmosphere, String colorTone, String layout, String style, bool styleOverride, String styleNote, String imageUrl, String referenceImagesJson, String taskId, String imageStatus, String status, String source
});




}
/// @nodoc
class _$LocationCopyWithImpl<$Res>
    implements $LocationCopyWith<$Res> {
  _$LocationCopyWithImpl(this._self, this._then);

  final Location _self;
  final $Res Function(Location) _then;

/// Create a copy of Location
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? projectId = freezed,Object? name = null,Object? time = null,Object? interiorExterior = null,Object? atmosphere = null,Object? colorTone = null,Object? layout = null,Object? style = null,Object? styleOverride = null,Object? styleNote = null,Object? imageUrl = null,Object? referenceImagesJson = null,Object? taskId = null,Object? imageStatus = null,Object? status = null,Object? source = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String,interiorExterior: null == interiorExterior ? _self.interiorExterior : interiorExterior // ignore: cast_nullable_to_non_nullable
as String,atmosphere: null == atmosphere ? _self.atmosphere : atmosphere // ignore: cast_nullable_to_non_nullable
as String,colorTone: null == colorTone ? _self.colorTone : colorTone // ignore: cast_nullable_to_non_nullable
as String,layout: null == layout ? _self.layout : layout // ignore: cast_nullable_to_non_nullable
as String,style: null == style ? _self.style : style // ignore: cast_nullable_to_non_nullable
as String,styleOverride: null == styleOverride ? _self.styleOverride : styleOverride // ignore: cast_nullable_to_non_nullable
as bool,styleNote: null == styleNote ? _self.styleNote : styleNote // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,referenceImagesJson: null == referenceImagesJson ? _self.referenceImagesJson : referenceImagesJson // ignore: cast_nullable_to_non_nullable
as String,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,imageStatus: null == imageStatus ? _self.imageStatus : imageStatus // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Location].
extension LocationPatterns on Location {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Location value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Location() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Location value)  $default,){
final _that = this;
switch (_that) {
case _Location():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Location value)?  $default,){
final _that = this;
switch (_that) {
case _Location() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _nullableIdFromJson)  String? id, @JsonKey(fromJson: _nullableIdFromJson, name: 'projectId')  String? projectId,  String name,  String time,  String interiorExterior,  String atmosphere,  String colorTone,  String layout,  String style,  bool styleOverride,  String styleNote,  String imageUrl,  String referenceImagesJson,  String taskId,  String imageStatus,  String status,  String source)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Location() when $default != null:
return $default(_that.id,_that.projectId,_that.name,_that.time,_that.interiorExterior,_that.atmosphere,_that.colorTone,_that.layout,_that.style,_that.styleOverride,_that.styleNote,_that.imageUrl,_that.referenceImagesJson,_that.taskId,_that.imageStatus,_that.status,_that.source);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _nullableIdFromJson)  String? id, @JsonKey(fromJson: _nullableIdFromJson, name: 'projectId')  String? projectId,  String name,  String time,  String interiorExterior,  String atmosphere,  String colorTone,  String layout,  String style,  bool styleOverride,  String styleNote,  String imageUrl,  String referenceImagesJson,  String taskId,  String imageStatus,  String status,  String source)  $default,) {final _that = this;
switch (_that) {
case _Location():
return $default(_that.id,_that.projectId,_that.name,_that.time,_that.interiorExterior,_that.atmosphere,_that.colorTone,_that.layout,_that.style,_that.styleOverride,_that.styleNote,_that.imageUrl,_that.referenceImagesJson,_that.taskId,_that.imageStatus,_that.status,_that.source);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: _nullableIdFromJson)  String? id, @JsonKey(fromJson: _nullableIdFromJson, name: 'projectId')  String? projectId,  String name,  String time,  String interiorExterior,  String atmosphere,  String colorTone,  String layout,  String style,  bool styleOverride,  String styleNote,  String imageUrl,  String referenceImagesJson,  String taskId,  String imageStatus,  String status,  String source)?  $default,) {final _that = this;
switch (_that) {
case _Location() when $default != null:
return $default(_that.id,_that.projectId,_that.name,_that.time,_that.interiorExterior,_that.atmosphere,_that.colorTone,_that.layout,_that.style,_that.styleOverride,_that.styleNote,_that.imageUrl,_that.referenceImagesJson,_that.taskId,_that.imageStatus,_that.status,_that.source);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Location extends Location {
  const _Location({@JsonKey(fromJson: _nullableIdFromJson) this.id, @JsonKey(fromJson: _nullableIdFromJson, name: 'projectId') this.projectId, this.name = '', this.time = '', this.interiorExterior = '', this.atmosphere = '', this.colorTone = '', this.layout = '', this.style = '', this.styleOverride = false, this.styleNote = '', this.imageUrl = '', this.referenceImagesJson = '', this.taskId = '', this.imageStatus = 'none', this.status = 'draft', this.source = 'manual'}): super._();
  factory _Location.fromJson(Map<String, dynamic> json) => _$LocationFromJson(json);

@override@JsonKey(fromJson: _nullableIdFromJson) final  String? id;
@override@JsonKey(fromJson: _nullableIdFromJson, name: 'projectId') final  String? projectId;
@override@JsonKey() final  String name;
@override@JsonKey() final  String time;
@override@JsonKey() final  String interiorExterior;
@override@JsonKey() final  String atmosphere;
@override@JsonKey() final  String colorTone;
@override@JsonKey() final  String layout;
@override@JsonKey() final  String style;
@override@JsonKey() final  bool styleOverride;
@override@JsonKey() final  String styleNote;
@override@JsonKey() final  String imageUrl;
@override@JsonKey() final  String referenceImagesJson;
@override@JsonKey() final  String taskId;
@override@JsonKey() final  String imageStatus;
@override@JsonKey() final  String status;
@override@JsonKey() final  String source;

/// Create a copy of Location
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LocationCopyWith<_Location> get copyWith => __$LocationCopyWithImpl<_Location>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LocationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Location&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.name, name) || other.name == name)&&(identical(other.time, time) || other.time == time)&&(identical(other.interiorExterior, interiorExterior) || other.interiorExterior == interiorExterior)&&(identical(other.atmosphere, atmosphere) || other.atmosphere == atmosphere)&&(identical(other.colorTone, colorTone) || other.colorTone == colorTone)&&(identical(other.layout, layout) || other.layout == layout)&&(identical(other.style, style) || other.style == style)&&(identical(other.styleOverride, styleOverride) || other.styleOverride == styleOverride)&&(identical(other.styleNote, styleNote) || other.styleNote == styleNote)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.referenceImagesJson, referenceImagesJson) || other.referenceImagesJson == referenceImagesJson)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.imageStatus, imageStatus) || other.imageStatus == imageStatus)&&(identical(other.status, status) || other.status == status)&&(identical(other.source, source) || other.source == source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,projectId,name,time,interiorExterior,atmosphere,colorTone,layout,style,styleOverride,styleNote,imageUrl,referenceImagesJson,taskId,imageStatus,status,source);

@override
String toString() {
  return 'Location(id: $id, projectId: $projectId, name: $name, time: $time, interiorExterior: $interiorExterior, atmosphere: $atmosphere, colorTone: $colorTone, layout: $layout, style: $style, styleOverride: $styleOverride, styleNote: $styleNote, imageUrl: $imageUrl, referenceImagesJson: $referenceImagesJson, taskId: $taskId, imageStatus: $imageStatus, status: $status, source: $source)';
}


}

/// @nodoc
abstract mixin class _$LocationCopyWith<$Res> implements $LocationCopyWith<$Res> {
  factory _$LocationCopyWith(_Location value, $Res Function(_Location) _then) = __$LocationCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: _nullableIdFromJson) String? id,@JsonKey(fromJson: _nullableIdFromJson, name: 'projectId') String? projectId, String name, String time, String interiorExterior, String atmosphere, String colorTone, String layout, String style, bool styleOverride, String styleNote, String imageUrl, String referenceImagesJson, String taskId, String imageStatus, String status, String source
});




}
/// @nodoc
class __$LocationCopyWithImpl<$Res>
    implements _$LocationCopyWith<$Res> {
  __$LocationCopyWithImpl(this._self, this._then);

  final _Location _self;
  final $Res Function(_Location) _then;

/// Create a copy of Location
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? projectId = freezed,Object? name = null,Object? time = null,Object? interiorExterior = null,Object? atmosphere = null,Object? colorTone = null,Object? layout = null,Object? style = null,Object? styleOverride = null,Object? styleNote = null,Object? imageUrl = null,Object? referenceImagesJson = null,Object? taskId = null,Object? imageStatus = null,Object? status = null,Object? source = null,}) {
  return _then(_Location(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String,interiorExterior: null == interiorExterior ? _self.interiorExterior : interiorExterior // ignore: cast_nullable_to_non_nullable
as String,atmosphere: null == atmosphere ? _self.atmosphere : atmosphere // ignore: cast_nullable_to_non_nullable
as String,colorTone: null == colorTone ? _self.colorTone : colorTone // ignore: cast_nullable_to_non_nullable
as String,layout: null == layout ? _self.layout : layout // ignore: cast_nullable_to_non_nullable
as String,style: null == style ? _self.style : style // ignore: cast_nullable_to_non_nullable
as String,styleOverride: null == styleOverride ? _self.styleOverride : styleOverride // ignore: cast_nullable_to_non_nullable
as bool,styleNote: null == styleNote ? _self.styleNote : styleNote // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,referenceImagesJson: null == referenceImagesJson ? _self.referenceImagesJson : referenceImagesJson // ignore: cast_nullable_to_non_nullable
as String,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,imageStatus: null == imageStatus ? _self.imageStatus : imageStatus // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
