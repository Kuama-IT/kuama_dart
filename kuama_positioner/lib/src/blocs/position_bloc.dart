import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:kuama_permissions/kuama_permissions.dart';
import 'package:kuama_positioner/src/use_cases/check_position_service.dart';
import 'package:kuama_positioner/src/use_cases/get_current_position.dart';
import 'package:kuama_positioner/src/use_cases/on_position_changes.dart';
import 'package:kuama_positioner/src/use_cases/on_service_changes.dart';
import 'package:pure_extensions/pure_extensions.dart';
import 'package:rxdart/rxdart.dart';

part '_positioner_event.dart';
part '_positioner_state.dart';

class PositionBloc extends Bloc<PositionBlocEvent, PositionBlocState> {
  final CheckPositionService _checkService = GetIt.I();
  final OnPositionServiceChanges _onServiceChanges = GetIt.I();
  final GetCurrentPosition _getCurrentLocation = GetIt.I();
  final OnPositionChanges _onPositionChanges = GetIt.I();

  final PermissionsBloc permissionBloc;

  final _permissionSubs = CompositeSubscription();
  final _serviceSubs = CompositeSubscription();
  final _positionSubs = CompositeSubscription();
  var _realTimeListenerCount = 0;

  PositionBloc({
    GeoPoint? lastPosition,
    required this.permissionBloc,
  }) : super(PositionBlocIdle(
          lastPosition: lastPosition,
          hasPermission: permissionBloc.state.checkGranted({}),
          isServiceEnabled: false,
        )) {
    on<PositionBlocEvent>(
      (event, emit) => emit.forEach<PositionBlocState>(mapEventToState(event), onData: (s) => s),
      transformer: (events, mapper) => events.asyncExpand((event) => mapper(event)),
    );
    permissionBloc.stream.listen((permissionState) {
      add(_PermissionUpdatePositionBloc(permissionState));
    }).addTo(_permissionSubs);
    if (permissionBloc.state.isGranted) {
      _initServicesStatusListener();
    }
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
      return _mapPermissionUpdate(event.state);
    }
    if (event is _ServiceUpdatePositionBloc) {
      return _mapServiceUpdate(event.isServiceEnabled);
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
  void _initServicesStatusListener() {
    if (_serviceSubs.isNotEmpty) return;
    Rx.concatEager([
      _checkService.call(NoParams()).asStream(),
      _onServiceChanges.call(NoParams()),
    ]).listen((isServiceEnabled) {
      add(_ServiceUpdatePositionBloc(isServiceEnabled));
    }).addTo(_serviceSubs);
  }

  void _cancelServiceStatusListener() {
    _serviceSubs.clear();
  }

  /// Update current status based on permission state
  Stream<PositionBlocState> _mapPermissionUpdate(PermissionBlocState permissionState) async* {
    // Skip all elaborating request states
    if (permissionState is PermissionBlocRequesting ||
        permissionState is PermissionBlocRequestConfirm) {
      return;
    }

    final state = this.state;

    final hasPermission = permissionState.isGranted;

    // Permission has been revoked, clean up and update the bloc state
    if (!hasPermission) {
      _cancelServiceStatusListener();
      await _restoreBloc();
      yield state.toIdle(hasPermission: false);
      return;
    }
    // Permission has been granted, update the bloc state
    if (!state.hasPermission) {
      // listen service status only after app gets the position permission
      _initServicesStatusListener();
      yield state.toIdle(hasPermission: true);
      return;
    }
    // No major changes. The bloc already has permission
  }

  /// Update current status based on service status
  ///
  /// If the position has been requested in realtime, listening will be started
  Stream<PositionBlocState> _mapServiceUpdate(bool isServiceEnabled) async* {
    // Service is disabled, clean up and update the bloc state
    if (!isServiceEnabled) {
      await _restoreBloc();
      yield state.toIdle(isServiceEnabled: false);
      return;
    }
    // Service is enabled, update the bloc state
    if (!state.isServiceEnabled) {
      yield state.toIdle(isServiceEnabled: true);

      if (_realTimeListenerCount <= 0) return;

      yield state.toLocating(isRealTime: true);
      _initPositionListener();
      return;
    }
    // No major changes. The bloc already has service status updated
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
        final position = await _getCurrentLocation.call(NoParams());
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
      _getCurrentLocation.call(NoParams()).asStream(),
      _onPositionChanges.call(NoParams()),
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
    _serviceSubs.dispose();
    _permissionSubs.dispose();
    return super.close();
  }
}
