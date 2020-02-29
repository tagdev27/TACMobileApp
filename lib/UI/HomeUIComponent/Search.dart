import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:treva_shop_flutter/ListItem/GiftBaskets.dart';
import 'package:treva_shop_flutter/UI/HomeUIComponent/DetailProduct.dart';
import 'package:treva_shop_flutter/UI/HomeUIComponent/PromotionDetail.dart';
import 'package:treva_shop_flutter/Utils/backgroud_utils.dart';
import 'package:treva_shop_flutter/Utils/colors.dart';
import 'package:treva_shop_flutter/Utils/general.dart';
import 'package:treva_shop_flutter/Utils/storage.dart';

class searchAppbar extends StatefulWidget {
  List<Products> products;
  searchAppbar(this.products);

  @override
  _searchAppbarState createState() => _searchAppbarState();
}

class _searchAppbarState extends State<searchAppbar> {
  StorageSystem ss = new StorageSystem();
  String fn = "";

  void getUser() {
    if (ss.getItem("user") != '') {
      Map<String, dynamic> user = json.decode(ss.getItem("user"));
      if (!mounted) return;
      setState(() {
        fn = '${user['fn']}'.toLowerCase();
      });
    } else {
      setState(() {
        fn = '';
      });
    }
  }

  final _random = new Random();

  bool _inAsyncCall = false;

  final _controller = new TextEditingController(text: '');

  List<Products> searchedProducts = new List();

  /// Sentence Text header "Hello i am Treva.........."
//  var _textHello = Padding(
//    padding: const EdgeInsets.only(right: 50.0, left: 20.0),
//    child: Text(
//      "Hello $fn, What would you like to search for?",
//      style: TextStyle(
//          letterSpacing: 0.1,
//          fontWeight: FontWeight.w600,
//          fontSize: 27.0,
//          color: Colors.black54,
//          fontFamily: "Gotik"),
//    ),
//  );

  Widget textHello() {
    return Padding(
      padding: const EdgeInsets.only(right: 50.0, left: 20.0),
      child: Text(
        "Hello $fn, What would you like to gift?",
        style: TextStyle(
            letterSpacing: 0.1,
            fontWeight: FontWeight.w600,
            fontSize: 27.0,
            color: Colors.black54,
            fontFamily: "Gotik"),
      ),
    );
  }

  //search database for products
  searchDb(String q) {
    String query = q;
    if (q.split(' ').length > 1) {
      query = q.split(' ')[0];
    }

    searchedProducts.clear();
    setState(() {
      _inAsyncCall = true;
    });

    String result = ""; //to determine if there's a result
    String subcategory_id = ""; //for sub category search

    //search through products first
    widget.products.forEach((p) {
      if (p.name.toLowerCase().contains(query.toLowerCase())) {
        result = "something";
        if (!mounted) return;
        setState(() {
          searchedProducts.add(p);
        });
      }
    });

    if (result.isEmpty) {
      //compare from sub categories
      new Utils().getCategories().then((category) async {
        category.forEach((c) {
          if (c.meta.toLowerCase().contains(query.toLowerCase()) ||
              c.name.toLowerCase().contains(query.toLowerCase()) ||
              c.description.toLowerCase().contains(query.toLowerCase())) {
            subcategory_id = c.id;
          }
        });
        if (subcategory_id.isEmpty) {
          setState(() {
            _inAsyncCall = false;
          });
          new GeneralUtils().neverSatisfied(context, 'Search Result',
              'No item found. Please try with other keywords.');
        } else {
          widget.products.forEach((p) {
            List<String> cats = p.category.split(',');
            if (cats.contains(subcategory_id)) {
              if (!mounted) return;
              setState(() {
                searchedProducts.add(p);
              });
            }
          });
//          final p = await new Utils().getProductsByCategoryID(subcategory_id);
          if (!mounted) return;
          setState(() {
//            searchedProducts = p;
            _inAsyncCall = false;
          });
//            new Timer(Duration(milliseconds: 1500), (){
//              setState(() {
//                searchedProducts = p;
//              });
//            });
        }
      });
    } else {
      setState(() {
        _inAsyncCall = false;
      });
    }
  }

  var _customTextStyleBlue = TextStyle(
      fontFamily: "Gotik",
      color: Color(0xFFEC008C),
      fontWeight: FontWeight.w700,
      fontSize: 15.0);

  /// Item TextFromField Search
  Widget _search() {
    return Padding(
      padding: const EdgeInsets.only(top: 35.0, right: 20.0, left: 20.0),
      child: Container(
        height: 50.0,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15.0,
                  spreadRadius: 0.0)
            ]),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 10.0),
            child: Theme(
              data: ThemeData(hintColor: Colors.transparent),
              child: TextFormField(
                controller: _controller,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    icon: Icon(
                      Icons.search,
                      color: Color(MyColors.primary_color),
                      size: 28.0,
                    ),
                    suffixIcon: IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          if (_controller.text.length == 0) return;
                          setState(() {
                            _controller.clear();
                          });
                        }),
                    hintText: "Find what you want",
                    hintStyle: TextStyle(
                        color: Colors.black54,
                        fontFamily: "Gotik",
                        fontWeight: FontWeight.w400)),
                textInputAction: TextInputAction.search,
                onFieldSubmitted: (searchValue) {
                  if (searchValue.isNotEmpty) {
                    searchDb(searchValue);
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Item Favorite Item with Card item
  Widget searchResult() {
    List<Widget> resultWidget = new List();
    searchedProducts.forEach((p) {
      resultWidget.add(
        Padding(padding: EdgeInsets.only(left: 20.0)),
      );
      resultWidget.add(
        FavoriteItem(
          all_products: widget.products,
          gridItem: p,
          image: p.pictures[0],
          title: p.name,
          Salary: new GeneralUtils().currencyFormattedMoney(p.price),
          Rating: '${p.ratingValue}',
          sale: '',//'${p.stock} in stock',
        ),
      );
    });
    resultWidget.add(
      Padding(padding: EdgeInsets.only(right: 10.0)),
    );

    return Padding(
      padding: const EdgeInsets.only(top: 30.0),
      child: Container(
        height: 250.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Text(
                    "Search Results",
                    style:
                        TextStyle(fontFamily: "Gotik", color: Colors.black26),
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.only(left: 0.0, top: 0.0),
                    child: FlatButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              PageRouteBuilder(
                                  pageBuilder: (_, __, ___) =>
                                      new promoDetail(searchedProducts)));
                        },
                        child: Text(
                          "See More",
                          style: _customTextStyleBlue,
                        ))),
              ],
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(top: 20.0, bottom: 2.0),
                scrollDirection: Axis.horizontal,
                children: resultWidget,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Popular Keyword Item
  var _sugestedText = Container(
    height: 160.0,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 20.0, top: 20.0),
          child: Text(
            "Populer Keyword",
            style: TextStyle(fontFamily: "Gotik", color: Colors.black26),
          ),
        ),
        Padding(padding: EdgeInsets.only(top: 20.0)),
        Expanded(
            child: ListView(
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            Padding(padding: EdgeInsets.only(left: 20.0)),
            KeywordItem(
              title: "Iphone X",
              title2: "Mackbook",
            ),
            KeywordItem(
              title: "Samsung",
              title2: "Apple",
            ),
            KeywordItem(
              title: "Note 9",
              title2: "Nevada",
            ),
            KeywordItem(
              title: "Watch",
              title2: "PC",
            ),
          ],
        ))
      ],
    ),
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
  }

  /// Item Favorite Item with Card item
  Widget _favorite() {
    final p = widget.products;
    if(p.length < 4){
      return Text('');
    }
    List<int> indexes = new List();

    for (int i = 0; i < 5; i++) {
      indexes.add(_random.nextInt(p.length - 1));
    }

    return Padding(
      padding: const EdgeInsets.only(top: 30.0),
      child: Container(
        height: 250.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Text(
                "Suggested",
                style: TextStyle(fontFamily: "Gotik", color: Colors.black26),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(top: 20.0, bottom: 2.0),
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  /// Get class FavoriteItem
                  Padding(padding: EdgeInsets.only(left: 20.0)),
                  FavoriteItem(
                    all_products: p,
                    gridItem: p[indexes[0]],
                    image: p[indexes[0]].pictures[0],
                    title: p[indexes[0]].name,
                    Salary: new GeneralUtils()
                        .currencyFormattedMoney(p[indexes[0]].price),
                    Rating: '${p[indexes[0]].ratingValue}',
                    sale: '',//'${p[indexes[0]].stock} in stock',
                  ),
                  Padding(padding: EdgeInsets.only(left: 20.0)),
                  FavoriteItem(
                    all_products: p,
                    gridItem: p[indexes[1]],
                    image: p[indexes[1]].pictures[0],
                    title: p[indexes[1]].name,
                    Salary: new GeneralUtils()
                        .currencyFormattedMoney(p[indexes[1]].price),
                    Rating: '${p[indexes[1]].ratingValue}',
                    sale: '',//'${p[indexes[1]].stock} in stock',
                  ),
                  Padding(padding: EdgeInsets.only(left: 20.0)),
                  FavoriteItem(
                    all_products: p,
                    gridItem: p[indexes[2]],
                    image: p[indexes[2]].pictures[0],
                    title: p[indexes[2]].name,
                    Salary: new GeneralUtils()
                        .currencyFormattedMoney(p[indexes[2]].price),
                    Rating: '${p[indexes[2]].ratingValue}',
                    sale: '',//'${p[indexes[2]].stock} in stock',
                  ),
                  Padding(padding: EdgeInsets.only(left: 20.0)),
                  FavoriteItem(
                    all_products: p,
                    gridItem: p[indexes[3]],
                    image: p[indexes[3]].pictures[0],
                    title: p[indexes[3]].name,
                    Salary: new GeneralUtils()
                        .currencyFormattedMoney(p[indexes[3]].price),
                    Rating: '${p[indexes[3]].ratingValue}',
                    sale: '',//'${p[indexes[3]].stock} in stock',
                  ),
                  Padding(padding: EdgeInsets.only(left: 20.0)),
                  FavoriteItem(
                    all_products: p,
                    gridItem: p[indexes[4]],
                    image: p[indexes[4]].pictures[0],
                    title: p[indexes[4]].name,
                    Salary: new GeneralUtils()
                        .currencyFormattedMoney(p[indexes[4]].price),
                    Rating: '${p[indexes[4]].ratingValue}',
                    sale: '',//'${p[indexes[4]].stock} in stock',
                  ),
                  Padding(padding: EdgeInsets.only(right: 10.0)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Color(MyColors.primary_color),
          ),
          title: Text(
            "Search",
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18.0,
                color: Colors.black54,
                fontFamily: "Gotik"),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0.0,
        ),
        body: ModalProgressHUD(
          opacity: 0.3,
          inAsyncCall: _inAsyncCall,
          progressIndicator: CircularProgressIndicator(),
          color: Color(MyColors.button_text_color),
          child: SingleChildScrollView(
            child: Container(
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.only(top: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    /// Caliing a variable
                    textHello(),
                    _search(),
                    (searchedProducts.isNotEmpty) ? searchResult() : Text(''),
//                _sugestedText,
                    _favorite(),
                    Padding(padding: EdgeInsets.only(bottom: 50.0, top: 2.0))
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}

/// Popular Keyword Item class
class KeywordItem extends StatelessWidget {
  @override
  String title, title2;
  GestureTapCallback tap, tap2;

  KeywordItem({this.tap, this.title, this.tap2, this.title2});

  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 4.0, left: 3.0),
          child: (title.isNotEmpty)
              ? Container(
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4.5,
                        spreadRadius: 1.0,
                      )
                    ],
                  ),
                  child: InkWell(
                      onTap: tap,
                      child: Center(
                        child: Text(
                          title,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.black54, fontFamily: "Sans"),
                        ),
                      )),
                )
              : Text(''),
        ),
        Padding(padding: EdgeInsets.only(top: 15.0)),
        (title2.isNotEmpty)
            ? Container(
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4.5,
                      spreadRadius: 1.0,
                    )
                  ],
                ),
                child: InkWell(
                  onTap: tap2,
                  child: Center(
                    child: Text(
                      title2,
                      style: TextStyle(
                        color: Colors.black54,
                        fontFamily: "Sans",
                      ),
                    ),
                  ),
                ))
            : Text(''),
      ],
    );
  }
}

///Favorite Item Card
class FavoriteItem extends StatelessWidget {
  List<Products> all_products;
  Products gridItem;

  String image, Rating, Salary, title, sale;

  FavoriteItem(
      {this.all_products,
      this.gridItem,
      this.image,
      this.Rating,
      this.Salary,
      this.title,
      this.sale});

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 2.0),
      child: InkWell(
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
                    Container(
                      height: 120.0,
                      width: 150.0,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(7.0),
                              topRight: Radius.circular(7.0)),
                          image: DecorationImage(
                              image: NetworkImage(image), fit: BoxFit.cover)),
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
                      padding: const EdgeInsets.only(
                          left: 15.0, right: 15.0, top: 5.0),
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
          )),
    );
  }
}
