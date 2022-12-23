class ExceptionCaught {
  final Object exception;
  final StackTrace stackTrace;

  const ExceptionCaught(this.exception, this.stackTrace);

  @override
  String toString() => '$exception\n$stackTrace';
}

/// Maintainers: Keep same structure as [Error]/[Exception]
abstract class Failure {
  final ExceptionCaught? exceptionCaught;

  Failure({required this.exceptionCaught});

  /// Explains the cause of the error and how to fix it
  String get message;

  @override
  String toString() => '$runtimeType: $message';
}
