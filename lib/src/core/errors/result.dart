import 'app_failure.dart';

sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is FailureResult<T>;

  R when<R>({
    required R Function(T value) success,
    required R Function(AppFailure failure) failure,
  }) {
    final result = this;
    return switch (result) {
      Success<T>(:final value) => success(value),
      FailureResult<T>(failure: final appFailure) => failure(appFailure),
    };
  }
}

final class Success<T> extends Result<T> {
  final T value;

  const Success(this.value);
}

final class FailureResult<T> extends Result<T> {
  final AppFailure failure;

  const FailureResult(this.failure);
}
