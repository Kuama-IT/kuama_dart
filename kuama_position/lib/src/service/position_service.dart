import 'package:get_it/get_it.dart';
import 'package:kuama_position/src/repositories/position_repository.dart';
import 'package:pure_extensions/pure_extensions.dart';

// TODO: Handle exception in geolocator_platform_interface/src/implementations/method_channel_geolocator.dart:229
class PositionService {
  PositionRepository get locatorRepo => GetIt.I();

  /// Check if the position service is enabled
  Future<bool> checkService() async {
    return await locatorRepo.checkService();
  }

  /// Request the current position of the user
  Future<GeoPoint> getCurrentPosition() async {
    return await locatorRepo.currentPosition;
  }

  /// Track the current position of the user
  Stream<GeoPoint> get onPositionChanges {
    return locatorRepo.onPositionChanges;
  }

  /// Receive the service status of the location
  @Deprecated('Use PermissionsBloc')
  Stream<bool> get onServiceChanges {
    return locatorRepo.onServiceChanges;
  }

  /// Open the position service page to enable it
  @Deprecated('Use PermissionsBloc')
  Future<bool> openServicePage() async {
    return await locatorRepo.openServicePage();
  }
}
