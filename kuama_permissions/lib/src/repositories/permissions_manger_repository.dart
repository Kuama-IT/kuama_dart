import 'package:get_it/get_it.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';

/// Proxy over a [PermissionHandlerPlatform] implementation
class PermissionsManagerRepository {
  PermissionHandlerPlatform get _handler => GetIt.I();

  /// Returns `true` if the app settings page could be opened, otherwise `false`.
  Future<bool> openAppSettings() async {
    return await _handler.openAppSettings();
  }

  /// Retrieves the [ServiceStatus] of each given [Permission]
  Future<ServiceStatus> checkService(Permission permission) async {
    return await _handler.checkServiceStatus(permission);
  }

  /// Retrieves the [PermissionStatus] of each given [Permission]
  ///
  /// Returns a [Map] containing the status of each requested [Permission].
  Future<Map<Permission, PermissionStatus>> checkPermissions(List<Permission> permissions) async {
    final results = await Future.wait(permissions.map((permission) async {
      return _handler.checkPermissionStatus(permission);
    }));
    return Map.fromIterables(permissions, results);
  }

  /// Requests the user for access to the supplied list of [Permission]s, if
  /// they have not already been granted before.
  ///
  /// Returns a [Map] containing the status per requested [Permission].
  Future<Map<Permission, PermissionStatus>> requestPermissions(List<Permission> permissions) async {
    return await _handler.requestPermissions(permissions);
  }
}
