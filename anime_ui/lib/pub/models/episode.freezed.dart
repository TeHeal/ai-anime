// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'episode.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Episode {

 int? get id; int? get projectId; String get title; int get sortIndex; String get summary; String get status; int get currentStep; DateTime? get lastActiveAt; List<Scene> get scenes;
/// Create a copy of Episode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EpisodeCopyWith<Episode> get copyWith => _$EpisodeCopyWithImpl<Episode>(this as Episode, _$identity);

  /// Serializes this Episode to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Episode&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.title, title) || other.title == title)&&(identical(other.sortIndex, sortIndex) || other.sortIndex == sortIndex)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.status, status) || other.status == status)&&(identical(other.currentStep, currentStep) || other.currentStep == currentStep)&&(identical(other.lastActiveAt, lastActiveAt) || other.lastActiveAt == lastActiveAt)&&const DeepCollectionEquality().equals(other.scenes, scenes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,projectId,title,sortIndex,summary,status,currentStep,lastActiveAt,const DeepCollectionEquality().hash(scenes));

@override
String toString() {
  return 'Episode(id: $id, projectId: $projectId, title: $title, sortIndex: $sortIndex, summary: $summary, status: $status, currentStep: $currentStep, lastActiveAt: $lastActiveAt, scenes: $scenes)';
}


}

/// @nodoc
abstract mixin class $EpisodeCopyWith<$Res>  {
  factory $EpisodeCopyWith(Episode value, $Res Function(Episode) _then) = _$EpisodeCopyWithImpl;
@useResult
$Res call({
 int? id, int? projectId, String title, int sortIndex, String summary, String status, int currentStep, DateTime? lastActiveAt, List<Scene> scenes
});




}
/// @nodoc
class _$EpisodeCopyWithImpl<$Res>
    implements $EpisodeCopyWith<$Res> {
  _$EpisodeCopyWithImpl(this._self, this._then);

  final Episode _self;
  final $Res Function(Episode) _then;

/// Create a copy of Episode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? projectId = freezed,Object? title = null,Object? sortIndex = null,Object? summary = null,Object? status = null,Object? currentStep = null,Object? lastActiveAt = freezed,Object? scenes = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as int?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,sortIndex: null == sortIndex ? _self.sortIndex : sortIndex // ignore: cast_nullable_to_non_nullable
as int,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,currentStep: null == currentStep ? _self.currentStep : currentStep // ignore: cast_nullable_to_non_nullable
as int,lastActiveAt: freezed == lastActiveAt ? _self.lastActiveAt : lastActiveAt // ignore: cast_nullable_to_non_nullable
as DateTime?,scenes: null == scenes ? _self.scenes : scenes // ignore: cast_nullable_to_non_nullable
as List<Scene>,
  ));
}

}


/// Adds pattern-matching-related methods to [Episode].
extension EpisodePatterns on Episode {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Episode value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Episode() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Episode value)  $default,){
final _that = this;
switch (_that) {
case _Episode():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Episode value)?  $default,){
final _that = this;
switch (_that) {
case _Episode() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  int? projectId,  String title,  int sortIndex,  String summary,  String status,  int currentStep,  DateTime? lastActiveAt,  List<Scene> scenes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Episode() when $default != null:
return $default(_that.id,_that.projectId,_that.title,_that.sortIndex,_that.summary,_that.status,_that.currentStep,_that.lastActiveAt,_that.scenes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  int? projectId,  String title,  int sortIndex,  String summary,  String status,  int currentStep,  DateTime? lastActiveAt,  List<Scene> scenes)  $default,) {final _that = this;
switch (_that) {
case _Episode():
return $default(_that.id,_that.projectId,_that.title,_that.sortIndex,_that.summary,_that.status,_that.currentStep,_that.lastActiveAt,_that.scenes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  int? projectId,  String title,  int sortIndex,  String summary,  String status,  int currentStep,  DateTime? lastActiveAt,  List<Scene> scenes)?  $default,) {final _that = this;
switch (_that) {
case _Episode() when $default != null:
return $default(_that.id,_that.projectId,_that.title,_that.sortIndex,_that.summary,_that.status,_that.currentStep,_that.lastActiveAt,_that.scenes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Episode implements Episode {
  const _Episode({this.id, this.projectId, this.title = '', this.sortIndex = 0, this.summary = '', this.status = 'not_started', this.currentStep = 0, this.lastActiveAt, final  List<Scene> scenes = const []}): _scenes = scenes;
  factory _Episode.fromJson(Map<String, dynamic> json) => _$EpisodeFromJson(json);

@override final  int? id;
@override final  int? projectId;
@override@JsonKey() final  String title;
@override@JsonKey() final  int sortIndex;
@override@JsonKey() final  String summary;
@override@JsonKey() final  String status;
@override@JsonKey() final  int currentStep;
@override final  DateTime? lastActiveAt;
 final  List<Scene> _scenes;
@override@JsonKey() List<Scene> get scenes {
  if (_scenes is EqualUnmodifiableListView) return _scenes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_scenes);
}


/// Create a copy of Episode
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EpisodeCopyWith<_Episode> get copyWith => __$EpisodeCopyWithImpl<_Episode>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EpisodeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Episode&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.title, title) || other.title == title)&&(identical(other.sortIndex, sortIndex) || other.sortIndex == sortIndex)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.status, status) || other.status == status)&&(identical(other.currentStep, currentStep) || other.currentStep == currentStep)&&(identical(other.lastActiveAt, lastActiveAt) || other.lastActiveAt == lastActiveAt)&&const DeepCollectionEquality().equals(other._scenes, _scenes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,projectId,title,sortIndex,summary,status,currentStep,lastActiveAt,const DeepCollectionEquality().hash(_scenes));

@override
String toString() {
  return 'Episode(id: $id, projectId: $projectId, title: $title, sortIndex: $sortIndex, summary: $summary, status: $status, currentStep: $currentStep, lastActiveAt: $lastActiveAt, scenes: $scenes)';
}


}

/// @nodoc
abstract mixin class _$EpisodeCopyWith<$Res> implements $EpisodeCopyWith<$Res> {
  factory _$EpisodeCopyWith(_Episode value, $Res Function(_Episode) _then) = __$EpisodeCopyWithImpl;
@override @useResult
$Res call({
 int? id, int? projectId, String title, int sortIndex, String summary, String status, int currentStep, DateTime? lastActiveAt, List<Scene> scenes
});




}
/// @nodoc
class __$EpisodeCopyWithImpl<$Res>
    implements _$EpisodeCopyWith<$Res> {
  __$EpisodeCopyWithImpl(this._self, this._then);

  final _Episode _self;
  final $Res Function(_Episode) _then;

/// Create a copy of Episode
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? projectId = freezed,Object? title = null,Object? sortIndex = null,Object? summary = null,Object? status = null,Object? currentStep = null,Object? lastActiveAt = freezed,Object? scenes = null,}) {
  return _then(_Episode(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as int?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,sortIndex: null == sortIndex ? _self.sortIndex : sortIndex // ignore: cast_nullable_to_non_nullable
as int,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,currentStep: null == currentStep ? _self.currentStep : currentStep // ignore: cast_nullable_to_non_nullable
as int,lastActiveAt: freezed == lastActiveAt ? _self.lastActiveAt : lastActiveAt // ignore: cast_nullable_to_non_nullable
as DateTime?,scenes: null == scenes ? _self._scenes : scenes // ignore: cast_nullable_to_non_nullable
as List<Scene>,
  ));
}


}

// dart format on
