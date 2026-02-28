// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'segment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ScriptSegment {

 int? get id; int? get projectId; int get sortIndex; String get content;
/// Create a copy of ScriptSegment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScriptSegmentCopyWith<ScriptSegment> get copyWith => _$ScriptSegmentCopyWithImpl<ScriptSegment>(this as ScriptSegment, _$identity);

  /// Serializes this ScriptSegment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScriptSegment&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.sortIndex, sortIndex) || other.sortIndex == sortIndex)&&(identical(other.content, content) || other.content == content));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,projectId,sortIndex,content);

@override
String toString() {
  return 'ScriptSegment(id: $id, projectId: $projectId, sortIndex: $sortIndex, content: $content)';
}


}

/// @nodoc
abstract mixin class $ScriptSegmentCopyWith<$Res>  {
  factory $ScriptSegmentCopyWith(ScriptSegment value, $Res Function(ScriptSegment) _then) = _$ScriptSegmentCopyWithImpl;
@useResult
$Res call({
 int? id, int? projectId, int sortIndex, String content
});




}
/// @nodoc
class _$ScriptSegmentCopyWithImpl<$Res>
    implements $ScriptSegmentCopyWith<$Res> {
  _$ScriptSegmentCopyWithImpl(this._self, this._then);

  final ScriptSegment _self;
  final $Res Function(ScriptSegment) _then;

/// Create a copy of ScriptSegment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? projectId = freezed,Object? sortIndex = null,Object? content = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as int?,sortIndex: null == sortIndex ? _self.sortIndex : sortIndex // ignore: cast_nullable_to_non_nullable
as int,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ScriptSegment].
extension ScriptSegmentPatterns on ScriptSegment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScriptSegment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScriptSegment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScriptSegment value)  $default,){
final _that = this;
switch (_that) {
case _ScriptSegment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScriptSegment value)?  $default,){
final _that = this;
switch (_that) {
case _ScriptSegment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  int? projectId,  int sortIndex,  String content)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScriptSegment() when $default != null:
return $default(_that.id,_that.projectId,_that.sortIndex,_that.content);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  int? projectId,  int sortIndex,  String content)  $default,) {final _that = this;
switch (_that) {
case _ScriptSegment():
return $default(_that.id,_that.projectId,_that.sortIndex,_that.content);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  int? projectId,  int sortIndex,  String content)?  $default,) {final _that = this;
switch (_that) {
case _ScriptSegment() when $default != null:
return $default(_that.id,_that.projectId,_that.sortIndex,_that.content);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ScriptSegment implements ScriptSegment {
  const _ScriptSegment({this.id, this.projectId, this.sortIndex = 0, this.content = ''});
  factory _ScriptSegment.fromJson(Map<String, dynamic> json) => _$ScriptSegmentFromJson(json);

@override final  int? id;
@override final  int? projectId;
@override@JsonKey() final  int sortIndex;
@override@JsonKey() final  String content;

/// Create a copy of ScriptSegment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScriptSegmentCopyWith<_ScriptSegment> get copyWith => __$ScriptSegmentCopyWithImpl<_ScriptSegment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScriptSegmentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScriptSegment&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.sortIndex, sortIndex) || other.sortIndex == sortIndex)&&(identical(other.content, content) || other.content == content));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,projectId,sortIndex,content);

@override
String toString() {
  return 'ScriptSegment(id: $id, projectId: $projectId, sortIndex: $sortIndex, content: $content)';
}


}

/// @nodoc
abstract mixin class _$ScriptSegmentCopyWith<$Res> implements $ScriptSegmentCopyWith<$Res> {
  factory _$ScriptSegmentCopyWith(_ScriptSegment value, $Res Function(_ScriptSegment) _then) = __$ScriptSegmentCopyWithImpl;
@override @useResult
$Res call({
 int? id, int? projectId, int sortIndex, String content
});




}
/// @nodoc
class __$ScriptSegmentCopyWithImpl<$Res>
    implements _$ScriptSegmentCopyWith<$Res> {
  __$ScriptSegmentCopyWithImpl(this._self, this._then);

  final _ScriptSegment _self;
  final $Res Function(_ScriptSegment) _then;

/// Create a copy of ScriptSegment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? projectId = freezed,Object? sortIndex = null,Object? content = null,}) {
  return _then(_ScriptSegment(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as int?,sortIndex: null == sortIndex ? _self.sortIndex : sortIndex // ignore: cast_nullable_to_non_nullable
as int,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
