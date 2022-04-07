import 'package:permission_handler/permission_handler.dart';

enum Service { location, bluetooth }

enum PermissionServiceStatus { enabled, disabled, denied }

extension PermissionToService on Permission {
  Service? toService() {
    for (final service in Service.values) {
      if (service.toPermissions().contains(this)) {
        return service;
      }
    }
    return null;
  }
}

extension ServiceToPermissions on Service {
  List<Permission> toPermissions() {
    switch (this) {
      case Service.location:
        return [Permission.location, Permission.locationAlways, Permission.locationWhenInUse];
      case Service.bluetooth:
        return [
          Permission.bluetooth,
          Permission.bluetoothScan,
          Permission.bluetoothAdvertise,
          Permission.bluetoothConnect
        ];
    }
  }

  Permission toPermission() => toPermissions().first;
}
