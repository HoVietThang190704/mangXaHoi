import 'package:mangxahoi/Utils.dart';

import '../Model/ProductModel.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'ApiResponse.dart';
import 'BaseRepository.dart';

class ProductRepository extends BaseRepository{
  Future<ApiResponse> getProducts(String url) async {
    final response = await http.get(Uri.parse("${Utils.baseUrl + url}"),
      headers: {
        "Content-Type": "application/json",
      },
    );
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final apiResponse = ApiResponse.fromJson(
        jsonData,
            (data) =>  (data  as List)
            .map((e) => ProductModel.fromJson(e))
            .toList(),
      );
      return apiResponse;
    }
    super.codeErrorHandle(response.statusCode);
    return ApiResponse(status: false, message: "",data: null);
  }
}