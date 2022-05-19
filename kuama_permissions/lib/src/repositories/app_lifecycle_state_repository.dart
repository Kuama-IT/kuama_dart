import 'dart:async';

import 'package:flutter/widgets.dart';

export 'package:flutter/widgets.dart' show AppLifecycleState;

class AppLifecycleStateRepository {
  StreamController<AppLifecycleState>? _subject;
  WidgetsBindingObserver? _observer;

  static AppLifecycleStateRepository? _instance;
  AppLifecycleStateRepository._();

  /// It is a singleton because only one observer should exist
  factory AppLifecycleStateRepository() {
    return _instance ??= AppLifecycleStateRepository._();
  }

  Stream<AppLifecycleState> get onChanges {
    _subject ??= StreamController.broadcast(
      sync: true,
      onListen: () {
        WidgetsBinding.instance.addObserver(_observer ??= _Observer(_subject!.add));
      },
      onCancel: () {
        WidgetsBinding.instance.removeObserver(_observer!);
      },
    );

    return _subject!.stream;
  }
}

class _Observer extends WidgetsBindingObserver {
  final void Function(AppLifecycleState state) onChangeChangeAppLifecycleState;

  _Observer(this.onChangeChangeAppLifecycleState);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    onChangeChangeAppLifecycleState(state);
  }
}
