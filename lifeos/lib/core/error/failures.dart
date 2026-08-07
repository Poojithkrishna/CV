/// Base class for expected, user-facing failures. Distinct from Dart
/// exceptions: a [Failure] is a normal outcome of an operation (e.g.
/// "validation failed"), not a bug, so it is modeled as data instead of
/// thrown and caught.
sealed class Failure {
  const Failure(this.message);

  final String message;

  @override
  String toString() => message;
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message);
}
