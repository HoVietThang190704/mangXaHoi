import 'package:mangxahoi/Model/StudentModel.dart';

import '../Model/ProductModel.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../Utils.dart';
import 'ApiResponse.dart';
import 'BaseRepository.dart';

class StudentRepository extends BaseRepository{
  Future<ApiResponse> getStudent() async {
    final response = await http.get(
      Uri.parse("${Utils.baseUrl}/api/Product/get-student"),
      headers: {
        "Content-Type": "application/json",
      },
    );
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final apiResponse = ApiResponse.fromJson(
        jsonData,
            (data) => StudentModel.fromJson(data),
      );
      return apiResponse;
    }
    super.codeErrorHandle(response.statusCode);
    return ApiResponse(status: false, message: "",data: null);
  }
}