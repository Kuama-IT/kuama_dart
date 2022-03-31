import 'package:kuama_positioner/src/blocs/position_bloc.dart';
import 'package:kuama_positioner/src/use_cases/check_position_service.dart';
import 'package:kuama_positioner/src/use_cases/get_current_position.dart';
import 'package:kuama_positioner/src/use_cases/on_service_changes.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pure_extensions/pure_extensions.dart';
import 'package:test/test.dart';

class _MockCheckPositionService extends Mock implements CheckPositionService {}

class _MockOnPositionServiceChanges extends Mock implements OnPositionServiceChanges {}

class _MockGetCurrentPosition extends Mock implements GetCurrentPosition {}

class _MockOnPositionChanges extends Mock implements OnPositionChanges {}

class _MockPositionPermissionBloc extends Mock implements PositionPermissionBloc {}

enum EmissionType { none, acquire, alreadyHas }

void main() {
  late _MockCheckPositionService mockCheckService;
  late _MockOnPositionServiceChanges mockOnServiceChanges;
  late _MockGetCurrentPosition mockGetCurrent;
  late _MockOnPositionChanges mockOnPositionChanges;

  late _MockPositionPermissionBloc mockPermissionBloc;

  late PositionBloc bloc;

  const tPermission = Permission.position;

  setUp(() {
    GetIt.instance
      ..reset()
      ..registerSingleton<CheckPositionService>(mockCheckService = _MockCheckPositionService())
      ..registerSingleton<OnPositionServiceChanges>(
          mockOnServiceChanges = _MockOnPositionServiceChanges())
      ..registerSingleton<GetCurrentPosition>(mockGetCurrent = _MockGetCurrentPosition())
      ..registerSingleton<OnPositionChanges>(mockOnPositionChanges = _MockOnPositionChanges());
  });

  void init({
    EmissionType permission = EmissionType.none,
    EmissionType service = EmissionType.none,
  }) {
    mockPermissionBloc = _MockPositionPermissionBloc();

    when(() => mockPermissionBloc.state).thenReturn(permission == EmissionType.alreadyHas
        ? const PermissionBlocRequested(permission: tPermission, status: PermissionStatus.granted)
        : const PermissionBlocRequested(permission: tPermission, status: PermissionStatus.denied));
    when(() => mockPermissionBloc.stream).thenAnswer((_) async* {
      if (permission == EmissionType.acquire) {
        yield const PermissionBlocRequested(
            permission: tPermission, status: PermissionStatus.granted);
      }
    });
    when(() => mockCheckService.call(NoParams())).thenAnswer((realInvocation) async {
      return service == EmissionType.alreadyHas;
    });
    when(() => mockOnServiceChanges.call(NoParams())).thenAnswer((_) async* {
      if (service == EmissionType.acquire) {
        yield true;
      }
    });

    bloc = PositionBloc(
      permissionBloc: mockPermissionBloc,
    );

    expect(
      bloc.state,
      PositionBlocIdle(
        lastPosition: null,
        hasPermission: permission == EmissionType.alreadyHas,
        isServiceEnabled: false,
      ),
    );
  }

  group('Test PositionBloc', () {
    test('Update the bloc when permission has been granted', () async {
      init(permission: EmissionType.acquire);

      await expectLater(
        bloc.stream,
        emitsInOrder([
          const PositionBlocIdle(
            lastPosition: null,
            hasPermission: true,
            isServiceEnabled: false,
          ),
        ]),
      );
    });

    // test('Update the bloc when service is enabled', () async {
    //   init(service: EmissionType.acquire);
    //
    //   await expectLater(
    //     bloc.stream,
    //     emitsInOrder([
    //       PositionerBlocIdle(
    //         lastPosition: null,
    //         hasPermission: false,
    //         isServiceEnabled: true,
    //       ),
    //     ]),
    //   );
    // });

    test('Update the bloc when has permission and service is enabled', () async {
      init(permission: EmissionType.acquire, service: EmissionType.acquire);

      await expectLater(
        bloc.stream,
        emitsInOrder([
          const PositionBlocIdle(
            lastPosition: null,
            hasPermission: true,
            isServiceEnabled: false,
          ),
          const PositionBlocIdle(
            lastPosition: null,
            hasPermission: true,
            isServiceEnabled: true,
          ),
        ]),
      );
    });

    test('A listener requests the current position', () async {
      init(permission: EmissionType.alreadyHas, service: EmissionType.alreadyHas);

      await expectLater(
        bloc.stream,
        emitsInOrder([
          const PositionBlocIdle(
            lastPosition: null,
            hasPermission: true,
            isServiceEnabled: true,
          ),
        ]),
      );

      when(() => mockGetCurrent.call(NoParams())).thenAnswer((_) async {
        return const GeoPoint(0.0, 0.0);
      });

      bloc.locate();

      await expectLater(
        bloc.stream,
        emitsInOrder([
          const PositionBlocLocating(
            isRealTime: false,
            lastPosition: null,
          ),
          const PositionBlocLocated(
            isRealTime: false,
            currentPosition: GeoPoint(0.0, 0.0),
          ),
        ]),
      );

      bloc.unTrack();

      expect(
        bloc.stream,
        emitsInOrder([
          const PositionBlocIdle(
            lastPosition: GeoPoint(0.0, 0.0),
            hasPermission: true,
            isServiceEnabled: true,
          ),
          emitsDone,
        ]),
      );

      await bloc.close();
    });

    test('A listener requests the position in realtime', () async {
      init(permission: EmissionType.alreadyHas, service: EmissionType.alreadyHas);

      await expectLater(
        bloc.stream,
        emitsInOrder([
          const PositionBlocIdle(
            lastPosition: null,
            hasPermission: true,
            isServiceEnabled: true,
          ),
        ]),
      );

      when(() => mockGetCurrent.call(NoParams())).thenAnswer((_) async {
        return const GeoPoint(0.0, 0.0);
      });
      when(() => mockOnPositionChanges.call(NoParams())).thenAnswer((_) async* {
        await Future.delayed(const Duration());
        yield const GeoPoint(1.0, 1.0);
      });

      // ======== Test user tracking ========

      bloc.track();

      await expectLater(
        bloc.stream,
        emitsInOrder([
          const PositionBlocLocating(
            isRealTime: true,
            lastPosition: null,
          ),
          const PositionBlocLocated(
            isRealTime: true,
            currentPosition: GeoPoint(0.0, 0.0),
          ),
          const PositionBlocLocated(
            isRealTime: true,
            currentPosition: GeoPoint(1.0, 1.0),
          ),
        ]),
      );

      bloc.unTrack();

      await expectLater(
        bloc.stream,
        emitsInOrder([
          const PositionBlocIdle(
            lastPosition: GeoPoint(1.0, 1.0),
            hasPermission: true,
            isServiceEnabled: true,
          ),
        ]),
      );

      // ======== Test restart user tracking ========

      bloc.track();

      await expectLater(
        bloc.stream,
        emitsInOrder([
          const PositionBlocLocating(
            isRealTime: true,
            lastPosition: GeoPoint(1.0, 1.0),
          ),
          const PositionBlocLocated(
            isRealTime: true,
            currentPosition: GeoPoint(0.0, 0.0),
          ),
          const PositionBlocLocated(
            isRealTime: true,
            currentPosition: GeoPoint(1.0, 1.0),
          ),
        ]),
      );

      bloc.unTrack();

      await expectLater(
        bloc.stream,
        emitsInOrder([
          const PositionBlocIdle(
            lastPosition: GeoPoint(1.0, 1.0),
            hasPermission: true,
            isServiceEnabled: true,
          ),
        ]),
      );

      // ======== Close bloc ========

      expect(
        bloc.stream,
        emitsInOrder([
          emitsDone,
        ]),
      );

      await bloc.close();
    });

    test('More listeners are registered, manage as if it were one', () async {
      init(permission: EmissionType.alreadyHas, service: EmissionType.alreadyHas);
      bloc.emit(const PositionBlocIdle(
        lastPosition: null,
        hasPermission: true,
        isServiceEnabled: true,
      ));

      when(() => mockGetCurrent.call(NoParams())).thenAnswer((_) async {
        return const GeoPoint(0.0, 0.0);
      });
      when(() => mockOnPositionChanges.call(NoParams())).thenAnswer((_) async* {
        yield const GeoPoint(0.0, 0.0);
      });

      bloc.track();
      bloc.locate();
      bloc.track();

      await expectLater(
        bloc.stream,
        emitsInOrder([
          const PositionBlocLocating(
            isRealTime: true,
            lastPosition: null,
          ),
          const PositionBlocLocated(
            isRealTime: true,
            currentPosition: GeoPoint(0.0, 0.0),
          ),
        ]),
      );

      verify(() => mockOnPositionChanges.call(NoParams())).called(1);

      bloc.unTrack();
      await Future.delayed(const Duration(milliseconds: 10));
      bloc.unTrack();

      await expectLater(
        bloc.stream,
        emitsInOrder([
          const PositionBlocIdle(
            lastPosition: GeoPoint(0.0, 0.0),
            hasPermission: true,
            isServiceEnabled: true,
          ),
        ]),
      );

      expect(
        bloc.stream,
        emitsInOrder([
          emitsDone,
        ]),
      );

      await bloc.close();
    });

    test('Emit real time position after bloc is initialized but track request before it', () async {
      when(() => mockGetCurrent.call(NoParams())).thenAnswer((_) async {
        return const GeoPoint(0.0, 0.0);
      });
      when(() => mockOnPositionChanges.call(NoParams())).thenAnswer((_) async* {});

      init(permission: EmissionType.acquire, service: EmissionType.acquire);

      bloc.track();

      await expectLater(
        bloc.stream,
        emitsInOrder([
          const PositionBlocIdle(
            lastPosition: null,
            hasPermission: true,
            isServiceEnabled: false,
          ),
          const PositionBlocIdle(
            lastPosition: null,
            hasPermission: true,
            isServiceEnabled: true,
          ),
          const PositionBlocLocating(
            isRealTime: true,
            lastPosition: null,
          ),
          const PositionBlocLocated(
            isRealTime: true,
            currentPosition: GeoPoint(0.0, 0.0),
          ),
        ]),
      );

      // ======== Close bloc ========

      expect(
        bloc.stream,
        emitsInOrder([
          emitsDone,
        ]),
      );

      await bloc.close();
    });
  });
}
