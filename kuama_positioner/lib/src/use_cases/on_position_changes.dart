import 'package:get_it/get_it.dart';
import 'package:kuama_flutter/kuama_flutter.dart';
import 'package:kuama_flutter/src/features/positioner/repositories/position_repository.dart';
import 'package:pure_extensions/pure_extensions.dart';

/// Track the current position of the user
class OnPositionChanges extends StreamUseCase<NoParams, GeoPoint> {
  final PositionRepository locatorRepo = GetIt.I();

  @override
  Stream<GeoPoint> onCall(NoParams params) {
    return locatorRepo.onPositionChanges;
  }
}

class LocationServiceDisabledFailure extends Failure {
  LocationServiceDisabledFailure({ErrorAndStackTrace? error}) : super(error: error);

  @override
  String get onMessage => 'LocationServiceDisabledFailure';
}

class PermissionDeniedFailure extends Failure {
  PermissionDeniedFailure({ErrorAndStackTrace? error}) : super(error: error);

  @override
  String get onMessage => 'PermissionDeniedFailure';
}

/*
 switch (exception.code) {
      case 'ACTIVITY_MISSING':
        throw ActivityMissingException(exception.message);
      case 'LOCATION_SERVICES_DISABLED':
        throw LocationServiceDisabledException();
      case 'LOCATION_SUBSCRIPTION_ACTIVE':
        throw AlreadySubscribedException();
      case 'PERMISSION_DEFINITIONS_NOT_FOUND':
        throw PermissionDefinitionsNotFoundException(exception.message);
      case 'PERMISSION_DENIED':
        throw PermissionDeniedException(exception.message);
      case 'PERMISSION_REQUEST_IN_PROGRESS':
        throw PermissionRequestInProgressException(exception.message);
      case 'LOCATION_UPDATE_FAILURE':
        throw PositionUpdateException(exception.message);
      default:
        throw exception;
    }
 */
