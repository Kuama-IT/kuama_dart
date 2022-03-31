/// Maintainers: Keep same structure as [Error]/[Exception]
abstract class Failure {
  Failure();

  /// Explains the cause of the error and how to fix it
  String get message;

  @override
  String toString() => '$runtimeType: $message';
}
