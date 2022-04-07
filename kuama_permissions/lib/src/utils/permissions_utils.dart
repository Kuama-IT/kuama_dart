import 'package:permission_handler/permission_handler.dart';

extension NamePermission on Permission {
  String get name => toString().split('.').last;
}

extension MapPermissionStatus on PermissionStatus {
  R map<R>({
    R Function()? denied,
    R Function()? permanentlyDenied,
    R Function()? granted,
    required R Function() orElse,
  }) {
    switch (this) {
      case PermissionStatus.denied:
        return (denied ?? orElse)();
      case PermissionStatus.granted:
        return (granted ?? orElse)();
      case PermissionStatus.restricted:
        return orElse();
      case PermissionStatus.limited:
        return orElse();
      case PermissionStatus.permanentlyDenied:
        return (permanentlyDenied ?? orElse)();
    }
  }
}
