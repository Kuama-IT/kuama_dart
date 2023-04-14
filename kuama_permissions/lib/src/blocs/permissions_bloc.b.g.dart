// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'permissions_bloc.b.dart';

// **************************************************************************
// DataClassGenerator
// **************************************************************************

mixin _$_CheckPermissionsEvent {
  _CheckPermissionsEvent get _self => this as _CheckPermissionsEvent;
  @override
  String toString() =>
      (ClassToString('_CheckPermissionsEvent')..add('permissions', _self.permissions)).toString();
}

mixin _$_RequestPermissionsEvent {
  _RequestPermissionsEvent get _self => this as _RequestPermissionsEvent;
  @override
  String toString() => (ClassToString('_RequestPermissionsEvent')
        ..add('permissions', _self.permissions)
        ..add('tryAgain', _self.tryAgain))
      .toString();
}

mixin _$_AskPermissionsEvent {
  _AskPermissionsEvent get _self => this as _AskPermissionsEvent;
  @override
  String toString() => (ClassToString('_AskPermissionsEvent')
        ..add('permissions', _self.permissions)
        ..add('tryAgain', _self.tryAgain))
      .toString();
}

mixin _$_ConfirmAskPermissionsEvent {
  _ConfirmAskPermissionsEvent get _self => this as _ConfirmAskPermissionsEvent;
  @override
  String toString() =>
      (ClassToString('_ConfirmAskPermissionsEvent')..add('canRequest', _self.canRequest))
          .toString();
}

mixin _$_RefreshPermissionsEvent {
  @override
  String toString() => (ClassToString('_RefreshPermissionsEvent')).toString();
}

mixin _$PermissionsBlocState {
  PermissionsBlocState get _self => this as PermissionsBlocState;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PermissionsBlocState &&
          runtimeType == other.runtimeType &&
          _self.isRefreshing == other.isRefreshing &&
          $mapEquality.equals(_self.permissionsStatus, other.permissionsStatus) &&
          $mapEquality.equals(_self.servicesStatus, other.servicesStatus);
  @override
  int get hashCode {
    var hashCode = 0;
    hashCode = $hashCombine(hashCode, _self.isRefreshing.hashCode);
    hashCode = $hashCombine(hashCode, $mapEquality.hash(_self.permissionsStatus));
    hashCode = $hashCombine(hashCode, $mapEquality.hash(_self.servicesStatus));
    return $hashFinish(hashCode);
  }

  @override
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
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CheckingPermissionState &&
          runtimeType == other.runtimeType &&
          _self.isRefreshing == other.isRefreshing &&
          $mapEquality.equals(_self.permissionsStatus, other.permissionsStatus) &&
          $mapEquality.equals(_self.servicesStatus, other.servicesStatus) &&
          $setEquality.equals(_self.payload, other.payload);
  @override
  int get hashCode {
    var hashCode = 0;
    hashCode = $hashCombine(hashCode, _self.isRefreshing.hashCode);
    hashCode = $hashCombine(hashCode, $mapEquality.hash(_self.permissionsStatus));
    hashCode = $hashCombine(hashCode, $mapEquality.hash(_self.servicesStatus));
    hashCode = $hashCombine(hashCode, $setEquality.hash(_self.payload));
    return $hashFinish(hashCode);
  }

  @override
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
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CheckedPermissionState &&
          runtimeType == other.runtimeType &&
          _self.isRefreshing == other.isRefreshing &&
          $mapEquality.equals(_self.permissionsStatus, other.permissionsStatus) &&
          $mapEquality.equals(_self.servicesStatus, other.servicesStatus) &&
          $setEquality.equals(_self.payload, other.payload);
  @override
  int get hashCode {
    var hashCode = 0;
    hashCode = $hashCombine(hashCode, _self.isRefreshing.hashCode);
    hashCode = $hashCombine(hashCode, $mapEquality.hash(_self.permissionsStatus));
    hashCode = $hashCombine(hashCode, $mapEquality.hash(_self.servicesStatus));
    hashCode = $hashCombine(hashCode, $setEquality.hash(_self.payload));
    return $hashFinish(hashCode);
  }

  @override
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
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RequestingPermissionsState &&
          runtimeType == other.runtimeType &&
          _self.isRefreshing == other.isRefreshing &&
          $mapEquality.equals(_self.permissionsStatus, other.permissionsStatus) &&
          $mapEquality.equals(_self.servicesStatus, other.servicesStatus) &&
          $setEquality.equals(_self.payload, other.payload);
  @override
  int get hashCode {
    var hashCode = 0;
    hashCode = $hashCombine(hashCode, _self.isRefreshing.hashCode);
    hashCode = $hashCombine(hashCode, $mapEquality.hash(_self.permissionsStatus));
    hashCode = $hashCombine(hashCode, $mapEquality.hash(_self.servicesStatus));
    hashCode = $hashCombine(hashCode, $setEquality.hash(_self.payload));
    return $hashFinish(hashCode);
  }

  @override
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
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RequestedPermissionsState &&
          runtimeType == other.runtimeType &&
          _self.isRefreshing == other.isRefreshing &&
          $mapEquality.equals(_self.permissionsStatus, other.permissionsStatus) &&
          $mapEquality.equals(_self.servicesStatus, other.servicesStatus) &&
          $setEquality.equals(_self.payload, other.payload) &&
          _self.isRequested == other.isRequested;
  @override
  int get hashCode {
    var hashCode = 0;
    hashCode = $hashCombine(hashCode, _self.isRefreshing.hashCode);
    hashCode = $hashCombine(hashCode, $mapEquality.hash(_self.permissionsStatus));
    hashCode = $hashCombine(hashCode, $mapEquality.hash(_self.servicesStatus));
    hashCode = $hashCombine(hashCode, $setEquality.hash(_self.payload));
    hashCode = $hashCombine(hashCode, _self.isRequested.hashCode);
    return $hashFinish(hashCode);
  }

  @override
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
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AskingPermissionsState &&
          runtimeType == other.runtimeType &&
          _self.isRefreshing == other.isRefreshing &&
          $mapEquality.equals(_self.permissionsStatus, other.permissionsStatus) &&
          $mapEquality.equals(_self.servicesStatus, other.servicesStatus) &&
          $setEquality.equals(_self.payload, other.payload);
  @override
  int get hashCode {
    var hashCode = 0;
    hashCode = $hashCombine(hashCode, _self.isRefreshing.hashCode);
    hashCode = $hashCombine(hashCode, $mapEquality.hash(_self.permissionsStatus));
    hashCode = $hashCombine(hashCode, $mapEquality.hash(_self.servicesStatus));
    hashCode = $hashCombine(hashCode, $setEquality.hash(_self.payload));
    return $hashFinish(hashCode);
  }

  @override
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
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfirmableAskPermissionsState &&
          runtimeType == other.runtimeType &&
          _self.isRefreshing == other.isRefreshing &&
          $mapEquality.equals(_self.permissionsStatus, other.permissionsStatus) &&
          $mapEquality.equals(_self.servicesStatus, other.servicesStatus) &&
          $setEquality.equals(_self.payload, other.payload) &&
          _self.isRestored == other.isRestored;
  @override
  int get hashCode {
    var hashCode = 0;
    hashCode = $hashCombine(hashCode, _self.isRefreshing.hashCode);
    hashCode = $hashCombine(hashCode, $mapEquality.hash(_self.permissionsStatus));
    hashCode = $hashCombine(hashCode, $mapEquality.hash(_self.servicesStatus));
    hashCode = $hashCombine(hashCode, $setEquality.hash(_self.payload));
    hashCode = $hashCombine(hashCode, _self.isRestored.hashCode);
    return $hashFinish(hashCode);
  }

  @override
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
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AskedPermissionsState &&
          runtimeType == other.runtimeType &&
          _self.isRefreshing == other.isRefreshing &&
          $mapEquality.equals(_self.permissionsStatus, other.permissionsStatus) &&
          $mapEquality.equals(_self.servicesStatus, other.servicesStatus) &&
          $setEquality.equals(_self.payload, other.payload) &&
          _self.isCancelled == other.isCancelled &&
          _self.isRequested == other.isRequested;
  @override
  int get hashCode {
    var hashCode = 0;
    hashCode = $hashCombine(hashCode, _self.isRefreshing.hashCode);
    hashCode = $hashCombine(hashCode, $mapEquality.hash(_self.permissionsStatus));
    hashCode = $hashCombine(hashCode, $mapEquality.hash(_self.servicesStatus));
    hashCode = $hashCombine(hashCode, $setEquality.hash(_self.payload));
    hashCode = $hashCombine(hashCode, _self.isCancelled.hashCode);
    hashCode = $hashCombine(hashCode, _self.isRequested.hashCode);
    return $hashFinish(hashCode);
  }

  @override
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
