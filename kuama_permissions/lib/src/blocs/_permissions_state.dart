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

  bool get isLoading {
    return maybeMap(checking: (_) => true, asking: (_) => true, orElse: (_) => false);
  }

  /// Referred to [PermissionsBloc.check]
  bool checkCanCheck(Set<Permission> permissions) {
    if (isLoading || isRefreshing || isWaiting) return false;
    return !permissions.every(permissionsStatus.containsKey);
  }

  /// Referred to [PermissionsBloc.ask]
  bool checkCanAsk(Set<Permission> permissions) {
    if (isLoading || isRefreshing || isWaiting) return false;
    return true;
  }

  /// Referred to [PermissionsBloc.confirmAsk]
  bool checkCanConfirmAsk(Set<Permission> permissions) {
    if (isLoading || isRefreshing) return false;
    return maybeMap(
      asked: (state) => const UnorderedIterableEquality().equals(state.payload, permissions),
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

  R map<R>({
    required R Function(CheckingPermissionState state) checking,
    required R Function(CheckedPermissionState state) checked,
    required R Function(AskingPermissionsState state) asking,
    required R Function(ConfirmableAskPermissionsState state) negatedAsk,
    required R Function(AskedPermissionsState state) asked,
  }) {
    final state = this;
    if (state is CheckingPermissionState) {
      return checking(state);
    } else if (state is CheckedPermissionState) {
      return checked(state);
    } else if (state is AskingPermissionsState) {
      return asking(state);
    } else if (state is ConfirmableAskPermissionsState) {
      return negatedAsk(state);
    } else if (state is AskedPermissionsState) {
      return asked(state);
    }
    throw 'Not supported ${state.runtimeType}';
  }

  R maybeMap<R>({
    R Function(CheckingPermissionState state)? checking,
    R Function(CheckedPermissionState state)? checked,
    R Function(AskingPermissionsState state)? asking,
    R Function(ConfirmableAskPermissionsState state)? asked,
    R Function(AskedPermissionsState state)? requested,
    required R Function(PermissionsBlocState state) orElse,
  }) {
    return map(
      checking: checking ?? orElse,
      checked: checked ?? orElse,
      asking: asking ?? orElse,
      negatedAsk: asked ?? orElse,
      asked: requested ?? orElse,
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
    required bool isRefreshing,
    required Map<Permission, PermissionStatus> permissionsStatus,
    required Map<Service, bool> servicesStatus,
    required this.payload,
  }) : super(
          isRefreshing: isRefreshing,
          permissionsStatus: permissionsStatus,
          servicesStatus: servicesStatus,
        );
}

@DataClass(copyable: true)
class CheckedPermissionState extends PermissionsBlocState with _$CheckedPermissionState {
  final Set<Permission> payload;

  const CheckedPermissionState({
    required bool isRefreshing,
    required Map<Permission, PermissionStatus> permissionsStatus,
    required Map<Service, bool> servicesStatus,
    required this.payload,
  }) : super(
          isRefreshing: isRefreshing,
          permissionsStatus: permissionsStatus,
          servicesStatus: servicesStatus,
        );
}

@DataClass(copyable: true)
class AskingPermissionsState extends PermissionsBlocState with _$AskingPermissionsState {
  final Set<Permission> payload;

  const AskingPermissionsState({
    required bool isRefreshing,
    required Map<Permission, PermissionStatus> permissionsStatus,
    required Map<Service, bool> servicesStatus,
    required this.payload,
  }) : super(
          isRefreshing: isRefreshing,
          permissionsStatus: permissionsStatus,
          servicesStatus: servicesStatus,
        );
}

@DataClass(copyable: true)
class ConfirmableAskPermissionsState extends PermissionsBlocState
    with _$ConfirmableAskPermissionsState {
  final Set<Permission> payload;

  /// Whether the state has been restored because the permission has not been granted.
  final bool isRestored;

  const ConfirmableAskPermissionsState({
    required bool isRefreshing,
    required Map<Permission, PermissionStatus> permissionsStatus,
    required Map<Service, bool> servicesStatus,
    required this.payload,
    required this.isRestored,
  }) : super(
          isRefreshing: isRefreshing,
          permissionsStatus: permissionsStatus,
          servicesStatus: servicesStatus,
        );
}

@DataClass(copyable: true)
class AskedPermissionsState extends PermissionsBlocState with _$AskedPermissionsState {
  final Set<Permission> payload;

  final bool isCancelled;

  /// Whether the permission has been requested.
  final bool isRequested;

  const AskedPermissionsState({
    required bool isRefreshing,
    required Map<Permission, PermissionStatus> permissionsStatus,
    required Map<Service, bool> servicesStatus,
    required this.payload,
    required this.isCancelled,
    required this.isRequested,
  }) : super(
          isRefreshing: isRefreshing,
          permissionsStatus: permissionsStatus,
          servicesStatus: servicesStatus,
        );
}
