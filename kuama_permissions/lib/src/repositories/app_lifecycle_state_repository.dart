import 'dart:async';

import 'package:flutter/widgets.dart';

export 'package:flutter/widgets.dart' show AppLifecycleState;

class AppLifecycleStateRepository {
  StreamController<AppLifecycleState>? _subject;
  WidgetsBindingObserver? _observer;

  Stream<AppLifecycleState> get onChanges {
    _subject ??= StreamController.broadcast(
      sync: true,
      onListen: () {
        WidgetsBinding.instance!.addObserver(_observer ??= _Observer(_subject!.add));
      },
      onCancel: () {
        WidgetsBinding.instance!.removeObserver(_observer!);
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
