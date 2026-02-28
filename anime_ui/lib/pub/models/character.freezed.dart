// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'character.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Character {

 int? get id; int? get projectId; String get name; String get aliasJson; String get appearance; String get style; bool get styleOverride; String get personality; String get voiceHint; String get emotions; String get scenes; String get gender; String get ageGroup; String get voiceId; String get voiceName; String get imageUrl; String get referenceImagesJson; String get taskId; String get imageStatus; bool get shared; String get status; String get source; String get variantsJson;// v3: classification
 String get importance; String get consistency; String get roleType; String get tagsJson; String get propsJson;// v3: bio
 String get bio; String get bioFragmentsJson;// v3: image gen override
 String get imageGenOverrideJson;
/// Create a copy of Character
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CharacterCopyWith<Character> get copyWith => _$CharacterCopyWithImpl<Character>(this as Character, _$identity);

  /// Serializes this Character to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Character&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.name, name) || other.name == name)&&(identical(other.aliasJson, aliasJson) || other.aliasJson == aliasJson)&&(identical(other.appearance, appearance) || other.appearance == appearance)&&(identical(other.style, style) || other.style == style)&&(identical(other.styleOverride, styleOverride) || other.styleOverride == styleOverride)&&(identical(other.personality, personality) || other.personality == personality)&&(identical(other.voiceHint, voiceHint) || other.voiceHint == voiceHint)&&(identical(other.emotions, emotions) || other.emotions == emotions)&&(identical(other.scenes, scenes) || other.scenes == scenes)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.ageGroup, ageGroup) || other.ageGroup == ageGroup)&&(identical(other.voiceId, voiceId) || other.voiceId == voiceId)&&(identical(other.voiceName, voiceName) || other.voiceName == voiceName)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.referenceImagesJson, referenceImagesJson) || other.referenceImagesJson == referenceImagesJson)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.imageStatus, imageStatus) || other.imageStatus == imageStatus)&&(identical(other.shared, shared) || other.shared == shared)&&(identical(other.status, status) || other.status == status)&&(identical(other.source, source) || other.source == source)&&(identical(other.variantsJson, variantsJson) || other.variantsJson == variantsJson)&&(identical(other.importance, importance) || other.importance == importance)&&(identical(other.consistency, consistency) || other.consistency == consistency)&&(identical(other.roleType, roleType) || other.roleType == roleType)&&(identical(other.tagsJson, tagsJson) || other.tagsJson == tagsJson)&&(identical(other.propsJson, propsJson) || other.propsJson == propsJson)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.bioFragmentsJson, bioFragmentsJson) || other.bioFragmentsJson == bioFragmentsJson)&&(identical(other.imageGenOverrideJson, imageGenOverrideJson) || other.imageGenOverrideJson == imageGenOverrideJson));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,projectId,name,aliasJson,appearance,style,styleOverride,personality,voiceHint,emotions,scenes,gender,ageGroup,voiceId,voiceName,imageUrl,referenceImagesJson,taskId,imageStatus,shared,status,source,variantsJson,importance,consistency,roleType,tagsJson,propsJson,bio,bioFragmentsJson,imageGenOverrideJson]);

@override
String toString() {
  return 'Character(id: $id, projectId: $projectId, name: $name, aliasJson: $aliasJson, appearance: $appearance, style: $style, styleOverride: $styleOverride, personality: $personality, voiceHint: $voiceHint, emotions: $emotions, scenes: $scenes, gender: $gender, ageGroup: $ageGroup, voiceId: $voiceId, voiceName: $voiceName, imageUrl: $imageUrl, referenceImagesJson: $referenceImagesJson, taskId: $taskId, imageStatus: $imageStatus, shared: $shared, status: $status, source: $source, variantsJson: $variantsJson, importance: $importance, consistency: $consistency, roleType: $roleType, tagsJson: $tagsJson, propsJson: $propsJson, bio: $bio, bioFragmentsJson: $bioFragmentsJson, imageGenOverrideJson: $imageGenOverrideJson)';
}


}

/// @nodoc
abstract mixin class $CharacterCopyWith<$Res>  {
  factory $CharacterCopyWith(Character value, $Res Function(Character) _then) = _$CharacterCopyWithImpl;
@useResult
$Res call({
 int? id, int? projectId, String name, String aliasJson, String appearance, String style, bool styleOverride, String personality, String voiceHint, String emotions, String scenes, String gender, String ageGroup, String voiceId, String voiceName, String imageUrl, String referenceImagesJson, String taskId, String imageStatus, bool shared, String status, String source, String variantsJson, String importance, String consistency, String roleType, String tagsJson, String propsJson, String bio, String bioFragmentsJson, String imageGenOverrideJson
});




}
/// @nodoc
class _$CharacterCopyWithImpl<$Res>
    implements $CharacterCopyWith<$Res> {
  _$CharacterCopyWithImpl(this._self, this._then);

  final Character _self;
  final $Res Function(Character) _then;

/// Create a copy of Character
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? projectId = freezed,Object? name = null,Object? aliasJson = null,Object? appearance = null,Object? style = null,Object? styleOverride = null,Object? personality = null,Object? voiceHint = null,Object? emotions = null,Object? scenes = null,Object? gender = null,Object? ageGroup = null,Object? voiceId = null,Object? voiceName = null,Object? imageUrl = null,Object? referenceImagesJson = null,Object? taskId = null,Object? imageStatus = null,Object? shared = null,Object? status = null,Object? source = null,Object? variantsJson = null,Object? importance = null,Object? consistency = null,Object? roleType = null,Object? tagsJson = null,Object? propsJson = null,Object? bio = null,Object? bioFragmentsJson = null,Object? imageGenOverrideJson = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as int?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,aliasJson: null == aliasJson ? _self.aliasJson : aliasJson // ignore: cast_nullable_to_non_nullable
as String,appearance: null == appearance ? _self.appearance : appearance // ignore: cast_nullable_to_non_nullable
as String,style: null == style ? _self.style : style // ignore: cast_nullable_to_non_nullable
as String,styleOverride: null == styleOverride ? _self.styleOverride : styleOverride // ignore: cast_nullable_to_non_nullable
as bool,personality: null == personality ? _self.personality : personality // ignore: cast_nullable_to_non_nullable
as String,voiceHint: null == voiceHint ? _self.voiceHint : voiceHint // ignore: cast_nullable_to_non_nullable
as String,emotions: null == emotions ? _self.emotions : emotions // ignore: cast_nullable_to_non_nullable
as String,scenes: null == scenes ? _self.scenes : scenes // ignore: cast_nullable_to_non_nullable
as String,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String,ageGroup: null == ageGroup ? _self.ageGroup : ageGroup // ignore: cast_nullable_to_non_nullable
as String,voiceId: null == voiceId ? _self.voiceId : voiceId // ignore: cast_nullable_to_non_nullable
as String,voiceName: null == voiceName ? _self.voiceName : voiceName // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,referenceImagesJson: null == referenceImagesJson ? _self.referenceImagesJson : referenceImagesJson // ignore: cast_nullable_to_non_nullable
as String,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,imageStatus: null == imageStatus ? _self.imageStatus : imageStatus // ignore: cast_nullable_to_non_nullable
as String,shared: null == shared ? _self.shared : shared // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,variantsJson: null == variantsJson ? _self.variantsJson : variantsJson // ignore: cast_nullable_to_non_nullable
as String,importance: null == importance ? _self.importance : importance // ignore: cast_nullable_to_non_nullable
as String,consistency: null == consistency ? _self.consistency : consistency // ignore: cast_nullable_to_non_nullable
as String,roleType: null == roleType ? _self.roleType : roleType // ignore: cast_nullable_to_non_nullable
as String,tagsJson: null == tagsJson ? _self.tagsJson : tagsJson // ignore: cast_nullable_to_non_nullable
as String,propsJson: null == propsJson ? _self.propsJson : propsJson // ignore: cast_nullable_to_non_nullable
as String,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,bioFragmentsJson: null == bioFragmentsJson ? _self.bioFragmentsJson : bioFragmentsJson // ignore: cast_nullable_to_non_nullable
as String,imageGenOverrideJson: null == imageGenOverrideJson ? _self.imageGenOverrideJson : imageGenOverrideJson // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Character].
extension CharacterPatterns on Character {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Character value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Character() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Character value)  $default,){
final _that = this;
switch (_that) {
case _Character():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Character value)?  $default,){
final _that = this;
switch (_that) {
case _Character() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  int? projectId,  String name,  String aliasJson,  String appearance,  String style,  bool styleOverride,  String personality,  String voiceHint,  String emotions,  String scenes,  String gender,  String ageGroup,  String voiceId,  String voiceName,  String imageUrl,  String referenceImagesJson,  String taskId,  String imageStatus,  bool shared,  String status,  String source,  String variantsJson,  String importance,  String consistency,  String roleType,  String tagsJson,  String propsJson,  String bio,  String bioFragmentsJson,  String imageGenOverrideJson)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Character() when $default != null:
return $default(_that.id,_that.projectId,_that.name,_that.aliasJson,_that.appearance,_that.style,_that.styleOverride,_that.personality,_that.voiceHint,_that.emotions,_that.scenes,_that.gender,_that.ageGroup,_that.voiceId,_that.voiceName,_that.imageUrl,_that.referenceImagesJson,_that.taskId,_that.imageStatus,_that.shared,_that.status,_that.source,_that.variantsJson,_that.importance,_that.consistency,_that.roleType,_that.tagsJson,_that.propsJson,_that.bio,_that.bioFragmentsJson,_that.imageGenOverrideJson);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  int? projectId,  String name,  String aliasJson,  String appearance,  String style,  bool styleOverride,  String personality,  String voiceHint,  String emotions,  String scenes,  String gender,  String ageGroup,  String voiceId,  String voiceName,  String imageUrl,  String referenceImagesJson,  String taskId,  String imageStatus,  bool shared,  String status,  String source,  String variantsJson,  String importance,  String consistency,  String roleType,  String tagsJson,  String propsJson,  String bio,  String bioFragmentsJson,  String imageGenOverrideJson)  $default,) {final _that = this;
switch (_that) {
case _Character():
return $default(_that.id,_that.projectId,_that.name,_that.aliasJson,_that.appearance,_that.style,_that.styleOverride,_that.personality,_that.voiceHint,_that.emotions,_that.scenes,_that.gender,_that.ageGroup,_that.voiceId,_that.voiceName,_that.imageUrl,_that.referenceImagesJson,_that.taskId,_that.imageStatus,_that.shared,_that.status,_that.source,_that.variantsJson,_that.importance,_that.consistency,_that.roleType,_that.tagsJson,_that.propsJson,_that.bio,_that.bioFragmentsJson,_that.imageGenOverrideJson);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  int? projectId,  String name,  String aliasJson,  String appearance,  String style,  bool styleOverride,  String personality,  String voiceHint,  String emotions,  String scenes,  String gender,  String ageGroup,  String voiceId,  String voiceName,  String imageUrl,  String referenceImagesJson,  String taskId,  String imageStatus,  bool shared,  String status,  String source,  String variantsJson,  String importance,  String consistency,  String roleType,  String tagsJson,  String propsJson,  String bio,  String bioFragmentsJson,  String imageGenOverrideJson)?  $default,) {final _that = this;
switch (_that) {
case _Character() when $default != null:
return $default(_that.id,_that.projectId,_that.name,_that.aliasJson,_that.appearance,_that.style,_that.styleOverride,_that.personality,_that.voiceHint,_that.emotions,_that.scenes,_that.gender,_that.ageGroup,_that.voiceId,_that.voiceName,_that.imageUrl,_that.referenceImagesJson,_that.taskId,_that.imageStatus,_that.shared,_that.status,_that.source,_that.variantsJson,_that.importance,_that.consistency,_that.roleType,_that.tagsJson,_that.propsJson,_that.bio,_that.bioFragmentsJson,_that.imageGenOverrideJson);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Character extends Character {
  const _Character({this.id, this.projectId, this.name = '', this.aliasJson = '', this.appearance = '', this.style = '', this.styleOverride = false, this.personality = '', this.voiceHint = '', this.emotions = '', this.scenes = '', this.gender = '', this.ageGroup = '', this.voiceId = '', this.voiceName = '', this.imageUrl = '', this.referenceImagesJson = '', this.taskId = '', this.imageStatus = 'none', this.shared = false, this.status = 'draft', this.source = 'manual', this.variantsJson = '', this.importance = '', this.consistency = '', this.roleType = '', this.tagsJson = '', this.propsJson = '', this.bio = '', this.bioFragmentsJson = '', this.imageGenOverrideJson = ''}): super._();
  factory _Character.fromJson(Map<String, dynamic> json) => _$CharacterFromJson(json);

@override final  int? id;
@override final  int? projectId;
@override@JsonKey() final  String name;
@override@JsonKey() final  String aliasJson;
@override@JsonKey() final  String appearance;
@override@JsonKey() final  String style;
@override@JsonKey() final  bool styleOverride;
@override@JsonKey() final  String personality;
@override@JsonKey() final  String voiceHint;
@override@JsonKey() final  String emotions;
@override@JsonKey() final  String scenes;
@override@JsonKey() final  String gender;
@override@JsonKey() final  String ageGroup;
@override@JsonKey() final  String voiceId;
@override@JsonKey() final  String voiceName;
@override@JsonKey() final  String imageUrl;
@override@JsonKey() final  String referenceImagesJson;
@override@JsonKey() final  String taskId;
@override@JsonKey() final  String imageStatus;
@override@JsonKey() final  bool shared;
@override@JsonKey() final  String status;
@override@JsonKey() final  String source;
@override@JsonKey() final  String variantsJson;
// v3: classification
@override@JsonKey() final  String importance;
@override@JsonKey() final  String consistency;
@override@JsonKey() final  String roleType;
@override@JsonKey() final  String tagsJson;
@override@JsonKey() final  String propsJson;
// v3: bio
@override@JsonKey() final  String bio;
@override@JsonKey() final  String bioFragmentsJson;
// v3: image gen override
@override@JsonKey() final  String imageGenOverrideJson;

/// Create a copy of Character
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CharacterCopyWith<_Character> get copyWith => __$CharacterCopyWithImpl<_Character>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CharacterToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Character&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.name, name) || other.name == name)&&(identical(other.aliasJson, aliasJson) || other.aliasJson == aliasJson)&&(identical(other.appearance, appearance) || other.appearance == appearance)&&(identical(other.style, style) || other.style == style)&&(identical(other.styleOverride, styleOverride) || other.styleOverride == styleOverride)&&(identical(other.personality, personality) || other.personality == personality)&&(identical(other.voiceHint, voiceHint) || other.voiceHint == voiceHint)&&(identical(other.emotions, emotions) || other.emotions == emotions)&&(identical(other.scenes, scenes) || other.scenes == scenes)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.ageGroup, ageGroup) || other.ageGroup == ageGroup)&&(identical(other.voiceId, voiceId) || other.voiceId == voiceId)&&(identical(other.voiceName, voiceName) || other.voiceName == voiceName)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.referenceImagesJson, referenceImagesJson) || other.referenceImagesJson == referenceImagesJson)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.imageStatus, imageStatus) || other.imageStatus == imageStatus)&&(identical(other.shared, shared) || other.shared == shared)&&(identical(other.status, status) || other.status == status)&&(identical(other.source, source) || other.source == source)&&(identical(other.variantsJson, variantsJson) || other.variantsJson == variantsJson)&&(identical(other.importance, importance) || other.importance == importance)&&(identical(other.consistency, consistency) || other.consistency == consistency)&&(identical(other.roleType, roleType) || other.roleType == roleType)&&(identical(other.tagsJson, tagsJson) || other.tagsJson == tagsJson)&&(identical(other.propsJson, propsJson) || other.propsJson == propsJson)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.bioFragmentsJson, bioFragmentsJson) || other.bioFragmentsJson == bioFragmentsJson)&&(identical(other.imageGenOverrideJson, imageGenOverrideJson) || other.imageGenOverrideJson == imageGenOverrideJson));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,projectId,name,aliasJson,appearance,style,styleOverride,personality,voiceHint,emotions,scenes,gender,ageGroup,voiceId,voiceName,imageUrl,referenceImagesJson,taskId,imageStatus,shared,status,source,variantsJson,importance,consistency,roleType,tagsJson,propsJson,bio,bioFragmentsJson,imageGenOverrideJson]);

@override
String toString() {
  return 'Character(id: $id, projectId: $projectId, name: $name, aliasJson: $aliasJson, appearance: $appearance, style: $style, styleOverride: $styleOverride, personality: $personality, voiceHint: $voiceHint, emotions: $emotions, scenes: $scenes, gender: $gender, ageGroup: $ageGroup, voiceId: $voiceId, voiceName: $voiceName, imageUrl: $imageUrl, referenceImagesJson: $referenceImagesJson, taskId: $taskId, imageStatus: $imageStatus, shared: $shared, status: $status, source: $source, variantsJson: $variantsJson, importance: $importance, consistency: $consistency, roleType: $roleType, tagsJson: $tagsJson, propsJson: $propsJson, bio: $bio, bioFragmentsJson: $bioFragmentsJson, imageGenOverrideJson: $imageGenOverrideJson)';
}


}

/// @nodoc
abstract mixin class _$CharacterCopyWith<$Res> implements $CharacterCopyWith<$Res> {
  factory _$CharacterCopyWith(_Character value, $Res Function(_Character) _then) = __$CharacterCopyWithImpl;
@override @useResult
$Res call({
 int? id, int? projectId, String name, String aliasJson, String appearance, String style, bool styleOverride, String personality, String voiceHint, String emotions, String scenes, String gender, String ageGroup, String voiceId, String voiceName, String imageUrl, String referenceImagesJson, String taskId, String imageStatus, bool shared, String status, String source, String variantsJson, String importance, String consistency, String roleType, String tagsJson, String propsJson, String bio, String bioFragmentsJson, String imageGenOverrideJson
});




}
/// @nodoc
class __$CharacterCopyWithImpl<$Res>
    implements _$CharacterCopyWith<$Res> {
  __$CharacterCopyWithImpl(this._self, this._then);

  final _Character _self;
  final $Res Function(_Character) _then;

/// Create a copy of Character
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? projectId = freezed,Object? name = null,Object? aliasJson = null,Object? appearance = null,Object? style = null,Object? styleOverride = null,Object? personality = null,Object? voiceHint = null,Object? emotions = null,Object? scenes = null,Object? gender = null,Object? ageGroup = null,Object? voiceId = null,Object? voiceName = null,Object? imageUrl = null,Object? referenceImagesJson = null,Object? taskId = null,Object? imageStatus = null,Object? shared = null,Object? status = null,Object? source = null,Object? variantsJson = null,Object? importance = null,Object? consistency = null,Object? roleType = null,Object? tagsJson = null,Object? propsJson = null,Object? bio = null,Object? bioFragmentsJson = null,Object? imageGenOverrideJson = null,}) {
  return _then(_Character(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as int?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,aliasJson: null == aliasJson ? _self.aliasJson : aliasJson // ignore: cast_nullable_to_non_nullable
as String,appearance: null == appearance ? _self.appearance : appearance // ignore: cast_nullable_to_non_nullable
as String,style: null == style ? _self.style : style // ignore: cast_nullable_to_non_nullable
as String,styleOverride: null == styleOverride ? _self.styleOverride : styleOverride // ignore: cast_nullable_to_non_nullable
as bool,personality: null == personality ? _self.personality : personality // ignore: cast_nullable_to_non_nullable
as String,voiceHint: null == voiceHint ? _self.voiceHint : voiceHint // ignore: cast_nullable_to_non_nullable
as String,emotions: null == emotions ? _self.emotions : emotions // ignore: cast_nullable_to_non_nullable
as String,scenes: null == scenes ? _self.scenes : scenes // ignore: cast_nullable_to_non_nullable
as String,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String,ageGroup: null == ageGroup ? _self.ageGroup : ageGroup // ignore: cast_nullable_to_non_nullable
as String,voiceId: null == voiceId ? _self.voiceId : voiceId // ignore: cast_nullable_to_non_nullable
as String,voiceName: null == voiceName ? _self.voiceName : voiceName // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,referenceImagesJson: null == referenceImagesJson ? _self.referenceImagesJson : referenceImagesJson // ignore: cast_nullable_to_non_nullable
as String,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,imageStatus: null == imageStatus ? _self.imageStatus : imageStatus // ignore: cast_nullable_to_non_nullable
as String,shared: null == shared ? _self.shared : shared // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,variantsJson: null == variantsJson ? _self.variantsJson : variantsJson // ignore: cast_nullable_to_non_nullable
as String,importance: null == importance ? _self.importance : importance // ignore: cast_nullable_to_non_nullable
as String,consistency: null == consistency ? _self.consistency : consistency // ignore: cast_nullable_to_non_nullable
as String,roleType: null == roleType ? _self.roleType : roleType // ignore: cast_nullable_to_non_nullable
as String,tagsJson: null == tagsJson ? _self.tagsJson : tagsJson // ignore: cast_nullable_to_non_nullable
as String,propsJson: null == propsJson ? _self.propsJson : propsJson // ignore: cast_nullable_to_non_nullable
as String,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,bioFragmentsJson: null == bioFragmentsJson ? _self.bioFragmentsJson : bioFragmentsJson // ignore: cast_nullable_to_non_nullable
as String,imageGenOverrideJson: null == imageGenOverrideJson ? _self.imageGenOverrideJson : imageGenOverrideJson // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
