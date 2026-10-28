/// Describes why an operation failed, in a form the UI can display.
class Failure {
  const Failure(this.message, {this.statusCode});

  final String message;
  final int? statusCode;
}

/// Outcome of an operation: either [Ok] with a value or [Err] with a [Failure].
sealed class Result<T> {
  const Result();
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);

  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);

  final Failure failure;
}
