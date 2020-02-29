import 'dart:async';

import 'package:flutter/material.dart';
import 'package:treva_shop_flutter/ListItem/GiftBaskets.dart';
import 'package:treva_shop_flutter/ListItem/MenuItem.dart';
import 'package:treva_shop_flutter/ListItem/category.dart';
import 'package:treva_shop_flutter/UI/HomeUIComponent/DetailProduct.dart';
import 'package:treva_shop_flutter/UI/HomeUIComponent/PromotionDetail.dart';
import 'package:treva_shop_flutter/UI/HomeUIComponent/Search.dart';
import 'package:shimmer/shimmer.dart';
import 'package:treva_shop_flutter/Utils/backgroud_utils.dart';
import 'package:treva_shop_flutter/Utils/colors.dart';
import 'package:treva_shop_flutter/Utils/general.dart';
import 'package:treva_shop_flutter/Library/carousel_pro/carousel_pro.dart';

class menuDetail extends StatefulWidget {

  List<Products> products;
  String menu_id, menu_name, menu_image;
  menuDetail(this.products, this.menu_id, this.menu_name, this.menu_image);

  @override
  _menuDetailState createState() => _menuDetailState();
}

/// Component widget MenuDetail
class _menuDetailState extends State<menuDetail> {
  ///
  /// Get image data dummy from firebase server
  ///
  var imageNetwork = NetworkImage("https://firebasestorage.googleapis.com/v0/b/beauty-look.appspot.com/o/a.jpg?alt=media&token=e36bbee2-4bfb-4a94-bd53-4055d29358e2");

  static List<Products> products = new List();
  static List<Products> new_products = new List();
  static List<Products> discount_products = new List();
  static List<Products> popular_products = new List();

  static List<Category> subCategories = new List();

  bool start = false;

  ///
  /// check the condition is right or wrong for image loaded or no
  ///
  bool loadImage = true;

  /// Custom text
  static var _customTextStyleBlack = TextStyle(
      fontFamily: "Gotik",
      color: Colors.black,
      fontWeight: FontWeight.w700,
      fontSize: 15.0);

  /// Custom Text Blue Color
  static var _customTextStyleBlue = TextStyle(
      fontFamily: "Gotik",
      color: Color(MyColors.primary_color),
      fontWeight: FontWeight.w700,
      fontSize: 15.0);


  ///
  /// SetState after imageNetwork loaded to change list card
  ///
  @override
  void initState() {
    imageNetwork.resolve(new ImageConfiguration()).addListener(new ImageStreamListener((ImageInfo image, bool synchronousCall) { /*...*/
      if(mounted){
        setState(() {
          loadImage = false;
        });
      }
    }));
    // TODO: implement initState
    super.initState();
    getAllSubCategories();
    //startOperations();
  }

  void getAllSubCategories() async {
    final sub = await new Utils().getSubCategoriesFromMainCategoryID(widget.menu_id);
    subCategories.clear();
    setState(() {
      subCategories = sub;
    });
    Timer(Duration(milliseconds: 500), (){
      subCategories = sub;
    });
    if(sub.isNotEmpty) {
      startOperations(sub[0].id);
    }
  }

  Future<void> startOperations(String sub_category_id) async {
    //products.clear();
    new_products.clear();
    discount_products.clear();
    popular_products.clear();
    //get list of products
//    final pro = await new Utils().getProducts();
    final pro = widget.products;
    //print('pro ================================================================================== ${pro.length}');
    if(!mounted) return;
    setState(() {
      products = new Utils().getRelatedProducts(pro, sub_category_id);
    });
    new Timer(Duration(milliseconds: 500), (){
      if(!mounted) return;
      setState(() {
        products = new Utils().getRelatedProducts(pro, sub_category_id);
        start = true;
      });
    });
  }

  void filterAllProducts() {
    new_products.clear();
    discount_products.clear();
    popular_products.clear();
    products.forEach((pro){
      if(!mounted) return;
      if(pro.sale){
        setState(() {
          discount_products.add(pro);
        });
      }
      if(pro.is_new){
        setState(() {
          new_products.add(pro);
        });
      }
      if(!pro.sale){
        setState(() {
          popular_products.add(pro);
        });
      }
    });

//    setState(() {
//      start = false;
//    });
  }


  /// Category Component in bottom of flash sale dynamic value

  List<Widget> getSubCategoryButtons() {
    List<Widget> cate = new List();

    cate.add(Padding(padding: EdgeInsets.only(left: 20.0)));

    int index = 0;
    subCategories.forEach((cat) {

      cate.add(
        KeywordItem(
          title: (index == 0) ? subCategories[index].name : (index + 2) < subCategories.length ? subCategories[index + 2].name : '',
          tap: (){
            if(index == 0) {
              startOperations(subCategories[index].id);
            }else {
              if((index + 2) < subCategories.length){
                startOperations(subCategories[index + 2].id);//2 < 3
              }
            }
          },
          title2: ((index + 1) < subCategories.length) ? subCategories[index + 1].name : '',
          tap2: (){
            if((index + 1) < subCategories.length){
              startOperations(subCategories[index + 1].id);
            }
          },
        )
      );

      cate.add(Padding(padding: EdgeInsets.only(left: 15.0)));

      index = index + 1;
    });

    cate.add(Padding(padding: EdgeInsets.only(left: 20.0)));
    return cate;
  }

  @override
  Widget build(BuildContext context) {
    if(products.isNotEmpty){
        filterAllProducts();
        if(mounted) {
          Timer(Duration(milliseconds: 500), () {
            filterAllProducts();
          });
        }
    }
    /// Item first above "Week Promotion" with image Promotion
    var _promoHorizontalList = Container(
      color: Colors.white,
      height: 215.0,
      padding: EdgeInsets.only(bottom: 40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
              padding: EdgeInsets.only(left: 20.0, top: 10.0, bottom: 3.0),
              child: Text("Week Promotion", style: _customTextStyleBlack)),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.only(top: 10.0),
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                /// Call itemPopular Class
                Padding(padding: EdgeInsets.only(left: 20.0)),
                itemPopular(
                  image: "assets/imgCamera/CameraDigital.png",
                  title: "Camera \n Digital",
                ),
                Padding(padding: EdgeInsets.only(left: 10.0)),
                itemPopular(
                  image: "assets/imgCamera/CompactCamera.png",
                  title: "Compact \n Camera",
                ),
                Padding(padding: EdgeInsets.only(left: 10.0)),
                itemPopular(
                  image: "assets/imgCamera/ActionCamera.png",
                  title: "Action \n Camera",
                ),
                Padding(padding: EdgeInsets.only(left: 5.0)),
              ],
            ),
          ),
        ],
      ),
    );

    /// imageSlider in header layout category detail
    var _imageSlider = Padding(
      padding: const EdgeInsets.only(
          top: 0.0, left: 10.0, right: 10.0, bottom: 35.0),
      child: Container(
        height: 180.0,
        child: new Carousel(
          boxFit: BoxFit.cover,
          dotColor: Colors.transparent,
          dotSize: 5.5,
          dotSpacing: 16.0,
          dotBgColor: Colors.transparent,
          showIndicator: false,
          overlayShadow: false,
          overlayShadowColors: Colors.white.withOpacity(0.9),
          overlayShadowSize: 0.9,
          images: [
            NetworkImage(widget.menu_image),
//            AssetImage("assets/img/bannerMan2.png"),
//            AssetImage("assets/img/bannerMan3.png"),
//            AssetImage("assets/img/bannerMan4.png"),
          ],
        ),
      ),
    );

    /// SubCategory item
    var _subCategory = Container(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 20.0, left: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Sub Category",
                  style: _customTextStyleBlack,
                ),
                InkWell(
                  onTap: null,
                  child: Text("", style: _customTextStyleBlue),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            child: Container(
              color: Colors.white,
              margin: EdgeInsets.only(right: 10.0, top: 15.0),
              height: 110.0,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: getSubCategoryButtons(),
              ),
            ),
          )
        ],
      ),
    );

//    <Widget>[
//      /// Get keyword item class in Search.dart
//      Padding(padding: EdgeInsets.only(left: 20.0)),
//      KeywordItem(
//        tap: (){
//          new GeneralUtils().neverSatisfied(context, 'hello', 'world');
//        },
//        title: "Action",
//        title2: "Drone",
//      ),
//      Padding(padding: EdgeInsets.only(left: 15.0)),
//      KeywordItem(
//        title: "Digital",
//        title2: "Handycam",
//      ),
//      Padding(padding: EdgeInsets.only(left: 15.0)),
//      KeywordItem(
//        title: "Analog",
//        title2: "CCTV",
//      ),
//      Padding(padding: EdgeInsets.only(left: 15.0)),
//      KeywordItem(
//        title: "Spy Cam",
//        title2: "Acesoris",
//      ),
//      Padding(padding: EdgeInsets.only(right: 20.0)),
//    ]

    /// Item Discount
    var _itemDiscount = Container(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Item Discount",
                  style: _customTextStyleBlack,
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(PageRouteBuilder(
                        pageBuilder: (_, __, ___) => new promoDetail(discount_products)));////////////////////////////coming back./////////////////////////////////////////
                  },
                  child: Text("See More", style: _customTextStyleBlue),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.only(right: 10.0),
              height: 300.0,
              ///
              ///
              /// check the condition if image data from server firebase loaded or no
              /// if image true (image still downloading from server)
              /// Card to set card loading animation
              ///
              ///
              child: loadImage? _loadingImageAnimation(context):
              ListView.builder(
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, int index)=>menuItemCard(products, discount_products[index]),
                itemCount: discount_products.length,
              ),
            ),
          )
        ],
      ),
    );

    /// Item Popular
    var _itemPopular = Padding(
      padding: const EdgeInsets.only(top: 30.0),
      child: Container(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 20.0, left: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "Item Popular",
                    style: _customTextStyleBlack,
                  ),
                  InkWell(
                    onTap: (){
                      Navigator.of(context).push(PageRouteBuilder(
                          pageBuilder: (_, __, ___) => new promoDetail(popular_products)));
                    },
                    child: Text("See More", style: _customTextStyleBlue),
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.only(right: 10.0),
                height: 300.0,
                child: loadImage? _loadingImageAnimation(context):
                ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (BuildContext context, int index)=>menuItemCard(products, popular_products[index]),
                  itemCount: popular_products.length,
                ),
              ),
            )
          ],
        ),
      ),
    );

    /// Item New
    var _itemNew = Padding(
      padding: const EdgeInsets.only(top: 30.0),
      child: Container(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 20.0, left: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "New Items",
                    style: _customTextStyleBlack,
                  ),
                  InkWell(
                    onTap: (){
                      Navigator.of(context).push(PageRouteBuilder(
                          pageBuilder: (_, __, ___) => new promoDetail(new_products)));
                    },
                    child: Text("See More", style: _customTextStyleBlue),
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.only(right: 10.0, bottom: 15.0),
                height: 300.0,
                ///
                ///
                /// check the condition if image data from server firebase loaded or no
                /// if image true (image still downloading from server)
                /// Card to set card loading animation
                ///
                ///
                child: loadImage? _loadingImageAnimation(context):
                ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (BuildContext context, int index)=>menuItemCard(products, new_products[index]),
                  itemCount: new_products.length,
                ),
              ),
            )
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          InkWell(
            onTap: () {
              Navigator.of(context).push(PageRouteBuilder(
                  pageBuilder: (_, __, ___) => new searchAppbar(widget.products)));
            },
            child: IconButton(
              onPressed: null,
              icon: Icon(Icons.search, color: Color(MyColors.primary_color)),
            ),
          ),
        ],
        centerTitle: true,
        title: Text(
          widget.menu_name,
          style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16.0,
              color: Colors.black54,
              fontFamily: "Gotik"),
        ),
        iconTheme: IconThemeData(
          color: Color(MyColors.primary_color),
        ),
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Column(
            children: <Widget>[
              /// Get a variable
//              _promoHorizontalList,
              _imageSlider,
              _subCategory,
              (new_products.length > 0) ? _itemNew : Text(''),
              (discount_products.length > 0) ? _itemDiscount : Text(''),
              (popular_products.length > 0) ? _itemPopular : Text(''),
            ],
          ),
        ),
      ),
    );
  }
}

///Item Popular component class
class itemPopular extends StatelessWidget {
  String image, title;

  itemPopular({this.image, this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
      ),
      child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            color: Colors.black.withOpacity(0.3),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 80.0, left: 10.0),
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontFamily: "Gotik",
                fontSize: 15.5,
                letterSpacing: 0.7,
                fontWeight: FontWeight.w600,
              ),
            ),
          )),
    );
  }
}

class menuItemCard extends StatelessWidget {

  Products item;
  List<Products> all_products;

  menuItemCard(this.all_products, this.item);

  String getProductPrice(Products pro) {
    return new GeneralUtils().currencyFormattedMoney(pro.price);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          top: 20.0, left: 10.0, bottom: 10.0, right: 0.0),
      child: InkWell(
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
              Container(
                width: 160.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        Container(
                          height: 185.0,
                          width: 160.0,
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
                              color: Color(MyColors.primary_color),
                              borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(20.0),
                                  topLeft: Radius.circular(5.0))),
                          child: Center(
                              child: Text(
                                "${item.discount}%",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600),
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
                        getProductPrice(item),
                        style: TextStyle(
                            fontFamily: "Sans",
                            fontWeight: FontWeight.w500,
                            fontSize: 14.0),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 15.0, right: 15.0, top: 5.0),
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
                            '',//'${item.stock} in stock',
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
              Shimmer.fromColors(
                baseColor: Colors.black38,
                highlightColor: Colors.white,
                child: Container(
                  width: 160.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          Container(
                            height: 185.0,
                            width: 160.0,
                            color: Colors.black12,
                          ),
                          Container(
                            height: 25.5,
                            width: 65.0,
                            decoration: BoxDecoration(
                                color: Color(MyColors.primary_color),
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
                            left: 15.0, right: 15.0, top: 15.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Text(
                                  "",
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
Widget _loadingImageAnimation(BuildContext context){
  return ListView.builder(
    scrollDirection: Axis.horizontal,
    itemBuilder: (BuildContext context, int index)=>loadingMenuItemCard(),
    itemCount: itemDiscount.length,
  );
}
