import 'package:flutter/cupertino.dart';

class StudentModel{
  late int Id;
  late String Name;
  late double Mark;

  StudentModel(int Id, String Name,  double Mark){
    this.Id  = Id;
    this.Name = Name;

    this.Mark = Mark;
  }
  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      json['id'],
      json['name'],
      double.parse( (json['mark'] ?? 0).toString()),
    );
  }

  @override
  String toString() {
    return 'ProductModel{Id: $Id, Name: $Name,  Mark: $Mark}';
  }
}