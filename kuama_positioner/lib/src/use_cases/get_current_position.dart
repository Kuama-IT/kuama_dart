import 'package:get_it/get_it.dart';
import 'package:kuama_flutter/src/features/positioner/repositories/position_repository.dart';
import 'package:kuama_flutter/src/shared/feature_structure/use_case/params.dart';
import 'package:kuama_flutter/src/shared/feature_structure/use_case/use_case.dart';
import 'package:pure_extensions/pure_extensions.dart';

/// Request the current position of the user
class GetCurrentPosition extends UseCase<NoParams, GeoPoint> {
  final PositionRepository locatorRepo = GetIt.I();

  @override
  Future<GeoPoint> onCall(NoParams params) async {
    return await locatorRepo.currentPosition;
  }
}
