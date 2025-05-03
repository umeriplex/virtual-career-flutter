class AppResponse<T>{
  final T? data;
  final String message;
  final int? statusCode;
  final bool success;

  AppResponse({
    this.data,
    this.message = 'Something went wrong, please try again',
    this.statusCode,
    this.success = false,
  });

  @override
  String toString() {
    return 'AppResponse{data: $data, message: $message, statusCode: $statusCode, success: $success}';
  }
}