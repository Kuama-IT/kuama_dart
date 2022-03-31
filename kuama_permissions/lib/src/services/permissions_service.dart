import 'package:get_it/get_it.dart';
import 'package:kuama_permissions/src/failures.dart';
import 'package:kuama_permissions/src/repositories/permissions_manger_repository.dart';
import 'package:kuama_permissions/src/repositories/permissions_preferences_repository.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
import 'package:pure_extensions/pure_extensions.dart';

/// It allows you to check the status, preferences of permissions and to update, request them
///
/// Flow:
/// 1. Check permissions with [checkPermissions]
/// 2. Ask the user if you can request permissions
/// 3. Based on the user's response, execute:
///   * Doesn't allow, call [addUnRequestPermissions] to save the permissions as un-request
///   * Allow, you calls [requestPermissions] to request permissions from the user
class PermissionsService {
  PermissionsPreferencesRepository get _preferences => GetIt.I();
  PermissionsManagerRepository get _handler => GetIt.I();

  /// Failures:
  /// - [FailedOpenAppPageFailure]
  Future<void> openAppSettings() async {
    final res = await _handler.openAppSettings();
    if (res) return;
    throw FailedOpenAppPageFailure(AppPage.settings);
  }

  /// Check permission status
  ///
  /// Permission status:
  /// - [PermissionStatus.granted] When permission is allowed
  /// - [PermissionStatus.denied] When the user has already denied ask permission.
  ///   You can call [requestPermissions]
  /// - [PermissionStatus.permanentlyDenied] When the permit is denied forever. The user to enable
  ///   the permission must do it externally from the app. For example use [openAppSettings]
  Future<Map<Permission, PermissionStatus>> checkPermissions(List<Permission> permissions) async {
    final preferencesPermissions = _preferences.check(permissions);
    final results = await _handler.checkPermissions(permissions);

    final grantedPermissions = results
        .where((key, value) => preferencesPermissions.containsKey(key) && value.isGranted)
        .keys;
    if (grantedPermissions.isNotEmpty) {
      await _preferences.update(grantedPermissions.toList(), true);
    }

    final unRequestPermission = preferencesPermissions.where((_, canRequest) => !canRequest).keys;

    return {
      for (final permission in unRequestPermission) permission: PermissionStatus.denied,
      ...results.where((_, status) => status.isGranted || status.isPermanentlyDenied),
    };
  }

  /// All [permissions] will be saved in the user's preferences as not requestable
  Future<void> addUnRequestPermissions(List<Permission> permissions) async {
    await _preferences.update(permissions, false);
  }

  /// Requests permissions
  ///
  /// All [permissions] will be saved in the user's preferences as requestable and if some
  /// permissions have been denied, they will be updated as not requestable
  Future<Map<Permission, PermissionStatus>> requestPermissions(List<Permission> permissions) async {
    await _preferences.update(permissions, true);

    final result = await _handler.requestPermissions(permissions);

    final deniedPermissions = result
        .where((permission, status) {
          return status.isDenied || status.isPermanentlyDenied;
        })
        .keys
        .toList();

    await _preferences.update(deniedPermissions, false);

    return result;
  }
}
