import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:kuama_permissions/kuama_permissions.dart';

class ServicesRepositoryImpl extends ServicesRepositoryBase {
  GeolocatorPlatform get geolocator => GetIt.I();

  @override
  Stream<bool> get onPositionChanges {
    return geolocator.getServiceStatusStream().map((event) => event == ServiceStatus.enabled);
  }
}
