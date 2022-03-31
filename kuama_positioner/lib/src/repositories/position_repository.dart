import 'package:pure_extensions/pure_extensions.dart';

abstract class PositionRepository {
  PositionRepository._();

  /// Open the position service page to enable it
  Future<bool> openServicePage();

  /// Check if the position service is enabled
  Future<bool> checkService();

  /// Receive the service status of the location
  Stream<bool> get onServiceChanges;

  /// Request the current position of the user
  Future<GeoPoint> get currentPosition;

  /// Track the current position of the user
  Stream<GeoPoint> get onPositionChanges;
}
