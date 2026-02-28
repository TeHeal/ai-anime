// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'voice.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Voice {

 int? get id; String get name; String get gender; String get voiceId; String get provider; String get audioUrl; String get status; String get taskId; String? get error; bool get shared;
/// Create a copy of Voice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoiceCopyWith<Voice> get copyWith => _$VoiceCopyWithImpl<Voice>(this as Voice, _$identity);

  /// Serializes this Voice to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Voice&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.voiceId, voiceId) || other.voiceId == voiceId)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.audioUrl, audioUrl) || other.audioUrl == audioUrl)&&(identical(other.status, status) || other.status == status)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.error, error) || other.error == error)&&(identical(other.shared, shared) || other.shared == shared));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,gender,voiceId,provider,audioUrl,status,taskId,error,shared);

@override
String toString() {
  return 'Voice(id: $id, name: $name, gender: $gender, voiceId: $voiceId, provider: $provider, audioUrl: $audioUrl, status: $status, taskId: $taskId, error: $error, shared: $shared)';
}


}

/// @nodoc
abstract mixin class $VoiceCopyWith<$Res>  {
  factory $VoiceCopyWith(Voice value, $Res Function(Voice) _then) = _$VoiceCopyWithImpl;
@useResult
$Res call({
 int? id, String name, String gender, String voiceId, String provider, String audioUrl, String status, String taskId, String? error, bool shared
});




}
/// @nodoc
class _$VoiceCopyWithImpl<$Res>
    implements $VoiceCopyWith<$Res> {
  _$VoiceCopyWithImpl(this._self, this._then);

  final Voice _self;
  final $Res Function(Voice) _then;

/// Create a copy of Voice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = null,Object? gender = null,Object? voiceId = null,Object? provider = null,Object? audioUrl = null,Object? status = null,Object? taskId = null,Object? error = freezed,Object? shared = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String,voiceId: null == voiceId ? _self.voiceId : voiceId // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,audioUrl: null == audioUrl ? _self.audioUrl : audioUrl // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,shared: null == shared ? _self.shared : shared // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Voice].
extension VoicePatterns on Voice {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Voice value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Voice() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Voice value)  $default,){
final _that = this;
switch (_that) {
case _Voice():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Voice value)?  $default,){
final _that = this;
switch (_that) {
case _Voice() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  String name,  String gender,  String voiceId,  String provider,  String audioUrl,  String status,  String taskId,  String? error,  bool shared)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Voice() when $default != null:
return $default(_that.id,_that.name,_that.gender,_that.voiceId,_that.provider,_that.audioUrl,_that.status,_that.taskId,_that.error,_that.shared);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  String name,  String gender,  String voiceId,  String provider,  String audioUrl,  String status,  String taskId,  String? error,  bool shared)  $default,) {final _that = this;
switch (_that) {
case _Voice():
return $default(_that.id,_that.name,_that.gender,_that.voiceId,_that.provider,_that.audioUrl,_that.status,_that.taskId,_that.error,_that.shared);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  String name,  String gender,  String voiceId,  String provider,  String audioUrl,  String status,  String taskId,  String? error,  bool shared)?  $default,) {final _that = this;
switch (_that) {
case _Voice() when $default != null:
return $default(_that.id,_that.name,_that.gender,_that.voiceId,_that.provider,_that.audioUrl,_that.status,_that.taskId,_that.error,_that.shared);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Voice extends Voice {
  const _Voice({this.id, this.name = '', this.gender = '', this.voiceId = '', this.provider = '', this.audioUrl = '', this.status = 'pending', this.taskId = '', this.error, this.shared = false}): super._();
  factory _Voice.fromJson(Map<String, dynamic> json) => _$VoiceFromJson(json);

@override final  int? id;
@override@JsonKey() final  String name;
@override@JsonKey() final  String gender;
@override@JsonKey() final  String voiceId;
@override@JsonKey() final  String provider;
@override@JsonKey() final  String audioUrl;
@override@JsonKey() final  String status;
@override@JsonKey() final  String taskId;
@override final  String? error;
@override@JsonKey() final  bool shared;

/// Create a copy of Voice
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoiceCopyWith<_Voice> get copyWith => __$VoiceCopyWithImpl<_Voice>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VoiceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Voice&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.voiceId, voiceId) || other.voiceId == voiceId)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.audioUrl, audioUrl) || other.audioUrl == audioUrl)&&(identical(other.status, status) || other.status == status)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.error, error) || other.error == error)&&(identical(other.shared, shared) || other.shared == shared));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,gender,voiceId,provider,audioUrl,status,taskId,error,shared);

@override
String toString() {
  return 'Voice(id: $id, name: $name, gender: $gender, voiceId: $voiceId, provider: $provider, audioUrl: $audioUrl, status: $status, taskId: $taskId, error: $error, shared: $shared)';
}


}

/// @nodoc
abstract mixin class _$VoiceCopyWith<$Res> implements $VoiceCopyWith<$Res> {
  factory _$VoiceCopyWith(_Voice value, $Res Function(_Voice) _then) = __$VoiceCopyWithImpl;
@override @useResult
$Res call({
 int? id, String name, String gender, String voiceId, String provider, String audioUrl, String status, String taskId, String? error, bool shared
});




}
/// @nodoc
class __$VoiceCopyWithImpl<$Res>
    implements _$VoiceCopyWith<$Res> {
  __$VoiceCopyWithImpl(this._self, this._then);

  final _Voice _self;
  final $Res Function(_Voice) _then;

/// Create a copy of Voice
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = null,Object? gender = null,Object? voiceId = null,Object? provider = null,Object? audioUrl = null,Object? status = null,Object? taskId = null,Object? error = freezed,Object? shared = null,}) {
  return _then(_Voice(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String,voiceId: null == voiceId ? _self.voiceId : voiceId // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,audioUrl: null == audioUrl ? _self.audioUrl : audioUrl // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,shared: null == shared ? _self.shared : shared // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
