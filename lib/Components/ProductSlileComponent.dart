import 'package:mangxahoi/Model/ProductModel.dart';
import 'package:mangxahoi/Service/ProductService.dart';
import 'package:flutter/material.dart';

import '../Utils.dart';
class ProductSlideComponent extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _productSlideComponent();
  }

}

class _productSlideComponent extends State<ProductSlideComponent>{
  List<ProductModel> productList = [];

  _productSlideComponent(){
    loadData();
  }
  loadData() async{
    ProductService productService = ProductService();
     var slide = await productService.getProducts(Utils.slideUrl);
     //var student = await productService.getStudent();
     print("product: ${slide}");
      //khi co loi xay ra, goi api insert error log lên backend: apiname, input, output, userlogin....
     //if else cho status + message.....
    productList = slide.data;
     setState(() {

     });
    //print("product: ${student}");
  }
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    double width = screenSize.width;
    // TODO: implement build
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: productList.length,

      itemBuilder: (context, index) {
        // Builder function called for each visible item
        return Container(
            margin:  EdgeInsets.only(right: 5),
          
          width: width*0.18,
          height: width*0.18,
            decoration:  BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              border: Border.all(width: 1,color: Colors.black54),
              image: DecorationImage(
                image: NetworkImage ('${Utils.baseUrl +  productList[index].ImageUrl}'),
                fit: BoxFit.cover,
              ),
            )
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return SizedBox(height: 5);
      },
    );
  }
  
}