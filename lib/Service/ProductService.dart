import 'package:mangxahoi/Repository/ApiResponse.dart';

import '../Model/ProductModel.dart';
import '../Repository/ProductRepository.dart';
import '../Repository/StudentRepository.dart';

class ProductService{
  var productRepository;

  late StudentRepository studentRepository;

  ProductService(){
    this.productRepository = ProductRepository();
    this.studentRepository = StudentRepository();
  }

  Future<ApiResponse> getProducts(String url) async{
    return productRepository.getProducts(url);
  }
  Future<ApiResponse> getStudent() async{
    return studentRepository.getStudent();
  }
}