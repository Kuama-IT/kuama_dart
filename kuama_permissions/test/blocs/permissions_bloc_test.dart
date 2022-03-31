import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:kuama_permissions/src/blocs/permissions_bloc.b.dart';
import 'package:kuama_permissions/src/services/permissions_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:permission_handler/permission_handler.dart';

import '../t_utils.dart';

class _MockPermissionsService extends Mock implements PermissionsService {}

void main() {
  late _MockPermissionsService _mockPermissionsService;

  late PermissionsBloc bloc;

  setUp(() {
    GetIt.I
        .registerSingleton<PermissionsService>(_mockPermissionsService = _MockPermissionsService());

    bloc = PermissionsBloc();
  });

  tearDown(() => GetIt.I.reset());

  group("PermissionsBloc", () {
    const tPermission1 = Permission.storage;
    const tPermission2 = Permission.camera;
    const tPermission3 = Permission.location;

    group('PermissionsBloc.check', () {
      test('cant check nothing because already checking, resolving, requesting, completed', () {
        bloc.emit(bloc.state.copyWith(
          places: {
            Permission.storage: PermissionPlace.checking,
            Permission.bluetooth: PermissionPlace.asking,
            Permission.camera: PermissionPlace.requesting,
          },
          status: {Permission.calendar: PermissionStatus.denied},
        ));
        var state = bloc.state;

        bloc.check({
          Permission.storage,
          Permission.bluetooth,
          Permission.camera,
          Permission.calendar,
        });

        expect(bloc.state, state);
      });

      test('success check with granted permission', () {
        var state = bloc.state;

        when(() => _mockPermissionsService.checkPermissions(any())).thenAnswer((_) async {
          return {tPermission1: PermissionStatus.granted};
        });

        after(() => bloc.check({tPermission1}));

        expect(
          bloc.stream,
          emitsInOrder([
            state = state.copyWith(
              places: {tPermission1: PermissionPlace.checking},
            ),
            state = state.copyWith(
              places: {},
              status: {tPermission1: PermissionStatus.granted},
            ),
          ]),
        );
      });

      test('success check with permission negated', () {
        var state = bloc.state;
        const tPermission = Permission.storage;

        when(() => _mockPermissionsService.checkPermissions(any())).thenAnswer((_) async {
          return {tPermission: PermissionStatus.permanentlyDenied};
        });

        after(() => bloc.check({tPermission}));

        expect(
          bloc.stream,
          emitsInOrder([
            state = state.copyWith(
              places: {tPermission: PermissionPlace.checking},
            ),
            state = state.copyWith(
              places: {},
              status: {tPermission: PermissionStatus.permanentlyDenied},
            ),
          ]),
        );
      });

      test('cancel check', () {
        var state = bloc.state;

        when(() => _mockPermissionsService.checkPermissions(any())).thenAnswer((_) async {
          bloc.emit(bloc.state.copyWith(
            places: {tPermission1: PermissionPlace.requesting},
          ));
          return {tPermission1: PermissionStatus.permanentlyDenied};
        });

        after(() => bloc.check({tPermission1}));

        expect(
          bloc.stream,
          emitsInOrder([
            state = state.copyWith(
              places: {tPermission1: PermissionPlace.checking},
            ),
            state = state.copyWith(
              places: {tPermission1: PermissionPlace.requesting},
              status: {},
            ),
          ]),
        );
      });
    });

    group('PermissionsBloc.resolveAsk', () {
      test('cant resolve nothing because unresolvable list is empty', () {
        var state = bloc.state;

        bloc.resolveAsk(false);

        expect(bloc.state, state);
      });

      test('resolve and request permission', () async {
        bloc.emit(bloc.state.copyWith(
          places: {tPermission1: PermissionPlace.asking},
        ));
        var state = bloc.state;

        when(() => _mockPermissionsService.requestPermissions(any())).thenAnswer((_) async {
          return {tPermission1: PermissionStatus.granted};
        });

        after(() => bloc.resolveAsk(true));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            state = state.copyWith(
              places: {tPermission1: PermissionPlace.requesting},
            ),
            state = state.copyWith(
              places: {},
              status: {tPermission1: PermissionStatus.granted},
            ),
          ]),
        );
        verifyNever(() => _mockPermissionsService.addUnRequestPermissions(any()));
      });

      test('negate resolution', () async {
        bloc.emit(bloc.state.copyWith(
          places: {tPermission1: PermissionPlace.asking},
        ));
        var state = bloc.state;

        when(() => _mockPermissionsService.addUnRequestPermissions(any())).thenAnswer((_) async {});

        after(() => bloc.resolveAsk(false));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            state = state.copyWith(
              places: {tPermission1: PermissionPlace.requesting},
              status: {},
            ),
            state = state.copyWith(
              places: {},
              status: {tPermission1: PermissionStatus.denied},
            ),
          ]),
        );
        verify(() => _mockPermissionsService.addUnRequestPermissions(any()));
      });
    });

    group('PermissionsBloc.request', () {
      test('cant request nothing because already request is performing', () {
        bloc.emit(bloc.state.copyWith(
          places: {tPermission1: PermissionPlace.requesting},
        ));
        var state = bloc.state;

        bloc.request({tPermission1});

        expect(bloc.state, state);
      });

      test('cant request nothing because already ask is performing', () {
        bloc.emit(bloc.state.copyWith(
          places: {tPermission1: PermissionPlace.asking},
        ));
        var state = bloc.state;

        bloc.request({tPermission1});

        expect(bloc.state, state);
      });

      test('check but not request because permission is already requested', () {
        var state = bloc.state;

        when(() => _mockPermissionsService.checkPermissions(any())).thenAnswer((_) async {
          return {
            tPermission1: PermissionStatus.granted,
            tPermission2: PermissionStatus.denied,
            tPermission3: PermissionStatus.permanentlyDenied,
          };
        });

        after(() => bloc.request({tPermission1, tPermission2, tPermission3}));

        expect(
          bloc.stream,
          emitsInOrder([
            state = state.copyWith(
              places: {
                tPermission1: PermissionPlace.requesting,
                tPermission2: PermissionPlace.requesting,
                tPermission3: PermissionPlace.requesting
              },
            ),
            state = state.copyWith(
              places: {},
              status: {
                tPermission1: PermissionStatus.granted,
                tPermission2: PermissionStatus.denied,
                tPermission3: PermissionStatus.permanentlyDenied
              },
            ),
          ]),
        );
      });

      test('check (in checking) but not request because permission is already resolved', () {
        bloc.emit(bloc.state.copyWith(
          places: {tPermission1: PermissionPlace.checking},
        ));
        var state = bloc.state;

        when(() => _mockPermissionsService.checkPermissions(any())).thenAnswer((_) async {
          return {tPermission1: PermissionStatus.granted};
        });

        after(() => bloc.request({tPermission1}));

        expect(
          bloc.stream,
          emitsInOrder([
            state = state.copyWith(
              places: {tPermission1: PermissionPlace.requesting},
            ),
            state = state.copyWith(
              places: {},
              status: {tPermission1: PermissionStatus.granted},
            ),
          ]),
        );
      });

      test('check and request resolution for permission not already requested', () {
        var state = bloc.state;

        when(() => _mockPermissionsService.checkPermissions(any())).thenAnswer((_) async {
          return {};
        });

        after(() => bloc.request({tPermission1}));

        expect(
          bloc.stream,
          emitsInOrder([
            state = state.copyWith(
              places: {tPermission1: PermissionPlace.requesting},
            ),
            state = state.copyWith(
              places: {tPermission1: PermissionPlace.asking},
            ),
          ]),
        );
      });

      test('Try to request the denied permissions again', () {
        bloc.emit(bloc.state.copyWith(
          status: {
            tPermission1: PermissionStatus.denied,
            tPermission2: PermissionStatus.permanentlyDenied
          },
        ));
        var state = bloc.state;

        when(() => _mockPermissionsService.checkPermissions(any())).thenAnswer((_) async {
          return {
            tPermission1: PermissionStatus.denied,
            tPermission2: PermissionStatus.permanentlyDenied
          };
        });
        when(() => _mockPermissionsService.requestPermissions(any())).thenAnswer((_) async {
          return {tPermission1: PermissionStatus.granted, tPermission2: PermissionStatus.granted};
        });

        after(() => bloc.request({tPermission1, tPermission2}, tryAgain: true));

        expect(
          bloc.stream,
          emitsInOrder([
            state = state.copyWith(
              places: {tPermission1: PermissionPlace.asking, tPermission2: PermissionPlace.asking},
            ),
          ]),
        );
      });
    });

    group('PermissionsBloc.refresh', () {
      test('Remove pending permission if permission is granted', () {
        bloc.emit(bloc.state.copyWith(
          places: {
            tPermission1: PermissionPlace.checking,
            tPermission2: PermissionPlace.asking,
            tPermission3: PermissionPlace.requesting
          },
        ));
        var state = bloc.state;

        when(() => _mockPermissionsService.checkPermissions(any())).thenAnswer((_) async {
          return {
            tPermission1: PermissionStatus.granted,
            tPermission2: PermissionStatus.granted,
            tPermission3: PermissionStatus.granted
          };
        });

        after(() => bloc.refresh());

        expect(
          bloc.stream,
          emitsInOrder([
            state = state.copyWith(
              places: {},
              status: {
                tPermission1: PermissionStatus.granted,
                tPermission2: PermissionStatus.granted,
                tPermission3: PermissionStatus.granted
              },
            ),
          ]),
        );
      });
    });
  });
}
