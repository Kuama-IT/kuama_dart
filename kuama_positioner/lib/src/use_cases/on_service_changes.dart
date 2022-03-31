import 'package:get_it/get_it.dart';
import 'package:kuama_flutter/src/features/positioner/repositories/position_repository.dart';
import 'package:kuama_flutter/src/shared/feature_structure/use_case/params.dart';
import 'package:kuama_flutter/src/shared/feature_structure/use_case/use_case.dart';

/// Receive the service status of the location
class OnPositionServiceChanges extends StreamUseCase<NoParams, bool> {
  final PositionRepository locatorRepo = GetIt.I();

  @override
  Stream<bool> onCall(NoParams params) {
    return locatorRepo.onServiceChanges;
  }
}
