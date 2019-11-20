import 'dart:async';

import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shimmer/shimmer.dart';
import 'package:treva_shop_flutter/ListItem/BrandDataList.dart';
import 'package:treva_shop_flutter/ListItem/FlashSaleItem.dart';
import 'package:treva_shop_flutter/ListItem/GiftBaskets.dart';
import 'package:treva_shop_flutter/ListItem/category.dart';
import 'package:treva_shop_flutter/UI/BrandUIComponent/Chat.dart';
import 'package:treva_shop_flutter/UI/HomeUIComponent/DetailProduct.dart';
import 'package:treva_shop_flutter/UI/HomeUIComponent/Home.dart';
import 'package:treva_shop_flutter/Utils/backgroud_utils.dart';
import 'package:treva_shop_flutter/Utils/colors.dart';
import 'package:treva_shop_flutter/Utils/general.dart';

class brandDetail extends StatefulWidget {
  @override

  /// Get data from BrandDataList.dart (List Item)
  /// Declare class
  final Category subCat;
  final List<Products> all_products;
  brandDetail(this.subCat, this.all_products);

  _brandDetailState createState() => _brandDetailState(subCat);
}

class _brandDetailState extends State<brandDetail> {
  /// set key for bottom sheet
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();

  List<Products> products = new List();

  /// Get data from BrandDataList.dart (List Item)
  /// Declare class
  final Category subCat;
  _brandDetailState(this.subCat);
  String notif = "Notifications";

  /// https://firebasestorage.googleapis.com/v0/b/beauty-look.appspot.com/o/Artboard%203.png?alt=media&token=dc7f4bf5-8f80-4f38-bb63-87aed9d59b95

  /// Custom text header for bottomSheet
  final _fontCostumSheetBotomHeader = TextStyle(
      fontFamily: "Berlin",
      color: Colors.black54,
      fontWeight: FontWeight.w600,
      fontSize: 16.0);

  /// Custom text for bottomSheet
  final _fontCostumSheetBotom = TextStyle(
      fontFamily: "Sans",
      color: Colors.black45,
      fontWeight: FontWeight.w400,
      fontSize: 16.0);

  /// Create Modal BottomSheet (SortBy)
  void _modalBottomSheetSort() {
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return SingleChildScrollView(
            child: new Container(
              height: 350.0,
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(padding: EdgeInsets.only(top: 20.0)),
                  Text("SORT BY", style: _fontCostumSheetBotomHeader),
                  Padding(padding: EdgeInsets.only(top: 20.0)),
                  Container(
                    width: 500.0,
                    color: Colors.black26,
                    height: 0.5,
                  ),
                  Padding(padding: EdgeInsets.only(top: 25.0)),
                  InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) => new Menu()));
                      },
                      child: Text(
                        "Popularity",
                        style: _fontCostumSheetBotom,
                      )),
                  Padding(padding: EdgeInsets.only(top: 25.0)),
                  Text(
                    "New",
                    style: _fontCostumSheetBotom,
                  ),
                  Padding(padding: EdgeInsets.only(top: 25.0)),
                  Text(
                    "Discount",
                    style: _fontCostumSheetBotom,
                  ),
                  Padding(padding: EdgeInsets.only(top: 25.0)),
                  Text(
                    "Price: High-Low",
                    style: _fontCostumSheetBotom,
                  ),
                  Padding(padding: EdgeInsets.only(top: 25.0)),
                  Text(
                    "Price: Log-High",
                    style: _fontCostumSheetBotom,
                  ),
                  Padding(padding: EdgeInsets.only(top: 25.0)),
                ],
              ),
            ),
          );
        });
  }

  /// Create Modal BottomSheet (RefineBy)
  void _modalBottomSheetRefine() {
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return SingleChildScrollView(
            child: new Container(
              height: 350.0,
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(padding: EdgeInsets.only(top: 20.0)),
                  Text("REFINE BY", style: _fontCostumSheetBotomHeader),
                  Padding(padding: EdgeInsets.only(top: 20.0)),
                  Container(
                    width: 500.0,
                    color: Colors.black26,
                    height: 0.5,
                  ),
                  Padding(padding: EdgeInsets.only(top: 25.0)),
                  InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) => new Menu()));
                      },
                      child: Text(
                        "Popularity",
                        style: _fontCostumSheetBotom,
                      )),
                  Padding(padding: EdgeInsets.only(top: 25.0)),
                  Text(
                    "New",
                    style: _fontCostumSheetBotom,
                  ),
                  Padding(padding: EdgeInsets.only(top: 25.0)),
                  Text(
                    "Discount",
                    style: _fontCostumSheetBotom,
                  ),
                  Padding(padding: EdgeInsets.only(top: 25.0)),
                  Text(
                    "Price: High-Low",
                    style: _fontCostumSheetBotom,
                  ),
                  Padding(padding: EdgeInsets.only(top: 25.0)),
                  Text(
                    "Price: Log-High",
                    style: _fontCostumSheetBotom,
                  ),
                  Padding(padding: EdgeInsets.only(top: 25.0)),
                ],
              ),
            ),
          );
        });
  }

  bool _inAsyncCall = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      _inAsyncCall = true;
    });
    widget.all_products.forEach((p){
      List<String> cats = p.category.split(',');
      if(cats.contains(subCat.id)){
        setState(() {
          products.add(p);
        });
      }
    });
    setState(() {
      _inAsyncCall = false;
    });
//    new Utils().getProductsByCategoryID(subCat.id).then((p) {
//      if (!mounted) return;
//      setState(() {
//        products = p;
//        print(p);
//        _inAsyncCall = false;
//      });
//      new Timer(Duration(milliseconds: 500), (){
//        setState(() {
//          products = p;
//          print(p);
//        });
//      });
//    });
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);

    /// Hero animation for image
    final hero = Hero(
      tag: 'hero-tag-${subCat.id}',
      child: new DecoratedBox(
        decoration: new BoxDecoration(
          image: new DecorationImage(
            fit: BoxFit.cover,
            image: new NetworkImage(subCat.image),
          ),
          shape: BoxShape.rectangle,
        ),
        child: Container(
          margin: EdgeInsets.only(top: 130.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: <Color>[
                  new Color(0x00FFFFFF),
                  new Color(0xFFFFFFFF),
                ],
                stops: [
                  0.0,
                  1.0
                ],
                begin: FractionalOffset(0.0, 0.0),
                end: FractionalOffset(0.0, 1.0)),
          ),
        ),
      ),
    );

    String getProductPrice(Products pro) {
      return new GeneralUtils().currencyFormattedMoney(pro.price);
    }

    ///  Grid item in bottom of Category
    var Grid = SingleChildScrollView(
      child: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            /// To set GridView item
            (products.length > 0)
                ? GridView.count(
                    shrinkWrap: true,
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 17.0,
                    childAspectRatio: 0.545,
                    crossAxisCount: 2,
                    primary: false,
                    children: products
                        .map((pro) =>
                            ItemGrid(products, pro, getProductPrice(pro)))
                        .toList(),
                  )
                : _loadingImageAnimation(
                    context) //products.map((pro) => ItemGrid(pro))
          ],
        ),
      ),
    );

    return Scaffold(
        key: _key,
        body: ModalProgressHUD(
          opacity: 0.3,
          inAsyncCall: _inAsyncCall,
          progressIndicator: CircularProgressIndicator(),
          color: Color(MyColors.button_text_color),
          child: CustomScrollView(
            scrollDirection: Axis.vertical,
            slivers: <Widget>[
              /// Appbar Custom using a SliverAppBar
              SliverAppBar(
                centerTitle: true,
                backgroundColor: Colors.white,
                iconTheme: IconThemeData(color: Colors.black),
                expandedHeight: 380.0,
                elevation: 0.1,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Text(
                      subCat.name,
                      style: TextStyle(
                          color: Colors.black54,
                          fontSize: 17.0,
                          fontFamily: "Popins",
                          fontWeight: FontWeight.w700),
                    ),
                    background: Material(
                      child: hero,
                    )),
              ),

              /// Container for description to Sort and Refine
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                              top: 0.0, left: 0.0, right: 0.0, bottom: 0.0),
                          child: Container(
                            height: 100.0,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4.0)),
                              color: Colors.white,
                            ),
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 30.0, left: 20.0, right: 20.0),
                                  child: Text(
                                    subCat.description,
                                    style: TextStyle(
                                        fontFamily: "Popins",
                                        fontWeight: FontWeight.w400,
                                        fontSize: 15.0,
                                        color: Colors.black54),
                                  ),
                                ),
                                Padding(padding: EdgeInsets.only(top: 40.0)),
//                            buttonCustom(
//                              color: Colors.blue,
//                              txt: "Message",
//                              ontap: () {
//                                Navigator.of(context).push(PageRouteBuilder(
//                                    pageBuilder: (_, __, ___) =>
//                                        new privatemessage(brand)));
//                              },
//                            ),
//                            Padding(padding: EdgeInsets.only(top: 10.0)),
//                            buttonCustom(
//                              color: Colors.indigoAccent,
//                              txt: notif,
//                              ontap: () {
//                                var snackBar = SnackBar(
//                                  content: Text(subCat.name + " Notificated"),
//                                  action: SnackBarAction(
//                                      label: "Undo",
//                                      onPressed: () {
//                                        setState(() {
//                                          if (notif == "Notifications") {
//                                            notif = "Notificated";
//                                          } else {
//                                            (notif = "Notifications");
//                                          }});
//                                      }),
//                                );
//                                setState(() {
//                                  if (notif == "Notifications") {
//                                    notif = "Notificated";
//                                  } else {
//                                    (notif = "Notifications");
//                                  }});
//                                _key.currentState.showSnackBar(snackBar);
//                              },
//                            )
                              ],
                            ),
                          ),
                        ),
                        Padding(padding: EdgeInsets.only(top: 15.0)),
//                    Container(
//                      height: 50.9,
//                      decoration: BoxDecoration(
//                        color: Colors.white,
//                        boxShadow: [
//                          BoxShadow(
//                              color: Colors.black12.withOpacity(0.1),
//                              blurRadius: 1.0,
//                              spreadRadius: 1.0),
//                        ],
//                      ),
//                      child: Row(
//                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                        children: <Widget>[
//                          InkWell(
//                            onTap: _modalBottomSheetSort,
//                            child: Row(
//                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                              children: <Widget>[
//                                Icon(Icons.arrow_drop_down),
//                                Padding(padding: EdgeInsets.only(right: 10.0)),
//                                Text(
//                                  "Sort",
//                                  style: _fontCostumSheetBotomHeader,
//                                ),
//                              ],
//                            ),
//                          ),
//                          Row(
//                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                            children: <Widget>[
//                              Container(
//                                height: 45.9,
//                                width: 1.0,
//                                decoration:
//                                    BoxDecoration(color: Colors.black12),
//                              )
//                            ],
//                          ),
//                          InkWell(
//                            onTap: _modalBottomSheetRefine,
//                            child: Row(
//                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                              children: <Widget>[
//                                Icon(Icons.arrow_drop_down),
//                                Padding(padding: EdgeInsets.only(right: 0.0)),
//                                Text(
//                                  "Refine",
//                                  style: _fontCostumSheetBotomHeader,
//                                ),
//                              ],
//                            ),
//                          ),
//                        ],
//                      ),
//                    ),
                      ],
                    ),
                  ),
                ),
              ),

              /// Create Grid Item
//          SliverGrid(
//            delegate: SliverChildBuilderDelegate(
//              (BuildContext context, int index) {
//                return Container(
//                  decoration: BoxDecoration(
//                      color: Colors.white,
//                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
//                      boxShadow: [
//                        BoxShadow(
//                          color: Color(0xFF656565).withOpacity(0.15),
//                          blurRadius: 4.0,
//                          spreadRadius: 1.0,
//                        )
//                      ]),
//                  child: Wrap(
//                    children: <Widget>[
//                      Column(
//                        crossAxisAlignment: CrossAxisAlignment.start,
//                        mainAxisAlignment: MainAxisAlignment.spaceAround,
//                        mainAxisSize: MainAxisSize.min,
//                        children: <Widget>[
//                          Container(
//                            height: mediaQueryData.size.height / 3.5,
//                            width: 200.0,
//                            decoration: BoxDecoration(
//                                borderRadius: BorderRadius.only(
//                                    topLeft: Radius.circular(7.0),
//                                    topRight: Radius.circular(7.0)),
//                                image: DecorationImage(
//                                    image: NetworkImage(''),//here
//                                    fit: BoxFit.cover)),
//                          ),
//                          Padding(padding: EdgeInsets.only(top: 7.0)),
//                          Padding(
//                            padding:
//                                const EdgeInsets.only(left: 15.0, right: 15.0),
//                            child: Text(
//                              '',//here
//                              style: TextStyle(
//                                  letterSpacing: 0.5,
//                                  color: Colors.black54,
//                                  fontFamily: "Sans",
//                                  fontWeight: FontWeight.w500,
//                                  fontSize: 13.0),
//                              overflow: TextOverflow.ellipsis,
//                            ),
//                          ),
//                          Padding(padding: EdgeInsets.only(top: 1.0)),
//                          Padding(
//                            padding:
//                                const EdgeInsets.only(left: 15.0, right: 15.0),
//                            child: Text(
//                              '',//here
//                              style: TextStyle(
//                                  fontFamily: "Sans",
//                                  fontWeight: FontWeight.w500,
//                                  fontSize: 14.0),
//                            ),
//                          ),
//                          Padding(
//                            padding: const EdgeInsets.only(
//                                left: 15.0, right: 15.0, top: 5.0),
//                            child: Row(
//                              crossAxisAlignment: CrossAxisAlignment.start,
//                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                              children: <Widget>[
//                                Row(
//                                  children: <Widget>[
//                                    Text(
//                                      '',//here
//                                      style: TextStyle(
//                                          fontFamily: "Sans",
//                                          color: Colors.black26,
//                                          fontWeight: FontWeight.w500,
//                                          fontSize: 12.0),
//                                    ),
//                                    Icon(
//                                      Icons.star,
//                                      color: Colors.yellow,
//                                      size: 14.0,
//                                    )
//                                  ],
//                                ),
//                                Text(
//                                  '',//here
//                                  style: TextStyle(
//                                      fontFamily: "Sans",
//                                      color: Colors.black26,
//                                      fontWeight: FontWeight.w500,
//                                      fontSize: 12.0),
//                                )
//                              ],
//                            ),
//                          ),
//                        ],
//                      ),
//                    ],
//                  ),
//                );
//              },
//              childCount: 20,
//            ),
//            /// Setting Size for Grid Item
//            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
//              maxCrossAxisExtent: 250.0,
//              mainAxisSpacing: 7.0,
//              crossAxisSpacing: 7.0,
//              childAspectRatio: 0.605,
//            ),
//          ),

              SliverGrid(
                delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                  return ItemGrid(products, products[index],
                      getProductPrice(products[index]));
                }, childCount: products.length),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 250.0,
                  mainAxisSpacing: 7.0,
                  crossAxisSpacing: 7.0,
                  childAspectRatio: 0.605,
                ),
              ),

              //Grid
            ],
          ),
        ));
  }
}

/// ItemGrid in bottom item "Recommended" item
class ItemGrid extends StatelessWidget {
  /// Get data from HomeGridItem.....dart class
  Products gridItem;
  List<Products> all_products;
  String price;
  ItemGrid(this.all_products, this.gridItem, this.price);

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            PageRouteBuilder(
                pageBuilder: (_, __, ___) =>
                    new detailProduk(all_products, gridItem),
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
                /// Set Animation image to detailProduk layout
                Hero(
                  tag: "hero-grid-${gridItem.id}",
                  child: Material(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            PageRouteBuilder(
                                opaque: false,
                                pageBuilder: (BuildContext context, _, __) {
                                  return new Material(
                                    color: Colors.black54,
                                    child: Container(
                                      padding: EdgeInsets.all(30.0),
                                      child: InkWell(
                                        child: Hero(
                                            tag: "hero-grid-${gridItem.id}",
                                            child: Image.network(
                                              gridItem.pictures[0],
                                              width: 300.0,
                                              height: 300.0,
                                              alignment: Alignment.center,
                                              fit: BoxFit.contain,
                                            )),
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ),
                                  );
                                },
                                transitionDuration:
                                    Duration(milliseconds: 500)));
                      },
                      child: Container(
                        height: mediaQueryData.size.height / 3.3,
                        width: 200.0,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(7.0),
                                topRight: Radius.circular(7.0)),
                            image: DecorationImage(
                                image: NetworkImage(gridItem.pictures[0]),
                                fit: BoxFit.cover)),
                      ),
                    ),
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 7.0)),
                Padding(
                  padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                  child: Text(
                    gridItem.name,
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
                            '${gridItem.ratingValue}',
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
                        '${gridItem.stock} in stock',
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

class loadingItemGrid extends StatelessWidget {
  @override
  SaleItem itemSale;
  loadingItemGrid(this.itemSale);
  final color = Colors.black38;
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(color: Colors.white, boxShadow: [
                BoxShadow(
                    color: Colors.black12.withOpacity(0.1),
                    spreadRadius: 0.2,
                    blurRadius: 0.5)
              ]),
              child: Shimmer.fromColors(
                baseColor: color,
                highlightColor: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: 140.0,
                      width: mediaQueryData.size.width / 2.1,
                      color: Colors.black12,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10.0, top: 10.0),
                      child: Container(
                        height: 15.0,
                        width: mediaQueryData.size.width / 2.6,
                        color: Colors.black12,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10.0, top: 8.0),
                      child: Container(
                        height: 10.0,
                        width: mediaQueryData.size.width / 4.1,
                        color: Colors.black12,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10.0, top: 10.0),
                      child: Container(
                        height: 8.0,
                        width: mediaQueryData.size.width / 6.0,
                        color: Colors.black12,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0, top: 10.0),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.star,
                            size: 11.0,
                            color: Colors.black12,
                          ),
                          Icon(
                            Icons.star,
                            size: 11.0,
                            color: Colors.black12,
                          ),
                          Icon(
                            Icons.star,
                            size: 11.0,
                            color: Colors.black12,
                          ),
                          Icon(
                            Icons.star,
                            size: 11.0,
                            color: Colors.black12,
                          ),
                          Icon(
                            Icons.star,
                            size: 11.0,
                            color: Colors.black12,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0, top: 10.0),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.location_on,
                            size: 13.0,
                            color: Colors.black38,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: Container(
                              height: 6.0,
                              width: mediaQueryData.size.width / 5.5,
                              color: Colors.black12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 24.0, left: 10.0, bottom: 15.0),
                      child: Container(
                        height: 7.0,
                        width: mediaQueryData.size.width / 2.5,
                        decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius:
                                BorderRadius.all(Radius.circular(4.0)),
                            shape: BoxShape.rectangle),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        )
      ],
    );
  }
}

Widget _loadingImageAnimation(BuildContext context) {
  MediaQueryData mediaQueryData = MediaQuery.of(context);
  return GridView.count(
    crossAxisCount: 2,
    shrinkWrap: true,
    childAspectRatio: mediaQueryData.size.height / 1300,
    crossAxisSpacing: 0.0,
    mainAxisSpacing: 0.0,
    primary: false,
    children: List.generate(
      /// Get data in flashSaleItem.dart (ListItem folder)
      flashData.length,
      (index) => loadingItemGrid(flashData[index]),
    ),
  );
}

/// Class For Botton Custom
class buttonCustom extends StatelessWidget {
  String txt;
  Color color;
  GestureTapCallback ontap;

  buttonCustom({this.txt, this.color, this.ontap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ontap,
      child: Container(
        height: 45.0,
        width: 300.0,
        decoration: BoxDecoration(
          color: color,
        ),
        child: Center(
            child: Text(
          txt,
          style: TextStyle(color: Colors.white, fontFamily: "Sans"),
        )),
      ),
    );
  }
}
