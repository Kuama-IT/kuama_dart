import 'package:bloc/bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:kuama_permissions/src/services/permissions_service.dart';
import 'package:mek_data_class/mek_data_class.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pure_extensions/pure_extensions.dart';

part 'permissions_bloc.b.g.dart';
part 'permissions_state.dart';

class PermissionsBloc extends Cubit<PermissionsBlocState> {
  PermissionsService get _service => GetIt.I();

  PermissionsBloc({
    Set<Permission> preCheck = const {},
  }) : super(PermissionsBlocState(
          places: {
            for (final permission in preCheck) permission: PermissionPlace.checking,
          },
          status: const {},
        )) {
    _onChecking(preCheck.toList());
  }

  /// Check permissions status
  void check(Set<Permission> permissions) {
    final effectivePermissions = state._whereCheck(permissions).toList();
    if (effectivePermissions.isEmpty) return;

    emit(state.copyWith(
      places: {
        ...state.places,
        for (final permission in effectivePermissions) permission: PermissionPlace.checking,
      },
    ));

    _onChecking(effectivePermissions);
  }

  /// Requires permissions and will be marked with [PermissionPlace.asking],
  /// resolve it with [resolveAsk]
  ///
  /// [tryAgain] If the permissions have already been requested once, it will try to request them again
  void request(Set<Permission> permissions, {bool tryAgain = false}) async {
    var requestable = state._whereRequest(permissions, tryAgain).toList();
    if (requestable.isEmpty) return;

    final checkable = state._whereRequestCheck(permissions);
    var checkResult = <Permission, PermissionStatus>{};

    if (checkable.isNotEmpty) {
      emit(state.copyWith(
        places: {
          ...state.places,
          for (final permission in requestable) permission: PermissionPlace.requesting,
        },
      ));

      checkResult = await _service.checkPermissions(permissions.toList());

      if (tryAgain) checkResult = checkResult.where((_, status) => status.isGranted);
    }

    requestable = requestable.whereNotContains(checkResult.keys).toList();
    final status = <Permission, PermissionStatus>{
      ...state.status,
      ...checkResult,
    };

    emit(state.copyWith(
      places: {
        ...state.places.where((permission, _) => !status.containsKey(permission)),
        for (final permission in requestable) permission: PermissionPlace.asking,
      },
      status: status,
    ));
  }

  /// Resolves permission [PermissionPlace.asking]
  ///
  /// [canRequest] Determines whether the user has permission to request permissions
  void resolveAsk(bool canRequest) async {
    if (!state.isAsking) return;

    final askingPermissions = state.asking.toList();
    emit(state.copyWith(
      places: {
        ...state.places,
        for (final permission in askingPermissions) permission: PermissionPlace.requesting,
      },
    ));

    if (canRequest) {
      _onRequesting(askingPermissions);
      return;
    } else {
      await _service.addUnRequestPermissions(askingPermissions);
    }

    emit(state.copyWith(
      places: state.places.where((_, place) => !place.isRequesting),
      status: {
        ...state.status,
        for (final permission in askingPermissions) permission: PermissionStatus.denied,
      },
    ));
  }

  bool _isRefreshing = false;

  /// Refresh the status of permissions
  void refresh() async {
    if (_isRefreshing) return;
    _isRefreshing = true;

    try {
      final permissions = <Permission>[...state.places.keys, ...state.status.keys];
      // TODO: Check only negated permission because granted permission if change app crash
      final results = await _service.checkPermissions(permissions);

      var nextPlaces = state.places;

      final changedPermissions = permissions.where((permission) {
        return state.status[permission] != results[permission];
      });
      final changedPlaces = state.places.where((permission, _) {
        return changedPermissions.contains(permission);
      });

      if (changedPlaces.isNotEmpty) {
        final hasProcessingPermissions = changedPlaces.any((_, place) {
          return place.isAsking || place.isRequesting;
        });
        if (hasProcessingPermissions) {
          nextPlaces = nextPlaces.where((_, status) => !status.isAsking && !status.isRequesting);
        }

        final checkingPermissions = changedPlaces.where((_, place) {
          return place.isChecking;
        });
        if (checkingPermissions.isNotEmpty) {
          nextPlaces =
              nextPlaces.where((permission, _) => !checkingPermissions.containsKey(permission));
        }
      }

      emit(state.copyWith(
        places: nextPlaces,
        status: {...state.status, ...results},
      ));
    } finally {
      _isRefreshing = false;
    }
  }

  void _onChecking(List<Permission> permissions) async {
    if (permissions.isEmpty) return;

    var results = await _service.checkPermissions(permissions);

    // Non emettere i risultati dei permessi che nel frattempo sono stati richiesti
    results = results.where((permission, _) => state.places[permission]!.isChecking);

    emit(state.copyWith(
      places: state.places.where((permission, place) {
        return !(place.isChecking && permissions.contains(permission));
      }),
      status: {
        ...state.status,
        ...results,
      },
    ));
  }

  void _onRequesting(List<Permission> permissions) async {
    final results = await _service.requestPermissions(permissions);

    emit(state.copyWith(
      places: state.places.where((permission, place) {
        return !(place.isRequesting && permissions.contains(permission));
      }),
      status: {
        ...state.status,
        ...results,
      },
    ));
  }
}
