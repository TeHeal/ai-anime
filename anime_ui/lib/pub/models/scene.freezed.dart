// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scene.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Scene {

 String? get id; String? get episodeId; String get sceneId; String get location; String get time; String get interiorExterior; List<String> get characters; int get sortIndex; List<SceneBlock> get blocks;
/// Create a copy of Scene
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SceneCopyWith<Scene> get copyWith => _$SceneCopyWithImpl<Scene>(this as Scene, _$identity);

  /// Serializes this Scene to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Scene&&(identical(other.id, id) || other.id == id)&&(identical(other.episodeId, episodeId) || other.episodeId == episodeId)&&(identical(other.sceneId, sceneId) || other.sceneId == sceneId)&&(identical(other.location, location) || other.location == location)&&(identical(other.time, time) || other.time == time)&&(identical(other.interiorExterior, interiorExterior) || other.interiorExterior == interiorExterior)&&const DeepCollectionEquality().equals(other.characters, characters)&&(identical(other.sortIndex, sortIndex) || other.sortIndex == sortIndex)&&const DeepCollectionEquality().equals(other.blocks, blocks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,episodeId,sceneId,location,time,interiorExterior,const DeepCollectionEquality().hash(characters),sortIndex,const DeepCollectionEquality().hash(blocks));

@override
String toString() {
  return 'Scene(id: $id, episodeId: $episodeId, sceneId: $sceneId, location: $location, time: $time, interiorExterior: $interiorExterior, characters: $characters, sortIndex: $sortIndex, blocks: $blocks)';
}


}

/// @nodoc
abstract mixin class $SceneCopyWith<$Res>  {
  factory $SceneCopyWith(Scene value, $Res Function(Scene) _then) = _$SceneCopyWithImpl;
@useResult
$Res call({
 String? id, String? episodeId, String sceneId, String location, String time, String interiorExterior, List<String> characters, int sortIndex, List<SceneBlock> blocks
});




}
/// @nodoc
class _$SceneCopyWithImpl<$Res>
    implements $SceneCopyWith<$Res> {
  _$SceneCopyWithImpl(this._self, this._then);

  final Scene _self;
  final $Res Function(Scene) _then;

/// Create a copy of Scene
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? episodeId = freezed,Object? sceneId = null,Object? location = null,Object? time = null,Object? interiorExterior = null,Object? characters = null,Object? sortIndex = null,Object? blocks = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,episodeId: freezed == episodeId ? _self.episodeId : episodeId // ignore: cast_nullable_to_non_nullable
as String?,sceneId: null == sceneId ? _self.sceneId : sceneId // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String,interiorExterior: null == interiorExterior ? _self.interiorExterior : interiorExterior // ignore: cast_nullable_to_non_nullable
as String,characters: null == characters ? _self.characters : characters // ignore: cast_nullable_to_non_nullable
as List<String>,sortIndex: null == sortIndex ? _self.sortIndex : sortIndex // ignore: cast_nullable_to_non_nullable
as int,blocks: null == blocks ? _self.blocks : blocks // ignore: cast_nullable_to_non_nullable
as List<SceneBlock>,
  ));
}

}


/// Adds pattern-matching-related methods to [Scene].
extension ScenePatterns on Scene {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Scene value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Scene() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Scene value)  $default,){
final _that = this;
switch (_that) {
case _Scene():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Scene value)?  $default,){
final _that = this;
switch (_that) {
case _Scene() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String? episodeId,  String sceneId,  String location,  String time,  String interiorExterior,  List<String> characters,  int sortIndex,  List<SceneBlock> blocks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Scene() when $default != null:
return $default(_that.id,_that.episodeId,_that.sceneId,_that.location,_that.time,_that.interiorExterior,_that.characters,_that.sortIndex,_that.blocks);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String? episodeId,  String sceneId,  String location,  String time,  String interiorExterior,  List<String> characters,  int sortIndex,  List<SceneBlock> blocks)  $default,) {final _that = this;
switch (_that) {
case _Scene():
return $default(_that.id,_that.episodeId,_that.sceneId,_that.location,_that.time,_that.interiorExterior,_that.characters,_that.sortIndex,_that.blocks);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String? episodeId,  String sceneId,  String location,  String time,  String interiorExterior,  List<String> characters,  int sortIndex,  List<SceneBlock> blocks)?  $default,) {final _that = this;
switch (_that) {
case _Scene() when $default != null:
return $default(_that.id,_that.episodeId,_that.sceneId,_that.location,_that.time,_that.interiorExterior,_that.characters,_that.sortIndex,_that.blocks);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Scene implements Scene {
  const _Scene({this.id, this.episodeId, this.sceneId = '', this.location = '', this.time = '', this.interiorExterior = '', final  List<String> characters = const [], this.sortIndex = 0, final  List<SceneBlock> blocks = const []}): _characters = characters,_blocks = blocks;
  factory _Scene.fromJson(Map<String, dynamic> json) => _$SceneFromJson(json);

@override final  String? id;
@override final  String? episodeId;
@override@JsonKey() final  String sceneId;
@override@JsonKey() final  String location;
@override@JsonKey() final  String time;
@override@JsonKey() final  String interiorExterior;
 final  List<String> _characters;
@override@JsonKey() List<String> get characters {
  if (_characters is EqualUnmodifiableListView) return _characters;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_characters);
}

@override@JsonKey() final  int sortIndex;
 final  List<SceneBlock> _blocks;
@override@JsonKey() List<SceneBlock> get blocks {
  if (_blocks is EqualUnmodifiableListView) return _blocks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_blocks);
}


/// Create a copy of Scene
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SceneCopyWith<_Scene> get copyWith => __$SceneCopyWithImpl<_Scene>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SceneToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Scene&&(identical(other.id, id) || other.id == id)&&(identical(other.episodeId, episodeId) || other.episodeId == episodeId)&&(identical(other.sceneId, sceneId) || other.sceneId == sceneId)&&(identical(other.location, location) || other.location == location)&&(identical(other.time, time) || other.time == time)&&(identical(other.interiorExterior, interiorExterior) || other.interiorExterior == interiorExterior)&&const DeepCollectionEquality().equals(other._characters, _characters)&&(identical(other.sortIndex, sortIndex) || other.sortIndex == sortIndex)&&const DeepCollectionEquality().equals(other._blocks, _blocks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,episodeId,sceneId,location,time,interiorExterior,const DeepCollectionEquality().hash(_characters),sortIndex,const DeepCollectionEquality().hash(_blocks));

@override
String toString() {
  return 'Scene(id: $id, episodeId: $episodeId, sceneId: $sceneId, location: $location, time: $time, interiorExterior: $interiorExterior, characters: $characters, sortIndex: $sortIndex, blocks: $blocks)';
}


}

/// @nodoc
abstract mixin class _$SceneCopyWith<$Res> implements $SceneCopyWith<$Res> {
  factory _$SceneCopyWith(_Scene value, $Res Function(_Scene) _then) = __$SceneCopyWithImpl;
@override @useResult
$Res call({
 String? id, String? episodeId, String sceneId, String location, String time, String interiorExterior, List<String> characters, int sortIndex, List<SceneBlock> blocks
});




}
/// @nodoc
class __$SceneCopyWithImpl<$Res>
    implements _$SceneCopyWith<$Res> {
  __$SceneCopyWithImpl(this._self, this._then);

  final _Scene _self;
  final $Res Function(_Scene) _then;

/// Create a copy of Scene
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? episodeId = freezed,Object? sceneId = null,Object? location = null,Object? time = null,Object? interiorExterior = null,Object? characters = null,Object? sortIndex = null,Object? blocks = null,}) {
  return _then(_Scene(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,episodeId: freezed == episodeId ? _self.episodeId : episodeId // ignore: cast_nullable_to_non_nullable
as String?,sceneId: null == sceneId ? _self.sceneId : sceneId // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String,interiorExterior: null == interiorExterior ? _self.interiorExterior : interiorExterior // ignore: cast_nullable_to_non_nullable
as String,characters: null == characters ? _self._characters : characters // ignore: cast_nullable_to_non_nullable
as List<String>,sortIndex: null == sortIndex ? _self.sortIndex : sortIndex // ignore: cast_nullable_to_non_nullable
as int,blocks: null == blocks ? _self._blocks : blocks // ignore: cast_nullable_to_non_nullable
as List<SceneBlock>,
  ));
}


}

// dart format on
