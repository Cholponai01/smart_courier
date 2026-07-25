import 'package:smart_courier/core/error/failure.dart';

sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  const Success(this.data);

  final T data;
}

final class ResultFailure<T> extends Result<T> {
  const ResultFailure(this.failure);

  final Failure failure;
}

/// Placeholder for successful operations that return no data.
final class Unit {
  const Unit._();

  static const value = Unit._();
}
