part of 'permissions_bloc.b.dart';

@DataClass(copyable: true)
abstract class PermissionsBlocState with _$PermissionsBlocState {
  /// Whether the status is updating, any iterations with the bloc are blocked when true.
  ///
  /// This normally happens when the app has been brought back to the foreground.
  /// It can lead to the resolution of a request confirmation when all its permissions are guaranteed.
  final bool isRefreshing;

  final Map<Permission, PermissionStatus> permissionsStatus;

  final Map<Service, bool> servicesStatus;

  const PermissionsBlocState({
    required this.isRefreshing,
    required this.permissionsStatus,
    required this.servicesStatus,
  });

  bool get isWaiting => this is ConfirmableAskPermissionsState;

  bool get isLoading;

  /// Returns whether [PermissionsBloc.check] is performable.
  ///
  /// It returns `false` when another action is in progress or the state is [ConfirmableAskPermissionsState].
  /// Returns whether no actions are in progress or the state isn’t [ConfirmableAskPermissionsState].
  bool checkCanCheck(Set<Permission> permissions) {
    if (isLoading || isRefreshing || isWaiting) return false;
    return !permissions.every(permissionsStatus.containsKey);
  }

  /// Returns whether [PermissionsBloc.request] is performable.
  ///
  /// Returns whether no actions are in progress or the state isn’t [ConfirmableAskPermissionsState].
  bool checkCanRequest(Set<Permission> permissions) {
    if (isLoading || isRefreshing || isWaiting) return false;
    return permissions.any((permission) {
      return permissionsStatus[permission] != PermissionStatus.granted;
    });
  }

  /// Returns whether [PermissionsBloc.ask] is performable.
  ///
  /// Returns whether no actions are in progress or the state isn’t [ConfirmableAskPermissionsState].
  bool checkCanAsk(Set<Permission> permissions) {
    if (isLoading || isRefreshing || isWaiting) return false;
    final isAllEnabled = permissions
        .map((e) => e.toService())
        .whereNotNull()
        .every((element) => servicesStatus[element] ?? false);
    if (!isAllEnabled) return true;
    return permissions.any((permission) {
      return permissionsStatus[permission] != PermissionStatus.granted;
    });
  }

  /// Returns whether [PermissionsBloc.confirmAsk] is performable.
  ///
  /// Returns whether the state is [ConfirmableAskPermissionsState].
  bool checkCanConfirmAsk(Set<Permission> permissions) {
    if (isLoading || isRefreshing) return false;
    return maybeMap(
      confirmableAsk: (state) =>
          const UnorderedIterableEquality().equals(state.payload, permissions),
      orElse: (_) => false,
    );
  }

  PermissionStatus resolveStatus(Set<Permission> permissions) {
    if (checkEvery(permissions, PermissionStatus.granted)) {
      return PermissionStatus.granted;
    }
    if (checkAny(permissions, PermissionStatus.permanentlyDenied)) {
      return PermissionStatus.permanentlyDenied;
    }
    return PermissionStatus.denied;
  }

  bool checkEvery(Set<Permission> permissions, PermissionStatus status) {
    return permissions.every((permission) {
      return (permissionsStatus[permission] ?? PermissionStatus.denied) == status;
    });
  }

  bool checkAny(Set<Permission> permissions, PermissionStatus status) {
    return permissions.any((permission) {
      return (permissionsStatus[permission] ?? PermissionStatus.denied) == status;
    });
  }

  bool checkService(Service service) => servicesStatus[service] ?? false;

  R map<R>({
    required R Function(CheckingPermissionState state) checking,
    required R Function(CheckedPermissionState state) checked,
    required R Function(RequestingPermissionsState state) requesting,
    required R Function(RequestedPermissionsState state) requested,
    required R Function(AskingPermissionsState state) asking,
    required R Function(ConfirmableAskPermissionsState state) confirmableAsk,
    required R Function(AskedPermissionsState state) asked,
  });

  R maybeMap<R>({
    R Function(CheckingPermissionState state)? checking,
    R Function(CheckedPermissionState state)? checked,
    R Function(RequestingPermissionsState state)? requesting,
    R Function(RequestedPermissionsState state)? requested,
    R Function(AskingPermissionsState state)? asking,
    R Function(ConfirmableAskPermissionsState state)? confirmableAsk,
    R Function(AskedPermissionsState state)? asked,
    required R Function(PermissionsBlocState state) orElse,
  }) {
    return map(
      checking: checking ?? orElse,
      checked: checked ?? orElse,
      requesting: requesting ?? orElse,
      requested: requested ?? orElse,
      asking: asking ?? orElse,
      confirmableAsk: confirmableAsk ?? orElse,
      asked: asked ?? orElse,
    );
  }

  @visibleForTesting
  PermissionsBlocState toChecking({
    Map<Permission, PermissionStatus>? permissionsStatus,
    Map<Service, bool>? servicesStatus,
    required Set<Permission> payload,
  }) {
    return CheckingPermissionState(
      isRefreshing: false,
      permissionsStatus: permissionsStatus ?? this.permissionsStatus,
      servicesStatus: servicesStatus ?? this.servicesStatus,
      payload: payload,
    );
  }

  @visibleForTesting
  PermissionsBlocState toChecked({
    Map<Permission, PermissionStatus>? permissionsStatus,
    Map<Service, bool>? servicesStatus,
    required Set<Permission> payload,
  }) {
    return CheckedPermissionState(
      isRefreshing: false,
      permissionsStatus: permissionsStatus ?? this.permissionsStatus,
      servicesStatus: servicesStatus ?? this.servicesStatus,
      payload: payload,
    );
  }

  @visibleForTesting
  PermissionsBlocState toRequesting({
    Map<Permission, PermissionStatus>? permissionsStatus,
    Map<Service, bool>? servicesStatus,
    required Set<Permission> payload,
  }) {
    return RequestingPermissionsState(
      isRefreshing: false,
      permissionsStatus: permissionsStatus ?? this.permissionsStatus,
      servicesStatus: servicesStatus ?? this.servicesStatus,
      payload: payload,
    );
  }

  @visibleForTesting
  PermissionsBlocState toRequested({
    Map<Permission, PermissionStatus>? permissionsStatus,
    Map<Service, bool>? servicesStatus,
    required Set<Permission> payload,
    required bool isRequested,
  }) {
    return RequestedPermissionsState(
      isRefreshing: false,
      permissionsStatus: permissionsStatus ?? this.permissionsStatus,
      servicesStatus: servicesStatus ?? this.servicesStatus,
      isRequested: isRequested,
      payload: payload,
    );
  }

  @visibleForTesting
  PermissionsBlocState toAsking({
    Map<Permission, PermissionStatus>? permissionsStatus,
    Map<Service, bool>? servicesStatus,
    required Set<Permission> payload,
  }) {
    return AskingPermissionsState(
      isRefreshing: false,
      permissionsStatus: permissionsStatus ?? this.permissionsStatus,
      servicesStatus: servicesStatus ?? this.servicesStatus,
      payload: payload,
    );
  }

  @visibleForTesting
  PermissionsBlocState toConfirmableAsk({
    Map<Permission, PermissionStatus>? permissionsStatus,
    Map<Service, bool>? servicesStatus,
    required Set<Permission> payload,
    required bool isRestored,
  }) {
    return ConfirmableAskPermissionsState(
      isRefreshing: false,
      permissionsStatus: permissionsStatus ?? this.permissionsStatus,
      servicesStatus: servicesStatus ?? this.servicesStatus,
      isRestored: isRestored,
      payload: payload,
    );
  }

  @visibleForTesting
  PermissionsBlocState toAsked({
    Map<Permission, PermissionStatus>? permissionsStatus,
    Map<Service, bool>? servicesStatus,
    required Set<Permission> payload,
    required bool isCancelled,
    required bool isRequested,
  }) {
    return AskedPermissionsState(
      isRefreshing: false,
      permissionsStatus: permissionsStatus ?? this.permissionsStatus,
      servicesStatus: servicesStatus ?? this.servicesStatus,
      payload: payload,
      isCancelled: isCancelled,
      isRequested: isRequested,
    );
  }
}

@DataClass(copyable: true)
class CheckingPermissionState extends PermissionsBlocState with _$CheckingPermissionState {
  final Set<Permission> payload;

  const CheckingPermissionState({
    required super.isRefreshing,
    required super.permissionsStatus,
    required super.servicesStatus,
    required this.payload,
  });

  @override
  bool get isLoading => true;

  @override
  R map<R>({
    required R Function(CheckingPermissionState state) checking,
    required R Function(CheckedPermissionState state) checked,
    required R Function(RequestingPermissionsState state) requesting,
    required R Function(RequestedPermissionsState state) requested,
    required R Function(AskingPermissionsState state) asking,
    required R Function(ConfirmableAskPermissionsState state) confirmableAsk,
    required R Function(AskedPermissionsState state) asked,
  }) {
    return checking(this);
  }
}

@DataClass(copyable: true)
class CheckedPermissionState extends PermissionsBlocState with _$CheckedPermissionState {
  final Set<Permission> payload;

  const CheckedPermissionState({
    required super.isRefreshing,
    required super.permissionsStatus,
    required super.servicesStatus,
    required this.payload,
  });

  @override
  bool get isLoading => false;

  @override
  R map<R>({
    required R Function(CheckingPermissionState state) checking,
    required R Function(CheckedPermissionState state) checked,
    required R Function(RequestingPermissionsState state) requesting,
    required R Function(RequestedPermissionsState state) requested,
    required R Function(AskingPermissionsState state) asking,
    required R Function(ConfirmableAskPermissionsState state) confirmableAsk,
    required R Function(AskedPermissionsState state) asked,
  }) {
    return checked(this);
  }
}

@DataClass(copyable: true)
class RequestingPermissionsState extends PermissionsBlocState with _$RequestingPermissionsState {
  final Set<Permission> payload;

  const RequestingPermissionsState({
    required super.isRefreshing,
    required super.permissionsStatus,
    required super.servicesStatus,
    required this.payload,
  });

  @override
  bool get isLoading => true;

  @override
  R map<R>({
    required R Function(CheckingPermissionState state) checking,
    required R Function(CheckedPermissionState state) checked,
    required R Function(RequestingPermissionsState state) requesting,
    required R Function(RequestedPermissionsState state) requested,
    required R Function(AskingPermissionsState state) asking,
    required R Function(ConfirmableAskPermissionsState state) confirmableAsk,
    required R Function(AskedPermissionsState state) asked,
  }) {
    return requesting(this);
  }
}

@DataClass(copyable: true)
class RequestedPermissionsState extends PermissionsBlocState with _$RequestedPermissionsState {
  final Set<Permission> payload;

  /// Whether the permission has been requested.
  final bool isRequested;

  const RequestedPermissionsState({
    required super.isRefreshing,
    required super.permissionsStatus,
    required super.servicesStatus,
    required this.payload,
    required this.isRequested,
  });

  @override
  bool get isLoading => false;

  @override
  R map<R>({
    required R Function(CheckingPermissionState state) checking,
    required R Function(CheckedPermissionState state) checked,
    required R Function(RequestingPermissionsState state) requesting,
    required R Function(RequestedPermissionsState state) requested,
    required R Function(AskingPermissionsState state) asking,
    required R Function(ConfirmableAskPermissionsState state) confirmableAsk,
    required R Function(AskedPermissionsState state) asked,
  }) {
    return requested(this);
  }
}

@DataClass(copyable: true)
class AskingPermissionsState extends PermissionsBlocState with _$AskingPermissionsState {
  final Set<Permission> payload;

  const AskingPermissionsState({
    required super.isRefreshing,
    required super.permissionsStatus,
    required super.servicesStatus,
    required this.payload,
  });

  @override
  bool get isLoading => true;

  @override
  R map<R>({
    required R Function(CheckingPermissionState state) checking,
    required R Function(CheckedPermissionState state) checked,
    required R Function(RequestingPermissionsState state) requesting,
    required R Function(RequestedPermissionsState state) requested,
    required R Function(AskingPermissionsState state) asking,
    required R Function(ConfirmableAskPermissionsState state) confirmableAsk,
    required R Function(AskedPermissionsState state) asked,
  }) {
    return asking(this);
  }
}

@DataClass(copyable: true)
class ConfirmableAskPermissionsState extends PermissionsBlocState
    with _$ConfirmableAskPermissionsState {
  final Set<Permission> payload;

  /// Whether the state has been restored because the permission has not been granted.
  final bool isRestored;

  const ConfirmableAskPermissionsState({
    required super.isRefreshing,
    required super.permissionsStatus,
    required super.servicesStatus,
    required this.payload,
    required this.isRestored,
  });

  @override
  bool get isLoading => false;

  @override
  R map<R>({
    required R Function(CheckingPermissionState state) checking,
    required R Function(CheckedPermissionState state) checked,
    required R Function(RequestingPermissionsState state) requesting,
    required R Function(RequestedPermissionsState state) requested,
    required R Function(AskingPermissionsState state) asking,
    required R Function(ConfirmableAskPermissionsState state) confirmableAsk,
    required R Function(AskedPermissionsState state) asked,
  }) {
    return confirmableAsk(this);
  }
}

@DataClass(copyable: true)
class AskedPermissionsState extends PermissionsBlocState with _$AskedPermissionsState {
  final Set<Permission> payload;

  final bool isCancelled;

  /// Whether the permission has been requested.
  final bool isRequested;

  const AskedPermissionsState({
    required super.isRefreshing,
    required super.permissionsStatus,
    required super.servicesStatus,
    required this.payload,
    required this.isCancelled,
    required this.isRequested,
  });

  @override
  bool get isLoading => false;

  @override
  R map<R>({
    required R Function(CheckingPermissionState state) checking,
    required R Function(CheckedPermissionState state) checked,
    required R Function(RequestingPermissionsState state) requesting,
    required R Function(RequestedPermissionsState state) requested,
    required R Function(AskingPermissionsState state) asking,
    required R Function(ConfirmableAskPermissionsState state) confirmableAsk,
    required R Function(AskedPermissionsState state) asked,
  }) {
    return asked(this);
  }
}
