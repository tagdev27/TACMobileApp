import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:treva_shop_flutter/ListItem/GiftBaskets.dart';
import 'package:treva_shop_flutter/ListItem/PromotionData.dart';
import 'package:treva_shop_flutter/UI/HomeUIComponent/DetailProduct.dart';
import 'package:treva_shop_flutter/Utils/general.dart';

class promoDetail extends StatefulWidget {

  final List<Products> products;
  promoDetail(this.products);

  @override
  _promoDetailState createState() => _promoDetailState();
}



class _promoDetailState extends State<promoDetail> {

  ///
  /// Get image data dummy from firebase server
  ///
  var imageNetwork = NetworkImage("https://firebasestorage.googleapis.com/v0/b/taconlinegiftshop.appspot.com/o/Screenshot_20181005-213916.png?alt=media&token=fbcd391d-1d91-4f7e-8ab5-8ff69cdc9514");

  ///
  /// check the condition is right or wrong for image loaded or no
  ///
  bool imageLoad = true;

  String query = '';

  List<Products> query_products = new List();

  ///
  /// SetState after imageNetwork loaded to change list card
  ///
  @override
  void initState() {
    imageNetwork.resolve(new ImageConfiguration()).addListener((_,__){
      if(mounted){
        setState(() {
          imageLoad = false;
        });
      }
    });
    // TODO: implement initState
    super.initState();
    query_products = widget.products;
  }
  @override
  Widget build(BuildContext context) {
    /// Item Search in bottom of appbar
    var _search = Container(
        height: 50.0,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1.0)),
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Theme(
            data: ThemeData(hintColor: Colors.transparent),
            child: TextFormField(
              decoration: InputDecoration(
                border: InputBorder.none,
                  icon: Icon(
                    Icons.search,
                    color: Colors.black38,
                    size: 18.0,
                  ),
                  suffixIcon: IconButton(icon: Icon(Icons.clear), onPressed: (){
                    setState(() {
                      query = '';
                      query_products = widget.products;
                    });
                  }),
                  hintText: "Search Items Promotion",
                  hintStyle: TextStyle(color: Colors.black38, fontSize: 14.0)),
                textInputAction: TextInputAction.search,
              initialValue: query,
              onFieldSubmitted: (searchValue) {
                if(searchValue.isNotEmpty){
                  setState(() {
                    query_products.clear();
                  });
                  widget.products.forEach((pro){
                    if(pro.name.toLowerCase().contains(searchValue.toLowerCase())){
                      setState(() {
                        query_products.add(pro);
                      });
                    }
                  });
                }
//                setState(() {
//                  query = searchValue;
//                });
              },
            ),
          ),
        ));

    /// Grid Item a product
    var _grid = SingleChildScrollView(
      child: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ///
            ///
            /// check the condition if image data from server firebase loaded or no
            /// if image true (image still downloading from server)
            /// Card to set card loading animation
            ///
            ///
            imageLoad? _imageLoading(context):
            GridView.count(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 7.0, vertical: 10.0),
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 15.0,
              childAspectRatio: 0.545,
              crossAxisCount: 2,
              primary: false,
              children: query_products.map((pro) => ItemGrid(widget.products, pro, getProductPrice(pro))).toList(),
            )
          ],
        ),
      ),
    );



//    List.generate(
//      /// Get data in flashSaleItem.dart (ListItem folder)
//      promotionItem.length,
//          (index) => ItemGrid(promotionItem[index]),
//    ),

    return Scaffold(
      /// Appbar item
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Products - TAC",
          style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16.0,
              color: Colors.black54,
              fontFamily: "Gotik"),
        ),
        iconTheme: IconThemeData(
          color: Color(0xFF6991C7),
        ),
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            /// Calling search and grid variable
            children: <Widget>[
              _search,
              _grid,
            ],
          ),
        ),
      ),
    );
  }

  String getProductPrice(Products pro) {
    return new GeneralUtils().currencyFormattedMoney(pro.price);
  }
}

/// ItemGrid class
class ItemGrid extends StatelessWidget {
  @override
  Products item;
  List<Products> all_products;
  String price;
  
  ItemGrid(this.all_products, this.item, this.price);
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return InkWell(
      onTap: (){
        Navigator.of(context).push(PageRouteBuilder(
            pageBuilder: (_, __, ___) => new detailProduk(all_products, item),
            transitionDuration: Duration(milliseconds: 900),

            /// Set animation Opacity in route to detailProduk layout
            transitionsBuilder:
                (_, Animation<double> animation, __, Widget child) {
              return Opacity(
                opacity: animation.value,
                child: child,
              );
            }));
      },
        child: Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF656565).withOpacity(0.15),
              blurRadius: 2.0,
              spreadRadius: 1.0,
//           offset: Offset(4.0, 10.0)
            )
          ]),
      child: Wrap(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                    height: mediaQueryData.size.height / 3.3,
                    width: 200.0,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(7.0),
                            topRight: Radius.circular(7.0)),
                        image: DecorationImage(
                            image: NetworkImage(item.pictures[0]), fit: BoxFit.cover)),
                  ),
      (item.discount > 0) ? Container(
                    height: 25.5,
                    width: 55.0,
                    decoration: BoxDecoration(
                        color: Color(0xFFD7124A),
                        borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(20.0),
                            topLeft: Radius.circular(5.0))),
                    child: Center(
                        child: Text(
                      "${item.discount}%",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    )),
                  ) : Text('')
                ],
              ),
              Padding(padding: EdgeInsets.only(top: 7.0)),
              Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                child: Text(
                  item.name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      letterSpacing: 0.5,
                      color: Colors.black54,
                      fontFamily: "Sans",
                      fontWeight: FontWeight.w500,
                      fontSize: 13.0),
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 1.0)),
              Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                child: Text(
                  price,
                  style: TextStyle(
                      fontFamily: "Sans",
                      fontWeight: FontWeight.w500,
                      fontSize: 14.0),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 15.0, right: 15.0, top: 5.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          '${item.ratingValue}',
                          style: TextStyle(
                              fontFamily: "Sans",
                              color: Colors.black26,
                              fontWeight: FontWeight.w500,
                              fontSize: 12.0),
                        ),
                        Icon(
                          Icons.star,
                          color: Colors.yellow,
                          size: 14.0,
                        )
                      ],
                    ),
                    Text(
                      '${item.stock} in stock',
                      style: TextStyle(
                          fontFamily: "Sans",
                          color: Colors.black26,
                          fontWeight: FontWeight.w500,
                          fontSize: 12.0),
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }
}

///
///
///
/// Loading Item Card Animation Constructor
///
///
///
class loadingMenuItemCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          top: 20.0, left: 10.0, bottom: 10.0, right: 0.0),
      child: InkWell(
        onTap: (){

        },
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF656565).withOpacity(0.15),
                  blurRadius: 2.0,
                  spreadRadius: 1.0,
//           offset: Offset(4.0, 10.0)
                )
              ]),
          child: Wrap(
            children: <Widget>[
              ///
              ///
              /// Shimmer class for animation loading
              ///
              ///
              Shimmer.fromColors(
                baseColor: Colors.black38,
                highlightColor: Colors.white,
                child: Container(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          Container(
                            height: 205.0,
                            width: 185.0,
                            color: Colors.black12,
                          ),
                          Container(
                            height: 25.5,
                            width: 65.0,
                            decoration: BoxDecoration(
                                color: Color(0xFFD7124A),
                                borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(20.0),
                                    topLeft: Radius.circular(5.0))),
                          )
                        ],
                      ),
                      Padding(
                          padding: const EdgeInsets.only(left: 10.0, right: 5.0,top: 12.0),
                          child: Container(
                            height: 9.5,
                            width: 130.0,
                            color: Colors.black12,
                          )
                      ),
                      Padding(
                          padding: const EdgeInsets.only(left: 10.0, right: 5.0,top: 10.0),
                          child: Container(
                            height: 9.5,
                            width: 80.0,
                            color: Colors.black12,
                          )
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 15.0, right: 15.0, top: 7.0,bottom: 0.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Icon(
                                  Icons.star,
                                  color: Colors.yellow,
                                  size: 14.0,
                                )
                              ],
                            ),
                            Container(
                              height: 8.0,
                              width: 30.0,
                              color: Colors.black12,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


///
///
/// Calling imageLoading animation for set a grid layout
///
///
Widget _imageLoading(BuildContext context){
  return GridView.count(
    shrinkWrap: true,
    padding: EdgeInsets.symmetric(horizontal: 7.0, vertical: 10.0),
    crossAxisSpacing: 10.0,
    mainAxisSpacing: 15.0,
    childAspectRatio: 0.545,
    crossAxisCount: 2,
    primary: false,
    children:List.generate(
      /// Get data in PromotionDetail.dart (ListItem folder)
      promotionItem.length,
          (index) => loadingMenuItemCard(),
    ),
  );
}