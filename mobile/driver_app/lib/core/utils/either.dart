/// Minimal `Either<L, R>` used by use cases to return either a [Failure]
/// (left) or a result value (right) without throwing across layer boundaries.
library;

sealed class Either<L, R> {
  const Either();

  bool get isLeft => this is Left<L, R>;

  bool get isRight => this is Right<L, R>;

  R get right {
    switch (this) {
      case Right(value: final value):
        return value;
      case Left():
        throw StateError('Called `.right` on a Left');
    }
  }

  L get left {
    switch (this) {
      case Left(value: final value):
        return value;
      case Right():
        throw StateError('Called `.left` on a Right');
    }
  }

  Either<L, R2> map<R2>(
    R2 Function(R value) transform,
  ) {
    switch (this) {
      case Right(value: final value):
        return Right<L, R2>(transform(value));
      case Left(value: final value):
        return Left<L, R2>(value);
    }
  }

  Either<L2, R> mapLeft<L2>(
    L2 Function(L value) transform,
  ) {
    switch (this) {
      case Left(value: final value):
        return Left<L2, R>(transform(value));
      case Right(value: final value):
        return Right<L2, R>(value);
    }
  }

  R2 fold<R2>(
    R2 Function(L left) onLeft,
    R2 Function(R right) onRight,
  ) {
    switch (this) {
      case Left(value: final value):
        return onLeft(value);
      case Right(value: final value):
        return onRight(value);
    }
  }
}

final class Left<L, R> extends Either<L, R> {
  const Left(this.value);

  final L value;

  @override
  bool operator ==(Object other) =>
      other is Left<L, R> && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

final class Right<L, R> extends Either<L, R> {
  const Right(this.value);

  final R value;

  @override
  bool operator ==(Object other) =>
      other is Right<L, R> && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

Either<L, R> left<L, R>(L value) => Left<L, R>(value);

Either<L, R> right<L, R>(R value) => Right<L, R>(value);
