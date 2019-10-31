import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:treva_shop_flutter/ListItem/GiftBaskets.dart';
import 'package:treva_shop_flutter/Utils/backgroud_utils.dart';
import 'package:treva_shop_flutter/Utils/storage.dart';

class GeneralUtils {
  StorageSystem ss;

  List<dynamic> cartItems = new List();

  GeneralUtils() {
    ss = new StorageSystem();
    String cart = ss.getItem('cartItems');
    if (cart.isNotEmpty) {
      cartItems = jsonDecode(cart);
    }
  }

  String formattedMoney(double price, String currency) {
    MoneyFormatterOutput mfo = FlutterMoneyFormatter(
            amount: price,
            settings: MoneyFormatterSettings(
                symbol: currency,
                thousandSeparator: ',',
                decimalSeparator: '.',
                symbolAndNumberSeparator: '',
                fractionDigits: 2,
                compactFormatType: CompactFormatType.short))
        .output;
    return mfo.symbolOnLeft;
  }

  double country_price(int price) {
    final res = ss.getItem('currency');

    Map<String, dynamic> data = jsonDecode(res);

    final exchange_rate = data['exchange_rate'];

    return price / exchange_rate;
  }

  double country_priceDouble(double price) {
    final res = ss.getItem('currency');

    Map<String, dynamic> data = jsonDecode(res);

    final exchange_rate = data['exchange_rate'];

    return price / exchange_rate;
  }

  String currencyFormattedMoney(int price) {
    double normalizedPrice = country_price(price);

    final res = ss.getItem('currency');
    Map<String, dynamic> data = jsonDecode(res);
    String curr = data['currency'];
    if (curr == '₦') {
      return '${formattedMoney(normalizedPrice, 'NGN')}';
    }
    return '${formattedMoney(normalizedPrice, '\$')}';
  }

  String currencyFormattedMoneyDouble(double price) {
    double normalizedPrice = country_priceDouble(price);

    final res = ss.getItem('currency');
    Map<String, dynamic> data = jsonDecode(res);
    String curr = data['currency'];
    if (curr == '₦') {
      return '${formattedMoney(normalizedPrice, 'NGN')}';
    }
    return '${formattedMoney(normalizedPrice, '\$')}';
  }

  List<dynamic> getCartItems() {
    return cartItems;
  }

  String addToCart(Products pro, int quantity) {
    if (hasItemInCart(pro)) {
      return 'Item already in cart';
    }
    Map<String, dynamic> newCart = Map();
    newCart['product'] = pro.toJSON();
    newCart['quantity'] = quantity;
    cartItems.add(newCart);
    ss.setPrefItem('cartItems', jsonEncode(cartItems));
    return 'Item added to cart';
  }

  String updateCart(Products pro, int quantity) {

    if(quantity > pro.stock){
      return 'Only ${pro.stock} items can be added to cart.';
    }

    List<dynamic> updatedCart = new List();

    cartItems.forEach((cart) {
      Map<String, dynamic> item = cart['product'];
      if (item['id'] == pro.id) {
        Map<String, dynamic> uCart = Map();
        uCart['product'] = pro.toJSON();
        uCart['quantity'] = quantity;
        updatedCart.add(uCart);
      } else {
        updatedCart.add(cart);
      }
    });
    ss.setPrefItem('cartItems', jsonEncode(updatedCart));
    return 'Item updated.';
  }

  void removeCart(int position) {
    cartItems.removeAt(position);
    ss.setPrefItem('cartItems', jsonEncode(cartItems));
  }

  bool hasItemInCart(Products pro) {
    bool isAdded = false;
    if (cartItems.isEmpty) {
      return false;
    }
    cartItems.forEach((cart) {
      Map<String, dynamic> item = cart['product'];
      if (item['id'] == pro.id) {
        isAdded = true;
      }
    });
    return isAdded;
  }

  Future<String> totalAmountInCart() {
    int prices = 0;
    cartItems.forEach((cart) {
      Map<String, dynamic> item = cart['product'];
      int quantity = cart['quantity'];
      prices += (item['price'] * quantity);
    });
    return Future.value(currencyFormattedMoney(prices));
  }

  Future<double> totalAmountInCartDouble() {
    double prices = 0;
    cartItems.forEach((cart) {
      Map<String, dynamic> item = cart['product'];
      int quantity = cart['quantity'];
      prices += (item['price'] * quantity);
    });
    return Future.value(prices);
  }

  int cartSize() {
    return cartItems.length;
  }

  void clearCart() {
    ss.setPrefItem('cartItems', '');
  }

  Future<List<Products>> searchByCategory(String category_id) async {
    List<Products> productsByCategory = new List();
    List<Products> products = await new Utils().getProducts();
    products.forEach((pro){
      if(pro.category.contains(category_id)){
        productsByCategory.add(pro);
      }
    });
    return productsByCategory;
  }

  Future<Null> neverSatisfied(BuildContext context, String _title, String _body) async {
    return showDialog<Null>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text(_title),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                new Text(_body),
              ],
            ),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
