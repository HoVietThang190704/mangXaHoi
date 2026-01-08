import 'package:mangxahoi/Components/ProductSlileComponent.dart';
import 'package:mangxahoi/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Components/AppBarComponent.dart';
import '../Components/BottomNavigationBarComponent.dart';
import '../Model/ProductModel.dart';
import '../Service/ProductService.dart';
class HomeView extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _homeView();
  }

}

class _homeView extends State<HomeView> {


  List<ProductModel> productList = [];

  late BuildContext _context;



  _homeView(){
    loadData();
  }
  loadData() async{
    ProductService productService = ProductService();
    var slide = await productService.getProducts(Utils.allProductUrl);
    //var student = await productService.getStudent();
    print("product: ${slide}");
    //if else cho status + message.....
    productList = slide.data;
    setState(() {

    });
    //print("product: ${student}");
  }


  void gridViewClick(int productId){
    print("Product Id: ${productId}");
    Navigator.pushNamed(_context, '/productDetail', arguments: {"Id": productId});
  }
  @override
  Widget build(BuildContext context) {
    this._context= context;
    var screenSize = MediaQuery.of(context).size;
    double width = screenSize.width;
    // TODO: implement build
    return Scaffold(
      appBar: AppBarComponent("Home"),
      body: Column(
        children: [
          Container(
            color: Colors.grey[200],
            height: width * 0.18,
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(5, 5, 0, 5),
            child: ProductSlideComponent(),
          ),
          //Text("Danh sách sản phảm", style: TextStyle(color: Colors.red,fontSize: 30),),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2, // Number of columns
              crossAxisSpacing: 10.0, // Space between columns
              mainAxisSpacing: 10.0, // Space between rows
              padding: EdgeInsets.all(10.0),
              childAspectRatio: 0.7,
              children: List.generate(productList.length, (index) {
                // Generates 30 items
                return InkWell(
                  onTap: () {
                    return gridViewClick(productList[index].Id);
                  },
                    child: Container(

                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    border: Border.all(width: 1, color: Colors.black54),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: width * 0.495,
                        height: width * 0.495,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          border: Border.all(width: 1, color: Colors.black54),
                          image: DecorationImage(
                            image: NetworkImage('${Utils.baseUrl + productList[index].ImageUrl}'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Text(
                        "${productList[index].Name}",
                        style: TextStyle(fontSize: 20),
                      ),
                      Text("${productList[index].Price}"),
                    ],
                  ),
                ))  ;
              }),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBarComponent(),
    );
  }
}
