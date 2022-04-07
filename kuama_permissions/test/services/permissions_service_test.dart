import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:kuama_permissions/src/entities/permissions_status_entity.b.dart';
import 'package:kuama_permissions/src/entities/service.dart';
import 'package:kuama_permissions/src/repositories/permissions_manger_repository.dart';
import 'package:kuama_permissions/src/repositories/permissions_preferences_repository.dart';
import 'package:kuama_permissions/src/services/permissions_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';

class _MockStoragePermissionsRepository extends Mock implements PermissionsPreferencesRepository {}

class _MockHandlerPermissionsRepository extends Mock implements PermissionsManagerRepository {}

class _FakePermission extends Fake implements Permission {}

void main() {
  late _MockHandlerPermissionsRepository _mockHandler;
  late _MockStoragePermissionsRepository _mockStorage;

  late PermissionsService service;

  setUp(() {
    GetIt.I
      ..registerSingleton<PermissionsManagerRepository>(
          _mockHandler = _MockHandlerPermissionsRepository())
      ..registerSingleton<PermissionsPreferencesRepository>(
          _mockStorage = _MockStoragePermissionsRepository());

    service = PermissionsService();

    registerFallbackValue(_FakePermission());
  });

  tearDown(() => GetIt.I.reset());

  group("PermissionsService", () {
    const tPermission1 = Permission.storage;
    const tPermission2 = Permission.camera;
    const tService = Permission.locationWhenInUse;

    group('PermissionsService.checkPermissions', () {
      test('Returns permission status', () async {
        when(() => _mockStorage.checkAsked(any())).thenReturn({
          tPermission1: true,
        });
        when(() => _mockHandler.checkPermissions(any())).thenAnswer((_) async {
          return {tPermission1: PermissionStatus.permanentlyDenied};
        });

        final result = await service.checkStatus([tPermission1]);

        expect(
          result,
          PermissionsStatusEntity(
            canAsk: false,
            areAllGrantedAndEnabled: false,
            permissions: {tPermission1: PermissionStatus.permanentlyDenied},
            services: {},
          ),
        );
      });

      test('Returns permission and services status', () async {
        when(() => _mockStorage.checkAsked(any())).thenReturn({
          tPermission1: true,
        });
        when(() => _mockHandler.checkPermissions(any())).thenAnswer((_) async {
          return {tService: PermissionStatus.permanentlyDenied};
        });
        when(() => _mockHandler.checkService(any())).thenAnswer((_) async {
          return ServiceStatus.enabled;
        });

        final result = await service.checkStatus([tService]);

        expect(
          result,
          PermissionsStatusEntity(
            canAsk: false,
            areAllGrantedAndEnabled: false,
            permissions: {tService: PermissionStatus.permanentlyDenied},
            services: {Service.location: true},
          ),
        );
      });
    });
  });
}
