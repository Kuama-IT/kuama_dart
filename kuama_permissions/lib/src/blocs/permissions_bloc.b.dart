import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:collection/collection.dart';
import 'package:get_it/get_it.dart';
import 'package:kuama_permissions/src/entities/service.dart';
import 'package:kuama_permissions/src/services/permissions_service.dart';
import 'package:mek_data_class/mek_data_class.dart';
import 'package:meta/meta.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pure_extensions/pure_extensions.dart';
import 'package:rxdart/rxdart.dart';

part '_permissions_event.dart';
part '_permissions_state.dart';
part 'permissions_bloc.b.g.dart';

class PermissionsBloc extends Bloc<_PermissionsBlocEvent, PermissionsBlocState> {
  PermissionsService get _service => GetIt.I();

  StreamSubscription<void>? _refreshPermissionsSub;
  final _servicesSubs = CompositeSubscription();

  PermissionsBloc()
      : super(const CheckedPermissionState(
          isRefreshing: false,
          permissionsStatus: {},
          servicesStatus: {},
          payload: {},
        )) {
    on<_PermissionsBlocEvent>(_onEvent, transformer: sequential());

    // TODO: Start listening to stream only when there is at least one permission inside the state
    _refreshPermissionsSub = _service.onRequiredPermissionsRefresh.listen((_) {
      _refresh();
    });
  }

  /// Check permissions status.
  ///
  /// You cannot perform this action on a [ConfirmableAskPermissionsState]
  ///
  /// While processing the actions, [CheckingPermissionState] is emitted.
  /// Once the action is completed, update both permissions and services status to [permissions] and emits [CheckedPermissionState].
  ///
  /// Extra: You can check if you can perform this method with [PermissionsBlocState.checkCanCheck].
  void check(Set<Permission> permissions) => add(_CheckPermissionsEvent(permissions));

  // TODO: Implement request permissions without need ask before request it
  // void request(Set<Permission> permissions);

  /// Asks permissions.
  ///
  /// You cannot perform this action on a [ConfirmableAskPermissionsState]
  ///
  /// While processing the actions, [AskingPermissionsState] is emitted.
  ///
  /// If the permissions have already been requested before or all permissions are granted,
  /// it emits [AskedPermissionsState] with [AskedPermissionsState.isRequested] to `false`.
  ///
  /// If the permissions can be requested, emits [ConfirmableAskPermissionsState]
  /// that can be confirmed with [confirmAsk].
  ///
  /// If the permissions have already been requested once, use [tryAgain] to request them again.
  ///
  /// Extra: You can check if you can perform this method with [PermissionsBlocState.checkCanAsk]
  void ask(Set<Permission> permissions, {bool tryAgain = false}) =>
      add(_AskPermissionsEvent(permissions, tryAgain: tryAgain));

  /// Resolves ask permission
  ///
  /// You cannot perform this action on a [ConfirmableAskPermissionsState]
  ///
  /// If the request is canceled, it emits [AskedPermissionsState.isCancelled] to `true`.
  ///
  /// If it is processed, it will emit [AskingPermissionsState].
  ///
  /// If the confirmation is unsuccessful, it emits [AskedPermissionsState.isRequested] to `false`.
  ///
  /// If the confirmation is successful and all permissions have been granted, it emits
  /// [AskedPermissionsState.isRequested] to `true`,
  /// otherwise it emits [ConfirmableAskPermissionsState.isRestored] to `true`.
  ///
  /// [canRequest] determines whether the user has allowed the permissions to be requested.
  /// If `null`, the request is discarded.
  ///
  /// Note: The confirmation may be completed after a refresh. See [PermissionsBlocState.isRefreshing].
  ///
  /// Extra: You can check if you can perform this method with [PermissionsBlocState.checkCanConfirmAsk].
  void confirmAsk(bool? canRequest) => add(_ConfirmAskPermissionsEvent(canRequest));

  Future<void> _onEvent(_PermissionsBlocEvent event, Emitter<PermissionsBlocState> emit) async {
    if (event is _CheckPermissionsEvent) {
      return await _onCheck(emit, event.permissions);
    } else if (event is _AskPermissionsEvent) {
      return await _onAsk(emit, event.permissions, tryAgain: event.tryAgain);
    } else if (event is _ConfirmAskPermissionsEvent) {
      return await _onConfirmAsk(emit, event.canRequest);
    } else if (event is _RefreshPermissionsEvent) {
      return await _onRefresh(emit);
    }
    throw 'Not supported ${event.runtimeType}';
  }

  Future<void> _onCheck(Emitter<PermissionsBlocState> emit, Set<Permission> permissions) async {
    if (permissions.isEmpty || !state.checkCanCheck(permissions)) return;

    if (permissions.every(state.permissionsStatus.containsKey)) return;

    emit(state.toChecking(
      payload: permissions,
    ));

    await _onChecking(emit, permissions);
  }

  Future<void> _onChecking(Emitter<PermissionsBlocState> emit, Set<Permission> permissions) async {
    final checkResult = await _service.checkStatus(permissions.toList());
    final permissionsStatus = checkResult.permissions;
    final servicesStatus = checkResult.services;

    _listenServices(servicesStatus.keys);

    emit(state.toChecked(
      payload: permissions,
      permissionsStatus: {...state.permissionsStatus, ...permissionsStatus},
      servicesStatus: {...state.servicesStatus, ...servicesStatus},
    ));
  }

  Future<void> _onAsk(
    Emitter<PermissionsBlocState> emit,
    Set<Permission> permissions, {
    bool tryAgain = false,
  }) async {
    if (permissions.isEmpty || !state.checkCanAsk(permissions)) return;

    emit(state.toAsking(
      payload: permissions,
    ));

    final result = await _service.checkStatus(permissions.toList(), tryAgain: tryAgain);

    _listenServices(result.services.keys);

    final permissionsStatus = {...state.permissionsStatus, ...result.permissions};
    final servicesStatus = {...state.servicesStatus, ...result.services};

    if (!result.canAsk || result.areAllGrantedAndEnabled) {
      emit(state.toAsked(
        permissionsStatus: permissionsStatus,
        servicesStatus: servicesStatus,
        payload: permissions,
        isCancelled: false,
        isRequested: false,
      ));
      return;
    }

    emit(state.toConfirmableAsk(
      permissionsStatus: permissionsStatus,
      servicesStatus: servicesStatus,
      payload: permissions,
      isRestored: false,
    ));
  }

  Future<void> _onConfirmAsk(Emitter<PermissionsBlocState> emit, bool? canRequest) async {
    var state = this.state;
    if (state is! ConfirmableAskPermissionsState) return;

    if (canRequest == null) {
      emit(state.toAsked(
        payload: state.payload,
        isCancelled: true,
        isRequested: false,
      ));
      return;
    }

    final askingPermissions = state.payload;
    emit(state.toAsking(
      payload: state.payload,
    ));

    if (canRequest) {
      await _onRequesting(emit, askingPermissions);
      return;
    }

    await _service.markAskedPermissions(askingPermissions.toList());

    state = this.state;
    emit(state.toAsked(
      permissionsStatus: {
        ...state.permissionsStatus,
        for (final permission in askingPermissions) permission: PermissionStatus.denied,
      },
      payload: askingPermissions,
      isCancelled: false,
      isRequested: false,
    ));
  }

  Future<void> _onRequesting(
    Emitter<PermissionsBlocState> emit,
    Set<Permission> permissions,
  ) async {
    final permissionStatus = await _service.requestPermissions(permissions.toList());

    if (permissionStatus.every((_, value) => value.isGranted)) {
      emit(state.toAsked(
        payload: permissions,
        permissionsStatus: {...state.permissionsStatus, ...permissionStatus},
        isCancelled: false,
        isRequested: true,
      ));
    } else {
      emit(state.toConfirmableAsk(
        permissionsStatus: {...state.permissionsStatus, ...permissionStatus},
        isRestored: true,
        payload: permissions,
      ));
    }
  }

  void _listenServices(Iterable<Service> services) {
    final newServices = services.whereNot(state.servicesStatus.containsKey);
    for (final service in newServices) {
      _servicesSubs.add(_service.onServiceChanges(service).listen((status) {
        _onServiceChanged(service, status);
      }));
    }
  }

  void _onServiceChanged(Service service, bool status) {
    _refresh();
  }

  /// Refresh the status of permissions
  void _refresh() => add(_RefreshPermissionsEvent());
  Future<void> _onRefresh(Emitter<PermissionsBlocState> emit) async {
    emit(this.state.copyWith(isRefreshing: true));

    var state = this.state;

    final allPermissions = state.maybeMap(asked: (state) {
      return [...state.permissionsStatus.keys, ...state.payload];
    }, orElse: (state) {
      return state.permissionsStatus.keys.toList();
    });

    // TODO: Check only negated permission because granted permission if change app crash
    // In ios when location is negated app not crash
    final resultsV2 = await _service.checkStatus(allPermissions);

    state = this.state;

    if (state is ConfirmableAskPermissionsState) {
      final isAllGranted = state.payload.every((permission) {
        return resultsV2.permissions[permission]?.isGranted ?? false;
      });

      if (isAllGranted) {
        emit(state.toAsked(
          permissionsStatus: {...state.permissionsStatus, ...resultsV2.permissions},
          servicesStatus: {...state.servicesStatus, ...resultsV2.services},
          payload: state.payload,
          isCancelled: false,
          isRequested: false,
        ));
        return;
      }
    }

    emit(state.copyWith(
      isRefreshing: false,
      permissionsStatus: {...state.permissionsStatus, ...resultsV2.permissions},
      servicesStatus: {...state.servicesStatus, ...resultsV2.services},
    ));
  }

  @override
  Future<void> close() async {
    await _refreshPermissionsSub?.cancel();
    await _servicesSubs.dispose();
    await super.close();
  }
}
