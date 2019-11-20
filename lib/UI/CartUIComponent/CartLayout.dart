import 'dart:async';

import 'package:flutter/material.dart';
import 'package:treva_shop_flutter/ListItem/CartItemData.dart';
import 'package:treva_shop_flutter/ListItem/GiftBaskets.dart';
import 'package:treva_shop_flutter/UI/CartUIComponent/Delivery.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:treva_shop_flutter/Utils/colors.dart';
import 'package:treva_shop_flutter/Utils/general.dart';

class cart extends StatefulWidget {
  @override
  _cartState createState() => _cartState();
}

class _cartState extends State<cart> {

  final List<cartItem> items = new List();

  @override
  void initState() {
    super.initState();
//    items.add(
//        cartItem(
//            img:'',
//            id: 45,
//            title:'name',
//            desc: 'shortDetails',
//            price: '200000',
//            quantity: 1
//        ));
    new GeneralUtils().getCartItems().forEach((cart){
      Map<String, dynamic> item = cart['product'];
      int quantity = cart['quantity'];
      setState(() {
        items.add(
          cartItem(
            img:item['pictures'][0],
            id: item['id'],
            title:item['name'],
            desc: item['shortDetails'],
            price: new GeneralUtils().currencyFormattedMoney(item['price']),
            quantity: quantity
          ),
        );
      });
    });
    new GeneralUtils().totalAmountInCart().then((total){
      setState(() {
        pay = total;
      });
    });
  }
  /// Declare price and value for chart
  int value = 1;
  String pay = "";

  @override
  Widget build(BuildContext context) {
      return Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(color: Color(MyColors.primary_color)),
            centerTitle: true,
            backgroundColor: Colors.white,
            title: Text(
              "Cart",
              style: TextStyle(
                  fontFamily: "Gotik",
                  fontSize: 18.0,
                  color: Colors.black54,
                  fontWeight: FontWeight.w700),
            ),
            elevation: 0.0,
          ),

          ///
          ///
          /// Checking item value of cart
          ///
          ///
          body: items.length > 0 ?
          Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height - 200.0,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (context,position){
                      ///
                      /// Widget for list view slide delete
                      ///
                      return Slidable(
                        delegate: new SlidableDrawerDelegate(),
                        actionExtentRatio: 0.25,
//                actions: <Widget>[
//                  new IconSlideAction(
//                    caption: 'Archive',
//                    color: Colors.blue,
//                    icon: Icons.archive,
//                    onTap: () {
//                       ///
//                      /// SnackBar show if cart Archive
//                      ///
//                      Scaffold.of(context)
//                          .showSnackBar(SnackBar(content: Text("Items Cart Archive"),duration: Duration(seconds: 2),backgroundColor: Colors.blue,));
//                    },
//                  ),
//                ],
                        secondaryActions: <Widget>[
                          new IconSlideAction(
                            key: Key(items[position].id.toString()),
                            caption: 'Delete',
                            color: Colors.red,
                            icon: Icons.delete,
                            onTap: () {
                              new GeneralUtils().removeCart(position);
                              setState(() {
                                items.removeAt(position);
                                //pay = new GeneralUtils().totalAmountInCart();
                              });
                              new Timer(Duration(milliseconds: 500), (){
                                new GeneralUtils().totalAmountInCart().then((total){
                                  setState(() {
                                    pay = total;
                                  });
                                });
                              });
                              ///
                              /// SnackBar show if cart delete
                              ///
                              Scaffold.of(context)
                                  .showSnackBar(SnackBar(content: Text("Item Cart Deleted"),duration: Duration(seconds: 2),backgroundColor: Colors.redAccent,));
                            },
                          ),
                        ],
                        child: Column(children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 1.0, left: 13.0, right: 13.0),
                            /// Background Constructor for card
                            child: Container(
                              height: 180.0,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12.withOpacity(0.1),
                                    blurRadius: 3.5,
                                    spreadRadius: 0.4,
                                  )
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                          padding: EdgeInsets.all(10.0),

                                          /// Image item
                                          child: Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.1),
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: Colors.black12.withOpacity(0.1),
                                                        blurRadius: 0.5,
                                                        spreadRadius: 0.1)
                                                  ]),
                                              child: Image.network('${items[position].img}',
                                                height: 130.0,
                                                width: 120.0,
                                                fit: BoxFit.cover,
                                              ))),
                                      Flexible(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 25.0, left: 10.0, right: 5.0),
                                          child: Column(

                                            /// Text Information Item
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                '${items[position].title}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontFamily: "Sans",
                                                  color: Colors.black87,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Padding(padding: EdgeInsets.only(top: 10.0)),
                                              Text(
                                                '${items[position].desc}',
                                                style: TextStyle(
                                                  color: Colors.black54,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 12.0,
                                                ),
                                              ),
                                              Padding(padding: EdgeInsets.only(top: 10.0)),
                                              Text('${items[position].price}'),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 18.0, left: 0.0),
                                                child: Container(
                                                  width: 115.0,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white70,
                                                      border: Border.all(
                                                          color: Colors.black12.withOpacity(0.1))),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment
                                                        .spaceAround,
                                                    children: <Widget>[

                                                      /// Decrease of value item
                                                      InkWell(
                                                        onTap: () {
                                                          int qty = items[position].quantity;
                                                          if((qty - 1) == 0){
                                                            return;
                                                          }
                                                          dynamic getP = new GeneralUtils().getCartItems()[position];
                                                          Products pro = Products.fromJson(getP['product']);
                                                          new GeneralUtils().updateCart(pro, qty - 1);
                                                          setState(() {
                                                            //value = value - 1;
                                                            items[position].quantity = qty - 1;
                                                            //pay= 950 * value;
                                                            //pay = new GeneralUtils().totalAmountInCart();
                                                          });
                                                          new Timer(Duration(milliseconds: 500), (){
                                                            new GeneralUtils().totalAmountInCart().then((total){
                                                              setState(() {
                                                                pay = total;
                                                              });
                                                            });
                                                          });
                                                        },
                                                        child: Container(
                                                          height: 30.0,
                                                          width: 30.0,
                                                          decoration: BoxDecoration(
                                                              border: Border(
                                                                  right: BorderSide(
                                                                      color: Colors.black12
                                                                          .withOpacity(0.1)))),
                                                          child: Center(child: Text("-")),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.symmetric(
                                                            horizontal: 18.0),
                                                        child: Text('${items[position].quantity}'),
                                                      ),

                                                      /// Increasing value of item
                                                      InkWell(
                                                        onTap: () {
                                                          dynamic getP = new GeneralUtils().getCartItems()[position];
                                                          Products pro = Products.fromJson(getP['product']);
                                                          int qty = items[position].quantity;
                                                          if((qty +1) > pro.stock){
                                                            displaySnackBar();
                                                            return;
                                                          }
                                                          String uc = new GeneralUtils().updateCart(pro, qty + 1);
                                                          setState(() {
                                                            //value = value + 1;
                                                            items[position].quantity = qty + 1;
                                                            //pay = 950 * value;
                                                            //pay = new GeneralUtils().totalAmountInCart();
                                                          });
                                                          new Timer(Duration(milliseconds: 500), (){
                                                            new GeneralUtils().totalAmountInCart().then((total){
                                                              setState(() {
                                                                pay = total;
                                                              });
                                                            });
                                                          });
                                                        },
                                                        child: Container(
                                                          height: 30.0,
                                                          width: 28.0,
                                                          decoration: BoxDecoration(
                                                              border: Border(
                                                                  left: BorderSide(
                                                                      color: Colors.black12
                                                                          .withOpacity(0.1)))),
                                                          child: Center(child: Text("+")),
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
                                    ],
                                  ),///here
                                ],
                              ),
                            ),
                          ),
                        ]),
                      );
                    },
                    scrollDirection: Axis.vertical,
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 8.0)),
                Divider(
                  height: 2.0,
                  color: Colors.black12,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 9.0, left: 10.0, right: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),

                        /// Total price of item buy
                        child: Text(
                          "Total : " + pay,
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 15.5,
                              fontFamily: "Sans"),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(PageRouteBuilder(
                              pageBuilder: (_, __, ___) => delivery()));
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: Container(
                            height: 40.0,
                            width: 120.0,
                            decoration: BoxDecoration(
                              color: Color(MyColors.primary_color),
                            ),
                            child: Center(
                              child: Text(
                                "Pay",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: "Sans",
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ) : noItemCart()
      );
    }

//  String totalAmountInCart() {
//    int prices = 0;
//    cartItems.forEach((cart) {
//      Map<String, dynamic> item = cart['product'];
//      int quantity = cart['quantity'];
//      prices += (item['price'] * quantity);
//    });
//    return new GeneralUtils().currencyFormattedMoney(prices);
//  }
    final scaffKey = GlobalKey<ScaffoldState>();
    void displaySnackBar() {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text("Quantity must not be greater than stock"),duration: Duration(seconds: 2),backgroundColor: Colors.redAccent,));
    }
  }

  ///
///
/// If no item cart this class showing
///
class noItemCart extends StatelessWidget {
  @override

  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return  Container(
      width: 500.0,
      color: Colors.white,
      height: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
                padding:
                EdgeInsets.only(top: mediaQueryData.padding.top + 50.0)),
            Image.asset(
              "assets/imgIllustration/IlustrasiCart.png",
              height: 300.0,
            ),
            Padding(padding: EdgeInsets.only(bottom: 10.0)),
            Text(
              "Cart is empty",
              style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 18.5,
                  color: Colors.black26.withOpacity(0.2),
                  fontFamily: "Popins"),
            ),
          ],
        ),
      ),
    );
  }
}
