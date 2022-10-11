class BaseError extends Error {
  final String message;
  BaseError(this.message) : super();
  @override
  String toString() => message;
}
