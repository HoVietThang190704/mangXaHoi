import 'package:mangxahoi/Utils.dart';
import 'package:mangxahoi/services/api_service.dart';

import '../Model/ProductModel.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'ApiResponse.dart';
import 'BaseRepository.dart';

class ProductRepository extends BaseRepository{
  Future<ApiResponse> getProducts(String url) async {
    // Use ApiService to perform the GET request
    final api = await ApiService.create();
    final jsonData = await api.getJson(url);

    final apiResponse = ApiResponse.fromJson(
      jsonData,
      (data) => (data as List).map((e) => ProductModel.fromJson(e)).toList(),
    );
    return apiResponse;
  }
}