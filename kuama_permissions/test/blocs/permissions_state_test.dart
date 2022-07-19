import 'package:flutter_test/flutter_test.dart';
import 'package:kuama_permissions/src/blocs/permissions_bloc.b.dart';
import 'package:kuama_permissions/src/entities/service.dart';
import 'package:permission_handler/permission_handler.dart';

import '../t_utils.dart';

void main() {
  group('PermissionsBlocState', () {
    const tPermission1 = Permission.location;
    const tPermission2 = Permission.camera;
    final permissions = {tPermission1, tPermission2};
    const tCheckingState = CheckingPermissionState(
      isRefreshing: false,
      permissionsStatus: {},
      servicesStatus: {},
      payload: {},
    );
    const tCheckedState = CheckedPermissionState(
      isRefreshing: false,
      permissionsStatus: {},
      servicesStatus: {},
      payload: {},
    );
    const tAskingState = AskingPermissionsState(
      isRefreshing: false,
      permissionsStatus: {},
      servicesStatus: {},
      payload: {},
    );
    const tRequestingState = RequestingPermissionsState(
      isRefreshing: false,
      permissionsStatus: {},
      servicesStatus: {},
      payload: {},
    );
    const tRequestedState = RequestedPermissionsState(
      isRefreshing: false,
      permissionsStatus: {},
      servicesStatus: {},
      payload: {},
      isRequested: false,
    );
    final tConfirmableAskState = ConfirmableAskPermissionsState(
      isRefreshing: false,
      permissionsStatus: {},
      servicesStatus: {},
      payload: {tPermission1},
      isRestored: false,
    );
    const tAskedState = AskedPermissionsState(
      isRefreshing: false,
      permissionsStatus: {},
      servicesStatus: {},
      payload: {},
      isCancelled: false,
      isRequested: false,
    );

    testTheory<PermissionsBlocState, bool>('isWaiting', [
      TheoryData(tCheckingState, false),
      TheoryData(tCheckedState, false),
      TheoryData(tRequestingState, false),
      TheoryData(tRequestedState, false),
      TheoryData(tAskingState, false),
      TheoryData(tConfirmableAskState, true),
      TheoryData(tAskedState, false),
    ], (state) {
      return state.isWaiting;
    });

    testTheory<PermissionsBlocState, bool>('isLoading', [
      TheoryData(tCheckingState, true),
      TheoryData(tCheckedState, false),
      TheoryData(tRequestingState, true),
      TheoryData(tRequestedState, false),
      TheoryData(tAskingState, true),
      TheoryData(tConfirmableAskState, false),
      TheoryData(tAskedState, false),
    ], (state) {
      return state.isLoading;
    });

    testTheory<PermissionsBlocState, bool>('checkCanCheck', [
      TheoryData(tCheckingState, false),
      TheoryData(tCheckedState, true),
      TheoryData(tRequestingState, false),
      TheoryData(tRequestedState, true),
      TheoryData(tAskingState, false),
      TheoryData(tConfirmableAskState, false),
      TheoryData(tAskedState, true),
    ], (state) {
      return state.checkCanCheck({tPermission1});
    });

    testTheory<PermissionsBlocState, bool>('checkCanAsk', [
      TheoryData(tCheckingState, false),
      TheoryData(tCheckedState, true),
      TheoryData(tRequestingState, false),
      TheoryData(tRequestedState, true),
      TheoryData(tAskingState, false),
      TheoryData(tConfirmableAskState, false),
      TheoryData(tAskedState, true),
    ], (state) {
      return state.checkCanAsk({tPermission1});
    });

    testTheory<PermissionsBlocState, bool>('checkCanConfirmAsk', [
      TheoryData(tCheckingState, false),
      TheoryData(tCheckedState, false),
      TheoryData(tRequestingState, false),
      TheoryData(tRequestedState, false),
      TheoryData(tAskingState, false),
      TheoryData(tConfirmableAskState, true),
      TheoryData(tAskedState, false),
    ], (state) {
      return state.checkCanConfirmAsk({tPermission1});
    });

    group('resolveStatus', () {
      test('Failed: permission is not resolved', () {
        final state = _createState();

        expect(state.resolveStatus({tPermission1}), PermissionStatus.denied);
      });

      test('Failed: permission is denied', () {
        final state = _createState(
          status: {tPermission1: PermissionStatus.denied},
        );

        expect(state.resolveStatus({tPermission1}), PermissionStatus.denied);
      });

      test('Success: because permission is granted', () {
        final state = _createState(
          status: {tPermission1: PermissionStatus.permanentlyDenied},
        );

        expect(state.resolveStatus({tPermission1}), PermissionStatus.permanentlyDenied);
      });

      test('Success: because permission is granted', () {
        final state = _createState(
          status: {tPermission1: PermissionStatus.granted},
        );

        expect(state.resolveStatus({tPermission1}), PermissionStatus.granted);
      });
    });

    group('checkEvery', () {
      test('if any permission is not present it returns false', () {
        final state = _createState(
          status: {
            tPermission2: PermissionStatus.granted,
          },
        );

        expect(state.checkEvery(permissions, PermissionStatus.denied), false);
      });

      test('if any permission is denied  it returns true', () {
        final state = _createState(
          status: {
            tPermission1: PermissionStatus.denied,
            tPermission2: PermissionStatus.granted,
          },
        );

        expect(state.checkAny(permissions, PermissionStatus.denied), true);
      });

      test('if all permissions are granted it returns false', () {
        final state = _createState(
          status: {
            tPermission1: PermissionStatus.granted,
            tPermission2: PermissionStatus.granted,
          },
        );

        expect(state.checkAny(permissions, PermissionStatus.denied), false);
      });
    });

    group('checkAny', () {
      test('if any permission is not present it returns true', () {
        final state = _createState(
          status: {
            tPermission2: PermissionStatus.granted,
          },
        );

        expect(state.checkAny(permissions, PermissionStatus.denied), true);
      });

      test('if any permission is denied it returns true', () {
        final state = _createState(
          status: {
            tPermission1: PermissionStatus.denied,
            tPermission2: PermissionStatus.granted,
          },
        );

        expect(state.checkAny(permissions, PermissionStatus.denied), true);
      });

      test('if all permissions are granted it returns false', () {
        final state = _createState(
          status: {
            tPermission1: PermissionStatus.granted,
            tPermission2: PermissionStatus.granted,
          },
        );

        expect(state.checkAny(permissions, PermissionStatus.denied), false);
      });
    });
  });
}

PermissionsBlocState _createState({
  Map<Permission, PermissionStatus> status = const {},
  Map<Service, bool> services = const {},
}) {
  return CheckedPermissionState(
    isRefreshing: false,
    permissionsStatus: status,
    servicesStatus: services,
    payload: {},
  );
}
