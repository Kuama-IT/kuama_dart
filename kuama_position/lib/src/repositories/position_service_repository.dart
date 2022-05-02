import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:kuama_permissions/kuama_permissions.dart';

mixin PositionServiceRepository on ServicesRepository {
  GeolocatorPlatform get _geoLocator => GetIt.I();

  @override
  Stream<bool> get onPositionChanges {
    return _geoLocator.getServiceStatusStream().map((status) => status == ServiceStatus.enabled);
  }
}
