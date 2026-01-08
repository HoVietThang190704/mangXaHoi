class ApiResponse<T> {
  final bool status;
  final String message;
  final T? data;

  ApiResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory ApiResponse.fromJson(
      Map<String, dynamic> json,
      T Function(dynamic json) fromJsonT,
      ) {
    return ApiResponse(
      status: json['status'],
      message: json['message'],
      data: json['data'] == null? null:  fromJsonT(json['data']) ,
    );
  }

  @override
  String toString() {
    return 'ApiResponse{status: $status, message: $message, data: $data}';
  }

}