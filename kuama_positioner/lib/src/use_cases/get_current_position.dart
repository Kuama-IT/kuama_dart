import 'package:get_it/get_it.dart';
import 'package:kuama_flutter/kuama_flutter.dart' show UseCase, NoParams;
import 'package:kuama_positioner/src/repositories/position_repository.dart';
import 'package:pure_extensions/pure_extensions.dart';

/// Request the current position of the user
class GetCurrentPosition extends UseCase<NoParams, GeoPoint> {
  final PositionRepository locatorRepo = GetIt.I();

  @override
  Future<GeoPoint> onCall(NoParams params) async {
    return await locatorRepo.currentPosition;
  }
}
