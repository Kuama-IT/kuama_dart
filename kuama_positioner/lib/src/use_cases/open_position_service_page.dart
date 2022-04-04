import 'package:get_it/get_it.dart';
import 'package:kuama_flutter/kuama_flutter.dart' show UseCase, NoParams;
import 'package:kuama_positioner/src/repositories/position_repository.dart';

/// Open the position service page to enable it
class OpenPositionServicePage extends UseCase<NoParams, bool> {
  final PositionRepository locatorRepo = GetIt.I();

  @override
  Future<bool> onCall(NoParams params) async {
    return await locatorRepo.openServicePage();
  }
}
