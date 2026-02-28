// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'episode_progress.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EpisodeProgress {

 String? get id; String get episodeId; String get projectId; bool get storyDone; bool get assetsDone; bool get scriptDone; bool get storyboardDone; bool get shotsDone; bool get episodeDone; int get storyPct; int get assetsPct; int get scriptPct; int get storyboardPct; int get shotsPct; int get episodePct; int get currentStep; String get currentPhase; int get overallPct;
/// Create a copy of EpisodeProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EpisodeProgressCopyWith<EpisodeProgress> get copyWith => _$EpisodeProgressCopyWithImpl<EpisodeProgress>(this as EpisodeProgress, _$identity);

  /// Serializes this EpisodeProgress to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EpisodeProgress&&(identical(other.id, id) || other.id == id)&&(identical(other.episodeId, episodeId) || other.episodeId == episodeId)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.storyDone, storyDone) || other.storyDone == storyDone)&&(identical(other.assetsDone, assetsDone) || other.assetsDone == assetsDone)&&(identical(other.scriptDone, scriptDone) || other.scriptDone == scriptDone)&&(identical(other.storyboardDone, storyboardDone) || other.storyboardDone == storyboardDone)&&(identical(other.shotsDone, shotsDone) || other.shotsDone == shotsDone)&&(identical(other.episodeDone, episodeDone) || other.episodeDone == episodeDone)&&(identical(other.storyPct, storyPct) || other.storyPct == storyPct)&&(identical(other.assetsPct, assetsPct) || other.assetsPct == assetsPct)&&(identical(other.scriptPct, scriptPct) || other.scriptPct == scriptPct)&&(identical(other.storyboardPct, storyboardPct) || other.storyboardPct == storyboardPct)&&(identical(other.shotsPct, shotsPct) || other.shotsPct == shotsPct)&&(identical(other.episodePct, episodePct) || other.episodePct == episodePct)&&(identical(other.currentStep, currentStep) || other.currentStep == currentStep)&&(identical(other.currentPhase, currentPhase) || other.currentPhase == currentPhase)&&(identical(other.overallPct, overallPct) || other.overallPct == overallPct));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,episodeId,projectId,storyDone,assetsDone,scriptDone,storyboardDone,shotsDone,episodeDone,storyPct,assetsPct,scriptPct,storyboardPct,shotsPct,episodePct,currentStep,currentPhase,overallPct);

@override
String toString() {
  return 'EpisodeProgress(id: $id, episodeId: $episodeId, projectId: $projectId, storyDone: $storyDone, assetsDone: $assetsDone, scriptDone: $scriptDone, storyboardDone: $storyboardDone, shotsDone: $shotsDone, episodeDone: $episodeDone, storyPct: $storyPct, assetsPct: $assetsPct, scriptPct: $scriptPct, storyboardPct: $storyboardPct, shotsPct: $shotsPct, episodePct: $episodePct, currentStep: $currentStep, currentPhase: $currentPhase, overallPct: $overallPct)';
}


}

/// @nodoc
abstract mixin class $EpisodeProgressCopyWith<$Res>  {
  factory $EpisodeProgressCopyWith(EpisodeProgress value, $Res Function(EpisodeProgress) _then) = _$EpisodeProgressCopyWithImpl;
@useResult
$Res call({
 String? id, String episodeId, String projectId, bool storyDone, bool assetsDone, bool scriptDone, bool storyboardDone, bool shotsDone, bool episodeDone, int storyPct, int assetsPct, int scriptPct, int storyboardPct, int shotsPct, int episodePct, int currentStep, String currentPhase, int overallPct
});




}
/// @nodoc
class _$EpisodeProgressCopyWithImpl<$Res>
    implements $EpisodeProgressCopyWith<$Res> {
  _$EpisodeProgressCopyWithImpl(this._self, this._then);

  final EpisodeProgress _self;
  final $Res Function(EpisodeProgress) _then;

/// Create a copy of EpisodeProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? episodeId = null,Object? projectId = null,Object? storyDone = null,Object? assetsDone = null,Object? scriptDone = null,Object? storyboardDone = null,Object? shotsDone = null,Object? episodeDone = null,Object? storyPct = null,Object? assetsPct = null,Object? scriptPct = null,Object? storyboardPct = null,Object? shotsPct = null,Object? episodePct = null,Object? currentStep = null,Object? currentPhase = null,Object? overallPct = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,episodeId: null == episodeId ? _self.episodeId : episodeId // ignore: cast_nullable_to_non_nullable
as String,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,storyDone: null == storyDone ? _self.storyDone : storyDone // ignore: cast_nullable_to_non_nullable
as bool,assetsDone: null == assetsDone ? _self.assetsDone : assetsDone // ignore: cast_nullable_to_non_nullable
as bool,scriptDone: null == scriptDone ? _self.scriptDone : scriptDone // ignore: cast_nullable_to_non_nullable
as bool,storyboardDone: null == storyboardDone ? _self.storyboardDone : storyboardDone // ignore: cast_nullable_to_non_nullable
as bool,shotsDone: null == shotsDone ? _self.shotsDone : shotsDone // ignore: cast_nullable_to_non_nullable
as bool,episodeDone: null == episodeDone ? _self.episodeDone : episodeDone // ignore: cast_nullable_to_non_nullable
as bool,storyPct: null == storyPct ? _self.storyPct : storyPct // ignore: cast_nullable_to_non_nullable
as int,assetsPct: null == assetsPct ? _self.assetsPct : assetsPct // ignore: cast_nullable_to_non_nullable
as int,scriptPct: null == scriptPct ? _self.scriptPct : scriptPct // ignore: cast_nullable_to_non_nullable
as int,storyboardPct: null == storyboardPct ? _self.storyboardPct : storyboardPct // ignore: cast_nullable_to_non_nullable
as int,shotsPct: null == shotsPct ? _self.shotsPct : shotsPct // ignore: cast_nullable_to_non_nullable
as int,episodePct: null == episodePct ? _self.episodePct : episodePct // ignore: cast_nullable_to_non_nullable
as int,currentStep: null == currentStep ? _self.currentStep : currentStep // ignore: cast_nullable_to_non_nullable
as int,currentPhase: null == currentPhase ? _self.currentPhase : currentPhase // ignore: cast_nullable_to_non_nullable
as String,overallPct: null == overallPct ? _self.overallPct : overallPct // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [EpisodeProgress].
extension EpisodeProgressPatterns on EpisodeProgress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EpisodeProgress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EpisodeProgress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EpisodeProgress value)  $default,){
final _that = this;
switch (_that) {
case _EpisodeProgress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EpisodeProgress value)?  $default,){
final _that = this;
switch (_that) {
case _EpisodeProgress() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String episodeId,  String projectId,  bool storyDone,  bool assetsDone,  bool scriptDone,  bool storyboardDone,  bool shotsDone,  bool episodeDone,  int storyPct,  int assetsPct,  int scriptPct,  int storyboardPct,  int shotsPct,  int episodePct,  int currentStep,  String currentPhase,  int overallPct)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EpisodeProgress() when $default != null:
return $default(_that.id,_that.episodeId,_that.projectId,_that.storyDone,_that.assetsDone,_that.scriptDone,_that.storyboardDone,_that.shotsDone,_that.episodeDone,_that.storyPct,_that.assetsPct,_that.scriptPct,_that.storyboardPct,_that.shotsPct,_that.episodePct,_that.currentStep,_that.currentPhase,_that.overallPct);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String episodeId,  String projectId,  bool storyDone,  bool assetsDone,  bool scriptDone,  bool storyboardDone,  bool shotsDone,  bool episodeDone,  int storyPct,  int assetsPct,  int scriptPct,  int storyboardPct,  int shotsPct,  int episodePct,  int currentStep,  String currentPhase,  int overallPct)  $default,) {final _that = this;
switch (_that) {
case _EpisodeProgress():
return $default(_that.id,_that.episodeId,_that.projectId,_that.storyDone,_that.assetsDone,_that.scriptDone,_that.storyboardDone,_that.shotsDone,_that.episodeDone,_that.storyPct,_that.assetsPct,_that.scriptPct,_that.storyboardPct,_that.shotsPct,_that.episodePct,_that.currentStep,_that.currentPhase,_that.overallPct);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String episodeId,  String projectId,  bool storyDone,  bool assetsDone,  bool scriptDone,  bool storyboardDone,  bool shotsDone,  bool episodeDone,  int storyPct,  int assetsPct,  int scriptPct,  int storyboardPct,  int shotsPct,  int episodePct,  int currentStep,  String currentPhase,  int overallPct)?  $default,) {final _that = this;
switch (_that) {
case _EpisodeProgress() when $default != null:
return $default(_that.id,_that.episodeId,_that.projectId,_that.storyDone,_that.assetsDone,_that.scriptDone,_that.storyboardDone,_that.shotsDone,_that.episodeDone,_that.storyPct,_that.assetsPct,_that.scriptPct,_that.storyboardPct,_that.shotsPct,_that.episodePct,_that.currentStep,_that.currentPhase,_that.overallPct);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EpisodeProgress implements EpisodeProgress {
  const _EpisodeProgress({this.id, this.episodeId = '', this.projectId = '', this.storyDone = false, this.assetsDone = false, this.scriptDone = false, this.storyboardDone = false, this.shotsDone = false, this.episodeDone = false, this.storyPct = 0, this.assetsPct = 0, this.scriptPct = 0, this.storyboardPct = 0, this.shotsPct = 0, this.episodePct = 0, this.currentStep = 0, this.currentPhase = 'story', this.overallPct = 0});
  factory _EpisodeProgress.fromJson(Map<String, dynamic> json) => _$EpisodeProgressFromJson(json);

@override final  String? id;
@override@JsonKey() final  String episodeId;
@override@JsonKey() final  String projectId;
@override@JsonKey() final  bool storyDone;
@override@JsonKey() final  bool assetsDone;
@override@JsonKey() final  bool scriptDone;
@override@JsonKey() final  bool storyboardDone;
@override@JsonKey() final  bool shotsDone;
@override@JsonKey() final  bool episodeDone;
@override@JsonKey() final  int storyPct;
@override@JsonKey() final  int assetsPct;
@override@JsonKey() final  int scriptPct;
@override@JsonKey() final  int storyboardPct;
@override@JsonKey() final  int shotsPct;
@override@JsonKey() final  int episodePct;
@override@JsonKey() final  int currentStep;
@override@JsonKey() final  String currentPhase;
@override@JsonKey() final  int overallPct;

/// Create a copy of EpisodeProgress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EpisodeProgressCopyWith<_EpisodeProgress> get copyWith => __$EpisodeProgressCopyWithImpl<_EpisodeProgress>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EpisodeProgressToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EpisodeProgress&&(identical(other.id, id) || other.id == id)&&(identical(other.episodeId, episodeId) || other.episodeId == episodeId)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.storyDone, storyDone) || other.storyDone == storyDone)&&(identical(other.assetsDone, assetsDone) || other.assetsDone == assetsDone)&&(identical(other.scriptDone, scriptDone) || other.scriptDone == scriptDone)&&(identical(other.storyboardDone, storyboardDone) || other.storyboardDone == storyboardDone)&&(identical(other.shotsDone, shotsDone) || other.shotsDone == shotsDone)&&(identical(other.episodeDone, episodeDone) || other.episodeDone == episodeDone)&&(identical(other.storyPct, storyPct) || other.storyPct == storyPct)&&(identical(other.assetsPct, assetsPct) || other.assetsPct == assetsPct)&&(identical(other.scriptPct, scriptPct) || other.scriptPct == scriptPct)&&(identical(other.storyboardPct, storyboardPct) || other.storyboardPct == storyboardPct)&&(identical(other.shotsPct, shotsPct) || other.shotsPct == shotsPct)&&(identical(other.episodePct, episodePct) || other.episodePct == episodePct)&&(identical(other.currentStep, currentStep) || other.currentStep == currentStep)&&(identical(other.currentPhase, currentPhase) || other.currentPhase == currentPhase)&&(identical(other.overallPct, overallPct) || other.overallPct == overallPct));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,episodeId,projectId,storyDone,assetsDone,scriptDone,storyboardDone,shotsDone,episodeDone,storyPct,assetsPct,scriptPct,storyboardPct,shotsPct,episodePct,currentStep,currentPhase,overallPct);

@override
String toString() {
  return 'EpisodeProgress(id: $id, episodeId: $episodeId, projectId: $projectId, storyDone: $storyDone, assetsDone: $assetsDone, scriptDone: $scriptDone, storyboardDone: $storyboardDone, shotsDone: $shotsDone, episodeDone: $episodeDone, storyPct: $storyPct, assetsPct: $assetsPct, scriptPct: $scriptPct, storyboardPct: $storyboardPct, shotsPct: $shotsPct, episodePct: $episodePct, currentStep: $currentStep, currentPhase: $currentPhase, overallPct: $overallPct)';
}


}

/// @nodoc
abstract mixin class _$EpisodeProgressCopyWith<$Res> implements $EpisodeProgressCopyWith<$Res> {
  factory _$EpisodeProgressCopyWith(_EpisodeProgress value, $Res Function(_EpisodeProgress) _then) = __$EpisodeProgressCopyWithImpl;
@override @useResult
$Res call({
 String? id, String episodeId, String projectId, bool storyDone, bool assetsDone, bool scriptDone, bool storyboardDone, bool shotsDone, bool episodeDone, int storyPct, int assetsPct, int scriptPct, int storyboardPct, int shotsPct, int episodePct, int currentStep, String currentPhase, int overallPct
});




}
/// @nodoc
class __$EpisodeProgressCopyWithImpl<$Res>
    implements _$EpisodeProgressCopyWith<$Res> {
  __$EpisodeProgressCopyWithImpl(this._self, this._then);

  final _EpisodeProgress _self;
  final $Res Function(_EpisodeProgress) _then;

/// Create a copy of EpisodeProgress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? episodeId = null,Object? projectId = null,Object? storyDone = null,Object? assetsDone = null,Object? scriptDone = null,Object? storyboardDone = null,Object? shotsDone = null,Object? episodeDone = null,Object? storyPct = null,Object? assetsPct = null,Object? scriptPct = null,Object? storyboardPct = null,Object? shotsPct = null,Object? episodePct = null,Object? currentStep = null,Object? currentPhase = null,Object? overallPct = null,}) {
  return _then(_EpisodeProgress(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,episodeId: null == episodeId ? _self.episodeId : episodeId // ignore: cast_nullable_to_non_nullable
as String,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,storyDone: null == storyDone ? _self.storyDone : storyDone // ignore: cast_nullable_to_non_nullable
as bool,assetsDone: null == assetsDone ? _self.assetsDone : assetsDone // ignore: cast_nullable_to_non_nullable
as bool,scriptDone: null == scriptDone ? _self.scriptDone : scriptDone // ignore: cast_nullable_to_non_nullable
as bool,storyboardDone: null == storyboardDone ? _self.storyboardDone : storyboardDone // ignore: cast_nullable_to_non_nullable
as bool,shotsDone: null == shotsDone ? _self.shotsDone : shotsDone // ignore: cast_nullable_to_non_nullable
as bool,episodeDone: null == episodeDone ? _self.episodeDone : episodeDone // ignore: cast_nullable_to_non_nullable
as bool,storyPct: null == storyPct ? _self.storyPct : storyPct // ignore: cast_nullable_to_non_nullable
as int,assetsPct: null == assetsPct ? _self.assetsPct : assetsPct // ignore: cast_nullable_to_non_nullable
as int,scriptPct: null == scriptPct ? _self.scriptPct : scriptPct // ignore: cast_nullable_to_non_nullable
as int,storyboardPct: null == storyboardPct ? _self.storyboardPct : storyboardPct // ignore: cast_nullable_to_non_nullable
as int,shotsPct: null == shotsPct ? _self.shotsPct : shotsPct // ignore: cast_nullable_to_non_nullable
as int,episodePct: null == episodePct ? _self.episodePct : episodePct // ignore: cast_nullable_to_non_nullable
as int,currentStep: null == currentStep ? _self.currentStep : currentStep // ignore: cast_nullable_to_non_nullable
as int,currentPhase: null == currentPhase ? _self.currentPhase : currentPhase // ignore: cast_nullable_to_non_nullable
as String,overallPct: null == overallPct ? _self.overallPct : overallPct // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
