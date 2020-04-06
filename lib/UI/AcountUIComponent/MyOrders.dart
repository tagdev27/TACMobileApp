import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:treva_shop_flutter/Utils/colors.dart';
import 'package:treva_shop_flutter/Utils/general.dart';

class order extends StatefulWidget {
  @override
  _orderState createState() => _orderState();
}

class _orderState extends State<order> {

  static var _txtCustom = TextStyle(
    color: Colors.black54,
    fontSize: 15.0,
    fontWeight: FontWeight.w500,
    fontFamily: "Gotik",
  );

  /// Create Big Circle for Data Order Not Success
  var _bigCircleNotYet = Padding(
    padding: const EdgeInsets.only(top: 8.0),
    child: Container(
      height: 20.0,
      width: 20.0,
      decoration: BoxDecoration(
        color: Colors.lightGreen,
        shape: BoxShape.circle,
      ),
    ),
  );

  /// Create Circle for Data Order Success
  var _bigCircle = Padding(
    padding: const EdgeInsets.only(top: 8.0),
    child: Container(
      height: 20.0,
      width: 20.0,
      decoration: BoxDecoration(
        color: Colors.lightGreen,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          Icons.check,
          color: Colors.white,
          size: 14.0,
        ),
      ),
    ),
  );

  /// Create Small Circle
  var _smallCircle = Padding(
    padding: const EdgeInsets.only(top: 8.0),
    child: Container(
      height: 3.0,
      width: 3.0,
      decoration: BoxDecoration(
        color: Colors.lightGreen,
        shape: BoxShape.circle,
      ),
    ),
  );


  dynamic _user_order = new Map();

  bool _inAsyncCall = false;

  Map<String, dynamic> product_sub_total = new Map();

  final _controller = new TextEditingController(text: '');

  getOrderByTrackingID(String id) {
    setState(() {
      _inAsyncCall = true;
    });
    int _id = double.parse(id).ceil();
    Firestore.instance
        .collection("orders")
        .where('track_id', isEqualTo: _id)
        .getDocuments()
        .then((query) {
      if (query.documents.length == 0) {
        setState(() {
          _inAsyncCall = false;
        });
        new GeneralUtils().neverSatisfied(context, 'Error',
            'Order details not found. Try again with a different track id');
        return;
      }
      setState(() {
        _inAsyncCall = false;
        _user_order = query.documents[0].data;
      });
    }).catchError((err) {
      setState(() {
        _inAsyncCall = false;
      });
      new GeneralUtils().neverSatisfied(context, 'Error', 'Please try again.');
    });
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            "Track My Order",
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20.0,
                color: Colors.black54,
                fontFamily: "Gotik"),
          ),
          centerTitle: true,
          iconTheme: IconThemeData(color: Color(MyColors.primary_color)),
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
                padding:
                    const EdgeInsets.only(top: 20.0, left: 25.0, right: 25.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _search(),
                    Container(
                      height: 20.0,
                    ),
                    (_user_order.isNotEmpty) ? _orderDetails() : Text(''),
                    Container(
                      height: 0.0,
                    ),
                    (_user_order.isNotEmpty) ? _expandedDetails() : Text(''),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  List<Widget> _left_side_bullets_circles() {
    List<Widget> w = new List();
    List<dynamic> track_details = _user_order['tracking_details'];
    int index = 0;
    track_details.forEach((dt) {
      if (index == track_details.length - 1) {
        w.add(Column(
          children: <Widget>[
            _bigCircle,
          ],
        ));
      } else {
        w.add(Column(
          children: <Widget>[
            _bigCircle,
            _smallCircle,
            _smallCircle,
            _smallCircle,
            _smallCircle,
            _smallCircle,
          ],
        ));
      }
      index = index + 1;
    });
    return w;
  }
  /*
  * <Widget>[
                  _bigCircleNotYet,
                  _smallCircle,
                  _smallCircle,
                  _smallCircle,
                  _smallCircle,
                  _smallCircle,
                  _bigCircle,
                  _smallCircle,
                  _smallCircle,
                  _smallCircle,
                  _smallCircle,
                  _smallCircle,
                  _bigCircle,
                  _smallCircle,
                  _smallCircle,
                  _smallCircle,
                  _smallCircle,
                  _smallCircle,
                  _bigCircle,
                ],
                *
                * qeueuItem(
                    icon: "assets/img/bag.png",
                    txtHeader: "Ready to Pickup",
                    txtInfo: "Order from TrevaShop",
                    time: "11:0",
                    paddingValue: 55.0,
                  ),
                  Padding(padding: EdgeInsets.only(top: 50.0)),
                  qeueuItem(
                    icon: "assets/img/courier.png",
                    txtHeader: "Order Processed",
                    txtInfo: "We are preparing your order",
                    time: "9:50",
                    paddingValue: 16.0,
                  ),
                  Padding(padding: EdgeInsets.only(top: 50.0)),
                  qeueuItem(
                    icon: "assets/img/payment.png",
                    txtHeader: "Payment Confirmed",
                    txtInfo: "Awaiting Confirmation",
                    time: "8:20",
                    paddingValue: 55.0,
                  ),
                  Padding(padding: EdgeInsets.only(top: 50.0)),
                  qeueuItem(
                    icon: "assets/img/order.png",
                    txtHeader: "Order Placed",
                    txtInfo: "We have received your order",
                    time: "8:00",
                    paddingValue: 19.0,
                  ),
  * */

  getIconForOrderItem(String title) {
    if (title.toLowerCase().contains('processing')) {
      return "assets/img/payment.png";
    }
    if (title.toLowerCase().contains('shipped')) {
      return "assets/img/courier.png";
    }
    if (title.toLowerCase().contains('completed')) {
      return "assets/img/bag.png";
    }
    return "assets/img/order.png";
  }

  List<Widget> _right_side_details() {
    List<Widget> w = new List();
    List<dynamic> track_details = _user_order['tracking_details'];
    int index = 0;
//    track_details.forEach((dt){
    for (int i = track_details.length - 1; i >= 0; i--) {
      dynamic dt = track_details[i];
      if (i == 0) {
        w.add(
          qeueuItem(
            icon: "assets/img/order.png",
            txtHeader: dt['title'],
            txtInfo: dt['text'],
            time: dt['time'],
            paddingValue: 19.0,
          ),
        );
      } else {
        w.add(Column(
          children: <Widget>[
            qeueuItem(
              icon: getIconForOrderItem("${dt['title']}"),
              txtHeader: dt['title'],
              txtInfo: dt['text'],
              time: dt['time'],
              paddingValue: 55.0,
            ),
            Padding(padding: EdgeInsets.only(top: 32.0)),
          ],
        ));
      }
      //index = index + 1;
    }
    return w;
  }

  Widget _orderDetails() {
    dynamic shipping = _user_order['shipping_details'];

    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            _user_order['created_date'],
            style: _txtCustom,
          ),
          Padding(padding: EdgeInsets.only(top: 7.0)),
          Text(
            "Order ID: ${_user_order['transaction_id']}",
            style: _txtCustom,
          ),
          Padding(padding: EdgeInsets.only(top: 30.0)),
          Text(
            "Orders",
            style: _txtCustom.copyWith(
                color: Colors.black54,
                fontSize: 18.0,
                fontWeight: FontWeight.w600),
          ),
          Padding(padding: EdgeInsets.only(top: 20.0)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(children: _left_side_bullets_circles()),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _right_side_details()),
            ],
          ), /////
          Padding(
            padding: const EdgeInsets.only(
                top: 48.0, bottom: 5.0, left: 0.0, right: 25.0),
            child: Container(
              padding: EdgeInsets.only(top: 20.0, left: 5.0, right: 5.0, bottom: 20.0),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12.withOpacity(0.1),
                      blurRadius: 4.5,
                      spreadRadius: 1.0,
                    )
                  ]),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Image.asset("assets/img/house.png"),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Text(
                        "Delivery Address",
                        style: _txtCustom.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Padding(padding: EdgeInsets.only(top: 5.0)),
                      Text(
                        "Address, Phone No. & Other Details",
                        style: _txtCustom.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 12.0,
                            color: Colors.black38),
                      ),
                      Padding(padding: EdgeInsets.only(top: 2.0)),
                      Container(
                        width: MediaQuery.of(context).size.width - 120.0,
                        child: Text(
                          "House: ${shipping['address']}, ${shipping['town']}, \n${shipping['state']}, ${shipping['country']}\nPhone: ${shipping['recipientphone']}\nInstruction: ${shipping['specialinstruction']}",
                          style: _txtCustom.copyWith(
                              fontWeight: FontWeight.w400,
                              fontSize: 12.0,
                              color: Colors.black38),
                          overflow: TextOverflow.clip,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _search() {
    return Container(
        height: 50.0,
        decoration: BoxDecoration(
            color: Colors.white,
            border:
                Border.all(color: Colors.grey.withOpacity(0.2), width: 1.0)),
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Theme(
            data: ThemeData(hintColor: Colors.transparent),
            child: TextFormField(
              controller: _controller,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  icon: Icon(
                    Icons.search,
                    color: Colors.black38,
                    size: 18.0,
                  ),
                  suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        if(_controller.text.length == 0) return;
                    setState(() {
                      _controller.clear();
                    });
                      }),
                  hintText: "Enter Tracking ID",
                  hintStyle: TextStyle(color: Colors.black38, fontSize: 14.0)),
              textInputAction: TextInputAction.search,
              keyboardType: TextInputType.number,
              onFieldSubmitted: (searchValue) {
                if (searchValue.isNotEmpty) {
                  getOrderByTrackingID(searchValue);
                }
              },
            ),
          ),
        ));
  }

  Widget productFill() {
    product_sub_total[_user_order['id']] = 0;

    double convertion_rate = (_user_order['conversion_rate'] == null)
        ? 1
        : double.parse("${_user_order['conversion_rate']}");
    String currency = (_user_order['currency_used'] == "₦")
        ? "NGN"
        : _user_order['currency_used'];

    List<dynamic> carts = _user_order['carts'];
    List<Widget> products = new List();

    carts.forEach((cart) {
      dynamic pro = cart['product'];
      int quantity = cart['quantity'];

      double pro_price = double.parse("${pro['price']}");// * quantity;
      double price = pro_price / convertion_rate;

//      print('data at index $index with id $id has price of $price');

      product_sub_total[_user_order['id']] += price;

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

  Widget _expandedDetails() {
    String currency = (_user_order['currency_used'] == "₦")
        ? "NGN"
        : _user_order['currency_used'];
    String final_amount = new GeneralUtils().formattedMoney(
        double.parse("${_user_order['total_amount']}"), currency);

    String delivery = "", tax = "";
    //delivery
    dynamic other_options = _user_order['other_payment_details'];
    if (other_options != null) {
      delivery = new GeneralUtils().formattedMoney(
          double.parse("${other_options['delivery']}"), currency);
//      print('data at index $index has delivery of $delivery');
      tax = new GeneralUtils()
          .formattedMoney(double.parse("${other_options['tax']}"), currency);
//      print('data at index $index has tax of $tax');
    }

    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0, left: 0.0, right: 0.0),
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
            productFill(),
            Container(
              height: 20.0,
            ),
            /**
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
                new GeneralUtils().formattedMoney(
                    product_sub_total[_user_order['id']], currency),
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
             */
            Container(
              margin: EdgeInsets.only(top: 20.0),
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

class qeueuItem extends StatefulWidget {

  final String icon, txtHeader, txtInfo, time;
  final double paddingValue;

  qeueuItem(
      {this.icon, this.txtHeader, this.txtInfo, this.time, this.paddingValue});

  @override
  State<StatefulWidget> createState() => _qeueuItem(this.icon, this.txtHeader, this.txtInfo, this.time, this.paddingValue);
}

/// Constructor Data Orders
class _qeueuItem extends State<qeueuItem> {


  static var _txtCustomOrder = TextStyle(
    color: Colors.black45,
    fontSize: 13.5,
    fontWeight: FontWeight.w600,
    fontFamily: "Gotik",
  );

  String icon, txtHeader, txtInfo, time;
  double paddingValue;

  _qeueuItem(
      this.icon, this.txtHeader, this.txtInfo, this.time, this.paddingValue);

  bool isShowMore = false;

  Widget displayTextProperly() {
    if (txtInfo.length > 40) {
      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        verticalDirection: VerticalDirection.down,
        children: <Widget>[

          (!isShowMore) ? Text(
            '${txtInfo.substring(0, 25)}...',
            softWrap: true,
            overflow: TextOverflow.clip,
            textAlign: TextAlign.left,
            style: _txtCustomOrder.copyWith(
                fontWeight: FontWeight.w400,
                fontSize: 12.0,
                color: Colors.black38),
          ) : Container(
            width: MediaQuery.of(context).size.width - 200.0,
              child: Text(
            '$txtInfo',
            softWrap: true,
            overflow: TextOverflow.clip,
            textAlign: TextAlign.left,
            style: _txtCustomOrder.copyWith(
                fontWeight: FontWeight.w400,
                fontSize: 12.0,
                color: Colors.black38),
          )),
          InkWell(child: Text((!isShowMore) ? 'show more' : 'show less', textAlign: TextAlign.left, style: TextStyle(color: Color(MyColors.primary_color)),), onTap: (){
            setState(() {
              if(!isShowMore){
                isShowMore = true;
              }else {
                isShowMore = false;
              }
            });
          },)
        ],
      );
    } else {
      return Text(
        txtInfo,
        textAlign: TextAlign.left,
        style: _txtCustomOrder.copyWith(
            fontWeight: FontWeight.w400, fontSize: 12.0, color: Colors.black38),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 13.0),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Image.asset(icon),
              Padding(
                padding: EdgeInsets.only(
                    left: 8.0,
                    right: 0.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(txtHeader, style: _txtCustomOrder),
                    displayTextProperly(),
                    Text(
                      time,
                      style: _txtCustomOrder
                        ..copyWith(fontWeight: FontWeight.w400),
                    )
                  ],
                ),
              ),
//              Text(
//                time,
//                style: _txtCustomOrder..copyWith(fontWeight: FontWeight.w400),
//              )
            ],
          ),
        ],
      ),
    );
  }
}
