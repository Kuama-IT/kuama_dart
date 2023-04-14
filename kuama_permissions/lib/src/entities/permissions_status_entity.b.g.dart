// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'permissions_status_entity.b.dart';

// **************************************************************************
// DataClassGenerator
// **************************************************************************

mixin _$PermissionsStatusEntity {
  PermissionsStatusEntity get _self => this as PermissionsStatusEntity;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PermissionsStatusEntity &&
          runtimeType == other.runtimeType &&
          _self.canResolve == other.canResolve &&
          _self.areAllGrantedAndEnabled == other.areAllGrantedAndEnabled &&
          $mapEquality.equals(_self.permissions, other.permissions) &&
          $mapEquality.equals(_self.services, other.services);
  @override
  int get hashCode {
    var hashCode = 0;
    hashCode = $hashCombine(hashCode, _self.canResolve.hashCode);
    hashCode = $hashCombine(hashCode, _self.areAllGrantedAndEnabled.hashCode);
    hashCode = $hashCombine(hashCode, $mapEquality.hash(_self.permissions));
    hashCode = $hashCombine(hashCode, $mapEquality.hash(_self.services));
    return $hashFinish(hashCode);
  }

  @override
  String toString() => (ClassToString('PermissionsStatusEntity')
        ..add('canResolve', _self.canResolve)
        ..add('areAllGrantedAndEnabled', _self.areAllGrantedAndEnabled)
        ..add('permissions', _self.permissions)
        ..add('services', _self.services))
      .toString();
}
