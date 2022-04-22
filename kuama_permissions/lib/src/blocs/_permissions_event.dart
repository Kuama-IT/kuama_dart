part of 'permissions_bloc.b.dart';

abstract class _PermissionsBlocEvent {
  R map<R>({
    required R Function(_CheckPermissionsEvent event) check,
    required R Function(_RequestPermissionsEvent event) request,
    required R Function(_AskPermissionsEvent event) ask,
    required R Function(_ConfirmAskPermissionsEvent event) confirmAsk,
    required R Function(_RefreshPermissionsEvent event) refresh,
  });
}

@DataClass(comparable: false)
class _CheckPermissionsEvent extends _PermissionsBlocEvent with _$_CheckPermissionsEvent {
  final Set<Permission> permissions;

  _CheckPermissionsEvent(this.permissions);

  @override
  R map<R>({
    required R Function(_CheckPermissionsEvent event) check,
    required R Function(_RequestPermissionsEvent event) request,
    required R Function(_AskPermissionsEvent event) ask,
    required R Function(_ConfirmAskPermissionsEvent event) confirmAsk,
    required R Function(_RefreshPermissionsEvent event) refresh,
  }) {
    return check(this);
  }
}

@DataClass(comparable: false)
class _RequestPermissionsEvent extends _PermissionsBlocEvent with _$_AskPermissionsEvent {
  final Set<Permission> permissions;

  _RequestPermissionsEvent(this.permissions);

  @override
  R map<R>({
    required R Function(_CheckPermissionsEvent event) check,
    required R Function(_RequestPermissionsEvent event) request,
    required R Function(_AskPermissionsEvent event) ask,
    required R Function(_ConfirmAskPermissionsEvent event) confirmAsk,
    required R Function(_RefreshPermissionsEvent event) refresh,
  }) {
    return request(this);
  }
}

@DataClass(comparable: false)
class _AskPermissionsEvent extends _PermissionsBlocEvent with _$_AskPermissionsEvent {
  final Set<Permission> permissions;
  final bool tryAgain;

  _AskPermissionsEvent(this.permissions, {required this.tryAgain});

  @override
  R map<R>({
    required R Function(_CheckPermissionsEvent event) check,
    required R Function(_RequestPermissionsEvent event) request,
    required R Function(_AskPermissionsEvent event) ask,
    required R Function(_ConfirmAskPermissionsEvent event) confirmAsk,
    required R Function(_RefreshPermissionsEvent event) refresh,
  }) {
    return ask(this);
  }
}

@DataClass(comparable: false)
class _ConfirmAskPermissionsEvent extends _PermissionsBlocEvent with _$_ConfirmAskPermissionsEvent {
  final bool? canRequest;

  _ConfirmAskPermissionsEvent(this.canRequest);

  @override
  R map<R>({
    required R Function(_CheckPermissionsEvent event) check,
    required R Function(_RequestPermissionsEvent event) request,
    required R Function(_AskPermissionsEvent event) ask,
    required R Function(_ConfirmAskPermissionsEvent event) confirmAsk,
    required R Function(_RefreshPermissionsEvent event) refresh,
  }) {
    return confirmAsk(this);
  }
}

@DataClass(comparable: false)
class _RefreshPermissionsEvent extends _PermissionsBlocEvent with _$_RefreshPermissionsEvent {
  _RefreshPermissionsEvent();

  @override
  R map<R>({
    required R Function(_CheckPermissionsEvent event) check,
    required R Function(_RequestPermissionsEvent event) request,
    required R Function(_AskPermissionsEvent event) ask,
    required R Function(_ConfirmAskPermissionsEvent event) confirmAsk,
    required R Function(_RefreshPermissionsEvent event) refresh,
  }) {
    return refresh(this);
  }
}
