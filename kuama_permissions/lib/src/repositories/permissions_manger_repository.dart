import 'package:get_it/get_it.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
import 'package:pure_extensions/pure_extensions.dart';

/// Proxy over a [PermissionHandlerPlatform] implementation
class PermissionsManagerRepository {
  PermissionHandlerPlatform get _handler => GetIt.I();

  /// Returns [true] if the app settings page could be opened, otherwise  [false].
  Future<bool> openAppSettings() async {
    return await _handler.openAppSettings();
  }

  /// Retrieves the [PermissionStatus] of each given [Permission]
  ///
  /// Returns a [Map] containing the status of each requested [Permission].
  Future<Map<Permission, PermissionStatus>> checkPermissions(List<Permission> permissions) async {
    final results = await permissions.map((permission) async {
      return _handler.checkPermissionStatus(permission);
    }).waitFutures();
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
