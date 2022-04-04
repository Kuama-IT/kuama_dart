import 'package:get_it/get_it.dart';
import 'package:kuama_flutter/kuama_flutter.dart' show StreamUseCase, NoParams;
import 'package:kuama_positioner/src/repositories/position_repository.dart';

/// Receive the service status of the location
class OnPositionServiceChanges extends StreamUseCase<NoParams, bool> {
  final PositionRepository locatorRepo = GetIt.I();

  @override
  Stream<bool> onCall(NoParams params) {
    return locatorRepo.onServiceChanges;
  }
}
