// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'permissions_bloc.b.dart';

// **************************************************************************
// DataClassGenerator
// **************************************************************************

// ignore_for_file: annotate_overrides, unused_element

mixin _$_CheckPermissionsEvent {
  _CheckPermissionsEvent get _self => this as _CheckPermissionsEvent;

  String toString() =>
      (ClassToString('_CheckPermissionsEvent')..add('permissions', _self.permissions)).toString();
}

mixin _$_RequestPermissionsEvent {
  _RequestPermissionsEvent get _self => this as _RequestPermissionsEvent;

  String toString() => (ClassToString('_RequestPermissionsEvent')
        ..add('permissions', _self.permissions)
        ..add('tryAgain', _self.tryAgain))
      .toString();
}

mixin _$_AskPermissionsEvent {
  _AskPermissionsEvent get _self => this as _AskPermissionsEvent;

  String toString() => (ClassToString('_AskPermissionsEvent')
        ..add('permissions', _self.permissions)
        ..add('tryAgain', _self.tryAgain))
      .toString();
}

mixin _$_ConfirmAskPermissionsEvent {
  _ConfirmAskPermissionsEvent get _self => this as _ConfirmAskPermissionsEvent;

  String toString() =>
      (ClassToString('_ConfirmAskPermissionsEvent')..add('canRequest', _self.canRequest))
          .toString();
}

mixin _$_RefreshPermissionsEvent {
  _RefreshPermissionsEvent get _self => this as _RefreshPermissionsEvent;

  String toString() => (ClassToString('_RefreshPermissionsEvent')).toString();
}

mixin _$PermissionsBlocState {
  PermissionsBlocState get _self => this as PermissionsBlocState;

  Iterable<Object?> get _props sync* {
    yield _self.isRefreshing;
    yield _self.permissionsStatus;
    yield _self.servicesStatus;
  }

  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PermissionsBlocState &&
          runtimeType == other.runtimeType &&
          DataClass.$equals(_props, other._props);

  int get hashCode => Object.hashAll(_props);

  String toString() => (ClassToString('PermissionsBlocState')
        ..add('isRefreshing', _self.isRefreshing)
        ..add('permissionsStatus', _self.permissionsStatus)
        ..add('servicesStatus', _self.servicesStatus))
      .toString();

  PermissionsBlocState copyWith({
    bool? isRefreshing,
    Map<Permission, PermissionStatus>? permissionsStatus,
    Map<Service, bool>? servicesStatus,
  });
}

mixin _$CheckingPermissionState {
  CheckingPermissionState get _self => this as CheckingPermissionState;

  Iterable<Object?> get _props sync* {
    yield _self.isRefreshing;
    yield _self.permissionsStatus;
    yield _self.servicesStatus;
    yield _self.payload;
  }

  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CheckingPermissionState &&
          runtimeType == other.runtimeType &&
          DataClass.$equals(_props, other._props);

  int get hashCode => Object.hashAll(_props);

  String toString() => (ClassToString('CheckingPermissionState')
        ..add('isRefreshing', _self.isRefreshing)
        ..add('permissionsStatus', _self.permissionsStatus)
        ..add('servicesStatus', _self.servicesStatus)
        ..add('payload', _self.payload))
      .toString();

  CheckingPermissionState copyWith({
    bool? isRefreshing,
    Map<Permission, PermissionStatus>? permissionsStatus,
    Map<Service, bool>? servicesStatus,
    Set<Permission>? payload,
  }) {
    return CheckingPermissionState(
      isRefreshing: isRefreshing ?? _self.isRefreshing,
      permissionsStatus: permissionsStatus ?? _self.permissionsStatus,
      servicesStatus: servicesStatus ?? _self.servicesStatus,
      payload: payload ?? _self.payload,
    );
  }
}

mixin _$CheckedPermissionState {
  CheckedPermissionState get _self => this as CheckedPermissionState;

  Iterable<Object?> get _props sync* {
    yield _self.isRefreshing;
    yield _self.permissionsStatus;
    yield _self.servicesStatus;
    yield _self.payload;
  }

  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CheckedPermissionState &&
          runtimeType == other.runtimeType &&
          DataClass.$equals(_props, other._props);

  int get hashCode => Object.hashAll(_props);

  String toString() => (ClassToString('CheckedPermissionState')
        ..add('isRefreshing', _self.isRefreshing)
        ..add('permissionsStatus', _self.permissionsStatus)
        ..add('servicesStatus', _self.servicesStatus)
        ..add('payload', _self.payload))
      .toString();

  CheckedPermissionState copyWith({
    bool? isRefreshing,
    Map<Permission, PermissionStatus>? permissionsStatus,
    Map<Service, bool>? servicesStatus,
    Set<Permission>? payload,
  }) {
    return CheckedPermissionState(
      isRefreshing: isRefreshing ?? _self.isRefreshing,
      permissionsStatus: permissionsStatus ?? _self.permissionsStatus,
      servicesStatus: servicesStatus ?? _self.servicesStatus,
      payload: payload ?? _self.payload,
    );
  }
}

mixin _$RequestingPermissionsState {
  RequestingPermissionsState get _self => this as RequestingPermissionsState;

  Iterable<Object?> get _props sync* {
    yield _self.isRefreshing;
    yield _self.permissionsStatus;
    yield _self.servicesStatus;
    yield _self.payload;
  }

  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RequestingPermissionsState &&
          runtimeType == other.runtimeType &&
          DataClass.$equals(_props, other._props);

  int get hashCode => Object.hashAll(_props);

  String toString() => (ClassToString('RequestingPermissionsState')
        ..add('isRefreshing', _self.isRefreshing)
        ..add('permissionsStatus', _self.permissionsStatus)
        ..add('servicesStatus', _self.servicesStatus)
        ..add('payload', _self.payload))
      .toString();

  RequestingPermissionsState copyWith({
    bool? isRefreshing,
    Map<Permission, PermissionStatus>? permissionsStatus,
    Map<Service, bool>? servicesStatus,
    Set<Permission>? payload,
  }) {
    return RequestingPermissionsState(
      isRefreshing: isRefreshing ?? _self.isRefreshing,
      permissionsStatus: permissionsStatus ?? _self.permissionsStatus,
      servicesStatus: servicesStatus ?? _self.servicesStatus,
      payload: payload ?? _self.payload,
    );
  }
}

mixin _$RequestedPermissionsState {
  RequestedPermissionsState get _self => this as RequestedPermissionsState;

  Iterable<Object?> get _props sync* {
    yield _self.isRefreshing;
    yield _self.permissionsStatus;
    yield _self.servicesStatus;
    yield _self.payload;
    yield _self.isRequested;
  }

  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RequestedPermissionsState &&
          runtimeType == other.runtimeType &&
          DataClass.$equals(_props, other._props);

  int get hashCode => Object.hashAll(_props);

  String toString() => (ClassToString('RequestedPermissionsState')
        ..add('isRefreshing', _self.isRefreshing)
        ..add('permissionsStatus', _self.permissionsStatus)
        ..add('servicesStatus', _self.servicesStatus)
        ..add('payload', _self.payload)
        ..add('isRequested', _self.isRequested))
      .toString();

  RequestedPermissionsState copyWith({
    bool? isRefreshing,
    Map<Permission, PermissionStatus>? permissionsStatus,
    Map<Service, bool>? servicesStatus,
    Set<Permission>? payload,
    bool? isRequested,
  }) {
    return RequestedPermissionsState(
      isRefreshing: isRefreshing ?? _self.isRefreshing,
      permissionsStatus: permissionsStatus ?? _self.permissionsStatus,
      servicesStatus: servicesStatus ?? _self.servicesStatus,
      payload: payload ?? _self.payload,
      isRequested: isRequested ?? _self.isRequested,
    );
  }
}

mixin _$AskingPermissionsState {
  AskingPermissionsState get _self => this as AskingPermissionsState;

  Iterable<Object?> get _props sync* {
    yield _self.isRefreshing;
    yield _self.permissionsStatus;
    yield _self.servicesStatus;
    yield _self.payload;
  }

  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AskingPermissionsState &&
          runtimeType == other.runtimeType &&
          DataClass.$equals(_props, other._props);

  int get hashCode => Object.hashAll(_props);

  String toString() => (ClassToString('AskingPermissionsState')
        ..add('isRefreshing', _self.isRefreshing)
        ..add('permissionsStatus', _self.permissionsStatus)
        ..add('servicesStatus', _self.servicesStatus)
        ..add('payload', _self.payload))
      .toString();

  AskingPermissionsState copyWith({
    bool? isRefreshing,
    Map<Permission, PermissionStatus>? permissionsStatus,
    Map<Service, bool>? servicesStatus,
    Set<Permission>? payload,
  }) {
    return AskingPermissionsState(
      isRefreshing: isRefreshing ?? _self.isRefreshing,
      permissionsStatus: permissionsStatus ?? _self.permissionsStatus,
      servicesStatus: servicesStatus ?? _self.servicesStatus,
      payload: payload ?? _self.payload,
    );
  }
}

mixin _$ConfirmableAskPermissionsState {
  ConfirmableAskPermissionsState get _self => this as ConfirmableAskPermissionsState;

  Iterable<Object?> get _props sync* {
    yield _self.isRefreshing;
    yield _self.permissionsStatus;
    yield _self.servicesStatus;
    yield _self.payload;
    yield _self.isRestored;
  }

  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfirmableAskPermissionsState &&
          runtimeType == other.runtimeType &&
          DataClass.$equals(_props, other._props);

  int get hashCode => Object.hashAll(_props);

  String toString() => (ClassToString('ConfirmableAskPermissionsState')
        ..add('isRefreshing', _self.isRefreshing)
        ..add('permissionsStatus', _self.permissionsStatus)
        ..add('servicesStatus', _self.servicesStatus)
        ..add('payload', _self.payload)
        ..add('isRestored', _self.isRestored))
      .toString();

  ConfirmableAskPermissionsState copyWith({
    bool? isRefreshing,
    Map<Permission, PermissionStatus>? permissionsStatus,
    Map<Service, bool>? servicesStatus,
    Set<Permission>? payload,
    bool? isRestored,
  }) {
    return ConfirmableAskPermissionsState(
      isRefreshing: isRefreshing ?? _self.isRefreshing,
      permissionsStatus: permissionsStatus ?? _self.permissionsStatus,
      servicesStatus: servicesStatus ?? _self.servicesStatus,
      payload: payload ?? _self.payload,
      isRestored: isRestored ?? _self.isRestored,
    );
  }
}

mixin _$AskedPermissionsState {
  AskedPermissionsState get _self => this as AskedPermissionsState;

  Iterable<Object?> get _props sync* {
    yield _self.isRefreshing;
    yield _self.permissionsStatus;
    yield _self.servicesStatus;
    yield _self.payload;
    yield _self.isCancelled;
    yield _self.isRequested;
  }

  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AskedPermissionsState &&
          runtimeType == other.runtimeType &&
          DataClass.$equals(_props, other._props);

  int get hashCode => Object.hashAll(_props);

  String toString() => (ClassToString('AskedPermissionsState')
        ..add('isRefreshing', _self.isRefreshing)
        ..add('permissionsStatus', _self.permissionsStatus)
        ..add('servicesStatus', _self.servicesStatus)
        ..add('payload', _self.payload)
        ..add('isCancelled', _self.isCancelled)
        ..add('isRequested', _self.isRequested))
      .toString();

  AskedPermissionsState copyWith({
    bool? isRefreshing,
    Map<Permission, PermissionStatus>? permissionsStatus,
    Map<Service, bool>? servicesStatus,
    Set<Permission>? payload,
    bool? isCancelled,
    bool? isRequested,
  }) {
    return AskedPermissionsState(
      isRefreshing: isRefreshing ?? _self.isRefreshing,
      permissionsStatus: permissionsStatus ?? _self.permissionsStatus,
      servicesStatus: servicesStatus ?? _self.servicesStatus,
      payload: payload ?? _self.payload,
      isCancelled: isCancelled ?? _self.isCancelled,
      isRequested: isRequested ?? _self.isRequested,
    );
  }
}
