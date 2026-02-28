// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scene_block.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SceneBlock {

 int? get id; int? get sceneId; String get type; String get character; String get emotion; String get content; int get sortIndex;
/// Create a copy of SceneBlock
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SceneBlockCopyWith<SceneBlock> get copyWith => _$SceneBlockCopyWithImpl<SceneBlock>(this as SceneBlock, _$identity);

  /// Serializes this SceneBlock to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SceneBlock&&(identical(other.id, id) || other.id == id)&&(identical(other.sceneId, sceneId) || other.sceneId == sceneId)&&(identical(other.type, type) || other.type == type)&&(identical(other.character, character) || other.character == character)&&(identical(other.emotion, emotion) || other.emotion == emotion)&&(identical(other.content, content) || other.content == content)&&(identical(other.sortIndex, sortIndex) || other.sortIndex == sortIndex));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sceneId,type,character,emotion,content,sortIndex);

@override
String toString() {
  return 'SceneBlock(id: $id, sceneId: $sceneId, type: $type, character: $character, emotion: $emotion, content: $content, sortIndex: $sortIndex)';
}


}

/// @nodoc
abstract mixin class $SceneBlockCopyWith<$Res>  {
  factory $SceneBlockCopyWith(SceneBlock value, $Res Function(SceneBlock) _then) = _$SceneBlockCopyWithImpl;
@useResult
$Res call({
 int? id, int? sceneId, String type, String character, String emotion, String content, int sortIndex
});




}
/// @nodoc
class _$SceneBlockCopyWithImpl<$Res>
    implements $SceneBlockCopyWith<$Res> {
  _$SceneBlockCopyWithImpl(this._self, this._then);

  final SceneBlock _self;
  final $Res Function(SceneBlock) _then;

/// Create a copy of SceneBlock
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? sceneId = freezed,Object? type = null,Object? character = null,Object? emotion = null,Object? content = null,Object? sortIndex = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,sceneId: freezed == sceneId ? _self.sceneId : sceneId // ignore: cast_nullable_to_non_nullable
as int?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,character: null == character ? _self.character : character // ignore: cast_nullable_to_non_nullable
as String,emotion: null == emotion ? _self.emotion : emotion // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,sortIndex: null == sortIndex ? _self.sortIndex : sortIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SceneBlock].
extension SceneBlockPatterns on SceneBlock {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SceneBlock value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SceneBlock() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SceneBlock value)  $default,){
final _that = this;
switch (_that) {
case _SceneBlock():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SceneBlock value)?  $default,){
final _that = this;
switch (_that) {
case _SceneBlock() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  int? sceneId,  String type,  String character,  String emotion,  String content,  int sortIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SceneBlock() when $default != null:
return $default(_that.id,_that.sceneId,_that.type,_that.character,_that.emotion,_that.content,_that.sortIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  int? sceneId,  String type,  String character,  String emotion,  String content,  int sortIndex)  $default,) {final _that = this;
switch (_that) {
case _SceneBlock():
return $default(_that.id,_that.sceneId,_that.type,_that.character,_that.emotion,_that.content,_that.sortIndex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  int? sceneId,  String type,  String character,  String emotion,  String content,  int sortIndex)?  $default,) {final _that = this;
switch (_that) {
case _SceneBlock() when $default != null:
return $default(_that.id,_that.sceneId,_that.type,_that.character,_that.emotion,_that.content,_that.sortIndex);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SceneBlock implements SceneBlock {
  const _SceneBlock({this.id, this.sceneId, this.type = 'action', this.character = '', this.emotion = '', this.content = '', this.sortIndex = 0});
  factory _SceneBlock.fromJson(Map<String, dynamic> json) => _$SceneBlockFromJson(json);

@override final  int? id;
@override final  int? sceneId;
@override@JsonKey() final  String type;
@override@JsonKey() final  String character;
@override@JsonKey() final  String emotion;
@override@JsonKey() final  String content;
@override@JsonKey() final  int sortIndex;

/// Create a copy of SceneBlock
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SceneBlockCopyWith<_SceneBlock> get copyWith => __$SceneBlockCopyWithImpl<_SceneBlock>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SceneBlockToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SceneBlock&&(identical(other.id, id) || other.id == id)&&(identical(other.sceneId, sceneId) || other.sceneId == sceneId)&&(identical(other.type, type) || other.type == type)&&(identical(other.character, character) || other.character == character)&&(identical(other.emotion, emotion) || other.emotion == emotion)&&(identical(other.content, content) || other.content == content)&&(identical(other.sortIndex, sortIndex) || other.sortIndex == sortIndex));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sceneId,type,character,emotion,content,sortIndex);

@override
String toString() {
  return 'SceneBlock(id: $id, sceneId: $sceneId, type: $type, character: $character, emotion: $emotion, content: $content, sortIndex: $sortIndex)';
}


}

/// @nodoc
abstract mixin class _$SceneBlockCopyWith<$Res> implements $SceneBlockCopyWith<$Res> {
  factory _$SceneBlockCopyWith(_SceneBlock value, $Res Function(_SceneBlock) _then) = __$SceneBlockCopyWithImpl;
@override @useResult
$Res call({
 int? id, int? sceneId, String type, String character, String emotion, String content, int sortIndex
});




}
/// @nodoc
class __$SceneBlockCopyWithImpl<$Res>
    implements _$SceneBlockCopyWith<$Res> {
  __$SceneBlockCopyWithImpl(this._self, this._then);

  final _SceneBlock _self;
  final $Res Function(_SceneBlock) _then;

/// Create a copy of SceneBlock
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? sceneId = freezed,Object? type = null,Object? character = null,Object? emotion = null,Object? content = null,Object? sortIndex = null,}) {
  return _then(_SceneBlock(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,sceneId: freezed == sceneId ? _self.sceneId : sceneId // ignore: cast_nullable_to_non_nullable
as int?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,character: null == character ? _self.character : character // ignore: cast_nullable_to_non_nullable
as String,emotion: null == emotion ? _self.emotion : emotion // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,sortIndex: null == sortIndex ? _self.sortIndex : sortIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
