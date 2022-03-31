import 'package:permission_handler/permission_handler.dart';

extension PermissionsMapExtensions on Map<Permission, PermissionStatus> {
  bool get areGranted => values.every((permission) => permission.isGranted);
}
