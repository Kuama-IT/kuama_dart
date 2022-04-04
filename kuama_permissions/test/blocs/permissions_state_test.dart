import 'package:flutter_test/flutter_test.dart';
import 'package:kuama_permissions/src/blocs/permissions_bloc.b.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  group('PermissionsBlocState', () {
    const tPermission = Permission.location;

    group('canRequest', () {
      test('Success: permission not already requested', () {
        final state = _createState();

        expect(state.canRequest({tPermission}), true);
      });

      test('Failed: permission in requesting', () {
        final state = _createState(
          places: {tPermission: PermissionPlace.requesting},
        );

        expect(state.canRequest({tPermission}), false);
      });

      test('Success: Permission already requested', () {
        final state = _createState(
          status: {tPermission: PermissionStatus.granted},
        );

        expect(state.canRequest({tPermission}), true);
      });
    });

    group('checkEveryGranted', () {
      test('Failed: permission is not resolved', () {
        final state = _createState();

        expect(state.checkEveryGranted({tPermission}), false);
      });

      test('Failed: permission is denied', () {
        final state = _createState(
          status: {tPermission: PermissionStatus.denied},
        );

        expect(state.checkEveryGranted({tPermission}), false);
      });

      test('Success: because permission is granted', () {
        final state = _createState(
          status: {tPermission: PermissionStatus.granted},
        );

        expect(state.checkEveryGranted({tPermission}), true);
      });
    });

    group('checkAnyGranted', () {
      test('Failed: permission is not resolved', () {
        final state = _createState();

        expect(state.checkAnyGranted({tPermission}), false);
      });

      test('Failed: permission is denied', () {
        final state = _createState(
          status: {tPermission: PermissionStatus.denied},
        );

        expect(state.checkAnyGranted({tPermission}), false);
      });

      test('Success: because permission is granted', () {
        final state = _createState(
          status: {tPermission: PermissionStatus.granted},
        );

        expect(state.checkAnyGranted({tPermission}), true);
      });
    });
  });
}

PermissionsBlocState _createState({
  Map<Permission, PermissionPlace> places = const {},
  Map<Permission, PermissionStatus> status = const {},
}) {
  return PermissionsBlocState(places: places, status: status);
}
