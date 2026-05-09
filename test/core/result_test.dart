import 'package:dashboard/src/core/errors/app_failure.dart';
import 'package:dashboard/src/core/errors/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('success maps value', () {
    const result = Success(42);
    expect(result.isSuccess, isTrue);
    expect(result.when(success: (value) => value, failure: (_) => 0), 42);
  });

  test('failure maps failure', () {
    const result = FailureResult<int>(ValidationFailure('bad input'));
    expect(result.isFailure, isTrue);
    expect(
      result.when(success: (_) => '', failure: (failure) => failure.message),
      'bad input',
    );
  });
}
