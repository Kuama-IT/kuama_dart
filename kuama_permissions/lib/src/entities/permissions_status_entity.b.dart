import 'package:kuama_permissions/src/entities/service.dart';
import 'package:mek_data_class/mek_data_class.dart';
import 'package:permission_handler/permission_handler.dart';

part 'permissions_status_entity.b.g.dart';

@DataClass(changeable: false)
class PermissionsStatusEntity with _$PermissionsStatusEntity {
  /// Whether the permissions can been asked or requested
  final bool canResolve;

  /// Whether all permissions are granted and services are enabled
  final bool areAllGrantedAndEnabled;

  final Map<Permission, PermissionStatus> permissions;

  final Map<Service, bool> services;

  const PermissionsStatusEntity({
    required this.canResolve,
    required this.areAllGrantedAndEnabled,
    required this.permissions,
    required this.services,
  });
}
