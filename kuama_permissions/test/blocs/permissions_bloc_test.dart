import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:kuama_permissions/src/blocs/permissions_bloc.b.dart';
import 'package:kuama_permissions/src/entities/permissions_status_entity.b.dart';
import 'package:kuama_permissions/src/entities/service.dart';
import 'package:kuama_permissions/src/services/permissions_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:permission_handler/permission_handler.dart';

import '../t_utils.dart';

class _MockPermissionsService extends Mock implements PermissionsService {}

class _MockPermissionsState extends Mock implements PermissionsBlocState {}

void main() {
  late StreamController<void> onRequiredPermissionsRefresh;
  late _MockPermissionsService mockPermissionsService;
  late _MockPermissionsState mockState;

  late PermissionsBloc bloc;

  setUp(() {
    GetIt.instance
        .registerSingleton<PermissionsService>(mockPermissionsService = _MockPermissionsService());
    mockState = _MockPermissionsState();

    onRequiredPermissionsRefresh = StreamController.broadcast(sync: true);

    when(() => mockPermissionsService.onRequiredPermissionsRefresh).thenAnswer((_) {
      return onRequiredPermissionsRefresh.stream;
    });

    Service.values.forEach(registerFallbackValue);

    bloc = PermissionsBloc();
  });

  tearDown(() async => Future.wait([GetIt.instance.reset(), onRequiredPermissionsRefresh.close()]));

  group('PermissionsBloc', () {
    const tPermission1 = Permission.storage;
    const tPermission2 = Permission.camera;
    const tPermissionService = Permission.location;
    const tService = Service.location;

    group('PermissionsBloc.check', () {
      test('cant check because cant operate', () {
        bloc.emit(mockState);
        final state = bloc.state;

        when(() => mockState.checkCanCheck(any())).thenReturn(false);

        bloc.check({Permission.calendarFullAccess});

        expect(bloc.state, state);
      });

      test('Check permissions', () async {
        var state = bloc.state;

        when(() => mockPermissionsService.checkStatus(any())).thenAnswer((_) async {
          return PermissionsStatusEntity(
            canResolve: true,
            areAllGrantedAndEnabled: true,
            permissions: {tPermission1: PermissionStatus.granted},
            services: {},
          );
        });

        after(() => bloc.check({tPermission1}));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            state = state.toChecking(
              payload: {tPermission1},
            ),
            state = state.toChecked(
              payload: {tPermission1},
              permissionsStatus: {tPermission1: PermissionStatus.granted},
            ),
          ]),
        );
      });

      test('success check permissions and start listen service changes', () async {
        var state = bloc.state;
        const tPermission = Permission.location;
        const tService = Service.location;

        when(() => mockPermissionsService.checkStatus(any())).thenAnswer((_) async {
          return PermissionsStatusEntity(
            canResolve: false,
            areAllGrantedAndEnabled: false,
            permissions: {tPermission: PermissionStatus.permanentlyDenied},
            services: {tService: true},
          );
        });
        when(() => mockPermissionsService.onServiceChanges(any())).thenAnswer((_) async* {});

        after(() => bloc.check({tPermission}));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            state = state.toChecking(
              payload: {tPermission},
            ),
            state = state.toChecked(
              permissionsStatus: {tPermission: PermissionStatus.permanentlyDenied},
              servicesStatus: {tService: true},
              payload: {tPermission},
            ),
          ]),
        );
        verify(() => mockPermissionsService.onServiceChanges(Service.location));
      });
    });

    group('PermissionsBloc.request', () {
      test('cant request because cant operate', () {
        bloc.emit(mockState);
        final state = bloc.state;

        when(() => mockState.checkCanRequest(any())).thenReturn(false);

        bloc.request({Permission.calendarFullAccess});

        expect(bloc.state, state);
      });

      test('skip request because permissions is already resolved', () async {
        var state = bloc.state;

        when(() => mockPermissionsService.checkStatus(any(), tryAgain: any(named: 'tryAgain')))
            .thenAnswer((_) async {
          return PermissionsStatusEntity(
            canResolve: false,
            areAllGrantedAndEnabled: false,
            permissions: {tPermissionService: PermissionStatus.denied},
            services: {tService: true},
          );
        });
        when(() => mockPermissionsService.onServiceChanges(any())).thenAnswer((_) async* {});

        after(() => bloc.request({tPermissionService}, tryAgain: false));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            state = state.toRequesting(
              payload: {tPermissionService},
            ),
            state = state.toRequested(
              isRequested: false,
              payload: {tPermissionService},
              permissionsStatus: {tPermissionService: PermissionStatus.denied},
              servicesStatus: {tService: true},
            ),
          ]),
        );
        verify(() => mockPermissionsService.onServiceChanges(tService));
      });

      test('Request permissions', () async {
        var state = bloc.state;

        when(() => mockPermissionsService.checkStatus(any(), tryAgain: any(named: 'tryAgain')))
            .thenAnswer((_) async {
          return PermissionsStatusEntity(
            canResolve: true,
            areAllGrantedAndEnabled: false,
            permissions: {tPermission1: PermissionStatus.granted},
            services: {},
          );
        });
        when(() => mockPermissionsService.requestPermissions(any())).thenAnswer((_) async {
          return PermissionsStatusEntity(
            canResolve: true,
            areAllGrantedAndEnabled: true,
            permissions: {tPermission1: PermissionStatus.granted},
            services: {},
          );
        });

        after(() => bloc.request({tPermission1}, tryAgain: false));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            state = state.toRequesting(
              payload: {tPermission1},
            ),
            state = state.toRequested(
              isRequested: true,
              payload: {tPermission1},
              permissionsStatus: {tPermission1: PermissionStatus.granted},
            ),
          ]),
        );
      });
    });

    group('PermissionsBloc.confirmAsk', () {
      test('cant confirm ask because cant operate', () {
        bloc.emit(mockState);
        final state = bloc.state;

        when(() => mockState.checkCanConfirmAsk(any())).thenReturn(false);

        bloc.confirmAsk(true);

        expect(bloc.state, state);
      });

      test('permissions is asked', () async {
        bloc.emit(bloc.state.toConfirmableAsk(
          payload: {tPermission1},
          isRestored: false,
        ));
        var state = bloc.state;

        when(() => mockPermissionsService.requestPermissions(any())).thenAnswer((_) async {
          return PermissionsStatusEntity(
            canResolve: false,
            areAllGrantedAndEnabled: true,
            permissions: {tPermission1: PermissionStatus.granted},
            services: {},
          );
        });

        after(() => bloc.confirmAsk(true));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            state = state.toAsking(
              payload: {tPermission1},
            ),
            state = state.toAsked(
              permissionsStatus: {tPermission1: PermissionStatus.granted},
              payload: {tPermission1},
              isCancelled: false,
              isRequested: true,
            ),
          ]),
        );
        verifyNever(() => mockPermissionsService.markAskedPermissions(any()));
      });

      test('permissions is not asked', () async {
        bloc.emit(bloc.state.toConfirmableAsk(
          permissionsStatus: {tPermission1: PermissionStatus.denied},
          payload: {tPermission1},
          isRestored: false,
        ));
        var state = bloc.state;

        when(() => mockPermissionsService.markAskedPermissions(any())).thenAnswer((_) async {});

        after(() => bloc.confirmAsk(false));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            state = state.toAsking(
              payload: {tPermission1},
            ),
            state = state.toAsked(
              payload: {tPermission1},
              isCancelled: false,
              isRequested: false,
            ),
          ]),
        );
        verify(() => mockPermissionsService.markAskedPermissions(any()));
      });

      test('confirm ask is cancelled', () async {
        bloc.emit(bloc.state.toConfirmableAsk(
          payload: {tPermission1},
          isRestored: false,
        ));
        var state = bloc.state;

        after(() => bloc.confirmAsk(null));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            state = state.toAsked(
              payload: {tPermission1},
              isCancelled: true,
              isRequested: false,
            ),
          ]),
        );
        verifyNever(() => mockPermissionsService.markAskedPermissions(any()));
      });
    });

    group('PermissionsBloc.ask', () {
      test('cant ask because cant operate', () {
        bloc.emit(mockState);
        final state = bloc.state;

        when(() => mockState.checkCanAsk(any())).thenReturn(false);

        bloc.ask({Permission.calendarFullAccess});

        expect(bloc.state, state);
      });

      test('skip check because permissions is already asked', () async {
        var state = bloc.state;

        when(() => mockPermissionsService.checkStatus(any())).thenAnswer((_) async {
          return PermissionsStatusEntity(
            canResolve: false,
            areAllGrantedAndEnabled: false,
            permissions: {tPermissionService: PermissionStatus.denied},
            services: {tService: true},
          );
        });
        when(() => mockPermissionsService.onServiceChanges(any())).thenAnswer((_) async* {});

        after(() => bloc.ask({tPermissionService}));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            state = state.toAsking(
              payload: {tPermissionService},
            ),
            state = state.toAsked(
              permissionsStatus: {tPermissionService: PermissionStatus.denied},
              servicesStatus: {tService: true},
              payload: {tPermissionService},
              isCancelled: false,
              isRequested: false,
            ),
          ]),
        );
        verify(() => mockPermissionsService.onServiceChanges(tService));
      });

      test('cant ask confirm because all permissions are granted', () async {
        var state = bloc.state;

        when(() => mockPermissionsService.checkStatus(any())).thenAnswer((_) async {
          return PermissionsStatusEntity(
            canResolve: false,
            areAllGrantedAndEnabled: true,
            permissions: {
              tPermission1: PermissionStatus.granted,
              tPermissionService: PermissionStatus.granted,
            },
            services: {tService: true},
          );
        });
        when(() => mockPermissionsService.onServiceChanges(any())).thenAnswer((_) async* {});

        after(() => bloc.ask({tPermission1}));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            state = state.toAsking(
              payload: {tPermission1},
            ),
            state = state.toAsked(
              permissionsStatus: {
                tPermission1: PermissionStatus.granted,
                tPermissionService: PermissionStatus.granted,
              },
              servicesStatus: {tService: true},
              payload: {tPermission1},
              isCancelled: false,
              isRequested: false,
            ),
          ]),
        );
        verify(() => mockPermissionsService.onServiceChanges(tService));
      });

      test('ask confirm because can ask permissions', () async {
        var state = bloc.state;

        when(() => mockPermissionsService.checkStatus(any())).thenAnswer((_) async {
          return PermissionsStatusEntity(
            canResolve: true,
            areAllGrantedAndEnabled: false,
            permissions: {
              tPermission1: PermissionStatus.granted,
              tPermission2: PermissionStatus.denied,
              tPermissionService: PermissionStatus.permanentlyDenied,
            },
            services: {tService: true},
          );
        });
        when(() => mockPermissionsService.onServiceChanges(any())).thenAnswer((_) async* {});

        after(() => bloc.ask({tPermission1, tPermission2, tPermissionService}));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            state = state.toAsking(
              payload: {tPermission1, tPermission2, tPermissionService},
            ),
            state = state.toConfirmableAsk(
              permissionsStatus: {
                tPermission1: PermissionStatus.granted,
                tPermission2: PermissionStatus.denied,
                tPermissionService: PermissionStatus.permanentlyDenied
              },
              servicesStatus: {tService: true},
              payload: {tPermission1, tPermission2, tPermissionService},
              isRestored: false,
            ),
          ]),
        );
        verify(() => mockPermissionsService.onServiceChanges(tService));
      });
    });

    group('PermissionsBloc.refresh', () {
      test('Update state with new permissions status', () async {
        bloc.emit(bloc.state.copyWith(
          permissionsStatus: {
            tPermission1: PermissionStatus.denied,
          },
        ));
        var state = bloc.state;

        when(() => mockPermissionsService.checkStatus(any())).thenAnswer((_) async {
          return PermissionsStatusEntity(
            canResolve: false,
            areAllGrantedAndEnabled: false,
            permissions: {
              tPermission1: PermissionStatus.granted,
            },
            services: {},
          );
        });

        after(() => onRequiredPermissionsRefresh.add(null));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            state = state.copyWith(isRefreshing: true),
            state = state.copyWith(
              isRefreshing: false,
              permissionsStatus: {
                tPermission1: PermissionStatus.granted,
              },
            ),
          ]),
        );
      });

      test('Resolved asking state when refresh is called', () async {
        bloc.emit(bloc.state.toConfirmableAsk(
          permissionsStatus: {
            tPermission1: PermissionStatus.denied,
          },
          payload: {tPermission1},
          isRestored: false,
        ));
        var state = bloc.state;

        when(() => mockPermissionsService.checkStatus(any())).thenAnswer((_) async {
          return PermissionsStatusEntity(
            canResolve: false,
            areAllGrantedAndEnabled: false,
            permissions: {
              tPermission1: PermissionStatus.granted,
            },
            services: {},
          );
        });

        after(() => onRequiredPermissionsRefresh.add(null));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            state = state.copyWith(isRefreshing: true),
            state = state.toAsked(
              permissionsStatus: {
                tPermission1: PermissionStatus.granted,
              },
              payload: {tPermission1},
              isCancelled: false,
              isRequested: false,
            ),
          ]),
        );
      });
    });
  });
}
