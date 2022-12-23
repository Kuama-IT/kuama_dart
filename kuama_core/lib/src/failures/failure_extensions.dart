import 'dart:async';

import 'package:kuama_core/src/failures/failure.dart';
import 'package:rxdart/rxdart.dart';

extension StreamFailureExtension<T> on Stream<T> {
  Stream<T> onFailureResume(Stream<T>? Function(Failure failure) healer) {
    return onErrorResume((error, stackTrace) {
      if (error is Failure) {
        final stream = healer(error);
        if (stream != null) return stream;
      }
      return Stream.error(error, stackTrace);
    });
  }
}

extension StreamSubscriptionExtension<T> on StreamSubscription<T> {
  void onFailure(FutureOr<bool> Function(Failure failure) handler) {
    onError((error, stackTrace) async {
      if (error is Failure) {
        final result = await handler(error);
        if (result) return;
      }
      Error.throwWithStackTrace(error, stackTrace);
    });
  }
}
