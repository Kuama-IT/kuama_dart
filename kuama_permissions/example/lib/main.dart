import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:kuama_permissions/kuama_permissions.dart';
import 'package:kuama_positioner/kuama_positioner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
import 'package:riverbloc/riverbloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

final permissions = {Permission.camera, Permission.locationWhenInUse};

final permissionBloc = BlocProvider<PermissionsBloc, PermissionsBlocState>((ref) {
  return PermissionsBloc(
    preCheck: permissions,
  );
});

final positionBloc = BlocProvider<PositionBloc, PositionBlocState>((ref) {
  return PositionBloc(
    permissionBloc: ref.watch(permissionBloc.bloc),
  );
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  GetIt.instance
    ..registerSingleton(await SharedPreferences.getInstance())
    ..registerSingleton(PermissionHandlerPlatform.instance)
    ..registerSingleton(AppLifecycleStateRepository())
    ..registerSingleton(PermissionsManagerRepository())
    ..registerSingleton(PermissionsPreferencesRepository())
    ..registerSingleton(PermissionsService());

  GetIt.instance
    ..registerSingleton(GeolocatorPlatform.instance)
    ..registerSingleton<PositionRepository>(PositionRepositoryImpl())
    ..registerSingleton(CheckPositionService())
    ..registerSingleton(GetCurrentPosition())
    ..registerSingleton(OnPositionChanges())
    ..registerSingleton(OnPositionServiceChanges())
    ..registerSingleton(OpenPositionServicePage());

  runApp(const ProviderScope(
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(permissionBloc);
    final positionState = ref.watch(positionBloc);

    String translatePermissionStatus(Permission permission) {
      if (state.places.containsKey(permission)) {
        return 'Place: ${state.places[permission]?.name}';
      } else if (state.status.containsKey(permission)) {
        return 'Status: ${state.status[permission]?.name}';
      }
      return '???';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(""),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Services:'),
            Row(
              children: [
                StreamBuilder<dynamic>(
                  stream: Geolocator.getServiceStatusStream(),
                  builder: (context, snapshot) {
                    return Text('Location Service: ${snapshot.data}');
                  },
                ),
              ],
            ),
            ...permissions.map((permission) {
              return Column(
                children: [
                  Text('$permission: ${translatePermissionStatus(permission)}'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () async {
                          final status = await permission.status;
                          print('Check result: ${status}');
                        },
                        child: Text('Check'),
                      ),
                      TextButton(
                        onPressed: () async {
                          final status = await permission.request();
                          print('Request result: ${status}');
                        },
                        child: Text('Request'),
                      ),
                    ],
                  ),
                ],
              );
            }).toList(),
            const Divider(),
            ...permissions.map((permission) {
              return Column(
                children: [
                  Text('$permission: ${translatePermissionStatus(permission)}'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () => ref.read(permissionBloc.bloc).request({permission}),
                        child: Text('Request'),
                      ),
                      TextButton(
                        onPressed: () =>
                            ref.read(permissionBloc.bloc).request({permission}, tryAgain: true),
                        child: Text('Re-Request'),
                      ),
                    ],
                  ),
                ],
              );
            }).toList(),
            Text('Ask'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed:
                      state.isAsking ? () => ref.read(permissionBloc.bloc).resolveAsk(false) : null,
                  child: Text('Failed'),
                ),
                TextButton(
                  onPressed:
                      state.isAsking ? () => ref.read(permissionBloc.bloc).resolveAsk(true) : null,
                  child: Text('Success'),
                ),
              ],
            ),
            Divider(),
            Text('hasPermission: ${positionState.hasPermission}'),
            Text('isServiceEnabled: ${positionState.isServiceEnabled}'),
            Text('lastPosition: ${positionState.lastPosition}'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => ref.refresh(positionBloc.bloc),
                  child: Text('Refresh Riverpod'),
                ),
                TextButton(
                  onPressed: () => ref.read(positionBloc.bloc).locate(),
                  child: Text('Locate'),
                ),
                TextButton(
                  onPressed: () => ref.read(positionBloc.bloc).unTrack(),
                  child: Text('Un-Track'),
                ),
                TextButton(
                  onPressed: () => ref.read(positionBloc.bloc).track(),
                  child: Text('Track'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
