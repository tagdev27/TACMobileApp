import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:rave_flutter/rave_flutter.dart';
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
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class payment extends StatefulWidget {
  final Map<String, dynamic> details;

  payment(this.details);

  final ChromeSafariBrowser browser =
      new MyChromeSafariBrowser(new MyInAppBrowser());

  @override
  _paymentState createState() => _paymentState();
}

class _paymentState extends State<payment> {
  final List<cartItem> items = new List();
  String total_amount = "", final_amount = "";
  String tax = "";
  String delivery = "";
  bool _inAsyncCall = false;
  double ft = 0;

  bool isCharged = false;
  String ref, card;
  double _tax, _delivery;
  List<String> deliveryOptions = ["select option"];
  List<dynamic> deliveryOptionsMap = new List();
  String delivery_selected = "select option";
  String delivery_selected_note = "";

  StorageSystem ss = new StorageSystem();

  String public_key = "", enc_key = "";

  double finalT = 0;

  double taxValue = 0;

  /// Duration for popup card if user succes to payment
  StartTime() async {
    return Timer(Duration(seconds: 7), navigator);
  }

  /// Navigation to route after user succes payment
  void navigator() {
    Navigator.of(context).pushReplacement(PageRouteBuilder(
        pageBuilder: (_, __, ___) => new bottomNavigationBar()));
  }

  getDeliveryOptions() {
    Firestore.instance
        .collection("db")
        .document("tacadmin")
        .collection("delivery")
        .getDocuments()
        .then((query) {
      query.documents.forEach((doc) {
        Map<String, dynamic> data = doc.data;
        if (!mounted) return;
        setState(() {
          deliveryOptions.add(data['name']);
          deliveryOptionsMap.add(data);
        });
      });
    });
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url,
          enableDomStorage: true,
          forceWebView: true,
          enableJavaScript: true,
          statusBarBrightness: Brightness.dark);
    } else {
//      throw 'Could not launch $url';
      new GeneralUtils()
          .neverSatisfied(context, 'Error', 'Cannot open parameter.');
    }
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
//    initPaystack();
  }

  Future<void> initPaystack() async {
    await PaystackPlugin.initialize(
        publicKey: "pk_test_8be8b3b21803dcb62514b6e55f3c6f90f4a74483");
  }

  void initFlutterWave() {
    http.get(
        'https://us-central1-taconlinegiftshop.cloudfunctions.net/getFlutterwaveKeys',
        headers: {'Authorization': 'api ATCNoQUGOoEvTwqWigCR'}).then((result) {
      dynamic resp = json.decode(result.body);
      public_key =
          "${resp['public_key']}"; //for test FLWPUBK_TEST-407af7e7116f735e90d8f87c23b2d205-X
      enc_key = "${resp['enc_key']}"; //for test FLWSECK_TESTee51a806e09f

//      getDeliveryOptions();
      setState(() {
        _inAsyncCall = false;
      });
    });
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
    taxValue = get_tax.data['tax_value'];
    new GeneralUtils().totalAmountInCartDouble().then((t) {
      ft = t;
      setState(() {
        _inAsyncCall = false;
      });
    });
//    new GeneralUtils().totalAmountInCartDouble().then((t) {
//      double mTax = ((GeneralUtils().country_priceDouble(t) * value) / 100);
//      finalT = mTax +
//          //GeneralUtils().country_priceDouble(2000.00) +
//          GeneralUtils().country_priceDouble(t);
//      setState(() {
//        tax = GeneralUtils().currencyFormattedMoneyDouble(mTax);
//        _tax = mTax;
//        //_delivery = GeneralUtils().country_priceDouble(2000.00);
//        final_amount = GeneralUtils().currencyFormattedMoneyDouble(finalT);
//        ft = GeneralUtils().country_priceDouble(finalT);
//      });
//
//      initFlutterWave(); //flutterwave initializer
//    });
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
        iconTheme: IconThemeData(color: Color(MyColors.primary_color)),
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
                    /**
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
                            color: Color(MyColors.primary_color),
                            fontFamily: ""),
                      ),
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
                      trailing: Container(
                        width: 150.0,
                        child: DropdownButton(
                          items: deliveryOptions.map((m) {
                            return DropdownMenuItem<String>(
                              value: m,
                              child: Text(
                                m,
                                textAlign: TextAlign.right,
                              ),
                            );
                          }).toList(),
                          onChanged: (String item) {
                            if (item == "select option") {
                              setState(() {
                                delivery_selected_note = "";
                                delivery_selected = item;
                              });
                              return;
                            }
                            setState(() {
                              delivery_selected = item;
                            });
                            deliveryOptionsMap.forEach((del) {
                              Map<String, dynamic> del_options = del;
                              String name = del_options['name'];
                              if (name == item) {
                                String amt = GeneralUtils()
                                    .currencyFormattedMoney(
                                        del_options['value']);
                                String desc =
                                    "${del_options['name']} (${del_options['description']}): $amt";
                                setState(() {
                                  delivery_selected_note = desc;
                                  delivery = new GeneralUtils()
                                      .currencyFormattedMoney(
                                          del_options['value']);
                                  _delivery = GeneralUtils()
                                      .country_priceDouble(double.parse(
                                          "${del_options['value']}"));
                                  final_amount = GeneralUtils()
                                      .currencyFormattedMoneyDouble(finalT +
                                          _delivery); //GeneralUtils().country_priceDouble(2000.00)
                                  ft = GeneralUtils()
                                      .country_priceDouble(finalT + _delivery);
                                });
                              }
                            });
                          },
                          value: delivery_selected,
                          hint: Text(
                            'select option',
                            textAlign: TextAlign.right,
                          ),
                          underline: Divider(
                            height: 0.0,
                            color: Colors.white,
                          ),
                          isExpanded: true,
                          style: TextStyle(
                              letterSpacing: 0.1,
                              fontSize: 18.0,
                              color: Colors.black,
                              fontFamily: ""),
                        ),
                      ),
//                      Text(
//                        delivery,
//                        style: TextStyle(
//                            letterSpacing: 0.1,
//                            fontWeight: FontWeight.bold,
//                            fontSize: 18.0,
//                            color: Colors.black,
//                            fontFamily: ""),
//                      ),
                    ),
                    Text(
                      delivery_selected_note,
                      style: TextStyle(
                          letterSpacing: 0.1,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                          color: Colors.black,
                          fontFamily: ""),
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
                        total_amount, //final_amount,
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
                        final res = ss.getItem('currency');
                        Map<String, dynamic> data = jsonDecode(res);
                        String curr = data['currency_name'];
                        if(curr != 'USD' || curr != 'CAD' || curr != 'EUR' || curr != 'GBP'){
                          payNow();
                          return;
                        }
                        String ru = ss.getItem('retry_url');
                        String k = ss.getItem('retry_key');
                        if (ru.isEmpty) {
                          uploadDataAndOpenPaymentDialog();
                        } else {
                          openBrowserPayment(ru, k);
                        }
                        //addOrderToFirebase("249347845");
                      },
                      child: Container(
                        height: 55.0,
                        margin:
                            EdgeInsets.only(left: 20.0, right: 20.0, top: 40.0),
                        decoration: BoxDecoration(
                            color: Color(MyColors.primary_color),
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

  openBrowserPayment(String url, String key) async {
//    setState(() {
//      _inAsyncCall = true;
//    });
    Firestore.instance
        .collection('orders')
        .document(key)
        .snapshots()
        .listen((_data) async {
      if (_data.data == null) {
        return;
      }
      Map<String, dynamic> dt = _data.data;
      String ps = dt['payment_status'];
      if (ps == 'paid') {
//        if(widget.browser.isOpened()){
//          widget.browser.onClosed();
//        }
        updateStockLevelForProduct();
//        setState(() {
//          _inAsyncCall = false;
//        });
        ss.deletePref('retry_url');
        ss.deletePref('retry_key');
        new GeneralUtils().showToast('Payment made successfully. Thank you for choosing TAC.');
        _showDialog(context);
        StartTime();
      }
    });
    await widget.browser.open(
        url: url,
        options: ChromeSafariBrowserClassOptions(
            androidChromeCustomTabsOptions:
                AndroidChromeCustomTabsOptions(addShareButton: false, showTitle: true, toolbarBackgroundColor: '#EC008C'),
            iosSafariOptions: IosSafariOptions(barCollapsingEnabled: true))).catchError((err){
      _launchURL(url);
    });
  }

  uploadDataAndOpenPaymentDialog() {
    setState(() {
      _inAsyncCall = true;
    });
    final res = ss.getItem('currency');
    Map<String, dynamic> data = jsonDecode(res);
    String curr = data['currency'];
    String country = data['country'];
    String ex_rate = "${data['exchange_rate']}";
    String reference =
        '${Random().nextInt(9999)}${Random().nextInt(9999)}'; //FirebaseDatabase.instance.reference().push().key;
    DateTime dt = DateTime.now();
    final key = FirebaseDatabase.instance.reference().push().key;
    final track =
        double.parse('${Random().nextInt(99999)}${Random().nextInt(99999)}')
            .ceil();
    List<dynamic> track_details = new List();
    final mT = Tracking('Order Placed', 'We have received your order', 'start',
        '${dt.month}/${dt.day}/${dt.year} - ${dt.hour}:${dt.minute}:${dt.second}');
    track_details.add(mT.toJSON());

    var other_payment_details = {
      'tax_value': taxValue,
      'tax': 0,
      'delivery': 0,
      'delivery_type': ''
    };

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

    String retryUrl =
        'https://tacgifts.com/home/checkout/success?orderrefno=$reference&orderkey=$key';

    var order = {
      'carts': product,
      'currency_used': curr,
      'conversion_rate': ex_rate,
      'payment_gateway_fee': 0,
      'merchant_fee': 0,
      'payment_gateway_used': 'none',
      'order_platform': 'mobile_app',
      'transaction_id': double.parse(reference).ceil(),
      'id': key,
      'country': country,
      'email': widget.details['email'],
      'created_date':
          '${months[dt.month - 1]} ${dt.day}, ${dt.year} - ${dt.hour}:${dt.minute}:${dt.second}',
      'timestamp': FieldValue.serverTimestamp(),
      'track_id': track,
      'status': 'pending',
      'payment_status': 'unpaid',
      'total_amount': ft,
      'shipping_details': widget.details,
      'gift_card_style': '',
      'tracking_details': track_details,
      'other_payment_details': other_payment_details,
      'retry_url': retryUrl
    };

    Firestore.instance
        .collection('orders')
        .document(key)
        .setData(order)
        .then((d) {
      setState(() {
        _inAsyncCall = false;
      });
      ss.setPrefItem("retry_url", retryUrl);
      ss.setPrefItem("retry_key", key);
      openBrowserPayment(retryUrl, key);
    }).catchError((err) {
      setState(() {
        _inAsyncCall = false;
      });
      new GeneralUtils()
          .neverSatisfied(context, 'Error', 'An error occured, try again');
    });
  }

  String setupCurrencyAndCountry() {
    final res = ss.getItem('currency');
    Map<String, dynamic> data = jsonDecode(res);
    String curr = data['currency_name'];
    String o_currency = (curr == "₦") ? "NGN" : curr;
    String o_country = "NG";
    switch (o_currency) {
      case 'KES':
        o_country = 'KE';
        break;
      case 'GHS':
        o_country = 'GH';
        break;
      case 'ZAR':
        o_country = 'ZA';
        break;
      case 'TZS':
        o_country = 'TZ';
        break;

      default:
        o_country = 'NG';
        break;
    }
    return o_country;
  }

  payNow() async {
//    if (delivery_selected == "select option") {
//      new GeneralUtils()
//          .neverSatisfied(context, 'Notice', 'Please select delivery option');
//      return;
//    }
    final res = ss.getItem('currency');
    Map<String, dynamic> data = jsonDecode(res);
    String curr = data['currency_name'];
    String ex_rate = "${data['exchange_rate']}";
    String reference =
        '${Random().nextInt(9999)}${Random().nextInt(9999)}'; //FirebaseDatabase.instance.reference().push().key;
    if (isCharged) {
      verifyTransaction(ref, card, ex_rate);
      return;
    }
    String country = setupCurrencyAndCountry();
    //flutterwave charge
    // Get a reference to RavePayInitializer
    var initializer = RavePayInitializer(
        amount: ft,
        publicKey: public_key,
        encryptionKey:
            enc_key) // companyName: Text('TAC GIFTS'), companyLogo: Image.network('https://tacgifts.com/assets/images/icon/logo.png'))
      ..country = country
      ..currency = (curr == "₦") ? "NGN" : curr
      ..email = widget.details['email']
      ..fName = widget.details['firstname']
      ..lName = widget.details['lastname']
      ..txRef = reference
      ..displayEmail = false
      ..displayAmount = false
      ..acceptMpesaPayments = true
      ..acceptAccountPayments = true
      ..acceptCardPayments = true
      ..acceptAchPayments = true
      ..acceptGHMobileMoneyPayments = true
      ..acceptUgMobileMoneyPayments = true
      ..staging = false
      ..isPreAuth = false
      ..displayFee = true
      ..payButtonText = "PAY NOW";

    try {
      // Initialize and get the transaction result
      RaveResult response = await RavePayManager()
          .initialize(context: context, initializer: initializer);
//      print(response);
//      return;
      if (response.status == RaveStatus.success) {
        setState(() {
          isCharged = true;
          ref = reference;
          card = "";
        });
        verifyTransaction(ref, "", ex_rate); //response.card.last4Digits
        return;
      }
      if (response.status == RaveStatus.error) {
        new GeneralUtils()
            .neverSatisfied(context, 'Payment Error', response.message);
        return;
      }
      if (response.status == RaveStatus.cancelled) {
        new GeneralUtils()
            .neverSatisfied(context, 'Payment Cancelled', response.message);
        return;
      }
    } catch (e) {
      setState(() {
        _inAsyncCall = false;
      });
      new GeneralUtils().neverSatisfied(context, 'Error', e.toString());
    }

    //String accessCode = '${Random().nextInt(9999999)}';
//    Charge charge = Charge()
//      ..amount = (ft * 100).toInt()
//      ..reference = reference
//      ..currency = (curr == "₦") ? "NGN" : curr//NGNchange to curr afterwards
//      // or ..accessCode = _getAccessCodeFrmInitialization()
//      ..email = widget.details['email'];
//    try {
//      CheckoutResponse response = await PaystackPlugin.checkout(context,
//          charge: charge, method: CheckoutMethod.card, fullscreen: true);
//      if (!response.status) {
//        new GeneralUtils()
//            .neverSatisfied(context, 'Payment Error', response.message);
//      } else {
//        setState(() {
//          isCharged = true;
//          ref = response.reference;
//          card = response.card.last4Digits;
//        });
//        verifyTransaction(response.reference, response.card.last4Digits, ex_rate);
//      }
//    } catch (e) {
//      setState(() {
//        _inAsyncCall = false;
//      });
//      new GeneralUtils().neverSatisfied(context, 'Error', e.toString());
//    }
  }

  void verifyTransaction(
      String reference, String cardNumber, String exchangeRate) {
    setState(() {
      _inAsyncCall = true;
    });
    /*https://api.paystack.co/transaction/verify/ Bearer sk_test_52b35d5eaa9f39c9411d14d9e5fb336602fc8773
    , body: {
      "txref": reference,
      "SECKEY": "FLWSECK_TEST-38fd24d95eddb03b581c35199aee2093-X"
    }
    'https://api.ravepay.co/flwv3-pug/getpaidx/api/v2/verify'
    */
    http.get(
        'https://us-central1-taconlinegiftshop.cloudfunctions.net/verifyTransaction?ref=$reference',
        headers: {'Authorization': 'api ATCNoQUGOoEvTwqWigCR'}).then((resp) {
//      print(res.body);
      Map<String, dynamic> res = json.decode(resp.body);

      if (res['error'] != null) {
        setState(() {
          _inAsyncCall = false;
        });
        new GeneralUtils().neverSatisfied(
            context, 'Error', 'Payment not successful. Please try again.');
        return;
      }

//      bool status = resp['status'];
//      String message = resp['message'];
//      Map<String, dynamic> dt = resp['data'];
//      String statusMessage = dt['status'];

      Map<String, dynamic> data = res['data'];
      String message = data['status'];
      String cc = data['chargecode'];
      dynamic amt = data['amount'];
      String curr = data['currency'];
      dynamic appfee = data['appfee'];
      dynamic _mf = data['amountsettledforthistransaction'];

      if (message == "successful" && (cc == '00' || cc == '0')) {
        //run other operation
        addOrderToFirebase(reference, exchangeRate, appfee, _mf);
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

  void addOrderToFirebase(String orderId, String exchangeRate, dynamic appfee,
      dynamic merchant_fee) {
    final res = ss.getItem('currency');
    Map<String, dynamic> data = jsonDecode(res);
    String curr = data['currency'];
    String country = data['country'];
    DateTime dt = DateTime.now();
    final key = FirebaseDatabase.instance.reference().push().key;
    final track =
        double.parse('${Random().nextInt(99999)}${Random().nextInt(99999)}')
            .ceil();
    //FirebaseDatabase.instance.reference().push().key.substring(1, 6);
    List<dynamic> track_details = new List();
    final mT = Tracking('Order Placed', 'We have received your order', 'start',
        '${dt.month}/${dt.day}/${dt.year} - ${dt.hour}:${dt.minute}:${dt.second}');
    track_details.add(mT.toJSON());

    var other_payment_details = {
      'tax': _tax,
      'delivery': _delivery,
      'delivery_type': delivery_selected
    };

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
      'conversion_rate': exchangeRate,
      'payment_gateway_fee': appfee,
      'merchant_fee': merchant_fee,
      'payment_gateway_used': 'flutterwave',
      'order_platform': 'mobile_app',
      'transaction_id': double.parse(orderId).ceil(),
      'id': key,
      'country': country,
      'email': widget.details['email'],
      'created_date':
          '${months[dt.month - 1]} ${dt.day}, ${dt.year} - ${dt.hour}:${dt.minute}:${dt.second}',
      'timestamp': FieldValue.serverTimestamp(),
      'track_id': track,
      'status': 'pending',
      'total_amount': ft,
      'shipping_details': widget.details,
      'gift_card_style': '',
      'tracking_details': track_details,
      'other_payment_details': other_payment_details
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
      if (gift_items != null) {
        for (dynamic gi in gift_items) {
          var gi_id = gi['id'];
          if (gi_id != null) {
            runFireStoreTransaction(gi_id);
          }
        }
      }
    });
    GeneralUtils().clearCart();
  }

  runFireStoreTransaction(String id) {
    Firestore.instance
        .collection('db')
        .document('tacadmin')
        .collection('items')
        .document(id)
        .updateData(<String, dynamic>{'stock_level': FieldValue.increment(-1)});
//    Firestore.instance.runTransaction((t) async {
//      var doc = await t.get(itemRef);
//      var newstock_level = doc.data['stock_level'] - 1;
//      t.update(itemRef, {'stock_level': newstock_level});
//    });
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
        _showDialog(context);
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
_showDialog(BuildContext ctx) {
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
            "Great!!",
            style: _txtCustomHead,
          ),
        )),
        Center(
            child: Padding(
          padding: const EdgeInsets.only(top: 30.0, bottom: 40.0),
          child: Text(
            "Your order has been received.\nYou should get a mail shortly.",
            style: _txtCustomSub,
          ),
        )),
      ],
    ),
  );
}

class MyInAppBrowser extends InAppBrowser {
  @override
  Future onLoadStart(String url) async {
//    print("\n\nStarted $url\n\n");
  }

  @override
  Future onLoadStop(String url) async {
//    print("\n\nStopped $url\n\n");
  }

  @override
  void onLoadError(String url, int code, String message) {
//    print("\n\nCan't load $url.. Error: $message\n\n");
  }

  @override
  void onExit() {
    print("\n\nBrowser closed!\n\n");
  }
}

class MyChromeSafariBrowser extends ChromeSafariBrowser {
  MyChromeSafariBrowser(browserFallback) : super(bFallback: browserFallback);

  @override
  void onOpened() {
    print("ChromeSafari browser opened");
  }

  @override
  void onLoaded() {
    print("ChromeSafari browser loaded");
  }

  @override
  void onClosed() {
    browserFallback.close();
    print("ChromeSafari browser closed");
  }
}
