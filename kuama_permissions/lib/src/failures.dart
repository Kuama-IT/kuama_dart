import 'package:kuama_flutter/kuama_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class MissingPermissionsFailure extends Failure {
  final List<Permission> permissions;

  MissingPermissionsFailure(this.permissions);

  @override
  String get message => 'Missing permissions: ${permissions.join(', ')}';
}

class FailedOpenAppPageFailure extends Failure {
  final AppPage page;

  FailedOpenAppPageFailure(this.page);

  @override
  String get message => 'Failed to open external page `${page.name}`';
}

enum AppPage { settings }
