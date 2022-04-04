part of 'position_bloc.dart';

abstract class PositionBlocEvent extends Equatable {
  const PositionBlocEvent();

  @override
  bool? get stringify => true;
}

/// [PositionBloc.locate]
class LocatePositionBloc extends PositionBlocEvent {
  final bool isRealTimeRequired;

  const LocatePositionBloc({this.isRealTimeRequired = false});

  @override
  List<Object?> get props => [isRealTimeRequired];
}

/// [PositionBloc.track]
class TrackPositionBloc extends PositionBlocEvent {
  const TrackPositionBloc();

  @override
  List<Object?> get props => [];
}

/// [PositionBloc.unTrack]
class UnTrackPositionBloc extends PositionBlocEvent {
  const UnTrackPositionBloc();

  @override
  List<Object?> get props => [];
}

/// Event to update the status of the position permission
class _PermissionUpdatePositionBloc extends PositionBlocEvent {
  final PermissionsBlocState state;

  const _PermissionUpdatePositionBloc(this.state);

  @override
  List<Object?> get props => [state];
}

/// Event to update the service status of the position
class _ServiceUpdatePositionBloc extends PositionBlocEvent {
  final bool isServiceEnabled;

  const _ServiceUpdatePositionBloc(this.isServiceEnabled);

  @override
  List<Object?> get props => [isServiceEnabled];
}

/// Event to update the realtime position
class _PositionUpdatePositionBloc extends PositionBlocEvent {
  final PositionBlocState state;

  const _PositionUpdatePositionBloc(this.state);

  @override
  List<Object?> get props => [state];
}
