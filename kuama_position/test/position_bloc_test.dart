import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:kuama_permissions/kuama_permissions.dart';
import 'package:kuama_position/src/blocs/position_bloc.dart';
import 'package:kuama_position/src/service/position_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pure_extensions/pure_extensions.dart';

class _MockPositionService extends Mock implements PositionService {}

class _MockPermissionsBloc extends Mock implements PermissionsBloc {}

enum EmissionType { none, acquire, alreadyHas }

void main() {
  late _MockPositionService mockPositionService;

  late _MockPermissionsBloc mockPermissionBloc;

  late PositionBloc bloc;

  const tPermission = Permission.locationWhenInUse;
  const tService = Service.location;

  setUp(() {
    GetIt.instance.registerSingleton<PositionService>(mockPositionService = _MockPositionService());
  });

  tearDown(() => GetIt.instance.reset());

  void init({
    EmissionType permission = EmissionType.none,
    EmissionType service = EmissionType.none,
  }) {
    mockPermissionBloc = _MockPermissionsBloc();

    when(() => mockPermissionBloc.state).thenReturn(CheckedPermissionState(
      isRefreshing: false,
      permissionsStatus: {
        if (permission == EmissionType.alreadyHas) tPermission: PermissionStatus.granted,
      },
      servicesStatus: {
        if (service == EmissionType.alreadyHas) tService: true,
      },
      payload: const {},
    ));
    when(() => mockPermissionBloc.stream).thenAnswer((_) async* {
      if (permission != EmissionType.acquire && service != EmissionType.acquire) return;
      yield CheckedPermissionState(
        isRefreshing: false,
        permissionsStatus: {
          if (permission == EmissionType.acquire) tPermission: PermissionStatus.granted,
        },
        servicesStatus: {
          if (service == EmissionType.acquire) tService: true,
        },
        payload: const {},
      );
    });

    bloc = PositionBloc(
      permissionsBloc: mockPermissionBloc,
    );

    expect(
      bloc.state,
      PositionBlocIdle(
        lastPosition: null,
        hasPermission: permission == EmissionType.alreadyHas,
        isServiceEnabled: service == EmissionType.alreadyHas,
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
            isServiceEnabled: true,
          ),
        ]),
      );
    });

    test('A listener requests the current position', () async {
      init(permission: EmissionType.alreadyHas, service: EmissionType.alreadyHas);

      when(() => mockPositionService.getCurrentPosition()).thenAnswer((_) async {
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

      when(() => mockPositionService.getCurrentPosition()).thenAnswer((_) async {
        return const GeoPoint(0.0, 0.0);
      });
      when(() => mockPositionService.onPositionChanges).thenAnswer((_) async* {
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

      when(() => mockPositionService.getCurrentPosition()).thenAnswer((_) async {
        return const GeoPoint(0.0, 0.0);
      });
      when(() => mockPositionService.onPositionChanges).thenAnswer((_) async* {
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

      verify(() => mockPositionService.onPositionChanges).called(1);

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
      when(() => mockPositionService.getCurrentPosition()).thenAnswer((_) async {
        return const GeoPoint(0.0, 0.0);
      });
      when(() => mockPositionService.onPositionChanges).thenAnswer((_) async* {});

      init(permission: EmissionType.acquire, service: EmissionType.acquire);

      bloc.track();

      await expectLater(
        bloc.stream,
        emitsInOrder([
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
