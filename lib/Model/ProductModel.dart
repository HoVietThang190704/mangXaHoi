import 'package:flutter/cupertino.dart';

class ProductModel{
  late int Id;
  late String Name;
  late String ImageUrl;
  late double Price;
  ProductModel(int Id, String Name, String ImageUrl, double Price){
    this.Id  = Id;
    this.Name = Name;
    this.ImageUrl = ImageUrl;
    this.Price = Price;
  }
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      json['id'],
      json['name'],
      json['imageUrl'] ?? "",
      double.parse( (json['price'] ?? 0).toString()),
    );
  }

  @override
  String toString() {
    return 'ProductModel{Id: $Id, Name: $Name, ImageUrl: $ImageUrl, Price: $Price}';
  }
}