// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'permissions_status_entity.b.dart';

// **************************************************************************
// DataClassGenerator
// **************************************************************************

// ignore_for_file: annotate_overrides

mixin _$PermissionsStatusEntity {
  PermissionsStatusEntity get _self => this as PermissionsStatusEntity;

  Iterable<Object?> get _props sync* {
    yield _self.canAsk;
    yield _self.areAllGrantedAndEnabled;
    yield _self.permissions;
    yield _self.services;
  }

  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _$PermissionsStatusEntity &&
          runtimeType == other.runtimeType &&
          DataClass.$equals(_props, other._props);

  int get hashCode => Object.hashAll(_props);

  String toString() => (ClassToString('PermissionsStatusEntity')
        ..add('canAsk', _self.canAsk)
        ..add('areAllGrantedAndEnabled', _self.areAllGrantedAndEnabled)
        ..add('permissions', _self.permissions)
        ..add('services', _self.services))
      .toString();
}
