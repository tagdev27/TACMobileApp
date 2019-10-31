import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:treva_shop_flutter/ListItem/CartItemData.dart';
import 'package:treva_shop_flutter/ListItem/track.dart';
import 'package:treva_shop_flutter/UI/BottomNavigationBar.dart';
import 'package:treva_shop_flutter/UI/CartUIComponent/CartLayout.dart';
import 'package:treva_shop_flutter/UI/CartUIComponent/Delivery.dart';
import 'package:treva_shop_flutter/UI/HomeUIComponent/Home.dart';
import 'package:treva_shop_flutter/Utils/colors.dart';
import 'package:treva_shop_flutter/Utils/email_service.dart';
import 'package:treva_shop_flutter/Utils/general.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:http/http.dart' as http;
import 'package:treva_shop_flutter/Utils/storage.dart';
import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';
import 'package:path_provider/path_provider.dart';

class payment extends StatefulWidget {
  final Map<String, dynamic> details;

  payment(this.details);

  @override
  _paymentState createState() => _paymentState();
}

class _paymentState extends State<payment> {
  final List<cartItem> items = new List();
  String total_amount = "", final_amount = "";
  String tax = "";
  String delivery = new GeneralUtils().currencyFormattedMoney(2000);
  bool _inAsyncCall = false;
  double ft = 0;

  bool isCharged = false;
  String ref, card;
  double _tax, _delivery;

  StorageSystem ss = new StorageSystem();

  /// Duration for popup card if user succes to payment
  StartTime() async {
    return Timer(Duration(seconds: 5), navigator);
  }

  /// Navigation to route after user succes payment
  void navigator() {
    Navigator.of(context).pushReplacement(PageRouteBuilder(
        pageBuilder: (_, __, ___) => new bottomNavigationBar()));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    new GeneralUtils().getCartItems().forEach((cart) {
      Map<String, dynamic> item = cart['product'];
      int quantity = cart['quantity'];
      setState(() {
        items.add(
          cartItem(
              img: item['pictures'][0],
              id: item['id'],
              title: item['name'],
              desc: item['shortDetails'],
              unit_price:
                  new GeneralUtils().currencyFormattedMoney(item['price']),
              price: new GeneralUtils()
                  .currencyFormattedMoney(item['price'] * quantity),
              quantity: quantity),
        );
      });
    });
    new GeneralUtils().totalAmountInCart().then((total) {
      setState(() {
        total_amount = total;
      });
    });
    getTaxValue();
    initPaystack();
  }

  Future<void> initPaystack() async {
    await PaystackPlugin.initialize(
        publicKey: "pk_test_8be8b3b21803dcb62514b6e55f3c6f90f4a74483");
  }

  void getTaxValue() async {
    setState(() {
      _inAsyncCall = true;
    });
    var get_tax = await Firestore.instance
        .collection('db')
        .document('tacadmin')
        .collection('settings')
        .document('tax')
        .get();
    int value = get_tax.data['tax_value'];
    new GeneralUtils().totalAmountInCartDouble().then((t) {
      double mTax = ((GeneralUtils().country_priceDouble(t) * value) / 100);
      double finalT = mTax +
          GeneralUtils().country_priceDouble(2000.00) +
          GeneralUtils().country_priceDouble(t);
      setState(() {
        tax = GeneralUtils().currencyFormattedMoneyDouble(mTax);
        _tax = mTax;
        _delivery = GeneralUtils().country_priceDouble(2000.00);
        final_amount = GeneralUtils().currencyFormattedMoneyDouble(finalT);
        _inAsyncCall = false;
        ft = GeneralUtils().country_priceDouble(finalT);
      });
    });
  }

  /// For radio button
  int tapvalue = 0;
  int tapvalue2 = 0;
  int tapvalue3 = 0;
  int tapvalue4 = 0;

  /// Custom Text
  var _customStyle = TextStyle(
      fontFamily: "Gotik",
      fontWeight: FontWeight.w800,
      color: Colors.black,
      fontSize: 17.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      /// Appbar
      appBar: AppBar(
        leading: InkWell(
            onTap: () {
              Navigator.of(context).pop(false);
            },
            child: Icon(Icons.arrow_back)),
        elevation: 0.0,
        title: Text(
          "Payment",
          style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18.0,
              color: Colors.black54,
              fontFamily: "Gotik"),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Color(0xFF6991C7)),
      ),
      body: ModalProgressHUD(
          opacity: 0.5,
          inAsyncCall: _inAsyncCall,
          progressIndicator: CircularProgressIndicator(),
          color: Color(MyColors.button_text_color),
          child: SingleChildScrollView(
            child: Container(
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
                    productFill(),
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
                        total_amount,
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

                    /// Button pay
                    InkWell(
                      onTap: () {
                        payWithPaystack();
                        //addOrderToFirebase("249347845");
                      },
                      child: Container(
                        height: 55.0,
                        margin:
                            EdgeInsets.only(left: 20.0, right: 20.0, top: 40.0),
                        decoration: BoxDecoration(
                            color: Colors.indigoAccent,
                            borderRadius:
                                BorderRadius.all(Radius.circular(40.0))),
                        child: Center(
                          child: Text(
                            "Pay",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16.5,
                                letterSpacing: 2.0),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    )
                  ],
                ),
              ),
            ),
          )),
    );
  }

  Widget productFill() {
    List<Widget> products = new List();
    items.forEach((cart) {
      products.add(ListTile(
        title: Text(
          '${cart.title} x ${cart.quantity}',
          style: TextStyle(
              letterSpacing: 0.1,
              fontSize: 16.0,
              color: Colors.black,
              fontFamily: ""),
        ),
        trailing: Text(
          cart.price,
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

  payWithPaystack() async {
    if (isCharged) {
      verifyTransaction(ref, card);
      return;
    }
    final res = ss.getItem('currency');
    Map<String, dynamic> data = jsonDecode(res);
    String curr = data['currency_name'];
    String reference = FirebaseDatabase.instance.reference().push().key;
    //String accessCode = '${Random().nextInt(9999999)}';
    Charge charge = Charge()
      ..amount = (ft * 100).toInt()
      ..reference = reference
      ..currency = "NGN"//curr//NGNchange to curr afterwards
      // or ..accessCode = _getAccessCodeFrmInitialization()
      ..email = widget.details['email'];
    try {
      CheckoutResponse response = await PaystackPlugin.checkout(context,
          charge: charge, method: CheckoutMethod.card, fullscreen: true);
      if (!response.status) {
        new GeneralUtils()
            .neverSatisfied(context, 'Payment Error', response.message);
      } else {
        setState(() {
          isCharged = true;
          ref = response.reference;
          card = response.card.last4Digits;
        });
        verifyTransaction(response.reference, response.card.last4Digits);
      }
    } catch (e) {
      setState(() {
        _inAsyncCall = false;
      });
      new GeneralUtils().neverSatisfied(context, 'Error', e.toString());
    }
  }

  void verifyTransaction(String reference, String cardNumber) {
    setState(() {
      _inAsyncCall = true;
    });
    http.get('https://api.paystack.co/transaction/verify/$reference', headers: {
      'Authorization': 'Bearer sk_test_52b35d5eaa9f39c9411d14d9e5fb336602fc8773'
    }).then((res) {
      print(res.body);
      Map<String, dynamic> resp = json.decode(res.body);
      bool status = resp['status'];
      String message = resp['message'];
      Map<String, dynamic> dt = resp['data'];
      String statusMessage = dt['status'];
      if (status && statusMessage == 'success') {
        //run other operation
        addOrderToFirebase(reference);
//        Map<String, dynamic> data = resp['data'];
//        Map<String, dynamic> auth = data['authorization'];
//        String auth_code = auth['authorization_code'];
//        DatabaseReference promoRef = FirebaseDatabase.instance
//            .reference()
//            .child('users/${_email.replaceAll('.', ',')}/payments');
//        String id = promoRef
//            .push()
//            .key;
//        promoRef.child(id).set({
//          'number': cardNumber,
//          'id': id,
//          'payment_code': auth_code,
//          'available': true,
//        }).whenComplete(() {
//
//        });
      } else {
        setState(() {
          _inAsyncCall = false;
        });
        new GeneralUtils().neverSatisfied(context, 'Error', message);
      }
    });
  }

  void addOrderToFirebase(String orderId) {
    final res = ss.getItem('currency');
    Map<String, dynamic> data = jsonDecode(res);
    String curr = data['currency'];
    String country = data['country'];
    DateTime dt = DateTime.now();
    final key = FirebaseDatabase.instance.reference().push().key;
    final track = FirebaseDatabase.instance.reference().push().key.substring(1, 6); //'${Random().nextInt(999999)}${Random().nextInt(999999)}';

    List<dynamic> track_details = new List();
    final mT = Tracking('Order Placed', 'We have received your order', 'start',
        '${dt.month}/${dt.day}/${dt.year} - ${dt.hour}:${dt.minute}:${dt.second}');
    track_details.add(mT.toJSON());

    var other_payment_details = {'tax': _tax, 'delivery': _delivery};

    var months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];

    List<dynamic> product = new List();

    new GeneralUtils().getCartItems().forEach((cart) {
      Map<String, dynamic> item = cart['product'];
      int quantity = cart['quantity'];
      var ct = {'product': item, 'quantity': quantity};
      product.add(ct);
    });

    var order = {
      'carts': product,
      'currency_used': curr,
      'transaction_id': orderId,
      'id': key,
      'country': country,
      'email': widget.details['email'],
      'created_date':
          '${months[dt.month - 1]} ${dt.day}, ${dt.year} - ${dt.hour}:${dt.minute}:${dt.second}',
      'track_id': track,
      'status': 'pending',
      'total_amount': ft,
      'shipping_details': widget.details,
      'gift_card_style': '',
      'tracking_details': track_details,
      'other_payment_detals': other_payment_details
    };

    dynamic alert = product[0];
    Map<String, dynamic> nw = alert['product'];

    Firestore.instance.collection('alert-new-order').document(key).setData({
      'country': country,
      'product_image': nw['pictures'][0],
      'product_link': nw['dynamic_link'],
      'product_name': nw['name'],
      'product_price': nw['price'],
      'username': widget.details,
    }).then((d) {
      Firestore.instance
          .collection('orders')
          .document(key)
          .setData(order)
          .then((d) {
        AfterFirebaseUpload(order, '$track', orderId,
            '${months[dt.month - 1]} ${dt.day}, ${dt.year} - ${dt.hour}:${dt.minute}:${dt.second}');
      });
    });
  }

  void AfterFirebaseUpload(Map<String, dynamic> order, String tracking_id,
      String orderId, String date) {
    updateStockLevelForProduct();

    String billing_name =
        '${widget.details['firstname']} ${widget.details['lastname']}';
    String currency_total_amount = final_amount;
    String trans_id = orderId;
    String shipping_details =
        '${widget.details['fullname']}<br> ${widget.details['address']}<br> ${widget.details['state']}, ${widget.details['country']}<br>Contact No. ${widget.details['recipientphone']}';
    String currency_shipping_fee = delivery;
    String currency_tax_fee = tax;

    String cart_items = '';

    items.forEach((cart) {
      cart_items += """
    <tr>
    <td width="50%"
    class="m_-7433457280851606022ordered-item-label-td m_-7433457280851606022product"
    style="padding-top:10px;padding-bottom:10px;border-top:1px solid #cccccc;border-bottom:1px solid #cccccc;font-family:arial;font-size:12px;color:#333333;border-collapse:collapse">
    ${cart.quantity} x ${cart.title} </td>
    <td align="right" width="25%"
    class="m_-7433457280851606022ordered-item-unit-price-td"
    style="padding-top:10px;padding-bottom:10px;border-top:1px solid #cccccc;border-bottom:1px solid #cccccc;font-family:arial;font-size:12px;color:#333333;border-collapse:collapse;text-align:right">
    ${cart.unit_price}
    </td>
    <td align="right" width="25%"
    class="m_-7433457280851606022ordered-item-cost-td"
    style="padding-top:10px;padding-bottom:10px;border-top:1px solid #cccccc;border-bottom:1px solid #cccccc;font-family:arial;font-size:12px;color:#333333;border-collapse:collapse;text-align:right">
    ${cart.price}
    </td>
    </tr>
    """;
    });
    String email_body = new EmailService().getBody(
        date,
        billing_name,
        currency_total_amount,
        trans_id,
        shipping_details,
        currency_shipping_fee,
        currency_tax_fee,
        cart_items,
        tracking_id);
    String email = widget.details['email'];
    uploadPDFToFirebase(
        email_body, email, trans_id, billing_name, date, tracking_id);
  }

  void updateStockLevelForProduct() {
    new GeneralUtils().getCartItems().forEach((cart) {
      Map<String, dynamic> item = cart['product'];
      int quantity = cart['quantity'];
      dynamic gift_items = item['items'];
      if(gift_items != null) {
        for (dynamic gi in gift_items) {
          var gi_id = gi['id'];
          if(gi_id != null) {
            runFireStoreTransaction(gi_id);
          }
        }
      }
    });
    GeneralUtils().clearCart();
  }

  runFireStoreTransaction(String id) {
    var itemRef = Firestore.instance
        .collection('db')
        .document('tacadmin')
        .collection('items')
        .document(id);
    Firestore.instance.runTransaction((t) async {
      var doc = await t.get(itemRef);
      var newstock_level = doc.data['stock_level'] - 1;
      t.update(itemRef, {'stock_level': newstock_level});
    });
  }

  Future<void> uploadPDFToFirebase(
      String email_body,
      String email,
      String trans_id,
      String billing_name,
      String date,
      String tracking_id) async {
    String key = FirebaseDatabase.instance.reference().push().key;
    Directory appDocDir = await getApplicationDocumentsDirectory();
    var targetPath = appDocDir.path;
    var generatedPdfFile = await FlutterHtmlToPdf.convertFromHtmlContent(
        email_body, targetPath, key);
    final StorageReference ref = FirebaseStorage.instance
        .ref()
        .child('invoices')
        .child('$key.pdf'); //rename choice
    final StorageUploadTask uploadTask = ref.putFile(generatedPdfFile);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    Firestore.instance.collection('invoices').document(key).setData({
      'id': key,
      'email': email,
      'invoice_id': trans_id,
      'created_date': date,
      'invoice_url': downloadUrl
    }).then((d) {
      String url =
          'https://avidprintsconcierge.com/emailsending/send.php?sender_email=$email&sender_name=$billing_name';
      http.post(url, body: {'body': email_body}).then((res) {
        setState(() {
          _inAsyncCall = false;
        });
        _showDialog(context, tracking_id);
        StartTime();
      });
    });
  }
}

/// Custom Text Header for Dialog after user succes payment
//_showDialog(context);
//StartTime();
///
var _txtCustomHead = TextStyle(
  color: Colors.black54,
  fontSize: 23.0,
  fontWeight: FontWeight.w600,
  fontFamily: "Gotik",
);

/// Custom Text Description for Dialog after user succes payment
var _txtCustomSub = TextStyle(
  color: Colors.black38,
  fontSize: 15.0,
  fontWeight: FontWeight.w500,
  fontFamily: "Gotik",
);

/// Card Popup if success payment
_showDialog(BuildContext ctx, tracking_id) {
  showDialog(
    context: ctx,
    barrierDismissible: false,
    child: SimpleDialog(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: 30.0, right: 60.0, left: 60.0),
          color: Colors.white,
          child: Image.asset(
            "assets/img/checklist.png",
            height: 110.0,
            color: Colors.lightGreen,
          ),
        ),
        Center(
            child: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Text(
            "Yuppy!!",
            style: _txtCustomHead,
          ),
        )),
        Center(
            child: Padding(
          padding: const EdgeInsets.only(top: 30.0, bottom: 40.0),
          child: Text(
            "Your order has been received\nTracking ID: $tracking_id",
            style: _txtCustomSub,
          ),
        )),
      ],
    ),
  );
}
