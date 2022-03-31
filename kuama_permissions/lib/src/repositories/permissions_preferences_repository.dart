import 'package:get_it/get_it.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Allows you to read and save user preferences regarding app permissions
///
/// Allows to persist a pair [Permission] - [bool],
/// where the boolean value is `true` if you can ask for the key [Permission]
///
/// ```dart
/// final repo = StoragePermissionsRepository();
///
/// final canAsk = await repo.read([Permission.activityRecognition])
/// if(canAsk[Permission.activityRecognition]) {
///   // ask Permission.activityRecognition to your user
/// }
/// ```
class PermissionsPreferencesRepository {
  SharedPreferences get _preferences => GetIt.I();

  /// For each permission it will be provided if the user has left
  /// a preference regarding accepting or denying the permission.
  ///
  /// If the permission is not included in the map the user has no preference
  Map<Permission, bool> check(List<Permission> canRequestPermissions) {
    final results = canRequestPermissions.map(_checkCanRequest);
    return Map.fromIterables(canRequestPermissions, results);
  }

  /// Update the permissions preferences if they can be requested
  Future<void> update(List<Permission> permissions, bool canRequest) async {
    await Future.wait(permissions.map((p) => _updateCanRequest(p, canRequest)));
  }

  bool _checkCanRequest(Permission permission) {
    return _preferences.getBool('$permission') ?? true;
  }

  Future<void> _updateCanRequest(Permission permission, bool canResolve) async {
    await _preferences.setBool('$permission', canResolve);
  }
}
