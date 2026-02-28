// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'voiceover.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Voiceover {

 int? get id; int? get projectId; int? get shotId; String get text; String get voiceId; String get voiceName; String get emotion; String get provider; String get model; String get audioUrl; double get duration; String get status; String get taskId;
/// Create a copy of Voiceover
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoiceoverCopyWith<Voiceover> get copyWith => _$VoiceoverCopyWithImpl<Voiceover>(this as Voiceover, _$identity);

  /// Serializes this Voiceover to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Voiceover&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.shotId, shotId) || other.shotId == shotId)&&(identical(other.text, text) || other.text == text)&&(identical(other.voiceId, voiceId) || other.voiceId == voiceId)&&(identical(other.voiceName, voiceName) || other.voiceName == voiceName)&&(identical(other.emotion, emotion) || other.emotion == emotion)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.model, model) || other.model == model)&&(identical(other.audioUrl, audioUrl) || other.audioUrl == audioUrl)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.status, status) || other.status == status)&&(identical(other.taskId, taskId) || other.taskId == taskId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,projectId,shotId,text,voiceId,voiceName,emotion,provider,model,audioUrl,duration,status,taskId);

@override
String toString() {
  return 'Voiceover(id: $id, projectId: $projectId, shotId: $shotId, text: $text, voiceId: $voiceId, voiceName: $voiceName, emotion: $emotion, provider: $provider, model: $model, audioUrl: $audioUrl, duration: $duration, status: $status, taskId: $taskId)';
}


}

/// @nodoc
abstract mixin class $VoiceoverCopyWith<$Res>  {
  factory $VoiceoverCopyWith(Voiceover value, $Res Function(Voiceover) _then) = _$VoiceoverCopyWithImpl;
@useResult
$Res call({
 int? id, int? projectId, int? shotId, String text, String voiceId, String voiceName, String emotion, String provider, String model, String audioUrl, double duration, String status, String taskId
});




}
/// @nodoc
class _$VoiceoverCopyWithImpl<$Res>
    implements $VoiceoverCopyWith<$Res> {
  _$VoiceoverCopyWithImpl(this._self, this._then);

  final Voiceover _self;
  final $Res Function(Voiceover) _then;

/// Create a copy of Voiceover
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? projectId = freezed,Object? shotId = freezed,Object? text = null,Object? voiceId = null,Object? voiceName = null,Object? emotion = null,Object? provider = null,Object? model = null,Object? audioUrl = null,Object? duration = null,Object? status = null,Object? taskId = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as int?,shotId: freezed == shotId ? _self.shotId : shotId // ignore: cast_nullable_to_non_nullable
as int?,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,voiceId: null == voiceId ? _self.voiceId : voiceId // ignore: cast_nullable_to_non_nullable
as String,voiceName: null == voiceName ? _self.voiceName : voiceName // ignore: cast_nullable_to_non_nullable
as String,emotion: null == emotion ? _self.emotion : emotion // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,audioUrl: null == audioUrl ? _self.audioUrl : audioUrl // ignore: cast_nullable_to_non_nullable
as String,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Voiceover].
extension VoiceoverPatterns on Voiceover {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Voiceover value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Voiceover() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Voiceover value)  $default,){
final _that = this;
switch (_that) {
case _Voiceover():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Voiceover value)?  $default,){
final _that = this;
switch (_that) {
case _Voiceover() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  int? projectId,  int? shotId,  String text,  String voiceId,  String voiceName,  String emotion,  String provider,  String model,  String audioUrl,  double duration,  String status,  String taskId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Voiceover() when $default != null:
return $default(_that.id,_that.projectId,_that.shotId,_that.text,_that.voiceId,_that.voiceName,_that.emotion,_that.provider,_that.model,_that.audioUrl,_that.duration,_that.status,_that.taskId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  int? projectId,  int? shotId,  String text,  String voiceId,  String voiceName,  String emotion,  String provider,  String model,  String audioUrl,  double duration,  String status,  String taskId)  $default,) {final _that = this;
switch (_that) {
case _Voiceover():
return $default(_that.id,_that.projectId,_that.shotId,_that.text,_that.voiceId,_that.voiceName,_that.emotion,_that.provider,_that.model,_that.audioUrl,_that.duration,_that.status,_that.taskId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  int? projectId,  int? shotId,  String text,  String voiceId,  String voiceName,  String emotion,  String provider,  String model,  String audioUrl,  double duration,  String status,  String taskId)?  $default,) {final _that = this;
switch (_that) {
case _Voiceover() when $default != null:
return $default(_that.id,_that.projectId,_that.shotId,_that.text,_that.voiceId,_that.voiceName,_that.emotion,_that.provider,_that.model,_that.audioUrl,_that.duration,_that.status,_that.taskId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Voiceover extends Voiceover {
  const _Voiceover({this.id, this.projectId, this.shotId, this.text = '', this.voiceId = '', this.voiceName = '', this.emotion = '', this.provider = '', this.model = '', this.audioUrl = '', this.duration = 0, this.status = 'pending', this.taskId = ''}): super._();
  factory _Voiceover.fromJson(Map<String, dynamic> json) => _$VoiceoverFromJson(json);

@override final  int? id;
@override final  int? projectId;
@override final  int? shotId;
@override@JsonKey() final  String text;
@override@JsonKey() final  String voiceId;
@override@JsonKey() final  String voiceName;
@override@JsonKey() final  String emotion;
@override@JsonKey() final  String provider;
@override@JsonKey() final  String model;
@override@JsonKey() final  String audioUrl;
@override@JsonKey() final  double duration;
@override@JsonKey() final  String status;
@override@JsonKey() final  String taskId;

/// Create a copy of Voiceover
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoiceoverCopyWith<_Voiceover> get copyWith => __$VoiceoverCopyWithImpl<_Voiceover>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VoiceoverToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Voiceover&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.shotId, shotId) || other.shotId == shotId)&&(identical(other.text, text) || other.text == text)&&(identical(other.voiceId, voiceId) || other.voiceId == voiceId)&&(identical(other.voiceName, voiceName) || other.voiceName == voiceName)&&(identical(other.emotion, emotion) || other.emotion == emotion)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.model, model) || other.model == model)&&(identical(other.audioUrl, audioUrl) || other.audioUrl == audioUrl)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.status, status) || other.status == status)&&(identical(other.taskId, taskId) || other.taskId == taskId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,projectId,shotId,text,voiceId,voiceName,emotion,provider,model,audioUrl,duration,status,taskId);

@override
String toString() {
  return 'Voiceover(id: $id, projectId: $projectId, shotId: $shotId, text: $text, voiceId: $voiceId, voiceName: $voiceName, emotion: $emotion, provider: $provider, model: $model, audioUrl: $audioUrl, duration: $duration, status: $status, taskId: $taskId)';
}


}

/// @nodoc
abstract mixin class _$VoiceoverCopyWith<$Res> implements $VoiceoverCopyWith<$Res> {
  factory _$VoiceoverCopyWith(_Voiceover value, $Res Function(_Voiceover) _then) = __$VoiceoverCopyWithImpl;
@override @useResult
$Res call({
 int? id, int? projectId, int? shotId, String text, String voiceId, String voiceName, String emotion, String provider, String model, String audioUrl, double duration, String status, String taskId
});




}
/// @nodoc
class __$VoiceoverCopyWithImpl<$Res>
    implements _$VoiceoverCopyWith<$Res> {
  __$VoiceoverCopyWithImpl(this._self, this._then);

  final _Voiceover _self;
  final $Res Function(_Voiceover) _then;

/// Create a copy of Voiceover
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? projectId = freezed,Object? shotId = freezed,Object? text = null,Object? voiceId = null,Object? voiceName = null,Object? emotion = null,Object? provider = null,Object? model = null,Object? audioUrl = null,Object? duration = null,Object? status = null,Object? taskId = null,}) {
  return _then(_Voiceover(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as int?,shotId: freezed == shotId ? _self.shotId : shotId // ignore: cast_nullable_to_non_nullable
as int?,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,voiceId: null == voiceId ? _self.voiceId : voiceId // ignore: cast_nullable_to_non_nullable
as String,voiceName: null == voiceName ? _self.voiceName : voiceName // ignore: cast_nullable_to_non_nullable
as String,emotion: null == emotion ? _self.emotion : emotion // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,audioUrl: null == audioUrl ? _self.audioUrl : audioUrl // ignore: cast_nullable_to_non_nullable
as String,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
