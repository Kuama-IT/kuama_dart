import 'package:kuama_core/kuama_core.dart';
import 'package:permission_handler/permission_handler.dart';

class MissingPermissionsFailure extends Failure {
  final List<Permission> permissions;

  MissingPermissionsFailure(this.permissions, {super.exceptionCaught});

  @override
  String get message => 'Missing permissions: ${permissions.join(', ')}';
}

class FailedOpenAppPageFailure extends Failure {
  final AppPage page;

  FailedOpenAppPageFailure(this.page, {super.exceptionCaught});

  @override
  String get message => 'Failed to open external page `${page.name}`';
}

enum AppPage { settings }
