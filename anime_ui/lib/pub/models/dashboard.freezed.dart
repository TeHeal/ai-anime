// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Dashboard {

 int get totalEpisodes; Map<String, int> get statusCounts; Map<String, StepCount> get phaseCounts; AssetSummary? get assetSummary; ReviewSummary? get reviewSummary; List<DashboardEpisode> get episodes;
/// Create a copy of Dashboard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardCopyWith<Dashboard> get copyWith => _$DashboardCopyWithImpl<Dashboard>(this as Dashboard, _$identity);

  /// Serializes this Dashboard to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Dashboard&&(identical(other.totalEpisodes, totalEpisodes) || other.totalEpisodes == totalEpisodes)&&const DeepCollectionEquality().equals(other.statusCounts, statusCounts)&&const DeepCollectionEquality().equals(other.phaseCounts, phaseCounts)&&(identical(other.assetSummary, assetSummary) || other.assetSummary == assetSummary)&&(identical(other.reviewSummary, reviewSummary) || other.reviewSummary == reviewSummary)&&const DeepCollectionEquality().equals(other.episodes, episodes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalEpisodes,const DeepCollectionEquality().hash(statusCounts),const DeepCollectionEquality().hash(phaseCounts),assetSummary,reviewSummary,const DeepCollectionEquality().hash(episodes));

@override
String toString() {
  return 'Dashboard(totalEpisodes: $totalEpisodes, statusCounts: $statusCounts, phaseCounts: $phaseCounts, assetSummary: $assetSummary, reviewSummary: $reviewSummary, episodes: $episodes)';
}


}

/// @nodoc
abstract mixin class $DashboardCopyWith<$Res>  {
  factory $DashboardCopyWith(Dashboard value, $Res Function(Dashboard) _then) = _$DashboardCopyWithImpl;
@useResult
$Res call({
 int totalEpisodes, Map<String, int> statusCounts, Map<String, StepCount> phaseCounts, AssetSummary? assetSummary, ReviewSummary? reviewSummary, List<DashboardEpisode> episodes
});


$AssetSummaryCopyWith<$Res>? get assetSummary;$ReviewSummaryCopyWith<$Res>? get reviewSummary;

}
/// @nodoc
class _$DashboardCopyWithImpl<$Res>
    implements $DashboardCopyWith<$Res> {
  _$DashboardCopyWithImpl(this._self, this._then);

  final Dashboard _self;
  final $Res Function(Dashboard) _then;

/// Create a copy of Dashboard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalEpisodes = null,Object? statusCounts = null,Object? phaseCounts = null,Object? assetSummary = freezed,Object? reviewSummary = freezed,Object? episodes = null,}) {
  return _then(_self.copyWith(
totalEpisodes: null == totalEpisodes ? _self.totalEpisodes : totalEpisodes // ignore: cast_nullable_to_non_nullable
as int,statusCounts: null == statusCounts ? _self.statusCounts : statusCounts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,phaseCounts: null == phaseCounts ? _self.phaseCounts : phaseCounts // ignore: cast_nullable_to_non_nullable
as Map<String, StepCount>,assetSummary: freezed == assetSummary ? _self.assetSummary : assetSummary // ignore: cast_nullable_to_non_nullable
as AssetSummary?,reviewSummary: freezed == reviewSummary ? _self.reviewSummary : reviewSummary // ignore: cast_nullable_to_non_nullable
as ReviewSummary?,episodes: null == episodes ? _self.episodes : episodes // ignore: cast_nullable_to_non_nullable
as List<DashboardEpisode>,
  ));
}
/// Create a copy of Dashboard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AssetSummaryCopyWith<$Res>? get assetSummary {
    if (_self.assetSummary == null) {
    return null;
  }

  return $AssetSummaryCopyWith<$Res>(_self.assetSummary!, (value) {
    return _then(_self.copyWith(assetSummary: value));
  });
}/// Create a copy of Dashboard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReviewSummaryCopyWith<$Res>? get reviewSummary {
    if (_self.reviewSummary == null) {
    return null;
  }

  return $ReviewSummaryCopyWith<$Res>(_self.reviewSummary!, (value) {
    return _then(_self.copyWith(reviewSummary: value));
  });
}
}


/// Adds pattern-matching-related methods to [Dashboard].
extension DashboardPatterns on Dashboard {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Dashboard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Dashboard() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Dashboard value)  $default,){
final _that = this;
switch (_that) {
case _Dashboard():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Dashboard value)?  $default,){
final _that = this;
switch (_that) {
case _Dashboard() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalEpisodes,  Map<String, int> statusCounts,  Map<String, StepCount> phaseCounts,  AssetSummary? assetSummary,  ReviewSummary? reviewSummary,  List<DashboardEpisode> episodes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Dashboard() when $default != null:
return $default(_that.totalEpisodes,_that.statusCounts,_that.phaseCounts,_that.assetSummary,_that.reviewSummary,_that.episodes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalEpisodes,  Map<String, int> statusCounts,  Map<String, StepCount> phaseCounts,  AssetSummary? assetSummary,  ReviewSummary? reviewSummary,  List<DashboardEpisode> episodes)  $default,) {final _that = this;
switch (_that) {
case _Dashboard():
return $default(_that.totalEpisodes,_that.statusCounts,_that.phaseCounts,_that.assetSummary,_that.reviewSummary,_that.episodes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalEpisodes,  Map<String, int> statusCounts,  Map<String, StepCount> phaseCounts,  AssetSummary? assetSummary,  ReviewSummary? reviewSummary,  List<DashboardEpisode> episodes)?  $default,) {final _that = this;
switch (_that) {
case _Dashboard() when $default != null:
return $default(_that.totalEpisodes,_that.statusCounts,_that.phaseCounts,_that.assetSummary,_that.reviewSummary,_that.episodes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Dashboard implements Dashboard {
  const _Dashboard({this.totalEpisodes = 0, final  Map<String, int> statusCounts = const {}, final  Map<String, StepCount> phaseCounts = const {}, this.assetSummary, this.reviewSummary, final  List<DashboardEpisode> episodes = const []}): _statusCounts = statusCounts,_phaseCounts = phaseCounts,_episodes = episodes;
  factory _Dashboard.fromJson(Map<String, dynamic> json) => _$DashboardFromJson(json);

@override@JsonKey() final  int totalEpisodes;
 final  Map<String, int> _statusCounts;
@override@JsonKey() Map<String, int> get statusCounts {
  if (_statusCounts is EqualUnmodifiableMapView) return _statusCounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_statusCounts);
}

 final  Map<String, StepCount> _phaseCounts;
@override@JsonKey() Map<String, StepCount> get phaseCounts {
  if (_phaseCounts is EqualUnmodifiableMapView) return _phaseCounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_phaseCounts);
}

@override final  AssetSummary? assetSummary;
@override final  ReviewSummary? reviewSummary;
 final  List<DashboardEpisode> _episodes;
@override@JsonKey() List<DashboardEpisode> get episodes {
  if (_episodes is EqualUnmodifiableListView) return _episodes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_episodes);
}


/// Create a copy of Dashboard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardCopyWith<_Dashboard> get copyWith => __$DashboardCopyWithImpl<_Dashboard>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DashboardToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Dashboard&&(identical(other.totalEpisodes, totalEpisodes) || other.totalEpisodes == totalEpisodes)&&const DeepCollectionEquality().equals(other._statusCounts, _statusCounts)&&const DeepCollectionEquality().equals(other._phaseCounts, _phaseCounts)&&(identical(other.assetSummary, assetSummary) || other.assetSummary == assetSummary)&&(identical(other.reviewSummary, reviewSummary) || other.reviewSummary == reviewSummary)&&const DeepCollectionEquality().equals(other._episodes, _episodes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalEpisodes,const DeepCollectionEquality().hash(_statusCounts),const DeepCollectionEquality().hash(_phaseCounts),assetSummary,reviewSummary,const DeepCollectionEquality().hash(_episodes));

@override
String toString() {
  return 'Dashboard(totalEpisodes: $totalEpisodes, statusCounts: $statusCounts, phaseCounts: $phaseCounts, assetSummary: $assetSummary, reviewSummary: $reviewSummary, episodes: $episodes)';
}


}

/// @nodoc
abstract mixin class _$DashboardCopyWith<$Res> implements $DashboardCopyWith<$Res> {
  factory _$DashboardCopyWith(_Dashboard value, $Res Function(_Dashboard) _then) = __$DashboardCopyWithImpl;
@override @useResult
$Res call({
 int totalEpisodes, Map<String, int> statusCounts, Map<String, StepCount> phaseCounts, AssetSummary? assetSummary, ReviewSummary? reviewSummary, List<DashboardEpisode> episodes
});


@override $AssetSummaryCopyWith<$Res>? get assetSummary;@override $ReviewSummaryCopyWith<$Res>? get reviewSummary;

}
/// @nodoc
class __$DashboardCopyWithImpl<$Res>
    implements _$DashboardCopyWith<$Res> {
  __$DashboardCopyWithImpl(this._self, this._then);

  final _Dashboard _self;
  final $Res Function(_Dashboard) _then;

/// Create a copy of Dashboard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalEpisodes = null,Object? statusCounts = null,Object? phaseCounts = null,Object? assetSummary = freezed,Object? reviewSummary = freezed,Object? episodes = null,}) {
  return _then(_Dashboard(
totalEpisodes: null == totalEpisodes ? _self.totalEpisodes : totalEpisodes // ignore: cast_nullable_to_non_nullable
as int,statusCounts: null == statusCounts ? _self._statusCounts : statusCounts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,phaseCounts: null == phaseCounts ? _self._phaseCounts : phaseCounts // ignore: cast_nullable_to_non_nullable
as Map<String, StepCount>,assetSummary: freezed == assetSummary ? _self.assetSummary : assetSummary // ignore: cast_nullable_to_non_nullable
as AssetSummary?,reviewSummary: freezed == reviewSummary ? _self.reviewSummary : reviewSummary // ignore: cast_nullable_to_non_nullable
as ReviewSummary?,episodes: null == episodes ? _self._episodes : episodes // ignore: cast_nullable_to_non_nullable
as List<DashboardEpisode>,
  ));
}

/// Create a copy of Dashboard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AssetSummaryCopyWith<$Res>? get assetSummary {
    if (_self.assetSummary == null) {
    return null;
  }

  return $AssetSummaryCopyWith<$Res>(_self.assetSummary!, (value) {
    return _then(_self.copyWith(assetSummary: value));
  });
}/// Create a copy of Dashboard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReviewSummaryCopyWith<$Res>? get reviewSummary {
    if (_self.reviewSummary == null) {
    return null;
  }

  return $ReviewSummaryCopyWith<$Res>(_self.reviewSummary!, (value) {
    return _then(_self.copyWith(reviewSummary: value));
  });
}
}


/// @nodoc
mixin _$StepCount {

 int get done; int get total;
/// Create a copy of StepCount
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StepCountCopyWith<StepCount> get copyWith => _$StepCountCopyWithImpl<StepCount>(this as StepCount, _$identity);

  /// Serializes this StepCount to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StepCount&&(identical(other.done, done) || other.done == done)&&(identical(other.total, total) || other.total == total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,done,total);

@override
String toString() {
  return 'StepCount(done: $done, total: $total)';
}


}

/// @nodoc
abstract mixin class $StepCountCopyWith<$Res>  {
  factory $StepCountCopyWith(StepCount value, $Res Function(StepCount) _then) = _$StepCountCopyWithImpl;
@useResult
$Res call({
 int done, int total
});




}
/// @nodoc
class _$StepCountCopyWithImpl<$Res>
    implements $StepCountCopyWith<$Res> {
  _$StepCountCopyWithImpl(this._self, this._then);

  final StepCount _self;
  final $Res Function(StepCount) _then;

/// Create a copy of StepCount
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? done = null,Object? total = null,}) {
  return _then(_self.copyWith(
done: null == done ? _self.done : done // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [StepCount].
extension StepCountPatterns on StepCount {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StepCount value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StepCount() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StepCount value)  $default,){
final _that = this;
switch (_that) {
case _StepCount():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StepCount value)?  $default,){
final _that = this;
switch (_that) {
case _StepCount() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int done,  int total)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StepCount() when $default != null:
return $default(_that.done,_that.total);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int done,  int total)  $default,) {final _that = this;
switch (_that) {
case _StepCount():
return $default(_that.done,_that.total);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int done,  int total)?  $default,) {final _that = this;
switch (_that) {
case _StepCount() when $default != null:
return $default(_that.done,_that.total);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StepCount implements StepCount {
  const _StepCount({this.done = 0, this.total = 0});
  factory _StepCount.fromJson(Map<String, dynamic> json) => _$StepCountFromJson(json);

@override@JsonKey() final  int done;
@override@JsonKey() final  int total;

/// Create a copy of StepCount
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StepCountCopyWith<_StepCount> get copyWith => __$StepCountCopyWithImpl<_StepCount>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StepCountToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StepCount&&(identical(other.done, done) || other.done == done)&&(identical(other.total, total) || other.total == total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,done,total);

@override
String toString() {
  return 'StepCount(done: $done, total: $total)';
}


}

/// @nodoc
abstract mixin class _$StepCountCopyWith<$Res> implements $StepCountCopyWith<$Res> {
  factory _$StepCountCopyWith(_StepCount value, $Res Function(_StepCount) _then) = __$StepCountCopyWithImpl;
@override @useResult
$Res call({
 int done, int total
});




}
/// @nodoc
class __$StepCountCopyWithImpl<$Res>
    implements _$StepCountCopyWith<$Res> {
  __$StepCountCopyWithImpl(this._self, this._then);

  final _StepCount _self;
  final $Res Function(_StepCount) _then;

/// Create a copy of StepCount
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? done = null,Object? total = null,}) {
  return _then(_StepCount(
done: null == done ? _self.done : done // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$AssetSummary {

 int get charactersTotal; int get charactersConfirmed; int get locationsTotal; int get locationsConfirmed;
/// Create a copy of AssetSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssetSummaryCopyWith<AssetSummary> get copyWith => _$AssetSummaryCopyWithImpl<AssetSummary>(this as AssetSummary, _$identity);

  /// Serializes this AssetSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AssetSummary&&(identical(other.charactersTotal, charactersTotal) || other.charactersTotal == charactersTotal)&&(identical(other.charactersConfirmed, charactersConfirmed) || other.charactersConfirmed == charactersConfirmed)&&(identical(other.locationsTotal, locationsTotal) || other.locationsTotal == locationsTotal)&&(identical(other.locationsConfirmed, locationsConfirmed) || other.locationsConfirmed == locationsConfirmed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,charactersTotal,charactersConfirmed,locationsTotal,locationsConfirmed);

@override
String toString() {
  return 'AssetSummary(charactersTotal: $charactersTotal, charactersConfirmed: $charactersConfirmed, locationsTotal: $locationsTotal, locationsConfirmed: $locationsConfirmed)';
}


}

/// @nodoc
abstract mixin class $AssetSummaryCopyWith<$Res>  {
  factory $AssetSummaryCopyWith(AssetSummary value, $Res Function(AssetSummary) _then) = _$AssetSummaryCopyWithImpl;
@useResult
$Res call({
 int charactersTotal, int charactersConfirmed, int locationsTotal, int locationsConfirmed
});




}
/// @nodoc
class _$AssetSummaryCopyWithImpl<$Res>
    implements $AssetSummaryCopyWith<$Res> {
  _$AssetSummaryCopyWithImpl(this._self, this._then);

  final AssetSummary _self;
  final $Res Function(AssetSummary) _then;

/// Create a copy of AssetSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? charactersTotal = null,Object? charactersConfirmed = null,Object? locationsTotal = null,Object? locationsConfirmed = null,}) {
  return _then(_self.copyWith(
charactersTotal: null == charactersTotal ? _self.charactersTotal : charactersTotal // ignore: cast_nullable_to_non_nullable
as int,charactersConfirmed: null == charactersConfirmed ? _self.charactersConfirmed : charactersConfirmed // ignore: cast_nullable_to_non_nullable
as int,locationsTotal: null == locationsTotal ? _self.locationsTotal : locationsTotal // ignore: cast_nullable_to_non_nullable
as int,locationsConfirmed: null == locationsConfirmed ? _self.locationsConfirmed : locationsConfirmed // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AssetSummary].
extension AssetSummaryPatterns on AssetSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AssetSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AssetSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AssetSummary value)  $default,){
final _that = this;
switch (_that) {
case _AssetSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AssetSummary value)?  $default,){
final _that = this;
switch (_that) {
case _AssetSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int charactersTotal,  int charactersConfirmed,  int locationsTotal,  int locationsConfirmed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AssetSummary() when $default != null:
return $default(_that.charactersTotal,_that.charactersConfirmed,_that.locationsTotal,_that.locationsConfirmed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int charactersTotal,  int charactersConfirmed,  int locationsTotal,  int locationsConfirmed)  $default,) {final _that = this;
switch (_that) {
case _AssetSummary():
return $default(_that.charactersTotal,_that.charactersConfirmed,_that.locationsTotal,_that.locationsConfirmed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int charactersTotal,  int charactersConfirmed,  int locationsTotal,  int locationsConfirmed)?  $default,) {final _that = this;
switch (_that) {
case _AssetSummary() when $default != null:
return $default(_that.charactersTotal,_that.charactersConfirmed,_that.locationsTotal,_that.locationsConfirmed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AssetSummary implements AssetSummary {
  const _AssetSummary({this.charactersTotal = 0, this.charactersConfirmed = 0, this.locationsTotal = 0, this.locationsConfirmed = 0});
  factory _AssetSummary.fromJson(Map<String, dynamic> json) => _$AssetSummaryFromJson(json);

@override@JsonKey() final  int charactersTotal;
@override@JsonKey() final  int charactersConfirmed;
@override@JsonKey() final  int locationsTotal;
@override@JsonKey() final  int locationsConfirmed;

/// Create a copy of AssetSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AssetSummaryCopyWith<_AssetSummary> get copyWith => __$AssetSummaryCopyWithImpl<_AssetSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AssetSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AssetSummary&&(identical(other.charactersTotal, charactersTotal) || other.charactersTotal == charactersTotal)&&(identical(other.charactersConfirmed, charactersConfirmed) || other.charactersConfirmed == charactersConfirmed)&&(identical(other.locationsTotal, locationsTotal) || other.locationsTotal == locationsTotal)&&(identical(other.locationsConfirmed, locationsConfirmed) || other.locationsConfirmed == locationsConfirmed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,charactersTotal,charactersConfirmed,locationsTotal,locationsConfirmed);

@override
String toString() {
  return 'AssetSummary(charactersTotal: $charactersTotal, charactersConfirmed: $charactersConfirmed, locationsTotal: $locationsTotal, locationsConfirmed: $locationsConfirmed)';
}


}

/// @nodoc
abstract mixin class _$AssetSummaryCopyWith<$Res> implements $AssetSummaryCopyWith<$Res> {
  factory _$AssetSummaryCopyWith(_AssetSummary value, $Res Function(_AssetSummary) _then) = __$AssetSummaryCopyWithImpl;
@override @useResult
$Res call({
 int charactersTotal, int charactersConfirmed, int locationsTotal, int locationsConfirmed
});




}
/// @nodoc
class __$AssetSummaryCopyWithImpl<$Res>
    implements _$AssetSummaryCopyWith<$Res> {
  __$AssetSummaryCopyWithImpl(this._self, this._then);

  final _AssetSummary _self;
  final $Res Function(_AssetSummary) _then;

/// Create a copy of AssetSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? charactersTotal = null,Object? charactersConfirmed = null,Object? locationsTotal = null,Object? locationsConfirmed = null,}) {
  return _then(_AssetSummary(
charactersTotal: null == charactersTotal ? _self.charactersTotal : charactersTotal // ignore: cast_nullable_to_non_nullable
as int,charactersConfirmed: null == charactersConfirmed ? _self.charactersConfirmed : charactersConfirmed // ignore: cast_nullable_to_non_nullable
as int,locationsTotal: null == locationsTotal ? _self.locationsTotal : locationsTotal // ignore: cast_nullable_to_non_nullable
as int,locationsConfirmed: null == locationsConfirmed ? _self.locationsConfirmed : locationsConfirmed // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ReviewSummary {

 int get totalShots; int get pendingReview; int get approved; int get rejected;
/// Create a copy of ReviewSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReviewSummaryCopyWith<ReviewSummary> get copyWith => _$ReviewSummaryCopyWithImpl<ReviewSummary>(this as ReviewSummary, _$identity);

  /// Serializes this ReviewSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReviewSummary&&(identical(other.totalShots, totalShots) || other.totalShots == totalShots)&&(identical(other.pendingReview, pendingReview) || other.pendingReview == pendingReview)&&(identical(other.approved, approved) || other.approved == approved)&&(identical(other.rejected, rejected) || other.rejected == rejected));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalShots,pendingReview,approved,rejected);

@override
String toString() {
  return 'ReviewSummary(totalShots: $totalShots, pendingReview: $pendingReview, approved: $approved, rejected: $rejected)';
}


}

/// @nodoc
abstract mixin class $ReviewSummaryCopyWith<$Res>  {
  factory $ReviewSummaryCopyWith(ReviewSummary value, $Res Function(ReviewSummary) _then) = _$ReviewSummaryCopyWithImpl;
@useResult
$Res call({
 int totalShots, int pendingReview, int approved, int rejected
});




}
/// @nodoc
class _$ReviewSummaryCopyWithImpl<$Res>
    implements $ReviewSummaryCopyWith<$Res> {
  _$ReviewSummaryCopyWithImpl(this._self, this._then);

  final ReviewSummary _self;
  final $Res Function(ReviewSummary) _then;

/// Create a copy of ReviewSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalShots = null,Object? pendingReview = null,Object? approved = null,Object? rejected = null,}) {
  return _then(_self.copyWith(
totalShots: null == totalShots ? _self.totalShots : totalShots // ignore: cast_nullable_to_non_nullable
as int,pendingReview: null == pendingReview ? _self.pendingReview : pendingReview // ignore: cast_nullable_to_non_nullable
as int,approved: null == approved ? _self.approved : approved // ignore: cast_nullable_to_non_nullable
as int,rejected: null == rejected ? _self.rejected : rejected // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ReviewSummary].
extension ReviewSummaryPatterns on ReviewSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReviewSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReviewSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReviewSummary value)  $default,){
final _that = this;
switch (_that) {
case _ReviewSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReviewSummary value)?  $default,){
final _that = this;
switch (_that) {
case _ReviewSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalShots,  int pendingReview,  int approved,  int rejected)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReviewSummary() when $default != null:
return $default(_that.totalShots,_that.pendingReview,_that.approved,_that.rejected);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalShots,  int pendingReview,  int approved,  int rejected)  $default,) {final _that = this;
switch (_that) {
case _ReviewSummary():
return $default(_that.totalShots,_that.pendingReview,_that.approved,_that.rejected);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalShots,  int pendingReview,  int approved,  int rejected)?  $default,) {final _that = this;
switch (_that) {
case _ReviewSummary() when $default != null:
return $default(_that.totalShots,_that.pendingReview,_that.approved,_that.rejected);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReviewSummary implements ReviewSummary {
  const _ReviewSummary({this.totalShots = 0, this.pendingReview = 0, this.approved = 0, this.rejected = 0});
  factory _ReviewSummary.fromJson(Map<String, dynamic> json) => _$ReviewSummaryFromJson(json);

@override@JsonKey() final  int totalShots;
@override@JsonKey() final  int pendingReview;
@override@JsonKey() final  int approved;
@override@JsonKey() final  int rejected;

/// Create a copy of ReviewSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReviewSummaryCopyWith<_ReviewSummary> get copyWith => __$ReviewSummaryCopyWithImpl<_ReviewSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReviewSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReviewSummary&&(identical(other.totalShots, totalShots) || other.totalShots == totalShots)&&(identical(other.pendingReview, pendingReview) || other.pendingReview == pendingReview)&&(identical(other.approved, approved) || other.approved == approved)&&(identical(other.rejected, rejected) || other.rejected == rejected));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalShots,pendingReview,approved,rejected);

@override
String toString() {
  return 'ReviewSummary(totalShots: $totalShots, pendingReview: $pendingReview, approved: $approved, rejected: $rejected)';
}


}

/// @nodoc
abstract mixin class _$ReviewSummaryCopyWith<$Res> implements $ReviewSummaryCopyWith<$Res> {
  factory _$ReviewSummaryCopyWith(_ReviewSummary value, $Res Function(_ReviewSummary) _then) = __$ReviewSummaryCopyWithImpl;
@override @useResult
$Res call({
 int totalShots, int pendingReview, int approved, int rejected
});




}
/// @nodoc
class __$ReviewSummaryCopyWithImpl<$Res>
    implements _$ReviewSummaryCopyWith<$Res> {
  __$ReviewSummaryCopyWithImpl(this._self, this._then);

  final _ReviewSummary _self;
  final $Res Function(_ReviewSummary) _then;

/// Create a copy of ReviewSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalShots = null,Object? pendingReview = null,Object? approved = null,Object? rejected = null,}) {
  return _then(_ReviewSummary(
totalShots: null == totalShots ? _self.totalShots : totalShots // ignore: cast_nullable_to_non_nullable
as int,pendingReview: null == pendingReview ? _self.pendingReview : pendingReview // ignore: cast_nullable_to_non_nullable
as int,approved: null == approved ? _self.approved : approved // ignore: cast_nullable_to_non_nullable
as int,rejected: null == rejected ? _self.rejected : rejected // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$DashboardEpisode {

 String? get id; String get title; int get sortIndex; String get summary; String get status; int get currentStep; String get currentPhase; int get sceneCount; List<String> get characterNames; DateTime? get lastActiveAt; DateTime? get createdAt; EpisodeProgress? get progress;
/// Create a copy of DashboardEpisode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardEpisodeCopyWith<DashboardEpisode> get copyWith => _$DashboardEpisodeCopyWithImpl<DashboardEpisode>(this as DashboardEpisode, _$identity);

  /// Serializes this DashboardEpisode to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardEpisode&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.sortIndex, sortIndex) || other.sortIndex == sortIndex)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.status, status) || other.status == status)&&(identical(other.currentStep, currentStep) || other.currentStep == currentStep)&&(identical(other.currentPhase, currentPhase) || other.currentPhase == currentPhase)&&(identical(other.sceneCount, sceneCount) || other.sceneCount == sceneCount)&&const DeepCollectionEquality().equals(other.characterNames, characterNames)&&(identical(other.lastActiveAt, lastActiveAt) || other.lastActiveAt == lastActiveAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.progress, progress) || other.progress == progress));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,sortIndex,summary,status,currentStep,currentPhase,sceneCount,const DeepCollectionEquality().hash(characterNames),lastActiveAt,createdAt,progress);

@override
String toString() {
  return 'DashboardEpisode(id: $id, title: $title, sortIndex: $sortIndex, summary: $summary, status: $status, currentStep: $currentStep, currentPhase: $currentPhase, sceneCount: $sceneCount, characterNames: $characterNames, lastActiveAt: $lastActiveAt, createdAt: $createdAt, progress: $progress)';
}


}

/// @nodoc
abstract mixin class $DashboardEpisodeCopyWith<$Res>  {
  factory $DashboardEpisodeCopyWith(DashboardEpisode value, $Res Function(DashboardEpisode) _then) = _$DashboardEpisodeCopyWithImpl;
@useResult
$Res call({
 String? id, String title, int sortIndex, String summary, String status, int currentStep, String currentPhase, int sceneCount, List<String> characterNames, DateTime? lastActiveAt, DateTime? createdAt, EpisodeProgress? progress
});


$EpisodeProgressCopyWith<$Res>? get progress;

}
/// @nodoc
class _$DashboardEpisodeCopyWithImpl<$Res>
    implements $DashboardEpisodeCopyWith<$Res> {
  _$DashboardEpisodeCopyWithImpl(this._self, this._then);

  final DashboardEpisode _self;
  final $Res Function(DashboardEpisode) _then;

/// Create a copy of DashboardEpisode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? title = null,Object? sortIndex = null,Object? summary = null,Object? status = null,Object? currentStep = null,Object? currentPhase = null,Object? sceneCount = null,Object? characterNames = null,Object? lastActiveAt = freezed,Object? createdAt = freezed,Object? progress = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,sortIndex: null == sortIndex ? _self.sortIndex : sortIndex // ignore: cast_nullable_to_non_nullable
as int,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,currentStep: null == currentStep ? _self.currentStep : currentStep // ignore: cast_nullable_to_non_nullable
as int,currentPhase: null == currentPhase ? _self.currentPhase : currentPhase // ignore: cast_nullable_to_non_nullable
as String,sceneCount: null == sceneCount ? _self.sceneCount : sceneCount // ignore: cast_nullable_to_non_nullable
as int,characterNames: null == characterNames ? _self.characterNames : characterNames // ignore: cast_nullable_to_non_nullable
as List<String>,lastActiveAt: freezed == lastActiveAt ? _self.lastActiveAt : lastActiveAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,progress: freezed == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as EpisodeProgress?,
  ));
}
/// Create a copy of DashboardEpisode
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EpisodeProgressCopyWith<$Res>? get progress {
    if (_self.progress == null) {
    return null;
  }

  return $EpisodeProgressCopyWith<$Res>(_self.progress!, (value) {
    return _then(_self.copyWith(progress: value));
  });
}
}


/// Adds pattern-matching-related methods to [DashboardEpisode].
extension DashboardEpisodePatterns on DashboardEpisode {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DashboardEpisode value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DashboardEpisode() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DashboardEpisode value)  $default,){
final _that = this;
switch (_that) {
case _DashboardEpisode():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DashboardEpisode value)?  $default,){
final _that = this;
switch (_that) {
case _DashboardEpisode() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String title,  int sortIndex,  String summary,  String status,  int currentStep,  String currentPhase,  int sceneCount,  List<String> characterNames,  DateTime? lastActiveAt,  DateTime? createdAt,  EpisodeProgress? progress)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DashboardEpisode() when $default != null:
return $default(_that.id,_that.title,_that.sortIndex,_that.summary,_that.status,_that.currentStep,_that.currentPhase,_that.sceneCount,_that.characterNames,_that.lastActiveAt,_that.createdAt,_that.progress);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String title,  int sortIndex,  String summary,  String status,  int currentStep,  String currentPhase,  int sceneCount,  List<String> characterNames,  DateTime? lastActiveAt,  DateTime? createdAt,  EpisodeProgress? progress)  $default,) {final _that = this;
switch (_that) {
case _DashboardEpisode():
return $default(_that.id,_that.title,_that.sortIndex,_that.summary,_that.status,_that.currentStep,_that.currentPhase,_that.sceneCount,_that.characterNames,_that.lastActiveAt,_that.createdAt,_that.progress);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String title,  int sortIndex,  String summary,  String status,  int currentStep,  String currentPhase,  int sceneCount,  List<String> characterNames,  DateTime? lastActiveAt,  DateTime? createdAt,  EpisodeProgress? progress)?  $default,) {final _that = this;
switch (_that) {
case _DashboardEpisode() when $default != null:
return $default(_that.id,_that.title,_that.sortIndex,_that.summary,_that.status,_that.currentStep,_that.currentPhase,_that.sceneCount,_that.characterNames,_that.lastActiveAt,_that.createdAt,_that.progress);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DashboardEpisode implements DashboardEpisode {
  const _DashboardEpisode({this.id, this.title = '', this.sortIndex = 0, this.summary = '', this.status = 'not_started', this.currentStep = 0, this.currentPhase = 'story', this.sceneCount = 0, final  List<String> characterNames = const [], this.lastActiveAt, this.createdAt, this.progress}): _characterNames = characterNames;
  factory _DashboardEpisode.fromJson(Map<String, dynamic> json) => _$DashboardEpisodeFromJson(json);

@override final  String? id;
@override@JsonKey() final  String title;
@override@JsonKey() final  int sortIndex;
@override@JsonKey() final  String summary;
@override@JsonKey() final  String status;
@override@JsonKey() final  int currentStep;
@override@JsonKey() final  String currentPhase;
@override@JsonKey() final  int sceneCount;
 final  List<String> _characterNames;
@override@JsonKey() List<String> get characterNames {
  if (_characterNames is EqualUnmodifiableListView) return _characterNames;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_characterNames);
}

@override final  DateTime? lastActiveAt;
@override final  DateTime? createdAt;
@override final  EpisodeProgress? progress;

/// Create a copy of DashboardEpisode
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardEpisodeCopyWith<_DashboardEpisode> get copyWith => __$DashboardEpisodeCopyWithImpl<_DashboardEpisode>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DashboardEpisodeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DashboardEpisode&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.sortIndex, sortIndex) || other.sortIndex == sortIndex)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.status, status) || other.status == status)&&(identical(other.currentStep, currentStep) || other.currentStep == currentStep)&&(identical(other.currentPhase, currentPhase) || other.currentPhase == currentPhase)&&(identical(other.sceneCount, sceneCount) || other.sceneCount == sceneCount)&&const DeepCollectionEquality().equals(other._characterNames, _characterNames)&&(identical(other.lastActiveAt, lastActiveAt) || other.lastActiveAt == lastActiveAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.progress, progress) || other.progress == progress));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,sortIndex,summary,status,currentStep,currentPhase,sceneCount,const DeepCollectionEquality().hash(_characterNames),lastActiveAt,createdAt,progress);

@override
String toString() {
  return 'DashboardEpisode(id: $id, title: $title, sortIndex: $sortIndex, summary: $summary, status: $status, currentStep: $currentStep, currentPhase: $currentPhase, sceneCount: $sceneCount, characterNames: $characterNames, lastActiveAt: $lastActiveAt, createdAt: $createdAt, progress: $progress)';
}


}

/// @nodoc
abstract mixin class _$DashboardEpisodeCopyWith<$Res> implements $DashboardEpisodeCopyWith<$Res> {
  factory _$DashboardEpisodeCopyWith(_DashboardEpisode value, $Res Function(_DashboardEpisode) _then) = __$DashboardEpisodeCopyWithImpl;
@override @useResult
$Res call({
 String? id, String title, int sortIndex, String summary, String status, int currentStep, String currentPhase, int sceneCount, List<String> characterNames, DateTime? lastActiveAt, DateTime? createdAt, EpisodeProgress? progress
});


@override $EpisodeProgressCopyWith<$Res>? get progress;

}
/// @nodoc
class __$DashboardEpisodeCopyWithImpl<$Res>
    implements _$DashboardEpisodeCopyWith<$Res> {
  __$DashboardEpisodeCopyWithImpl(this._self, this._then);

  final _DashboardEpisode _self;
  final $Res Function(_DashboardEpisode) _then;

/// Create a copy of DashboardEpisode
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? title = null,Object? sortIndex = null,Object? summary = null,Object? status = null,Object? currentStep = null,Object? currentPhase = null,Object? sceneCount = null,Object? characterNames = null,Object? lastActiveAt = freezed,Object? createdAt = freezed,Object? progress = freezed,}) {
  return _then(_DashboardEpisode(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,sortIndex: null == sortIndex ? _self.sortIndex : sortIndex // ignore: cast_nullable_to_non_nullable
as int,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,currentStep: null == currentStep ? _self.currentStep : currentStep // ignore: cast_nullable_to_non_nullable
as int,currentPhase: null == currentPhase ? _self.currentPhase : currentPhase // ignore: cast_nullable_to_non_nullable
as String,sceneCount: null == sceneCount ? _self.sceneCount : sceneCount // ignore: cast_nullable_to_non_nullable
as int,characterNames: null == characterNames ? _self._characterNames : characterNames // ignore: cast_nullable_to_non_nullable
as List<String>,lastActiveAt: freezed == lastActiveAt ? _self.lastActiveAt : lastActiveAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,progress: freezed == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as EpisodeProgress?,
  ));
}

/// Create a copy of DashboardEpisode
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EpisodeProgressCopyWith<$Res>? get progress {
    if (_self.progress == null) {
    return null;
  }

  return $EpisodeProgressCopyWith<$Res>(_self.progress!, (value) {
    return _then(_self.copyWith(progress: value));
  });
}
}

// dart format on
