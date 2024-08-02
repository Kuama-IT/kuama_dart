import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:kuama_core/kuama_core.dart';
import 'package:kuama_permissions/kuama_permissions.dart';
import 'package:kuama_position/src/service/position_service.dart';
import 'package:pure_extensions/pure_extensions.dart';
import 'package:rxdart/rxdart.dart';

part '_position_event.dart';
part '_position_state.dart';

class PositionBloc extends Bloc<_PositionBlocEvent, PositionBlocState> {
  PositionService get _service => GetIt.I();

  /// Any of these permissions are sufficient for the use of the bloc
  static final permissions = <Permission>{
    Permission.location,
    Permission.locationWhenInUse,
    Permission.locationAlways
  };

  final _initSubs = CompositeSubscription();
  final _positionSubs = CompositeSubscription();
  var _realTimeListenerCount = 0;

  PositionBloc({
    GeoPoint? lastPosition,
    required PermissionsBloc permissionsBloc,
  }) : super(PositionBlocIdle(
          lastPosition: lastPosition,
          hasPermission: permissionsBloc.state.checkAny(permissions, PermissionStatus.granted),
          isServiceEnabled: permissionsBloc.state.checkService(Service.location),
        )) {
    on<_PositionBlocEvent>(_mapEventToState, transformer: sequential());

    _initServiceAndPermissionStatusListeners(permissionsBloc);
  }

  /// Call it to locate a user.
  void locate() => add(const _LocatePositionBloc());

  /// Call it to track location user. Remember to call [unTrack] to free up resources
  void track() => add(const _TrackPositionBloc());

  /// It stops listening to the position in realtime when there are no more listeners for it
  ///
  /// It must be called when you were listening to the position in realtime.
  /// There is no need to call it if you weren't listening to the realtime position.
  void unTrack() => add(const _UnTrackPositionBloc());

  Future<void> _mapEventToState(_PositionBlocEvent event, Emitter<PositionBlocState> emit) async {
    return event.map<Future<void>>(updateStatus: (event) {
      return _mapStatusUpdate(emit, event.hasPermissionGranted, event.isServiceEnabled);
    }, locate: (event) {
      return _mapLocate(emit, event);
    }, track: (event) {
      return _mapTrack(emit, event);
    }, unTrack: (event) {
      return _mapUnTrack(emit, event);
    }, emitTrackingError: (event) async {
      if (!state.canLocalize) return;
      emit(state.toFailed(failure: event.failure));
    }, emitTrackingPosition: (event) async {
      if (!state.canLocalize) return;
      emit(state.toLocated(isRealTime: true, currentPosition: event.position));
    });
  }

  Future<void> _restoreBloc() async {
    await _positionSubs.clear();
  }

  /// Start listening for the service status
  void _initServiceAndPermissionStatusListeners(PermissionsBloc permissionBloc) {
    permissionBloc.stream.listen((state) {
      final hasPermissionGranted = state.checkAny(permissions, PermissionStatus.granted);
      final isServiceEnabled = state.checkService(Service.location);
      add(_UpdateStatusEvent(
        hasPermissionGranted: hasPermissionGranted,
        isServiceEnabled: isServiceEnabled,
      ));
    }, onError: onError).addTo(_initSubs);
  }

  /// Update current status based on permission and service status
  ///
  /// If the position has been requested in realtime, listening will be started
  Future<void> _mapStatusUpdate(
    Emitter<PositionBlocState> emit,
    bool hasPermission,
    bool isServiceEnabled,
  ) async {
    final state = this.state;

    if (state.hasPermission == hasPermission && state.isServiceEnabled == isServiceEnabled) {
      return;
    }

    // Service is disabled or not has permission, clean up and update the bloc state
    if (!hasPermission || !isServiceEnabled) {
      emit(state.toIdle(hasPermission: hasPermission, isServiceEnabled: isServiceEnabled));
      await _restoreBloc();
      return;
    }

    // Permission and service is enabled, start listen location updates

    if (_positionSubs.isNotEmpty) return;

    emit(state.toIdle(hasPermission: true, isServiceEnabled: true));

    if (_realTimeListenerCount <= 0) return;

    emit(state.toLocating(isRealTime: true));
    _initPositionListener();
  }

  /// It will output the current position once
  ///
  /// If the realtime position is active the last position is valid
  Future<void> _mapLocate(Emitter<PositionBlocState> emit, _LocatePositionBloc event) async {
    // You do not have the necessary credentials to be able to locate the user
    if (!state.canLocalize) return;

    // If bloc is not listening to realtime position, it will shortly output the current position
    if (_realTimeListenerCount <= 0) {
      emit(state.toLocating(isRealTime: false));

      try {
        final position = await _service.getCurrentPosition();
        emit(state.toLocated(isRealTime: false, currentPosition: position));
      } on Failure catch (failure) {
        emit(state.toFailed(failure: failure));
      }
      return;
    }
  }

  /// Listen realtime position
  void _initPositionListener() {
    Rx.concatEager([
      // ignore: discarded_futures
      _service.getCurrentPosition().asStream(),
      _service.onPositionChanges,
    ]).onFailureResume((failure) {
      add(_EmitTrackingFailureEvent(failure));
      return const Stream.empty();
    }).listen((position) {
      add(_EmitTrackingPositionEvent(position));
    }, onError: onError).addTo(_positionSubs);
  }

  /// It will output current position many times
  ///
  /// If it is not possible to have the position in real time, it will be requested as soon as possible
  /// If the realtime position is already requested, no operation is performed
  Future<void> _mapTrack(Emitter<PositionBlocState> emit, _TrackPositionBloc event) async {
    _realTimeListenerCount++;

    // You do not have the necessary credentials to be able to locate the user
    if (!state.canLocalize) return;

    // Already listen realtime position events
    if (_positionSubs.isNotEmpty) {
      return;
    }

    emit(state.toLocating(isRealTime: true));

    _initPositionListener();
  }

  /// Stop listening to the actual location if there are no more listeners for it
  Future<void> _mapUnTrack(Emitter<PositionBlocState> emit, _UnTrackPositionBloc event) async {
    // Reduce the counter of listeners only if it has at least one
    if (_realTimeListenerCount > 0) _realTimeListenerCount--;

    // You do not have the necessary credentials to be able to locate the user
    if (!state.canLocalize) return;

    // Other listeners are listening to the position in realtime
    if (_realTimeListenerCount > 0) {
      return;
    }

    // Nobody is listening to the real position
    await _positionSubs.clear();
    emit(state.toIdle(hasPermission: true, isServiceEnabled: true));
  }

  @override
  Future<void> close() {
    _positionSubs.dispose();
    _initSubs.dispose();
    return super.close();
  }
}
