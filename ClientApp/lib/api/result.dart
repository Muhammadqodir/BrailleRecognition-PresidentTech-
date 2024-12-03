// ignore_for_file: public_member_api_docs, sort_constructors_first
class ApiResult<T> {
  bool isSuccess;
  String message;
  T? data;
  ApiResult({
    required this.isSuccess,
    required this.message,
    this.data,
  });

  ApiResult.success({
    required this.data,
    this.isSuccess = true,
    this.message = "",
  });

  ApiResult.error({
    this.isSuccess = false,
    this.message = "",
  });
}
