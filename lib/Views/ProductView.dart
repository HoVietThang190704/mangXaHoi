import 'package:flutter/material.dart';

import '../Components/AppBarComponent.dart';
import '../Components/BottomNavigationBarComponent.dart';
import '../Model/ProductModel.dart';
import '../Utils.dart';

class ProductView extends StatelessWidget {
  List<ProductModel> productList = [];

  ProductView() {
    for (int i = 0; i < 10; i++) {
      int indexImage = i % 2 + 1;
      productList.add(
        ProductModel(
          (i + 1),
          "Product ${i + 1}",
          "Assets/Images/nq${indexImage}.png",
          100,
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    double width = screenSize.width;
    // TODO: implement build
    return Scaffold(
      appBar: AppBarComponent("Product"),
      body: ListView.separated(
        scrollDirection: Axis.vertical,
        itemCount: productList.length,

        itemBuilder: (context, index) {
          // Builder function called for each visible item
          return Container(
            child: Row(

              children: [
                Container(
                  width: width * 0.3,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    border: Border.all(width: 1, color: Colors.black54),
                    image: DecorationImage(
                      image: AssetImage('${productList[index].ImageUrl}'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  margin:EdgeInsets.only(left: 5) ,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${productList[index].Name}"),
                      Text("${productList[index].Price}")
                      
                    ],
                  ),
                ),
              ],
            ),
            margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
            padding: EdgeInsets.all(5),
            width: double.infinity,
            height: width * 0.3,

            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              border: Border.all(width: 1, color: Colors.black54),
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return SizedBox(height: 5);
        },
      ),
      bottomNavigationBar: BottomNavigationBarComponent(),
    );
  }
}
