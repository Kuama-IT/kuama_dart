import 'package:get_it/get_it.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Allows you to read and save user preferences regarding app permissions
///
/// Allows to persist a pair [Permission] - [bool],
/// [bool] represents whether the [Permission] has already been asked.
///
/// ```dart
/// final repo = StoragePermissionsRepository();
///
/// final canAsk = await repo.checkAsked([Permission.activityRecognition])
/// if(!canAsk[Permission.activityRecognition]) {
///   // ask Permission.activityRecognition to your user
/// }
/// ```
class PermissionsPreferencesRepository {
  SharedPreferences get _preferences => GetIt.I();

  /// Returns which permissions have already been asked
  Map<Permission, bool> checkAsked(List<Permission> permissions) {
    return {
      for (final permission in permissions)
        permission: _preferences.getBool('$permission') ?? false,
    };
  }

  /// Update the permissions preferences if they can't be requested
  Future<void> markAsked(List<Permission> permissions) async {
    await Future.wait(permissions.map((permission) async {
      await _preferences.setBool('$permission', true);
    }));
  }
}
