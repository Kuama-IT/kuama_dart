part of 'position_bloc.dart';

abstract class PositionBlocState extends Equatable {
  final LatLng? lastPosition;

  const PositionBlocState({required this.lastPosition});

  bool get hasPermission {
    final state = this;
    if (state is PositionBlocIdle) {
      return state.hasPermission;
    }
    return true;
  }

  bool get isServiceEnabled {
    final state = this;
    if (state is PositionBlocIdle) {
      return state.isServiceEnabled;
    }
    return true;
  }

  /// Check if you can call [PositionBloc.locate].
  /// You must have permission and active service
  bool get canLocalize => hasPermission && isServiceEnabled;

  bool get hasLastPosition => lastPosition != null;

  PositionBlocState toIdle({LatLng? position, bool? hasPermission, bool? isServiceEnabled}) {
    return PositionBlocIdle(
      lastPosition: position ?? lastPosition,
      hasPermission: hasPermission ?? this.hasPermission,
      isServiceEnabled: isServiceEnabled ?? this.isServiceEnabled,
    );
  }

  PositionBlocLocating toLocating({required bool isRealTime}) {
    return PositionBlocLocating(
      lastPosition: lastPosition,
      isRealTime: isRealTime,
    );
  }

  PositionBlocState toFailed({required Failure failure}) {
    return PositionBlocFailed(lastPosition: lastPosition, failure: failure);
  }

  PositionBlocState toLocated({
    required bool isRealTime,
    required LatLng currentPosition,
  }) {
    return PositionBlocLocated(
      isRealTime: isRealTime,
      currentPosition: currentPosition,
    );
  }

  @override
  bool get stringify => true;
}

/// It is waiting for a localization request that can only be requested when [canLocalize] is true
class PositionBlocIdle extends PositionBlocState {
  /// In ios it will always be false if the service is disabled
  @override
  final bool hasPermission;
  @override
  final bool isServiceEnabled;

  const PositionBlocIdle({
    required super.lastPosition,
    required this.hasPermission,
    required this.isServiceEnabled,
  });

  @override
  List<Object?> get props => [lastPosition, hasPermission, isServiceEnabled];
}

/// It is locating the user
class PositionBlocLocating extends PositionBlocState {
  final bool isRealTime;

  const PositionBlocLocating({
    required super.lastPosition,
    required this.isRealTime,
  });

  @override
  List<Object?> get props => [lastPosition, isRealTime];
}

/// Localization failed
class PositionBlocFailed extends PositionBlocState {
  final Failure failure;

  const PositionBlocFailed({
    required super.lastPosition,
    required this.failure,
  });

  @override
  List<Object?> get props => [lastPosition, failure];
}

/// The user has been located
/// Other positions will be issued if [isRealTime] is true
class PositionBlocLocated extends PositionBlocState {
  final bool isRealTime;
  final LatLng currentPosition;

  const PositionBlocLocated({
    required this.isRealTime,
    required this.currentPosition,
  }) : super(lastPosition: currentPosition);

  @override
  List<Object?> get props => [lastPosition, isRealTime, currentPosition];
}
