// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'permissions_bloc.b.dart';

// **************************************************************************
// DataClassGenerator
// **************************************************************************

// ignore_for_file: annotate_overrides

mixin _$PermissionsBlocState {
  PermissionsBlocState get _self => this as PermissionsBlocState;

  Iterable<Object?> get _props sync* {
    yield _self.places;
    yield _self.status;
  }

  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _$PermissionsBlocState &&
          runtimeType == other.runtimeType &&
          DataClass.$equals(_props, other._props);

  int get hashCode => Object.hashAll(_props);

  String toString() => (ClassToString('PermissionsBlocState')
        ..add('places', _self.places)
        ..add('status', _self.status))
      .toString();

  PermissionsBlocState copyWith({
    Map<Permission, PermissionPlace>? places,
    Map<Permission, PermissionStatus>? status,
  }) {
    return PermissionsBlocState(
      places: places ?? _self.places,
      status: status ?? _self.status,
    );
  }
}
