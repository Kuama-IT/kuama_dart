part of 'position_bloc.dart';

abstract class _PositionBlocEvent extends Equatable {
  const _PositionBlocEvent();

  R map<R>({
    required R Function(_UpdateStatusEvent event) updateStatus,
    required R Function(_LocatePositionBloc event) locate,
    required R Function(_TrackPositionBloc event) track,
    required R Function(_UnTrackPositionBloc event) unTrack,
    required R Function(_EmitTrackingFailureEvent event) emitTrackingError,
    required R Function(_EmitTrackingPositionEvent event) emitTrackingPosition,
  });

  @override
  bool? get stringify => true;
}

/// Event to update the status of the position permissions and service
class _UpdateStatusEvent extends _PositionBlocEvent {
  final bool hasPermissionGranted;
  final bool isServiceEnabled;

  const _UpdateStatusEvent({required this.hasPermissionGranted, required this.isServiceEnabled});

  @override
  R map<R>({
    required R Function(_UpdateStatusEvent event) updateStatus,
    required R Function(_LocatePositionBloc event) locate,
    required R Function(_TrackPositionBloc event) track,
    required R Function(_UnTrackPositionBloc event) unTrack,
    required R Function(_EmitTrackingFailureEvent event) emitTrackingError,
    required R Function(_EmitTrackingPositionEvent event) emitTrackingPosition,
  }) {
    return updateStatus(this);
  }

  @override
  List<Object?> get props => [hasPermissionGranted, isServiceEnabled];
}

/// [PositionBloc.locate]
class _LocatePositionBloc extends _PositionBlocEvent {
  const _LocatePositionBloc();

  @override
  R map<R>({
    required R Function(_UpdateStatusEvent event) updateStatus,
    required R Function(_LocatePositionBloc event) locate,
    required R Function(_TrackPositionBloc event) track,
    required R Function(_UnTrackPositionBloc event) unTrack,
    required R Function(_EmitTrackingFailureEvent event) emitTrackingError,
    required R Function(_EmitTrackingPositionEvent event) emitTrackingPosition,
  }) {
    return locate(this);
  }

  @override
  List<Object?> get props => [];
}

/// [PositionBloc.track]
class _TrackPositionBloc extends _PositionBlocEvent {
  const _TrackPositionBloc();

  @override
  R map<R>({
    required R Function(_UpdateStatusEvent event) updateStatus,
    required R Function(_LocatePositionBloc event) locate,
    required R Function(_TrackPositionBloc event) track,
    required R Function(_UnTrackPositionBloc event) unTrack,
    required R Function(_EmitTrackingPositionEvent event) emitTrackingPosition,
    required R Function(_EmitTrackingFailureEvent event) emitTrackingError,
  }) {
    return track(this);
  }

  @override
  List<Object?> get props => [];
}

/// [PositionBloc.unTrack]
class _UnTrackPositionBloc extends _PositionBlocEvent {
  const _UnTrackPositionBloc();

  @override
  R map<R>({
    required R Function(_UpdateStatusEvent event) updateStatus,
    required R Function(_LocatePositionBloc event) locate,
    required R Function(_TrackPositionBloc event) track,
    required R Function(_UnTrackPositionBloc event) unTrack,
    required R Function(_EmitTrackingFailureEvent event) emitTrackingError,
    required R Function(_EmitTrackingPositionEvent event) emitTrackingPosition,
  }) {
    return unTrack(this);
  }

  @override
  List<Object?> get props => [];
}

/// Event to update the realtime position
class _EmitTrackingPositionEvent extends _PositionBlocEvent {
  final GeoPoint position;

  const _EmitTrackingPositionEvent(this.position);

  @override
  R map<R>({
    required R Function(_LocatePositionBloc event) locate,
    required R Function(_TrackPositionBloc event) track,
    required R Function(_UnTrackPositionBloc event) unTrack,
    required R Function(_UpdateStatusEvent event) updateStatus,
    required R Function(_EmitTrackingFailureEvent event) emitTrackingError,
    required R Function(_EmitTrackingPositionEvent event) emitTrackingPosition,
  }) {
    return emitTrackingPosition(this);
  }

  @override
  List<Object?> get props => [position];
}

/// Event to update the realtime position with failure
class _EmitTrackingFailureEvent extends _PositionBlocEvent {
  final Failure failure;

  const _EmitTrackingFailureEvent(this.failure);

  @override
  R map<R>({
    required R Function(_UpdateStatusEvent event) updateStatus,
    required R Function(_LocatePositionBloc event) locate,
    required R Function(_TrackPositionBloc event) track,
    required R Function(_UnTrackPositionBloc event) unTrack,
    required R Function(_EmitTrackingFailureEvent event) emitTrackingError,
    required R Function(_EmitTrackingPositionEvent event) emitTrackingPosition,
  }) {
    return emitTrackingError(this);
  }

  @override
  List<Object?> get props => [failure];
}
