part of 'permissions_bloc.b.dart';

class _PermissionsBlocEvent {}

@DataClass(comparable: false)
class _CheckPermissionsEvent extends _PermissionsBlocEvent with _$_CheckPermissionsEvent {
  final Set<Permission> permissions;

  _CheckPermissionsEvent(this.permissions);
}

@DataClass(comparable: false)
class _AskPermissionsEvent extends _PermissionsBlocEvent with _$_AskPermissionsEvent {
  final Set<Permission> permissions;
  final bool tryAgain;

  _AskPermissionsEvent(this.permissions, {required this.tryAgain});
}

@DataClass(comparable: false)
class _ConfirmAskPermissionsEvent extends _PermissionsBlocEvent with _$_ConfirmAskPermissionsEvent {
  final bool? canRequest;

  _ConfirmAskPermissionsEvent(this.canRequest);
}

@DataClass(comparable: false)
class _RefreshPermissionsEvent extends _PermissionsBlocEvent with _$_RefreshPermissionsEvent {
  _RefreshPermissionsEvent();
}
