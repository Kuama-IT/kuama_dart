import 'package:get_it/get_it.dart';
import 'package:kuama_permissions/src/entities/permissions_status_entity.b.dart';
import 'package:kuama_permissions/src/entities/service.dart';
import 'package:kuama_permissions/src/failures.dart';
import 'package:kuama_permissions/src/repositories/app_lifecycle_state_repository.dart';
import 'package:kuama_permissions/src/repositories/permissions_manger_repository.dart';
import 'package:kuama_permissions/src/repositories/permissions_preferences_repository.dart';
import 'package:kuama_permissions/src/repositories/services_repository.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
import 'package:pure_extensions/pure_extensions.dart';

/// It allows you to check the status or preferences of the permissions and to update or request them
///
/// Flow:
/// 1. Check permissions with [checkStatus]
/// 2. Request the permissions with [requestPermissions]
class PermissionsService {
  PermissionsPreferencesRepository get _preferences => GetIt.I();
  PermissionsManagerRepository get _handler => GetIt.I();
  AppLifecycleStateRepository get _appLifecycleState => GetIt.I();
  ServicesRepository get _services => GetIt.I();

  /// Failures:
  /// - [FailedOpenAppPageFailure]
  Future<void> openAppSettings() async {
    final res = await _handler.openAppSettings();
    if (res) return;
    throw FailedOpenAppPageFailure(AppPage.settings);
  }

  /// Listen to a service status changes
  Stream<bool> onServiceChanges(Service service) {
    switch (service) {
      case Service.location:
        return _services.onPositionChanges;
      case Service.bluetooth:
        return _services.onBluetoothChanges;
    }
  }

  /// Check permission status
  ///
  /// If the returned status is "disabled", enable it and check again before requesting
  /// the permissions once more. (This is mandatory in Android)
  Future<PermissionsStatusEntity> checkStatus(
    List<Permission> permissions, {
    bool tryAgain = false,
  }) async {
    final preferencesPermissions = _preferences.checkAsked(permissions);
    final canAsk = preferencesPermissions.any((_, isAsked) => !isAsked);

    var checkedPermissions = await _handler.checkPermissions(permissions);

    final services = permissions.map((permission) => permission.toService()).whereNotNull();
    final checkedServices = await _checkServices(services.toList());

    final isAllGranted = checkedPermissions.every((_, status) => status.isGranted);
    final isAllEnabled = checkedServices.every((_, status) => status);

    return PermissionsStatusEntity(
      canAsk: canAsk || tryAgain,
      areAllGrantedAndEnabled: isAllGranted && isAllEnabled,
      permissions: checkedPermissions,
      services: checkedServices,
    );
  }

  /// Mark [permissions] as "not requestable"
  Future<void> markAskedPermissions(List<Permission> permissions) async {
    await _preferences.markAsked(permissions);
  }

  /// Requests [permissions] and mark them as "not requestable"
  Future<Map<Permission, PermissionStatus>> requestPermissions(List<Permission> permissions) async {
    await _preferences.markAsked(permissions);

    return await _handler.requestPermissions(permissions);
  }

  Stream<void> get onRequiredPermissionsRefresh async* {
    AppLifecycleState prevState = AppLifecycleState.paused;
    await for (final state in _appLifecycleState.onChanges) {
      if (prevState == AppLifecycleState.paused && state == AppLifecycleState.resumed) {
        yield null;
      }
      prevState = state;
    }
  }

  Future<Map<Service, bool>> _checkServices(List<Service> services) async {
    final results = await Future.wait(services.map((service) async {
      final result = await _handler.checkService(service.toPermission());
      return MapEntry(service, result);
    }));
    return results.map((e) {
      assert(e.value != ServiceStatus.notApplicable, '`${e.key}` not has applicable service');
      return MapEntry(e.key, e.value == ServiceStatus.enabled);
    }).toMap();
  }
}
