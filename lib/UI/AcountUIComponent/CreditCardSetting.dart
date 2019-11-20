import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:treva_shop_flutter/Utils/colors.dart';
import 'package:treva_shop_flutter/Utils/general.dart';
import 'package:treva_shop_flutter/Utils/storage.dart';
import 'package:expandable/expandable.dart';

/// Custom Text Header
var _txtCustomHead = TextStyle(
  color: Colors.black54,
  fontSize: 17.0,
  fontWeight: FontWeight.w600,
  fontFamily: "Gotik",
);

/// Custom Text Detail
var _txtCustomSub = TextStyle(
  color: Colors.black38,
  fontSize: 13.5,
  fontWeight: FontWeight.w500,
  fontFamily: "Gotik",
);

/// Declare example Credit Card
String numberCC = "9867 - 2312 - 3212 - 4213";
String nameCC = "Alissa Hearth";
String cvvCC = "765";

List<dataTransaction> transactions = new List();
List<dynamic> orders = new List();
int selected_index = 0;

class creditCardSetting extends StatefulWidget {
  @override
  _creditCardSettingState createState() => _creditCardSettingState();
}

class _creditCardSettingState extends State<creditCardSetting> {

  StorageSystem ss = new StorageSystem();
  String _fn, _ln, _email;

  bool _inAsyncCall = false;

  void getUser() {
    setState(() {
      _inAsyncCall = true;
    });
    if (ss.getItem("user") != '') {
      Map<String, dynamic> user = json.decode(ss.getItem("user"));
      if (!mounted) return;
      setState(() {
        _fn = '${user['fn']}';
        _ln = '${user['ln']}';
        _email = '${user['email']}';
      });
      getOrders();
    }
  }

  getOrders() {
    Firestore.instance
        .collection("orders")
        .where('email', isEqualTo: _email).orderBy('timestamp', descending: true)
        .getDocuments()
        .then((query) {
      if (query.documents.length > 0) {
        int dex  = 0;
        query.documents.forEach((doc) {
          Map<String,dynamic> data = doc.data;
          String date = "${data['created_date']}".split('-')[0];
          List<dynamic> carts = data['carts'];
          dynamic cart_item = carts[0];
          dynamic pro = cart_item['product'];
          String name = pro['name'];
          String currency = (data['currency_used'] == "₦") ? "NGN" : data['currency_used'];
          String price = new GeneralUtils().formattedMoney(double.parse("${data['total_amount']}"), currency);//"$currency ${data['total_amount']}";
          setState(() {
            orders.add(doc.data);
            transactions.add(dataTransaction(
              index: dex,
              date: date,
              item: name,
              price: price,
            ));
          });
          dex = dex + 1;
        });
      }
      setState(() {
        _inAsyncCall = false;
      });
    }).catchError((err){
      setState(() {
        _inAsyncCall = false;
      });
      new GeneralUtils().neverSatisfied(context, 'Error', 'Please try again.');
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    return Scaffold(
        appBar: AppBar(
          leading: InkWell(
              onTap: () {
                Navigator.of(context).pop(false);
              },
              child: Icon(Icons.arrow_back)),
          elevation: 0.0,
          title: Text(
            "My Orders",
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18.0,
                color: Colors.black54,
                fontFamily: "Gotik"),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Color(MyColors.primary_color)),
        ),
        body: ModalProgressHUD(
          opacity: 0.3,
          inAsyncCall: _inAsyncCall,
          progressIndicator: CircularProgressIndicator(),
          color: Color(MyColors.button_text_color),
          child: SingleChildScrollView(
            child: Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
//              Padding(
//                padding:
//                    const EdgeInsets.only(top: 10.0, left: 15.0, right: 15.0),
//                child: Stack(
//                  children: <Widget>[
//                    Image.asset(
//                      "assets/img/creditCardVisa.png",
//                      height: 220.0,
//                      fit: BoxFit.fill,
//                    ),
//                    Column(
//                      children: <Widget>[
//                        Padding(
//                          padding: EdgeInsets.only(
//                              top: mediaQuery.padding.top + 75.0),
//                          child: Text(
//                            numberCC,
//                            style: _txtCustomHead.copyWith(
//                                color: Colors.white,
//                                fontSize: 18.0,
//                                letterSpacing: 3.5),
//                          ),
//                        ),
//                        Padding(
//                          padding: EdgeInsets.only(
//                              top: mediaQuery.padding.top + 10.0,
//                              left: 20.0,
//                              right: 20.0),
//                          child: Row(
//                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                            children: <Widget>[
//                              Text(
//                                "Card Name",
//                                style:
//                                    _txtCustomSub.copyWith(color: Colors.white),
//                              ),
//                              Text("CVV / CVC",
//                                  style: _txtCustomSub.copyWith(
//                                      color: Colors.white)),
//                            ],
//                          ),
//                        ),
//                        Padding(
//                          padding: EdgeInsets.only(
//                              left: 20.0, right: 40.0, top: 2.0),
//                          child: Row(
//                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                            children: <Widget>[
//                              Text(nameCC,
//                                  style: _txtCustomSub.copyWith(
//                                      color: Colors.white)),
//                              Text(cvvCC,
//                                  style: _txtCustomSub.copyWith(
//                                      color: Colors.white)),
//                            ],
//                          ),
//                        )
//                      ],
//                    )
//                  ],
//                ),
//              ),
//              Padding(
//                padding: const EdgeInsets.only(top: 30.0, left: 15.0),
//                child: Text(
//                  "Card Information",
//                  style: _txtCustomHead,
//                ),
//              ),
//              creditCard(),
                  (orders.length > 0) ? Padding(
                    padding: const EdgeInsets.only(
                        top: 30.0, left: 15.0, bottom: 10.0),
                    child: Text(
                      "Order Details",
                      style: _txtCustomHead.copyWith(fontSize: 16.0),
                    ),
                  ): Text(''),
                  (orders.length > 0) ? transactionsDetail() : noItemOrder()
                ],
              ),
            ),
          ),
        ));
  }
}

/// Constructor for Card
class creditCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, left: 15.0, right: 15.0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4.5,
                spreadRadius: 1.0,
              )
            ]),
        child: Column(
          children: <Widget>[
            Padding(
              padding:
                  const EdgeInsets.only(top: 20.0, left: 20.0, right: 60.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "My Personal Card",
                    style: _txtCustomHead.copyWith(
                        fontSize: 15.0, fontWeight: FontWeight.w600),
                  ),
                  Image.asset(
                    "assets/img/credit.png",
                    height: 30.0,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 20.0, bottom: 5.0, left: 20.0, right: 60.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Card Number",
                        style: _txtCustomSub,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: Text(numberCC),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Exp.",
                        style: _txtCustomSub,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: Text("12/29"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 15.0,
                bottom: 30.0,
                left: 20.0,
                right: 30.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Card Name",
                        style: _txtCustomSub,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: Text(nameCC),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "CVV/CVC.",
                        style: _txtCustomSub,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: Text(cvvCC),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
                height: 50.0,
                width: 1000.0,
                color: Colors.blueGrey.withOpacity(0.1),
                child: Center(
                    child: Text("Edit Detail",
                        style: _txtCustomHead.copyWith(
                            fontSize: 15.0, color: Colors.blueGrey))))
          ],
        ),
      ),
    );
  }
}

/// Constructor for Transactions
class transactionsDetail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    return Padding(
      padding: const EdgeInsets.only(
          top: 10.0, left: 5.0, right: 5.0, bottom: 10.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4.5,
              spreadRadius: 1.0,
            )
          ],
        ),
        child: Column(
          children: transactions,
        ),
      ),
    );
  }
}

/// Constructor for Transactions Data
class dataTransaction extends StatelessWidget {

  int index;
  String date, item, price;

  dataTransaction({this.index, this.date, this.item, this.price});

  List<double> product_sub_totals = new List(orders.length);

  @override
  Widget build(BuildContext context) {

    return ExpandablePanel(
      header: _header(),
      //collapsed: Text(item, softWrap: true, maxLines: 2, overflow: TextOverflow.ellipsis,),
      expanded: _expanded(index),
      tapHeaderToExpand: true,
      tapBodyToCollapse: true,
      hasIcon: true,
    );
  }

  Widget _header() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 20.0, bottom: 20.0, left: 5.0, right: 5.0),
          child: InkWell(
              onTap: () {
                selected_index = index;
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: Text(
                      date,
                      style: _txtCustomSub.copyWith(
                          color: Colors.black38,
                          fontSize: 11.0,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  Container(
                    width: 120.0,
                    child: Text(
                      item,
                      style: _txtCustomSub.copyWith(color: Colors.black54),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(price,
                      style: _txtCustomSub.copyWith(
                        color: Color(MyColors.primary_color),
                        fontSize: 16.0,
                      )),
                ],
              )),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Divider(
            height: 0.5,
            color: Colors.black12,
          ),
        ),
      ],
    );
  }

  Widget productFill(int index) {

    double product_sub_total = 0;

    Map<String,dynamic> data = orders[index];
    String id = data['id'];

    double convertion_rate = (data['conversion_rate'] == null) ? 1 : double.parse("${data['conversion_rate']}");
    String currency = (data['currency_used'] == "₦") ? "NGN" : data['currency_used'];

    List<dynamic> carts = data['carts'];
    List<Widget> products = new List();

    carts.forEach((cart) {
      dynamic pro = cart['product'];
      int quantity = cart['quantity'];

      double pro_price = double.parse("${pro['price']}") * quantity;
      double price = pro_price / convertion_rate;

//      print('data at index $index with id $id has price of $price');

      product_sub_total += price;

      product_sub_totals[index] = product_sub_total;

      String fPrice = new GeneralUtils().formattedMoney(price, currency);


      products.add(ListTile(
        title: Text(
          '${pro['name']} x $quantity',
          style: TextStyle(
              letterSpacing: 0.1,
              fontSize: 16.0,
              color: Colors.black,
              fontFamily: ""),
        ),
        trailing: Text(
          fPrice,
          style: TextStyle(
              letterSpacing: 0.1,
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
              color: Colors.black,
              fontFamily: ""),
        ),
      ));
      products.add(
        Container(
          margin: EdgeInsets.only(top: 0.0),
          child: Divider(
            height: 1.0,
          ),
        ),
      );
    });
    return Container(
      child: Column(
        children: products,
      ),
    );
  }

  Widget _expanded(int index) {

    Map<String,dynamic> data = orders[index];
//    String date = "${data['created_date']}".split('-')[0];
    List<dynamic> carts = data['carts'];
//    dynamic cart_item = carts[0];
//    dynamic pro = cart_item['product'];
//    String name = pro['name'];
    String currency = (data['currency_used'] == "₦") ? "NGN" : data['currency_used'];
    String final_amount = new GeneralUtils().formattedMoney(double.parse("${data['total_amount']}"), currency);

    String delivery = "", tax = "";
    //delivery
    dynamic other_options = data['other_payment_detals'];
    if(other_options != null) {
      delivery = new GeneralUtils().formattedMoney(
          double.parse("${other_options['delivery']}"), currency);
//      print('data at index $index has delivery of $delivery');
      tax = new GeneralUtils().formattedMoney(
          double.parse("${other_options['tax']}"), currency);
//      print('data at index $index has tax of $tax');
    }

    return Container(
      color: Colors.white,
      child: Padding(
        padding:
        const EdgeInsets.only(top: 30.0, left: 20.0, right: 20.0),
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text(
                "Product",
                style: TextStyle(
                    letterSpacing: 0.1,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                    color: Colors.black,
                    fontFamily: ""),
              ),
              trailing: Text(
                "Total",
                style: TextStyle(
                    letterSpacing: 0.1,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                    color: Colors.black,
                    fontFamily: ""),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 20.0),
              child: Divider(
                height: 1.0,
              ),
            ),
            productFill(index),
            Container(
              height: 20.0,
            ),
            ListTile(
              title: Text(
                "Subtotal",
                style: TextStyle(
                    letterSpacing: 0.1,
                    fontSize: 16.0,
                    color: Colors.black,
                    fontFamily: ""),
              ),
              trailing: Text(
                new GeneralUtils().formattedMoney(product_sub_totals[index], currency),
                style: TextStyle(
                    letterSpacing: 0.1,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                    color: Color(MyColors.primary_color),
                    fontFamily: ""),
              ),
            ),
            Container(
              height: 0.0,
            ),
            ListTile(
              title: Text(
                "Tax",
                style: TextStyle(
                    letterSpacing: 0.1,
                    fontSize: 16.0,
                    color: Colors.black,
                    fontFamily: ""),
              ),
              trailing: Text(
                tax,
                style: TextStyle(
                    letterSpacing: 0.1,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                    color: Colors.black,
                    fontFamily: ""),
              ),
            ),
            Container(
              height: 0.0,
            ),
            ListTile(
              title: Text(
                "Delivery",
                style: TextStyle(
                    letterSpacing: 0.1,
                    fontSize: 16.0,
                    color: Colors.black,
                    fontFamily: ""),
              ),
              trailing: Text(
                        delivery,
                        style: TextStyle(
                            letterSpacing: 0.1,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                            color: Colors.black,
                            fontFamily: ""),
                      ),
            ),
            Container(
              margin: EdgeInsets.only(top: 20.0),
              child: Divider(
                height: 1.0,
              ),
            ),
            ListTile(
              title: Text(
                "Total",
                style: TextStyle(
                    letterSpacing: 0.1,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                    color: Colors.black,
                    fontFamily: ""),
              ),
              trailing: Text(
                final_amount,
                style: TextStyle(
                    letterSpacing: 0.1,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                    color: Color(MyColors.primary_color),
                    fontFamily: ""),
              ),
            ),
            SizedBox(
              height: 20.0,
            )
          ],
        ),
      ),
    );
  }
}

class noItemOrder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Container(
      width: 500.0,
      color: Colors.white,
      height: mediaQueryData.size.height,
      child: Container(
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
              "Order is empty",
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
