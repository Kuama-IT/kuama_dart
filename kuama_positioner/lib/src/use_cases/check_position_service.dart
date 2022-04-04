import 'package:kuama_flutter/kuama_flutter.dart';
import 'package:kuama_positioner/src/repositories/position_repository.dart';

/// Check if the position service is enabled
class CheckPositionService extends UseCase<NoParams, bool> {
  final PositionRepository locatorRepo = GetIt.I();

  @override
  Future<bool> onCall(NoParams params) async {
    return await locatorRepo.checkService();
  }
}
