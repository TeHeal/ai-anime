// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StoryboardShot {

 int? get id; int? get projectId; int? get segmentId; int? get sceneId; int get sortIndex; String get prompt; String get stylePrompt; String get imageUrl; String get videoUrl; String get taskId; String get status; int get duration; String? get cameraType; String? get cameraAngle; String? get dialogue; String? get voice; String get lipSync; String? get characterName; int? get characterId; String? get emotion; String? get voiceName; String? get transition; String? get audioDesign; String? get priority; String? get negativePrompt; String get reviewStatus; String? get reviewComment;
/// Create a copy of StoryboardShot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StoryboardShotCopyWith<StoryboardShot> get copyWith => _$StoryboardShotCopyWithImpl<StoryboardShot>(this as StoryboardShot, _$identity);

  /// Serializes this StoryboardShot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StoryboardShot&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.segmentId, segmentId) || other.segmentId == segmentId)&&(identical(other.sceneId, sceneId) || other.sceneId == sceneId)&&(identical(other.sortIndex, sortIndex) || other.sortIndex == sortIndex)&&(identical(other.prompt, prompt) || other.prompt == prompt)&&(identical(other.stylePrompt, stylePrompt) || other.stylePrompt == stylePrompt)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.videoUrl, videoUrl) || other.videoUrl == videoUrl)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.status, status) || other.status == status)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.cameraType, cameraType) || other.cameraType == cameraType)&&(identical(other.cameraAngle, cameraAngle) || other.cameraAngle == cameraAngle)&&(identical(other.dialogue, dialogue) || other.dialogue == dialogue)&&(identical(other.voice, voice) || other.voice == voice)&&(identical(other.lipSync, lipSync) || other.lipSync == lipSync)&&(identical(other.characterName, characterName) || other.characterName == characterName)&&(identical(other.characterId, characterId) || other.characterId == characterId)&&(identical(other.emotion, emotion) || other.emotion == emotion)&&(identical(other.voiceName, voiceName) || other.voiceName == voiceName)&&(identical(other.transition, transition) || other.transition == transition)&&(identical(other.audioDesign, audioDesign) || other.audioDesign == audioDesign)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.negativePrompt, negativePrompt) || other.negativePrompt == negativePrompt)&&(identical(other.reviewStatus, reviewStatus) || other.reviewStatus == reviewStatus)&&(identical(other.reviewComment, reviewComment) || other.reviewComment == reviewComment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,projectId,segmentId,sceneId,sortIndex,prompt,stylePrompt,imageUrl,videoUrl,taskId,status,duration,cameraType,cameraAngle,dialogue,voice,lipSync,characterName,characterId,emotion,voiceName,transition,audioDesign,priority,negativePrompt,reviewStatus,reviewComment]);

@override
String toString() {
  return 'StoryboardShot(id: $id, projectId: $projectId, segmentId: $segmentId, sceneId: $sceneId, sortIndex: $sortIndex, prompt: $prompt, stylePrompt: $stylePrompt, imageUrl: $imageUrl, videoUrl: $videoUrl, taskId: $taskId, status: $status, duration: $duration, cameraType: $cameraType, cameraAngle: $cameraAngle, dialogue: $dialogue, voice: $voice, lipSync: $lipSync, characterName: $characterName, characterId: $characterId, emotion: $emotion, voiceName: $voiceName, transition: $transition, audioDesign: $audioDesign, priority: $priority, negativePrompt: $negativePrompt, reviewStatus: $reviewStatus, reviewComment: $reviewComment)';
}


}

/// @nodoc
abstract mixin class $StoryboardShotCopyWith<$Res>  {
  factory $StoryboardShotCopyWith(StoryboardShot value, $Res Function(StoryboardShot) _then) = _$StoryboardShotCopyWithImpl;
@useResult
$Res call({
 int? id, int? projectId, int? segmentId, int? sceneId, int sortIndex, String prompt, String stylePrompt, String imageUrl, String videoUrl, String taskId, String status, int duration, String? cameraType, String? cameraAngle, String? dialogue, String? voice, String lipSync, String? characterName, int? characterId, String? emotion, String? voiceName, String? transition, String? audioDesign, String? priority, String? negativePrompt, String reviewStatus, String? reviewComment
});




}
/// @nodoc
class _$StoryboardShotCopyWithImpl<$Res>
    implements $StoryboardShotCopyWith<$Res> {
  _$StoryboardShotCopyWithImpl(this._self, this._then);

  final StoryboardShot _self;
  final $Res Function(StoryboardShot) _then;

/// Create a copy of StoryboardShot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? projectId = freezed,Object? segmentId = freezed,Object? sceneId = freezed,Object? sortIndex = null,Object? prompt = null,Object? stylePrompt = null,Object? imageUrl = null,Object? videoUrl = null,Object? taskId = null,Object? status = null,Object? duration = null,Object? cameraType = freezed,Object? cameraAngle = freezed,Object? dialogue = freezed,Object? voice = freezed,Object? lipSync = null,Object? characterName = freezed,Object? characterId = freezed,Object? emotion = freezed,Object? voiceName = freezed,Object? transition = freezed,Object? audioDesign = freezed,Object? priority = freezed,Object? negativePrompt = freezed,Object? reviewStatus = null,Object? reviewComment = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as int?,segmentId: freezed == segmentId ? _self.segmentId : segmentId // ignore: cast_nullable_to_non_nullable
as int?,sceneId: freezed == sceneId ? _self.sceneId : sceneId // ignore: cast_nullable_to_non_nullable
as int?,sortIndex: null == sortIndex ? _self.sortIndex : sortIndex // ignore: cast_nullable_to_non_nullable
as int,prompt: null == prompt ? _self.prompt : prompt // ignore: cast_nullable_to_non_nullable
as String,stylePrompt: null == stylePrompt ? _self.stylePrompt : stylePrompt // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,videoUrl: null == videoUrl ? _self.videoUrl : videoUrl // ignore: cast_nullable_to_non_nullable
as String,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,cameraType: freezed == cameraType ? _self.cameraType : cameraType // ignore: cast_nullable_to_non_nullable
as String?,cameraAngle: freezed == cameraAngle ? _self.cameraAngle : cameraAngle // ignore: cast_nullable_to_non_nullable
as String?,dialogue: freezed == dialogue ? _self.dialogue : dialogue // ignore: cast_nullable_to_non_nullable
as String?,voice: freezed == voice ? _self.voice : voice // ignore: cast_nullable_to_non_nullable
as String?,lipSync: null == lipSync ? _self.lipSync : lipSync // ignore: cast_nullable_to_non_nullable
as String,characterName: freezed == characterName ? _self.characterName : characterName // ignore: cast_nullable_to_non_nullable
as String?,characterId: freezed == characterId ? _self.characterId : characterId // ignore: cast_nullable_to_non_nullable
as int?,emotion: freezed == emotion ? _self.emotion : emotion // ignore: cast_nullable_to_non_nullable
as String?,voiceName: freezed == voiceName ? _self.voiceName : voiceName // ignore: cast_nullable_to_non_nullable
as String?,transition: freezed == transition ? _self.transition : transition // ignore: cast_nullable_to_non_nullable
as String?,audioDesign: freezed == audioDesign ? _self.audioDesign : audioDesign // ignore: cast_nullable_to_non_nullable
as String?,priority: freezed == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as String?,negativePrompt: freezed == negativePrompt ? _self.negativePrompt : negativePrompt // ignore: cast_nullable_to_non_nullable
as String?,reviewStatus: null == reviewStatus ? _self.reviewStatus : reviewStatus // ignore: cast_nullable_to_non_nullable
as String,reviewComment: freezed == reviewComment ? _self.reviewComment : reviewComment // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [StoryboardShot].
extension StoryboardShotPatterns on StoryboardShot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StoryboardShot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StoryboardShot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StoryboardShot value)  $default,){
final _that = this;
switch (_that) {
case _StoryboardShot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StoryboardShot value)?  $default,){
final _that = this;
switch (_that) {
case _StoryboardShot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  int? projectId,  int? segmentId,  int? sceneId,  int sortIndex,  String prompt,  String stylePrompt,  String imageUrl,  String videoUrl,  String taskId,  String status,  int duration,  String? cameraType,  String? cameraAngle,  String? dialogue,  String? voice,  String lipSync,  String? characterName,  int? characterId,  String? emotion,  String? voiceName,  String? transition,  String? audioDesign,  String? priority,  String? negativePrompt,  String reviewStatus,  String? reviewComment)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StoryboardShot() when $default != null:
return $default(_that.id,_that.projectId,_that.segmentId,_that.sceneId,_that.sortIndex,_that.prompt,_that.stylePrompt,_that.imageUrl,_that.videoUrl,_that.taskId,_that.status,_that.duration,_that.cameraType,_that.cameraAngle,_that.dialogue,_that.voice,_that.lipSync,_that.characterName,_that.characterId,_that.emotion,_that.voiceName,_that.transition,_that.audioDesign,_that.priority,_that.negativePrompt,_that.reviewStatus,_that.reviewComment);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  int? projectId,  int? segmentId,  int? sceneId,  int sortIndex,  String prompt,  String stylePrompt,  String imageUrl,  String videoUrl,  String taskId,  String status,  int duration,  String? cameraType,  String? cameraAngle,  String? dialogue,  String? voice,  String lipSync,  String? characterName,  int? characterId,  String? emotion,  String? voiceName,  String? transition,  String? audioDesign,  String? priority,  String? negativePrompt,  String reviewStatus,  String? reviewComment)  $default,) {final _that = this;
switch (_that) {
case _StoryboardShot():
return $default(_that.id,_that.projectId,_that.segmentId,_that.sceneId,_that.sortIndex,_that.prompt,_that.stylePrompt,_that.imageUrl,_that.videoUrl,_that.taskId,_that.status,_that.duration,_that.cameraType,_that.cameraAngle,_that.dialogue,_that.voice,_that.lipSync,_that.characterName,_that.characterId,_that.emotion,_that.voiceName,_that.transition,_that.audioDesign,_that.priority,_that.negativePrompt,_that.reviewStatus,_that.reviewComment);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  int? projectId,  int? segmentId,  int? sceneId,  int sortIndex,  String prompt,  String stylePrompt,  String imageUrl,  String videoUrl,  String taskId,  String status,  int duration,  String? cameraType,  String? cameraAngle,  String? dialogue,  String? voice,  String lipSync,  String? characterName,  int? characterId,  String? emotion,  String? voiceName,  String? transition,  String? audioDesign,  String? priority,  String? negativePrompt,  String reviewStatus,  String? reviewComment)?  $default,) {final _that = this;
switch (_that) {
case _StoryboardShot() when $default != null:
return $default(_that.id,_that.projectId,_that.segmentId,_that.sceneId,_that.sortIndex,_that.prompt,_that.stylePrompt,_that.imageUrl,_that.videoUrl,_that.taskId,_that.status,_that.duration,_that.cameraType,_that.cameraAngle,_that.dialogue,_that.voice,_that.lipSync,_that.characterName,_that.characterId,_that.emotion,_that.voiceName,_that.transition,_that.audioDesign,_that.priority,_that.negativePrompt,_that.reviewStatus,_that.reviewComment);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StoryboardShot extends StoryboardShot {
  const _StoryboardShot({this.id, this.projectId, this.segmentId, this.sceneId, this.sortIndex = 0, this.prompt = '', this.stylePrompt = '', this.imageUrl = '', this.videoUrl = '', this.taskId = '', this.status = 'pending', this.duration = 5, this.cameraType, this.cameraAngle, this.dialogue, this.voice, this.lipSync = '口型同步', this.characterName, this.characterId, this.emotion, this.voiceName, this.transition, this.audioDesign, this.priority, this.negativePrompt, this.reviewStatus = 'pending', this.reviewComment}): super._();
  factory _StoryboardShot.fromJson(Map<String, dynamic> json) => _$StoryboardShotFromJson(json);

@override final  int? id;
@override final  int? projectId;
@override final  int? segmentId;
@override final  int? sceneId;
@override@JsonKey() final  int sortIndex;
@override@JsonKey() final  String prompt;
@override@JsonKey() final  String stylePrompt;
@override@JsonKey() final  String imageUrl;
@override@JsonKey() final  String videoUrl;
@override@JsonKey() final  String taskId;
@override@JsonKey() final  String status;
@override@JsonKey() final  int duration;
@override final  String? cameraType;
@override final  String? cameraAngle;
@override final  String? dialogue;
@override final  String? voice;
@override@JsonKey() final  String lipSync;
@override final  String? characterName;
@override final  int? characterId;
@override final  String? emotion;
@override final  String? voiceName;
@override final  String? transition;
@override final  String? audioDesign;
@override final  String? priority;
@override final  String? negativePrompt;
@override@JsonKey() final  String reviewStatus;
@override final  String? reviewComment;

/// Create a copy of StoryboardShot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StoryboardShotCopyWith<_StoryboardShot> get copyWith => __$StoryboardShotCopyWithImpl<_StoryboardShot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StoryboardShotToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StoryboardShot&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.segmentId, segmentId) || other.segmentId == segmentId)&&(identical(other.sceneId, sceneId) || other.sceneId == sceneId)&&(identical(other.sortIndex, sortIndex) || other.sortIndex == sortIndex)&&(identical(other.prompt, prompt) || other.prompt == prompt)&&(identical(other.stylePrompt, stylePrompt) || other.stylePrompt == stylePrompt)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.videoUrl, videoUrl) || other.videoUrl == videoUrl)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.status, status) || other.status == status)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.cameraType, cameraType) || other.cameraType == cameraType)&&(identical(other.cameraAngle, cameraAngle) || other.cameraAngle == cameraAngle)&&(identical(other.dialogue, dialogue) || other.dialogue == dialogue)&&(identical(other.voice, voice) || other.voice == voice)&&(identical(other.lipSync, lipSync) || other.lipSync == lipSync)&&(identical(other.characterName, characterName) || other.characterName == characterName)&&(identical(other.characterId, characterId) || other.characterId == characterId)&&(identical(other.emotion, emotion) || other.emotion == emotion)&&(identical(other.voiceName, voiceName) || other.voiceName == voiceName)&&(identical(other.transition, transition) || other.transition == transition)&&(identical(other.audioDesign, audioDesign) || other.audioDesign == audioDesign)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.negativePrompt, negativePrompt) || other.negativePrompt == negativePrompt)&&(identical(other.reviewStatus, reviewStatus) || other.reviewStatus == reviewStatus)&&(identical(other.reviewComment, reviewComment) || other.reviewComment == reviewComment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,projectId,segmentId,sceneId,sortIndex,prompt,stylePrompt,imageUrl,videoUrl,taskId,status,duration,cameraType,cameraAngle,dialogue,voice,lipSync,characterName,characterId,emotion,voiceName,transition,audioDesign,priority,negativePrompt,reviewStatus,reviewComment]);

@override
String toString() {
  return 'StoryboardShot(id: $id, projectId: $projectId, segmentId: $segmentId, sceneId: $sceneId, sortIndex: $sortIndex, prompt: $prompt, stylePrompt: $stylePrompt, imageUrl: $imageUrl, videoUrl: $videoUrl, taskId: $taskId, status: $status, duration: $duration, cameraType: $cameraType, cameraAngle: $cameraAngle, dialogue: $dialogue, voice: $voice, lipSync: $lipSync, characterName: $characterName, characterId: $characterId, emotion: $emotion, voiceName: $voiceName, transition: $transition, audioDesign: $audioDesign, priority: $priority, negativePrompt: $negativePrompt, reviewStatus: $reviewStatus, reviewComment: $reviewComment)';
}


}

/// @nodoc
abstract mixin class _$StoryboardShotCopyWith<$Res> implements $StoryboardShotCopyWith<$Res> {
  factory _$StoryboardShotCopyWith(_StoryboardShot value, $Res Function(_StoryboardShot) _then) = __$StoryboardShotCopyWithImpl;
@override @useResult
$Res call({
 int? id, int? projectId, int? segmentId, int? sceneId, int sortIndex, String prompt, String stylePrompt, String imageUrl, String videoUrl, String taskId, String status, int duration, String? cameraType, String? cameraAngle, String? dialogue, String? voice, String lipSync, String? characterName, int? characterId, String? emotion, String? voiceName, String? transition, String? audioDesign, String? priority, String? negativePrompt, String reviewStatus, String? reviewComment
});




}
/// @nodoc
class __$StoryboardShotCopyWithImpl<$Res>
    implements _$StoryboardShotCopyWith<$Res> {
  __$StoryboardShotCopyWithImpl(this._self, this._then);

  final _StoryboardShot _self;
  final $Res Function(_StoryboardShot) _then;

/// Create a copy of StoryboardShot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? projectId = freezed,Object? segmentId = freezed,Object? sceneId = freezed,Object? sortIndex = null,Object? prompt = null,Object? stylePrompt = null,Object? imageUrl = null,Object? videoUrl = null,Object? taskId = null,Object? status = null,Object? duration = null,Object? cameraType = freezed,Object? cameraAngle = freezed,Object? dialogue = freezed,Object? voice = freezed,Object? lipSync = null,Object? characterName = freezed,Object? characterId = freezed,Object? emotion = freezed,Object? voiceName = freezed,Object? transition = freezed,Object? audioDesign = freezed,Object? priority = freezed,Object? negativePrompt = freezed,Object? reviewStatus = null,Object? reviewComment = freezed,}) {
  return _then(_StoryboardShot(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as int?,segmentId: freezed == segmentId ? _self.segmentId : segmentId // ignore: cast_nullable_to_non_nullable
as int?,sceneId: freezed == sceneId ? _self.sceneId : sceneId // ignore: cast_nullable_to_non_nullable
as int?,sortIndex: null == sortIndex ? _self.sortIndex : sortIndex // ignore: cast_nullable_to_non_nullable
as int,prompt: null == prompt ? _self.prompt : prompt // ignore: cast_nullable_to_non_nullable
as String,stylePrompt: null == stylePrompt ? _self.stylePrompt : stylePrompt // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,videoUrl: null == videoUrl ? _self.videoUrl : videoUrl // ignore: cast_nullable_to_non_nullable
as String,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,cameraType: freezed == cameraType ? _self.cameraType : cameraType // ignore: cast_nullable_to_non_nullable
as String?,cameraAngle: freezed == cameraAngle ? _self.cameraAngle : cameraAngle // ignore: cast_nullable_to_non_nullable
as String?,dialogue: freezed == dialogue ? _self.dialogue : dialogue // ignore: cast_nullable_to_non_nullable
as String?,voice: freezed == voice ? _self.voice : voice // ignore: cast_nullable_to_non_nullable
as String?,lipSync: null == lipSync ? _self.lipSync : lipSync // ignore: cast_nullable_to_non_nullable
as String,characterName: freezed == characterName ? _self.characterName : characterName // ignore: cast_nullable_to_non_nullable
as String?,characterId: freezed == characterId ? _self.characterId : characterId // ignore: cast_nullable_to_non_nullable
as int?,emotion: freezed == emotion ? _self.emotion : emotion // ignore: cast_nullable_to_non_nullable
as String?,voiceName: freezed == voiceName ? _self.voiceName : voiceName // ignore: cast_nullable_to_non_nullable
as String?,transition: freezed == transition ? _self.transition : transition // ignore: cast_nullable_to_non_nullable
as String?,audioDesign: freezed == audioDesign ? _self.audioDesign : audioDesign // ignore: cast_nullable_to_non_nullable
as String?,priority: freezed == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as String?,negativePrompt: freezed == negativePrompt ? _self.negativePrompt : negativePrompt // ignore: cast_nullable_to_non_nullable
as String?,reviewStatus: null == reviewStatus ? _self.reviewStatus : reviewStatus // ignore: cast_nullable_to_non_nullable
as String,reviewComment: freezed == reviewComment ? _self.reviewComment : reviewComment // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
