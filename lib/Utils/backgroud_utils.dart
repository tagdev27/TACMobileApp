import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:treva_shop_flutter/ListItem/GiftBaskets.dart';
import 'package:treva_shop_flutter/ListItem/Rev.dart';
import 'package:treva_shop_flutter/ListItem/category.dart';
import 'package:treva_shop_flutter/Utils/storage.dart';

class Utils {
  String currency = '₦', country = 'Nigeria';
  double exchange_rate = 1;

  Utils();

  void getUserIpDetails() {
    StorageSystem ss = new StorageSystem();
    http.get('http://ip-api.com/json').then((res) async { //https://ipapi.co/json
      if (res.body.isNotEmpty) {
        dynamic r = json.decode(res.body);
        country = r['country'];//country_name
        Firestore.instance
            .collection('db')
            .document('tacadmin')
            .collection('currency')
            .where('country', isEqualTo: country)
            .getDocuments()
            .then((query) async {
          if (query.documents.length > 0) {
            Map<String, dynamic> curr = query.documents[0].data;
            exchange_rate = (curr['exchange_rate'] == 1)
                ? curr['exchange_rate'] * 1.0
                : curr['exchange_rate'];
            currency = curr['symbol'];
            Map<String, dynamic> dataSave = new Map();
            dataSave['currency'] = currency;
            dataSave['currency_name'] = curr['name'];
            dataSave['country'] = country;
            dataSave['exchange_rate'] = exchange_rate;
            ss.setPrefItem('currency', jsonEncode(dataSave));
            //ss.disposePref();
          }else {
            dynamic curr = await getCurrencyForUnKnownCountries();
            Map<String, dynamic> dataSave = new Map();
            dataSave['currency'] = '\$';
            dataSave['currency_name'] = 'USD';
            dataSave['country'] = country;
            dataSave['exchange_rate'] = curr['exchange_rate'];//365.0;
            ss.setPrefItem('currency', jsonEncode(dataSave));
          }
        });
      }else {
        dynamic curr = await getCurrencyForUnKnownCountries();
        Map<String, dynamic> dataSave = new Map();
        dataSave['currency'] = '\$';
        dataSave['currency_name'] = 'USD';
        dataSave['country'] = country;
        dataSave['exchange_rate'] = curr['exchange_rate'];//365.0;
        ss.setPrefItem('currency', jsonEncode(dataSave));
      }
    });
  }

  Future<dynamic> getCurrencyForUnKnownCountries() async {
    DocumentSnapshot ref = await Firestore.instance.collection('db').document('tacadmin').collection('currency').document('-LhzMHbxXOyF-jwOYyGF').get();
    return ref.data;
  }

  //List all products
  Future<List<Products>> getProducts() async {
    StorageSystem ss = new StorageSystem();
    var result = await http.get(
        'https://us-central1-taconlinegiftshop.cloudfunctions.net/get_all_products?action=get',
        headers: {'Authorization': 'api ATCNoQUGOoEvTwqWigCR'});

    ss.setPrefItem('all_products', result.body);

    List<dynamic> listPro = json.decode(result.body);

    List<Products> finalProducts = new List();

    listPro.forEach((product) async {

      final reviews = await getReviews(product['key']);

      double total_rating = 0;

      if(reviews.isNotEmpty){
        double tr = 0;
        reviews.forEach((rev){
          tr += rev.rating;
        });
        total_rating = tr / reviews.length;
      }

      Products p = new Products(
          id: product['id'],
          key: product['key'],
          name: product['name'],
          price: product['price'],
          salePrice: product['salePrice'],
          discount: product['discount'],
          pictures: product['pictures'],
          shortDetails: product['shortDetails'],
          description: product['description'],
          stock: product['stock'],
          is_new: product['new'],
          sale: product['sale'],
          category: product['category'],
          colors: product['colors'],
          size: product['size'],
          tags: product['tags'],
          variants: product['variants'],
          items: product['items'],
          scheduled_sales_period: product['scheduled_sales_period'],
          weight: product['weight'],
          created_date: product['created_date'],
          modified_date: product['modified_date'],
          created_by: product['created_by'],
          dynamic_link: product['dynamic_link'],
          menu_link: product['menu_link'],
          deleted: product['deleted'],
          ratingTotal: reviews.length,
          ratingValue: total_rating);
      finalProducts.add(p);
    });
    return finalProducts;
  }

  //List al products by category id
  Future<List<Products>> getProductsByCategoryID(String sub_cat_id) async {
//    var result = await http.get(
//        'https://us-central1-taconlinegiftshop.cloudfunctions.net/get_all_products?action=get',
//        headers: {'Authorization': 'api ATCNoQUGOoEvTwqWigCR'});
//
//    List<dynamic> listPro = json.decode(result.body);

    List<Products> listPro = await getProducts();

    List<Products> finalProducts = new List();

    listPro.forEach((product) async {

      final reviews = await getReviews(product.key);

      double total_rating = 0;

      if(reviews.isNotEmpty){
        double tr = 0;
        reviews.forEach((rev){
          tr += rev.rating;
        });
        total_rating = tr / reviews.length;
      }

      List<String> categories = "${product.category}".split(',');

      if(categories.contains(sub_cat_id)) {
        Products p = new Products(
            id: product.id,
            key: product.key,
            name: product.name,
            price: product.price,
            salePrice: product.salePrice,
            discount: product.discount,
            pictures: product.pictures,
            shortDetails: product.shortDetails,
            description: product.description,
            stock: product.stock,
            is_new: product.is_new,
            sale: product.sale,
            category: product.category,
            colors: product.colors,
            size: product.size,
            tags: product.tags,
            variants: product.variants,
            items: product.items,
            scheduled_sales_period: product.scheduled_sales_period,
            weight: product.weight,
            created_date: product.created_date,
            modified_date: product.modified_date,
            created_by: product.created_by,
            dynamic_link: product.dynamic_link,
            menu_link: product.menu_link,
            deleted: product.deleted,
            ratingTotal: reviews.length,
            ratingValue: total_rating);
        finalProducts.add(p);
      }
    });
    return finalProducts;
  }

  //Get all categories
  Future<List<Category>> getCategories() async {
    var query = await Firestore.instance
        .collection('db')
        .document('tacadmin')
        .collection('sub-categories')
        .where('deleted', isEqualTo: false)
        .getDocuments();

    List<Category> category = new List();

    query.documents.forEach((snapshot) {
      Map<String, dynamic> cat = snapshot.data;

      Category c = new Category(
          id: cat['id'],
          main_category_id: cat['main_category_id'],
          name: cat['name'],
          description: cat['description'],
          created_date: cat['created_date'],
          created_by: cat['created_by'],
          image: cat['image'],
          deleted: cat['deleted'],
          meta: cat['meta'],
          modified_date: cat['modified_date'],
          link: cat['link'],
          merchant: cat['merchant']);
      category.add(c);
    });

    return category;
  }

  //Get all reviews
  Future<List<Reviews>> getReviews(String key) async {
    var query = await Firestore.instance
        .collection('reviews')
        .where('product_id', isEqualTo: key)
        .getDocuments();

    List<Reviews> reviews = new List();

    query.documents.forEach((snapshot) {
      Map<String, dynamic> r = snapshot.data;

      Reviews rev = new Reviews(
          id: r['id'],
          name: r['name'],
          email: r['email'],
          title: r['title'],
          text: r['text'],
          rating: r['rating'],
          created_date: r['created_date'],
          product_id: r['product_id']);
      reviews.add(rev);
    });

    return reviews;
  }

  //Get products stored locally on device
  List<Products> getLocalProducts(){
    StorageSystem ss = new StorageSystem();
    String getP = ss.getItem('all_products');
    List<dynamic> listPro = json.decode(getP);

    List<Products> finalProducts = new List();

    listPro.forEach((product) async {

      final reviews = await getReviews(product['key']);

      double total_rating = 0;

      if(reviews.isNotEmpty){
        double tr = 0;
        reviews.forEach((rev){
          tr += rev.rating;
        });
        total_rating = tr / reviews.length;
      }

      Products p = new Products(
          id: product['id'],
          key: product['key'],
          name: product['name'],
          price: product['price'],
          salePrice: product['salePrice'],
          discount: product['discount'],
          pictures: product['pictures'],
          shortDetails: product['shortDetails'],
          description: product['description'],
          stock: product['stock'],
          is_new: product['new'],
          sale: product['sale'],
          category: product['category'],
          colors: product['colors'],
          size: product['size'],
          tags: product['tags'],
          variants: product['variants'],
          items: product['items'],
          scheduled_sales_period: product['scheduled_sales_period'],
          weight: product['weight'],
          created_date: product['created_date'],
          modified_date: product['modified_date'],
          created_by: product['created_by'],
          dynamic_link: product['dynamic_link'],
          menu_link: product['menu_link'],
          deleted: product['deleted'],
          ratingTotal: reviews.length,
          ratingValue: total_rating);
      finalProducts.add(p);
    });
    return finalProducts;
  }

  //Get products similar with the current product using categories to compare
  List<Products> getRelatedProducts(List<Products> all_products, String current_product_category) {
    List<Products> related = new List();

    //print(current_product_category);

    //List<Products> all_products = getLocalProducts();

    //print('all_products = ${all_products.length}');

    all_products.forEach((pro){
      List<String> curr_cat_split = current_product_category.split(',');
      List<String> pro_cat_split = pro.category.split(',');
      if(pro_cat_split.contains(current_product_category)){
        related.add(pro);
      }
//      print('added = ${related.length}');
//      for(int i = 0; i < curr_cat_split.length; i++){
//        for(int j = 0; j < pro_cat_split.length; j++){
//          if(curr_cat_split[i] == pro_cat_split[j]){
//            if(!related.contains(pro)) {
//              related.add(pro);
//            }
//          }
//        }
//      }
    });

    return related;
  }

  //Get sub-categories by main-category id
  Future<List<Category>> getSubCategoriesFromMainCategoryID(String main_category_id) async{

    var query = await Firestore.instance
        .collection('db')
        .document('tacadmin')
        .collection('sub-categories')
        .where('deleted', isEqualTo: false)
        .where('main_category_id', isEqualTo: main_category_id)
        .getDocuments();

    List<Category> sub_category = new List();

    query.documents.forEach((snapshot) {
      Map<String, dynamic> cat = snapshot.data;

      Category c = new Category(
          id: cat['id'],
          main_category_id: cat['main_category_id'],
          name: cat['name'],
          description: cat['description'],
          created_date: cat['created_date'],
          created_by: cat['created_by'],
          image: cat['image'],
          deleted: cat['deleted'],
          meta: cat['meta'],
          modified_date: cat['modified_date'],
          link: cat['link'],
          merchant: cat['merchant']);
      sub_category.add(c);
    });

    return sub_category;

  }
}
