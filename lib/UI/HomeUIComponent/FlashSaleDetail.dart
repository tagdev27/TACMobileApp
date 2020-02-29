import 'dart:async';

import 'package:treva_shop_flutter/Library/carousel_pro/carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:treva_shop_flutter/ListItem/FlashSaleItem.dart';
import 'package:treva_shop_flutter/ListItem/GiftBaskets.dart';
import 'package:treva_shop_flutter/ListItem/Rev.dart';
import 'package:treva_shop_flutter/UI/CartUIComponent/CartLayout.dart';
import 'package:treva_shop_flutter/UI/HomeUIComponent/ChatItem.dart';
import 'package:treva_shop_flutter/UI/CartUIComponent/Delivery.dart';
import 'package:treva_shop_flutter/UI/HomeUIComponent/PromotionDetail.dart';
import 'package:treva_shop_flutter/Utils/backgroud_utils.dart';
import 'package:treva_shop_flutter/Utils/colors.dart';
import 'package:treva_shop_flutter/Utils/general.dart';

class flashSaleDetail extends StatefulWidget {

  final Products itemSale;
  List<Products> all_products;
  flashSaleDetail(this.all_products, this.itemSale);

  @override
  _flashSaleDetailState createState() => _flashSaleDetailState(itemSale);
}

class _flashSaleDetailState extends State<flashSaleDetail> {
  /// Declare class in FlashSaleItem.dart
  final Products itemSale;
  _flashSaleDetailState(this.itemSale);

  //List<Reviews> mRev = new List();
  static List<Products> products = new List();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startOperations();
  }

  void startOperations() async{
    //get list of products
//    final pro = new Utils().getRelatedProducts(itemSale.category);
    final pro = widget.all_products;
//    final pro = await new Utils().getProducts();
    setState(() {
      products = new Utils().getRelatedProducts(pro, itemSale.category);
    });
//    new Timer(Duration(milliseconds: 500), (){
//      setState(() {
//        products = new Utils().getRelatedProducts(pro, itemSale.category);
//      });
//    });
  }

  @override
  static BuildContext ctx;
  int valueItemChart = new GeneralUtils().cartSize();
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();

  /// Create a bottomSheet "ViewMore" in description
  void _bottomSheet() {
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return SingleChildScrollView(
            child: Container(
              color: Colors.black26,
              child: Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Container(
                  height: 1500.0,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0))),
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(padding: EdgeInsets.only(top: 20.0)),
                      Center(
                          child: Text(
                        "Description",
                        style: _subHeaderCustomStyle,
                      )),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 20.0, left: 20.0, right: 20.0, bottom: 20.0),
                        child: Text(itemSale.description, style: _detailText),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  /// Variable for custom Text
  static var _customTextStyle = TextStyle(
    color: Colors.black87,
    fontFamily: "Gotik",
    fontSize: 17.0,
    fontWeight: FontWeight.w800,
  );

  /// Variable Custom Text for Header text
  static var _subHeaderCustomStyle = TextStyle(
      color: Colors.black54,
      fontWeight: FontWeight.w700,
      fontFamily: "Gotik",
      fontSize: 16.0);

  /// Variable Custom Text for Detail text
  static var _detailText = TextStyle(
      fontFamily: "Gotik",
      color: Colors.black54,
      letterSpacing: 0.3,
      wordSpacing: 0.5);

  static List<Widget> getSuggestedProducts() {

    List<Widget> suggest = new List();

    for(int i = 0; i < products.length; i++) {
      suggest.add(FavoriteItem(
        image: products[i].pictures[0],
        title: products[i].name,
        Salary: new GeneralUtils().currencyFormattedMoney(products[i].price),
        Rating: '${products[i].ratingValue}',
        sale: '',//'${products[i].stock} in stock',
      ),);
      suggest.add(Padding(padding: EdgeInsets.only(left: 10.0)),);
    }

    return suggest;
  }

  /// Variable Component UI use in bottom layout "Top Rated Products"
  Widget _suggestedItem() {
    return Padding(
      padding:
      const EdgeInsets.only(left: 15.0, right: 20.0, top: 30.0, bottom: 20.0),
      child: Container(
        height: 280.0,
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Top Rated Products",
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: "Gotik",
                      fontSize: 15.0),
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(PageRouteBuilder(
                        pageBuilder: (_, __, ___) => new promoDetail(products)));
                  },
                  child: Text(
                    "See More",
                    style: TextStyle(
                        color: Colors.pinkAccent.withOpacity(0.8),
                        fontFamily: "Gotik",
                        fontWeight: FontWeight.w700),
                  ),
                )
              ],
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(top: 20.0, bottom: 2.0),
                scrollDirection: Axis.horizontal,
                children: getSuggestedProducts(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Component any widget for FlashSaleDetail
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        actions: <Widget>[
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                  PageRouteBuilder(pageBuilder: (_, __, ___) => new cart()));
            },
            child: Stack(
              alignment: AlignmentDirectional(-1.0, -0.8),
              children: <Widget>[
                IconButton(
                  onPressed:null,
                    icon: Icon(
                  Icons.shopping_cart,
                  color: Colors.black26,
                )),
                CircleAvatar(
                  radius: 10.0,
                  backgroundColor: Color(MyColors.primary_color),
                  child: Text(
                    valueItemChart.toString(),
                    style: TextStyle(color: Colors.white, fontSize: 13.0),
                  ),
                ),
              ],
            ),
          ),
        ],
        elevation: 0.5,
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          "Product Detail",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black54,
            fontSize: 17.0,
            fontFamily: "Gotik",
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  /// ImageSlider in header
                  Container(
                      height: 300.0,
                      child: Hero(
                        tag: "hero-flashsale-${itemSale.id}",
                        child: Material(
                          child: new Carousel(
                            dotColor: Colors.black26,
                            dotIncreaseSize: 1.7,
                            dotBgColor: Colors.transparent,
                            autoplay: false,
                            boxFit: BoxFit.cover,
                            images: [
                              NetworkImage(itemSale.pictures[0]),
//                              NetworkImage(itemSale.pictures[0]),
//                              NetworkImage(itemSale.pictures[0]),
                            ],
                          ),
                        ),
                      )),

                  ///Label FlashSale in bottom header
                  Container(
                    height: 50.0,
                    width: 1000.0,
                    color: Colors.pinkAccent,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Padding(padding: EdgeInsets.only(left: 20.0)),
                            Image.asset(
                              "assets/icon/flashSaleIcon.png",
                              height: 25.0,
                            ),
                            Padding(padding: EdgeInsets.only(left: 10.0)),
                            Text(
                              "Flash Sale",
                              style: _customTextStyle.copyWith(
                                  color: Colors.white),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 15.0),
                          child: Text(
                            '',//'${itemSale.stock} in stock',
                            style: _customTextStyle.copyWith(
                                color: Colors.white, fontSize: 13.5),
                          ),
                        )
                      ],
                    ),
                  ),

                  /// White Background for Title, Price and Ratting
                  Container(
                    decoration: BoxDecoration(color: Colors.white, boxShadow: [
                      BoxShadow(
                        color: Color(0xFF656565).withOpacity(0.15),
                        blurRadius: 1.0,
                        spreadRadius: 0.2,
                      )
                    ]),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0, top: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            itemSale.name,
                            style: _customTextStyle,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Padding(padding: EdgeInsets.only(top: 5.0)),
                          Text(
                            new GeneralUtils().currencyFormattedMoney(itemSale.price),
                            style: _customTextStyle.copyWith(
                                decoration: TextDecoration.lineThrough,
                                fontSize: 13.0,
                                color: Colors.black26),
                          ),
                          Padding(padding: EdgeInsets.only(top: 5.0)),
                          Text(
                            new GeneralUtils().currencyFormattedMoney(itemSale.salePrice),
                            style: _customTextStyle.copyWith(
                                color: Colors.pinkAccent, fontSize: 20.0),
                          ),
                          Padding(padding: EdgeInsets.only(top: 10.0)),
                          Divider(
                            color: Colors.black12,
                            height: 1.0,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 10.0, bottom: 10.0),
                            child: Row(
                              children: <Widget>[
                                Container(
                                  height: 30.0,
                                  width: 75.0,
                                  decoration: BoxDecoration(
                                    color: Colors.lightGreen,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20.0)),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        '${itemSale.ratingTotal}',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.only(left: 8.0)),
                                      Icon(
                                        Icons.star,
                                        color: Colors.white,
                                        size: 19.0,
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: Text(
                                    '${itemSale.ratingValue}',
                                    style: TextStyle(
                                        color: Colors.black26,
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w500),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),

                  /// Detail Product
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Container(
                      height: 205.0,
                      width: 600.0,
                      decoration:
                          BoxDecoration(color: Colors.white, boxShadow: [
                        BoxShadow(
                          color: Color(0xFF656565).withOpacity(0.15),
                          blurRadius: 1.0,
                          spreadRadius: 0.2,
                        )
                      ]),
                      child: Padding(
                        padding: EdgeInsets.only(top: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 20.0),
                              child: Text(
                                "Detail Product",
                                style: _subHeaderCustomStyle,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 20.0,
                                  right: 20.0,
                                  bottom: 10.0,
                                  left: 20.0),
                              child: Text(
                                itemSale.shortDetails,
                                style: _detailText,
                                textDirection: TextDirection.ltr,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  /// Description
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Container(
                      height: 205.0,
                      width: 600.0,
                      decoration:
                          BoxDecoration(color: Colors.white, boxShadow: [
                        BoxShadow(
                          color: Color(0xFF656565).withOpacity(0.15),
                          blurRadius: 1.0,
                          spreadRadius: 0.2,
                        )
                      ]),
                      child: Padding(
                        padding: EdgeInsets.only(top: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 20.0),
                              child: Text(
                                "Description",
                                style: _subHeaderCustomStyle,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 15.0,
                                  right: 20.0,
                                  bottom: 10.0,
                                  left: 20.0),
                              child: Text(itemSale.description,
                                  style: _detailText),
                            ),
                            Center(
                              child: InkWell(
                                onTap: () {
                                  _bottomSheet();
                                },
                                child: Text(
                                  "View More",
                                  style: TextStyle(
                                    color: Colors.pinkAccent,
                                    fontSize: 15.0,
                                    fontFamily: "Gotik",
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),

                  ///Call a variable suggested Item(Top Rated Product Card) in bottom of description
                  (products.length > 0) ? _suggestedItem() : Text('')
                ],
              ),
            ),
          ),

          /// If user click icon chart SnackBar show
          /// this code to show a SnackBar
          /// and Increase a valueItemChart + 1
          InkWell(
            onTap: () {
              String addCart = new GeneralUtils().addToCart(itemSale, 1);
              var snackbar = SnackBar(
                content: Text("Item Added"),
              );
              new Timer(Duration(milliseconds: 500), (){
                setState(() {
                  valueItemChart = new GeneralUtils().cartSize();
                });
              });
              _key.currentState.showSnackBar(snackbar);
            },

            /// Shopping Cart in bottom layout
            child: Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: Container(
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      height: 40.0,
                      width: 60.0,
                      decoration: BoxDecoration(
                          color: Colors.white12.withOpacity(0.1),
                          border: Border.all(color: Colors.black12)),
                      child: Center(
                        child: Image.asset(
                          "assets/icon/shopping-cart.png",
                          height: 23.0,
                        ),
                      ),
                    ),

                    /// Icon Message in bottom layout with Flexible
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(PageRouteBuilder(
                            pageBuilder: (_, ___, ____) => new chatItem()));
                      },
                      child: Container(
                        height: 40.0,
                        width: 60.0,
                        decoration: BoxDecoration(
                            color: Colors.white12.withOpacity(0.1),
                            border: Border.all(color: Colors.black12)),
                        child: Center(
                          child: Image.asset("assets/icon/message.png",
                              height: 20.0),
                        ),
                      ),
                    ),
                    /// Button Pay
                    InkWell(
                      onTap: () {
                        new GeneralUtils().addToCart(itemSale, 1);
                        Navigator.of(context).push(PageRouteBuilder(
                            pageBuilder: (_, __, ___) => new delivery()));
                      },
                      child: Container(
                        height: 45.0,
                        width: 200.0,
                        decoration: BoxDecoration(
                          color: Colors.pinkAccent,
                        ),
                        child: Center(
                          child: Text(
                            "Pay",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

/// class Item for card in "top rated products"
class FavoriteItem extends StatelessWidget {
  String image, Rating, Salary, title, sale;
  FavoriteItem({this.image, this.Rating, this.Salary, this.title, this.sale});

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 5.0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF656565).withOpacity(0.15),
                blurRadius: 4.0,
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
                Container(
                  height: 150.0,
                  width: 150.0,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(7.0),
                          topRight: Radius.circular(7.0)),
                      image: DecorationImage(
                          image: AssetImage(image), fit: BoxFit.cover)),
                ),
                Padding(padding: EdgeInsets.only(top: 15.0)),
                Padding(
                  padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                  child: Text(
                    title,
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
                    Salary,
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
                            Rating,
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
                        sale,
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
      ),
    );
  }
}
