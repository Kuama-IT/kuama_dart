import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:kuama_flutter/kuama_flutter.dart' show Failure, StreamFailureExtension;
import 'package:kuama_permissions/kuama_permissions.dart';
import 'package:kuama_positioner/src/service/position_service.dart';
import 'package:pure_extensions/pure_extensions.dart';
import 'package:rxdart/rxdart.dart';

part '_positioner_event.dart';
part '_positioner_state.dart';

class PositionBloc extends Bloc<PositionBlocEvent, PositionBlocState> {
  PositionService get _service => GetIt.I();

  /// Any of these permissions are sufficient for the use of the bloc
  static final _permissions = <Permission>{
    Permission.location,
    Permission.locationWhenInUse,
    Permission.locationAlways
  };
  final PermissionsBloc permissionBloc;

  final _initSubs = CompositeSubscription();
  final _positionSubs = CompositeSubscription();
  var _realTimeListenerCount = 0;

  PositionBloc({
    GeoPoint? lastPosition,
    required this.permissionBloc,
  }) : super(PositionBlocIdle(
          lastPosition: lastPosition,
          hasPermission: permissionBloc.state.checkAnyGranted(_permissions),
          isServiceEnabled: false,
        )) {
    on<PositionBlocEvent>(
      (event, emit) => emit.forEach<PositionBlocState>(mapEventToState(event), onData: (s) => s),
      transformer: (events, mapper) => events.asyncExpand((event) => mapper(event)),
    );

    _initServiceAndPermissionStatusListeners();
  }

  /// Call it to locate a user.
  void locate() => add(const LocatePositionBloc());

  /// Call it to track location user. Remember to call [unTrack] to free up resources
  void track() => add(const TrackPositionBloc());

  /// It stops listening to the position in realtime when there are no more listeners for it
  ///
  /// It must be called when you were listening to the position in realtime.
  /// There is no need to call it if you weren't listening to the realtime position.
  void unTrack() => add(const UnTrackPositionBloc());

  Stream<PositionBlocState> mapEventToState(PositionBlocEvent event) {
    if (event is _PermissionUpdatePositionBloc) {
      return _mapPermissionAndServiceUpdates(
          event.state.checkAnyGranted(_permissions), state.isServiceEnabled);
    }
    if (event is _ServiceUpdatePositionBloc) {
      return _mapPermissionAndServiceUpdates(state.hasPermission, event.isServiceEnabled);
    }

    if (event is LocatePositionBloc) {
      return _mapLocate(event);
    }
    if (event is TrackPositionBloc) {
      return _mapTrack(event);
    }
    if (event is _PositionUpdatePositionBloc) {
      if (!state.canLocalize) return const Stream.empty();
      return Stream.value(event.state);
    }
    if (event is UnTrackPositionBloc) {
      return _mapUnTrack(event);
    }
    throw UnimplementedError('$event');
  }

  Future<void> _restoreBloc() async {
    await _positionSubs.clear();
  }

  /// Start listening for the service status
  void _initServiceAndPermissionStatusListeners() {
    Rx.concatEager([
      _service.checkService().asStream(),
      _service.onServiceChanges,
    ]).listen((isServiceEnabled) {
      add(_ServiceUpdatePositionBloc(isServiceEnabled));
    }).addTo(_initSubs);

    permissionBloc.stream.listen((permissionState) {
      add(_PermissionUpdatePositionBloc(permissionState));
    }).addTo(_initSubs);
  }

  /// Update current status based on permission and service status
  ///
  /// If the position has been requested in realtime, listening will be started
  Stream<PositionBlocState> _mapPermissionAndServiceUpdates(
    bool hasPermission,
    bool isServiceEnabled,
  ) async* {
    final state = this.state;

    // Service is disabled or not has permission, clean up and update the bloc state
    if (!hasPermission || !isServiceEnabled) {
      yield state.toIdle(hasPermission: hasPermission, isServiceEnabled: isServiceEnabled);
      await _restoreBloc();
      return;
    }

    // Permission and service is enabled, start listen location updates

    if (_positionSubs.isNotEmpty) return;

    yield state.toIdle(hasPermission: true, isServiceEnabled: true);

    if (_realTimeListenerCount <= 0) return;

    yield state.toLocating(isRealTime: true);
    _initPositionListener();
  }

  /// It will output the current position once
  ///
  /// If the realtime position is active the last position is valid
  Stream<PositionBlocState> _mapLocate(LocatePositionBloc event) async* {
    // You do not have the necessary credentials to be able to locate the user
    if (!state.canLocalize) return;

    // If bloc is not listening to realtime position, it will shortly output the current position
    if (_realTimeListenerCount <= 0) {
      yield state.toLocating(isRealTime: false);

      try {
        final position = await _service.getCurrentPosition();
        yield state.toLocated(isRealTime: false, currentPosition: position);
      } on Failure catch (failure) {
        yield state.toFailed(failure: failure);
      }
      return;
    }
  }

  /// Listen realtime position
  void _initPositionListener() {
    Rx.concatEager([
      _service.getCurrentPosition().asStream(),
      _service.onPositionChanges,
    ]).onFailureResume((failure) {
      add(_PositionUpdatePositionBloc(state.toFailed(failure: failure)));
      return const Stream.empty();
    }).listen((position) {
      add(_PositionUpdatePositionBloc(state.toLocated(
        isRealTime: true,
        currentPosition: position,
      )));
    }).addTo(_positionSubs);
  }

  /// It will output current position many times
  ///
  /// If it is not possible to have the position in real time, it will be requested as soon as possible
  /// If the realtime position is already requested, no operation is performed
  Stream<PositionBlocState> _mapTrack(TrackPositionBloc event) async* {
    _realTimeListenerCount++;

    // You do not have the necessary credentials to be able to locate the user
    if (!state.canLocalize) return;

    // Already listen realtime position events
    if (_positionSubs.isNotEmpty) {
      return;
    }

    yield state.toLocating(isRealTime: true);

    _initPositionListener();
  }

  /// Stop listening to the actual location if there are no more listeners for it
  Stream<PositionBlocState> _mapUnTrack(UnTrackPositionBloc event) async* {
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
    yield state.toIdle(hasPermission: true, isServiceEnabled: true);
  }

  @override
  Future<void> close() {
    _positionSubs.dispose();
    _initSubs.dispose();
    return super.close();
  }
}
