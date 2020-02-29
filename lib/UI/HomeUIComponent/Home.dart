import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';
import 'package:treva_shop_flutter/Library/carousel_pro/carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:treva_shop_flutter/ListItem/FlashSaleItem.dart';
import 'package:treva_shop_flutter/ListItem/GiftBaskets.dart';
import 'package:treva_shop_flutter/ListItem/HomeGridItemRecomended.dart';
import 'package:treva_shop_flutter/ListItem/category.dart';
import 'package:treva_shop_flutter/ListItem/main-category.dart';
import 'package:treva_shop_flutter/UI/HomeUIComponent/AppbarGradient.dart';
import 'package:treva_shop_flutter/Library/countdown/countdown.dart';
import 'package:treva_shop_flutter/UI/HomeUIComponent/CategoryDetail.dart';
import 'package:treva_shop_flutter/UI/HomeUIComponent/DetailProduct.dart';
import 'package:treva_shop_flutter/UI/HomeUIComponent/FlashSale.dart';
import 'package:treva_shop_flutter/UI/HomeUIComponent/MenuDetail.dart';
import 'package:treva_shop_flutter/UI/HomeUIComponent/MoreCategory.dart';
import 'package:treva_shop_flutter/UI/HomeUIComponent/MoreMenu.dart';
import 'package:treva_shop_flutter/UI/HomeUIComponent/PromotionDetail.dart';
import 'package:treva_shop_flutter/Utils/backgroud_utils.dart';
import 'package:treva_shop_flutter/Utils/colors.dart';
import 'package:treva_shop_flutter/Utils/general.dart';
import 'package:treva_shop_flutter/Utils/storage.dart';

class Menu extends StatefulWidget {
  @override
  _MenuState createState() => _MenuState();
}

/// Component all widget in home
class _MenuState extends State<Menu> with TickerProviderStateMixin {
  /// Declare class GridItem from HomeGridItemReoomended.dart in folder ListItem
  GridItem gridItem;

  bool isStarted = false;
  var hourssub, minutesub, secondsub;

  /// CountDown for timer
  CountDown hours, minutes, seconds;
  int days = 0, hourstime = 0, minute = 0, second = 0;

  /// Set for StartStopPress CountDown
  onStartStopPress() {
    if (this.secondsub == null) {
      secondsub = seconds.stream.listen(null);
      secondsub.onData((Duration d) {
        print(d);
        setState(() {
          second = d.inSeconds;
        });
      });
    }
    if (this.minutesub == null) {
      minutesub = minutes.stream.listen(null);
      minutesub.onData((Duration d) {
        print(d);
        setState(() {
          minute = d.inMinutes;
        });
      });
    }
    if (this.hourssub == null) {
      hourssub = hours.stream.listen(null);
      hourssub.onData((Duration d) {
        print(d);
        setState(() {
          hourstime = d.inHours;
        });
      });
    }
  }

  List<Products> products = new List();
  List<Products> productsLimited = new List();
  List<Products> salesProductsWithSchedule = new List();
  List<Category> subCategories = new List();
  
  List<MainCategory> menus = new List();

  StorageSystem ss = new StorageSystem();
  String country = '';

  //banners collection
  Map<String, dynamic> banners = new Map();

  /// To set duration initState auto start if FlashSale Layout open
  @override
  void initState() {
//    hours = new CountDown(new Duration(hours: 24));
//    minutes = new CountDown(new Duration(hours: 1));
//    seconds = new CountDown(new Duration(minutes: 1));
//
//    onStartStopPress();
    // TODO: implement initState
    super.initState();
    //getMainCategories();
    getBanners();
    getMainCategories();
    startOperations();
  }
  
  Future<void> getMainCategories() async {
    var query = await Firestore.instance.collection('db').document('tacadmin').collection('main-categories').where('deleted', isEqualTo: false).getDocuments();
    query.documents.forEach((snapshot){
      Map<String, dynamic> mn = snapshot.data;
      MainCategory mc = MainCategory(mn['id'], mn['name'], mn['image']);
      if(!mounted) return;
      setState(() {
        menus.add(mc);
      });
    });
  }

  Future<void> getBanners() async {
    var query = await Firestore.instance.collection('db').document('tacadmin').collection('settings').document('banners').get();
    if(!mounted) return;
    setState(() {
      banners = query.data;
    });
  }

  String getMenuIcon(String name){
    String nm = name.toLowerCase();
    if(nm == 'anniversary'){
      return 'assets/icon/camera.png';
    }
    return 'assets/icon/camera.png';
  }

  Future<void> startOperations() async {
    //get list of products
    final pro = await new Utils().getProducts();
    if(mounted){
      setState(() {
        products = pro;
        //if(pr)
//        for(int i =0; i < 10; i++) {
//          productsLimited = pro.sublist(0, 10);
//        }
      });
    }
    final cat = await new Utils().getCategories();
    if(mounted){
      setState(() {
        subCategories = cat;
      });
    }

    String res = ss.getItem('currency');
    if(res == ''){
      new Utils().getUserIpDetails();
    }
    res = ss.getItem('currency');
    //print('res = $res');
    Map<String, dynamic> data = jsonDecode(res);
    if(mounted){
      setState(() {
        country = data['country'];
      });
    }
  }

  String getMonth(String month) {
    int index = 0;
    List<String> mths = [
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

    for (int i = 0; i < mths.length; i++) {
      if (mths[i] == month) {
        index = i;
      }
    }
    int finalIndex = index + 1;
    if (finalIndex < 10) {
      return '0$finalIndex';
    }
    return '$finalIndex';
  }

  void getScheduleSales() {
    Products sale_product = salesProductsWithSchedule.last;

    String schedule_date_end =
        sale_product.scheduled_sales_period.split('-')[1];

    List<String> sc = schedule_date_end
        .substring(0, schedule_date_end.indexOf('G'))
        .split(' ');

//    print('a ==== ${sc[3]}');
//    print('b ==== ${getMonth(sc[1])}');
//    print('c ==== ${sc[2]}');

    //var endDate = new DateTime.utc(int.parse(sc[3]), getMonth(sc[1]) + 1, int.parse(sc[2]));
    var ed = DateTime.parse(
        '${sc[3]}-${getMonth(sc[1])}-${sc[2]} 00:00:00.000000'); //2019-07-30 08:45:58.876005

    Duration clock = ed.difference(DateTime.now());

    CountDown cd = CountDown(clock);
    var sub = cd.stream.listen(null);
    isStarted = true;
    sub.onData((Duration d) {
      int milli = d.inMilliseconds;
      if (mounted) {
        setState(() {
          days = milli ~/ (1000 * 60 * 60 * 24);
          hourstime = (milli % (1000 * 60 * 60 * 24)) ~/ (1000 * 60 * 60);
          minute = (milli % (1000 * 60 * 60)) ~/ (1000 * 60);
          second = (milli % (1000 * 60)) ~/ (1000);
        });
      }
    });
    //print('d ==== ${clock.inDays}');

//    hours = new CountDown(new Duration(hours: clock.inHours));
//    minutes = new CountDown(new Duration(minutes: clock.inMinutes));
//    seconds = new CountDown(new Duration(seconds: clock.inSeconds));

    //onStartStopPress();
  }



  @override
  Widget build(BuildContext context) {
    if (!isStarted) {
      products.forEach((p) {
        String schedule = p.scheduled_sales_period;
        if (schedule != '-' && p.sale) {//
          salesProductsWithSchedule.add(p);
        }
      });
      if (salesProductsWithSchedule.isNotEmpty) {
        getScheduleSales();
      }
    }
    MediaQueryData mediaQueryData = MediaQuery.of(context);
//    double size = mediaQueryData.size.height;

    /// Navigation to MenuDetail.dart if user Click icon in category Menu like a example camera
    var _onClickMenuIcon = (String id, String name, String image) {
//      Navigator.push(context, PageRouteBuilder(
//          pageBuilder: (_, __, ___) => new menuDetail(products, id, name, image)));
      Navigator.push(context, PageRouteBuilder(
          pageBuilder: (_, __, ___) => new menuDetail(products, id, name, image),
          transitionDuration: Duration(milliseconds: 750),

          /// Set animation with opacity
          transitionsBuilder:
              (_, Animation<double> animation, __, Widget child) {
            return Opacity(
              opacity: animation.value,
              child: child,
            );
          }));
    };

    var onClickMenuIcon = () {
      Navigator.of(context).push(PageRouteBuilder(
          pageBuilder: (_, __, ___) => new menuDetail(products, '', '',''),
          transitionDuration: Duration(milliseconds: 750),

          /// Set animation with opacity
          transitionsBuilder:
              (_, Animation<double> animation, __, Widget child) {
            return Opacity(
              opacity: animation.value,
              child: child,
            );
          }));
    };

    /// Navigation to promoDetail.dart if user Click icon in Week Promotion
    var onClickWeekPromotion = () {
      Navigator.push(context, PageRouteBuilder(
          pageBuilder: (_, __, ___) => new promoDetail(products),
          transitionDuration: Duration(milliseconds: 750),
          transitionsBuilder:
              (_, Animation<double> animation, __, Widget child) {
            return Opacity(
              opacity: animation.value,
              child: child,
            );
          }));
    };

    /// Navigation to categoryDetail.dart if user Click icon in Category
//    var onClickCategory = (String category_id) {
//      Navigator.of(context).push(PageRouteBuilder(
//          pageBuilder: (_, __, ___) => new categoryDetail(category_id),
//          transitionDuration: Duration(milliseconds: 750),
//          transitionsBuilder:
//              (_, Animation<double> animation, __, Widget child) {
//            return Opacity(
//              opacity: animation.value,
//              child: child,
//            );
//          }));
//    };

    /// Declare device Size
    var deviceSize = MediaQuery.of(context).size;

    /// ImageSlider in header
    var imageSlider = Container(
      height: 182.0,
      child: new Carousel(
        boxFit: BoxFit.cover,
        dotColor: Color(MyColors.primary_color).withOpacity(0.8),
        dotSize: 5.5,
        dotSpacing: 16.0,
        dotBgColor: Colors.transparent,
        showIndicator: true,
        overlayShadow: true,
        overlayShadowColors: Colors.white.withOpacity(0.9),
        overlayShadowSize: 0.9,
        images: [
          NetworkImage("${banners['social_tree_image']}"),
          NetworkImage("${banners['slider1_image']}"),
          NetworkImage("${banners['slider2_image']}"),
          NetworkImage("${banners['grid1_image']}"),
          NetworkImage("${banners['grid2_image']}"),
          NetworkImage("${banners['grid3_image']}"),
          NetworkImage("${banners['grid4_image']}"),
        ],
      ),
    );

    bool isNotStackOverFlowError(int currentIndex, int length) {
      return currentIndex <= length;
    }

    Widget loadMenu() {
      List<Widget> addMenus = new List();
      int index = 0;
      int number_of_rows = (menus.length ~/ 4) + (menus.length % 4);
      int len = menus.length;

      for(int i = 0; i < number_of_rows; i++){
        for(int j = 0; j < 4; j++) {
          bool check1 = isNotStackOverFlowError(j, 4);
          bool check2 = isNotStackOverFlowError(j, 4);
          bool check3 = isNotStackOverFlowError(j, 4);
          bool check4 = isNotStackOverFlowError(j, 4);

          addMenus.add(Padding(padding: EdgeInsets.only(top: 23.0)),);
          addMenus.add(CategoryIconValue(
            icon1: (check1) ? menus[(j + i)].icon : null,
            tap1: (check1) ? () {
              _onClickMenuIcon(menus[(j + i)].id, menus[(j + i)].name,'');
            } : null,
            title1: (check1) ? menus[(j + i)].name : null,

            icon2: (check2) ? menus[(1 + i)].icon : null,
            tap2: (check2) ? () {
              _onClickMenuIcon(menus[(1 + i)].id, menus[(1 + i)].name,'');
            } : null,
            title2: (check2) ? menus[(1 + i)].name : null,

            icon3: (check3) ? menus[(2 + i)].icon : null,
            tap3: (check3) ? () {
              _onClickMenuIcon(menus[(2 + i)].id, menus[(2 + i)].name,'');
            } : null,
            title3: (check3) ? menus[(2 + i)].name : null,

            icon4: (check4) ? menus[(3 + i)].icon : null,
            tap4: (check4) ? () {
              _onClickMenuIcon(menus[(3 + i)].id, menus[(3 + i)].name,'');
            } : null,
            title4: (check4) ? menus[(3 + i)].name : null,
          ),);
        }
      }
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: addMenus,
        ),
      );
    }

    //return main-category after checking if it exists
    MainCategory getMainCategoryByIndex(int index) {
      return (menus[index] == null) ? null : menus[index];
    }

    /// CategoryIcon Component
    Widget categoryIcon() {
      return Container(
        color: Colors.white,
        padding: EdgeInsets.only(top: 20.0),
        alignment: AlignmentDirectional.centerStart,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 20.0, top: 0.0),
                  child: Text(
                    "Menu",
                    style: TextStyle(
                        fontSize: 13.5,
                        fontFamily: "Sans",
                        fontWeight: FontWeight.w700),
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.only(left: 0.0, top: 0.0),
                    child: FlatButton(onPressed: () {
                      Navigator.push(context, PageRouteBuilder(
                          pageBuilder: (_, __, ___) =>
                          new MoreMenu(products, menus)));
                    }, child: Text(
                      "See More",
                      style: _customTextStyleBlue,
                    ))
                ),
              ],
            ),
            Padding(padding: EdgeInsets.only(top: 0.0)),
            //loadMenu(),
            /// Get class CategoryIconValue
//          CategoryIconValue(
//            tap1: (){
//              _onClickMenuIcon(getMainCategoryByIndex(0).id, getMainCategoryByIndex(0).name, getMainCategoryByIndex(0).icon);
//            },
//            icon1: getMainCategoryByIndex(0).icon,
//            title1: getMainCategoryByIndex(0).name,
//            id1: getMainCategoryByIndex(0).id,
//
//            tap2: (){
//              _onClickMenuIcon(getMainCategoryByIndex(1).id, getMainCategoryByIndex(1).name, getMainCategoryByIndex(1).icon);
//            },
//            icon2: getMainCategoryByIndex(1).icon,
//            title2: getMainCategoryByIndex(1).name,
//            id2: getMainCategoryByIndex(1).id,
//
//            tap3: (){
//              _onClickMenuIcon(getMainCategoryByIndex(2).id, getMainCategoryByIndex(2).name, getMainCategoryByIndex(2).icon);
//            },
//            icon3: getMainCategoryByIndex(2).icon,
//            title3: getMainCategoryByIndex(2).name,
//            id3: getMainCategoryByIndex(2).id,
//
//            tap4: (){
//              _onClickMenuIcon(getMainCategoryByIndex(3).id, getMainCategoryByIndex(3).name, getMainCategoryByIndex(3).icon);
//            },
//            icon4: getMainCategoryByIndex(3).icon,
//            title4: getMainCategoryByIndex(3).name,
//            id4: getMainCategoryByIndex(3).id,
//          ),
//          Padding(padding: EdgeInsets.only(top: 23.0)),
//          CategoryIconValue(
//            icon1: getMainCategoryByIndex(4).icon,
//            tap1: (){
//              _onClickMenuIcon(getMainCategoryByIndex(4).id, getMainCategoryByIndex(4).name, getMainCategoryByIndex(4).icon);
//            },
//            title1: getMainCategoryByIndex(4).name,
//            id1: getMainCategoryByIndex(4).id,
//
//            icon2: getMainCategoryByIndex(5).icon,
//            tap2: (){
//              _onClickMenuIcon(getMainCategoryByIndex(5).id, getMainCategoryByIndex(5).name, getMainCategoryByIndex(5).icon);
//            },
//            title2: getMainCategoryByIndex(5).name,
//            id2: getMainCategoryByIndex(5).id,
//
//            icon3: getMainCategoryByIndex(6).icon,
//            tap3: (){
//              _onClickMenuIcon(getMainCategoryByIndex(6).id, getMainCategoryByIndex(6).name, getMainCategoryByIndex(6).icon);
//            },
//            title3: getMainCategoryByIndex(6).name,
//            id3: getMainCategoryByIndex(6).id,
//
//            icon4: getMainCategoryByIndex(7).icon,
//            tap4: (){
//              _onClickMenuIcon(getMainCategoryByIndex(7).id, getMainCategoryByIndex(7).name, getMainCategoryByIndex(7).icon);
//            },
//            title4: getMainCategoryByIndex(7).name,
//            id4: getMainCategoryByIndex(7).id,
//          ),
            Padding(padding: EdgeInsets.only(top: 23.0)),
            CategoryIconValue(
              products: products,
              id1: (menus[0] != null) ? menus[0].id : '',
              id2: (menus[1] != null) ? menus[1].id : '',
              id3: (menus[2] != null) ? menus[2].id : '',
              id4: (menus[3] != null) ? menus[3].id : '',

              icon1: (menus[0] != null) ? menus[0].icon : '',
              icon2: (menus[1] != null) ? menus[1].icon : '',
              icon3: (menus[2] != null) ? menus[2].icon : '',
              icon4: (menus[3] != null) ? menus[3].icon : '',

              title1: (menus[0] != null) ? menus[0].name : '',
              title2: (menus[1] != null) ? menus[1].name : '',
              title3: (menus[2] != null) ? menus[2].name : '',
              title4: (menus[3] != null) ? menus[3].name : '',
//            id1: "-LnPVStbmzq8incIRg7T",
//            icon1: "https://firebasestorage.googleapis.com/v0/b/taconlinegiftshop.appspot.com/o/main-category%2Fgift_1.jpg?alt=media&token=379b5f16-b804-4408-a2c0-5d3956127652",
//            //tap1: _onClickMenuIcon("-LnPVStbmzq8incIRg7T", "Anniversary", "https://firebasestorage.googleapis.com/v0/b/taconlinegiftshop.appspot.com/o/main-category%2Fgift_1.jpg?alt=media&token=379b5f16-b804-4408-a2c0-5d3956127652"),
//            title1: "Anniversary",
//
//            id2: "-LnPVYrVP8qr7kECXBjJ",
//            icon2: "https://firebasestorage.googleapis.com/v0/b/taconlinegiftshop.appspot.com/o/main-category%2Fgift_2.jpg?alt=media&token=0b8a61bc-959c-4a66-ad5f-f06b2c0a5111",
//            //tap2: _onClickMenuIcon("-LnPVYrVP8qr7kECXBjJ", "Birthday", "https://firebasestorage.googleapis.com/v0/b/taconlinegiftshop.appspot.com/o/main-category%2Fgift_2.jpg?alt=media&token=0b8a61bc-959c-4a66-ad5f-f06b2c0a5111"),
//            title2: "Birthday",
//
//            id3: "-LnPW-rPY2XGgtqShBCI",
//            icon3: "https://firebasestorage.googleapis.com/v0/b/taconlinegiftshop.appspot.com/o/main-category%2Fgift_5.jpg?alt=media&token=2f82fd60-5779-4308-bbb0-d5d6ff3207d5",
//            //tap3: _onClickMenuIcon("-LnPVdiwGifhYCS7yyBY", "Wine Gifts", "https://firebasestorage.googleapis.com/v0/b/taconlinegiftshop.appspot.com/o/main-category%2Fgift_3.jpg?alt=media&token=6aa1e22a-c25c-4d0e-9f2e-d094af3c30ac"),
//            title3: "Cooporate",
//
//            id4: "-LnPWEEYGFLc56K_YdMR",
//            icon4: "https://firebasestorage.googleapis.com/v0/b/taconlinegiftshop.appspot.com/o/main-category%2Fgift_20.jpg?alt=media&token=0bae1bbc-a5d7-4a11-bb2a-5a0d5c2ba57b",
//            //tap4: _onClickMenuIcon("-LnPVtl0WavW-1rWeZUd", "Congratulations", "https://firebasestorage.googleapis.com/v0/b/taconlinegiftshop.appspot.com/o/main-category%2Fgift_6.jpg?alt=media&token=e5671331-2706-42f9-a2d9-121dacab335e"),
//            title4: "Specials",
            ),

            Padding(padding: EdgeInsets.only(bottom: 30.0))
          ],
        ),
      );
    }

    // ListView a WeekPromotion Component dynamic data
    List<Widget> getPromoHorizontalList() {
      List<Widget> best_selling = new List();
        if (products.length > 5) {
          for (int i = 0; i < 5; i++) {
            Products p = products[i];
            best_selling.add(Padding(padding: EdgeInsets.only(left: 20.0)));
            best_selling.add(
              InkWell(
                  onTap: onClickWeekPromotion,
                  child: Image.network(
                    p.pictures[0],
                    height: 392.0,
                  )),
            );
          }
        }

//      products.sublist(0,3).forEach((p){
//
//      });

        return best_selling;
    }

    /// ListView a WeekPromotion Component
    var PromoHorizontalList = Container(
      color: Colors.white,
      height: 230.0,
      padding: EdgeInsets.only(bottom: 40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
              padding: EdgeInsets.only(left: 20.0, top: 15.0, bottom: 3.0),
              child: Text(
                "Best Selling",
                style: TextStyle(
                    fontSize: 15.0,
                    fontFamily: "Sans",
                    fontWeight: FontWeight.w700),
              )),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.only(top: 10.0),
              scrollDirection: Axis.horizontal,
              children: getPromoHorizontalList(),
            ) //: _loadingImageAnimationForBestSelling(context),
          ),
        ],
      ),
    );

    List<Widget> getFlashSell() {
      List<Widget> flash_sell = new List();

      flash_sell.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: mediaQueryData.padding.left + 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  "assets/img/flashsaleicon.png",
                  height: deviceSize.height * 0.087,
                ),
                Text(
                  "Flash",
                  style: TextStyle(
                    fontFamily: "Popins",
                    fontSize: 30.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "Sale",
                  style: TextStyle(
                    fontFamily: "Sans",
                    fontSize: 28.0,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.only(top: mediaQueryData.padding.top + 30),
                ),
                Text(
                  "End sale in :",
                  style: TextStyle(
                    fontFamily: "Sans",
                    fontSize: 15.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 2.0),
                ),

                /// Get a countDown variable
                Text(
                  days.toString() +
                      " : " +
                      hourstime.toString() +
                      " : " +
                      minute.toString() +
                      " : " +
                      second.toString(),
                  style: TextStyle(
                    fontFamily: "Sans",
                    fontSize: 19.0,
                    letterSpacing: 2.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            )
          ],
        ),
      );
      flash_sell.add(
        Padding(padding: EdgeInsets.only(left: 40.0)),
      );

      salesProductsWithSchedule.forEach((pro) {
        String price = new GeneralUtils().currencyFormattedMoney(pro.price);
        String salePrice =
            new GeneralUtils().currencyFormattedMoney(pro.salePrice);
        flash_sell.add(flashSaleItem(
          banners['parallax_banner_image'],
          price: salePrice,
          saleP: price,
          flashItem: pro,
          place: country,
          stock: "${pro.stock} Available",
          colorLine: (pro.stock <= 10) ? 0xFFFFA500 : 0xFF52B640,
          widthLine: (pro.stock <= 10) ? 50.0 : 100.0,
          salesList: salesProductsWithSchedule
        ));
        flash_sell.add(
          Padding(padding: EdgeInsets.only(left: 10.0)),
        );
      });

      return flash_sell;
    }

    /// FlashSale component
    var FlashSell = Container(
      height: 390.0,
      decoration: BoxDecoration(
        /// To set Gradient in flashSale background
        gradient: LinearGradient(colors: [
          Color(0xFF7F7FD5).withOpacity(0.8),
          Color(0xFF86A8E7),
          Color(0xFF91EAE4)
        ]),
      ),

      /// To set FlashSale Scrolling horizontal
      child:
          ListView(scrollDirection: Axis.horizontal, children: getFlashSell()),
    );

    /// Category Component in bottom of flash sale dynamic value

    List<Widget> getcategoryImageBottoms(int start, int end) {
      List<Widget> cate = new List();

      int index = 0;
      subCategories.sublist(0, 5).forEach((cat) {
        cate.add(Padding(padding: EdgeInsets.only(left: 10.0)));
        cate.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(padding: EdgeInsets.only(top: 15.0)),
              CategoryItemValue(
                products: products,
                image: (index < 2) ? subCategories[index].image : subCategories[index * 5].image,
                title: (index < 2) ? subCategories[index].name : subCategories[index * 5].name,
                id: (index < 2) ? subCategories[index].id : subCategories[index * 5].id,
//                tap: (){
//                  onClickCategory(subCategories[index].id);
//                },
              ),
              ((index + 2) < subCategories.length)
                  ? Padding(
                      padding: EdgeInsets.only(top: 10.0),
                    )
                  : Text(''),
              ((index + 2) < subCategories.length)
                  ? CategoryItemValue(
                products: products,
                      image: subCategories[index + 2].image,
                      title: subCategories[index + 2].name, //0 1 2 3 4 5 6
//                      tap: (){
//                        onClickCategory(subCategories[index + 2].id);
//                      },
                      id: subCategories[index + 2].id
                    )
                  : Text(''),
            ],
          ),
        );
        index = index + 1;
      });

      return cate;
    }

    /// Category Component in bottom of flash sale
    var categoryImageBottom = Container(
      height: 310.0,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 20.0, top: 0.0),
                child: Text(
                  "Category",
                  style: TextStyle(
                      fontSize: 13.5,
                      fontFamily: "Sans",
                      fontWeight: FontWeight.w700),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 0.0, top: 0.0),
                  child: FlatButton(onPressed: (){
                    Navigator.push(context, PageRouteBuilder(
                        pageBuilder: (_, __, ___) => new MoreCategory(products, 'All', sub_cat: subCategories, menus_id: null)));
                  }, child: Text(
                    "See More",
                    style: _customTextStyleBlue,
                  ))
              ),
            ],
          ),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: (subCategories.length > 5) ? getcategoryImageBottoms(0, 0) : [],
            ),
          )
        ],
      ),
    );

    ///  Grid item in bottom of Category
    var Grid = SingleChildScrollView(
      child: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 0.0, top: 0.0),
                  child: Text(
                    "Recommended",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 17.0,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 0.0, top: 0.0),
                  child: FlatButton(onPressed: (){
                    Navigator.push(context, PageRouteBuilder(
                        pageBuilder: (_, __, ___) => new promoDetail(products)));
                  }, child: Text(
                    "See More",
                    style: _customTextStyleBlue,
                  ))
                ),
              ],
            ),

            /// To set GridView item
      (products.length > 0) ? GridView.count(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 17.0,
              childAspectRatio: 0.545,
              crossAxisCount: 2,
              primary: false,
              children: products
                  .map((pro) => ItemGrid(products, pro, getProductPrice(pro)))
                  .toList(),
            ) : _loadingImageAnimation(context) //products.map((pro) => ItemGrid(pro))
          ],
        ),
      ),
    );

    return Scaffold(
      /// Use Stack to costume a appbar
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(
                        top: mediaQueryData.padding.top + 58.5)),

                /// Call var imageSlider
                (banners.isEmpty) ? Text('') : imageSlider,

                /// Call var categoryIcon
                (menus.length > 0) ? categoryIcon() : Text(''),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                ),

                /// Call var PromoHorizontalList
                (products.length > 5) ? PromoHorizontalList : Text(''),

                /// Call var a FlashSell, i am sorry Typo :v
                (salesProductsWithSchedule.isNotEmpty) ? FlashSell : Text(''),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                ),
                categoryImageBottom,
                Padding(
                  padding: EdgeInsets.only(bottom: 10.0),
                ),

                /// Call a Grid variable, this is item list in Recomended item
                Grid,
              ],
            ),
          ),

          /// Get a class AppbarGradient
          /// This is a Appbar in home activity
          AppbarGradient(products),
        ],
      ),
    );
  }

  String getProductPrice(Products pro) {
    return new GeneralUtils().currencyFormattedMoney(pro.price);
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
        Navigator.push(context, PageRouteBuilder(
            pageBuilder: (_, __, ___) => new detailProduk(all_products, gridItem),
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
                        Navigator.push(context, PageRouteBuilder(
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
                            transitionDuration: Duration(milliseconds: 500)));
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
                        '',//'${gridItem.stock} in stock',
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

/// Component FlashSaleItem
class flashSaleItem extends StatelessWidget {
  final String price;
  final String saleP;
  final String place;
  final String stock;
  final int colorLine;
  final double widthLine;
  final List<Products> salesList;
  final String banner_head;

  final Products flashItem;

  flashSaleItem(
      this.banner_head,
      {this.price,
      this.saleP,
      this.flashItem,
      this.place,
      this.stock,
      this.colorLine,
      this.widthLine, this.salesList});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            InkWell(
              onTap: () {
                Navigator.push(context, PageRouteBuilder(
                    pageBuilder: (_, __, ___) => new flashSale(place, banner_head, salesProductsWithSchedule: salesList,),
                    transitionsBuilder:
                        (_, Animation<double> animation, __, Widget child) {
                      return Opacity(
                        opacity: animation.value,
                        child: child,
                      );
                    },
                    transitionDuration: Duration(milliseconds: 850)));
              },
              child: Container(
                height: 305.0,
                width: 145.0,
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 140.0,
                      width: 145.0,
                      child: Image.network(
                        flashItem.pictures[0],
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.only(left: 8.0, right: 3.0, top: 15.0),
                      child: Text(flashItem.name,
                          style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                              fontFamily: "Sans")),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10.0, top: 5.0),
                      child: Text(price,
                          style: TextStyle(
                              fontSize: 10.5,
                              decoration: TextDecoration.lineThrough,
                              color: Colors.black54,
                              fontWeight: FontWeight.w600,
                              fontFamily: "Sans")),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10.0, top: 5.0),
                      child: Text(saleP,
                          style: TextStyle(
                              fontSize: 12.0,
                              color: Color(0xFF7F7FD5),
                              fontWeight: FontWeight.w800,
                              fontFamily: "Sans")),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0, top: 5.0),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.star,
                            size: 11.0,
                            color: Colors.yellow,
                          ),
                          Icon(
                            Icons.star,
                            size: 11.0,
                            color: Colors.yellow,
                          ),
                          Icon(
                            Icons.star,
                            size: 11.0,
                            color: Colors.yellow,
                          ),
                          Icon(
                            Icons.star,
                            size: 11.0,
                            color: Colors.yellow,
                          ),
                          Icon(
                            Icons.star_half,
                            size: 11.0,
                            color: Colors.yellow,
                          ),
                          Text(
                            '${flashItem.ratingTotal}',
                            style: TextStyle(
                                fontSize: 10.0,
                                fontWeight: FontWeight.w500,
                                fontFamily: "Sans",
                                color: Colors.black38),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0, top: 5.0),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.location_on,
                            size: 11.0,
                            color: Colors.black38,
                          ),
                          Text(
                            place,
                            style: TextStyle(
                                fontSize: 10.0,
                                fontWeight: FontWeight.w500,
                                fontFamily: "Sans",
                                color: Colors.black38),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, left: 10.0),
                      child: Text(
                        stock,
                        style: TextStyle(
                            fontSize: 10.0,
                            fontWeight: FontWeight.w500,
                            fontFamily: "Sans",
                            color: Colors.black),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, left: 10.0),
                      child: Container(
                        height: 5.0,
                        width: widthLine,
                        decoration: BoxDecoration(
                            color: Color(colorLine),
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

class loadingItemGrid extends StatelessWidget {
  @override
  SaleItem itemSale;
  loadingItemGrid(this.itemSale);
  final color = Colors.black38;
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return  Row(
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
                    ),   Padding(
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
                            padding: const EdgeInsets.only(left:5.0),
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
                        width: mediaQueryData.size.width/2.5,
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

Widget _loadingImageAnimation(BuildContext context){
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

Widget _loadingImageAnimationForBestSelling(BuildContext context){
  MediaQueryData mediaQueryData = MediaQuery.of(context);
  return ListView(
    scrollDirection: Axis.horizontal,
//    crossAxisCount: 2,
    shrinkWrap: true,
//    childAspectRatio: mediaQueryData.size.height / 1300,
//    crossAxisSpacing: 0.0,
//    mainAxisSpacing: 0.0,
    primary: false,
    children: List.generate(
      /// Get data in flashSaleItem.dart (ListItem folder)
      flashData.length,
          (index) => loadingItemGrid(flashData[index]),
    ),
  );
}

/// Component category item bellow FlashSale
class CategoryItemValue extends StatelessWidget {
  List<Products> products;
  String image, title, id;
  GestureTapCallback tap;

  CategoryItemValue({
    this.products,
    this.image,
    this.title,
    this.tap,
    this.id
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        Navigator.push(context, PageRouteBuilder(
            pageBuilder: (_, __, ___) => new categoryDetail(products, id, title, image),
            transitionDuration: Duration(milliseconds: 750),
            transitionsBuilder:
                (_, Animation<double> animation, __, Widget child) {
              return Opacity(
                opacity: animation.value,
                child: child,
              );
            }));
      },
      child: Container(
        height: 105.0,
        width: 160.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(3.0)),
          image: DecorationImage(image: NetworkImage(image), fit: BoxFit.cover),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(3.0)),
            color: Colors.black.withOpacity(0.25),
          ),
          child: Center(
              child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontFamily: "Berlin",
              fontSize: 18.5,
              letterSpacing: 0.7,
              fontWeight: FontWeight.w800,
            ),
          )),
        ),
      ),
    );
  }
}

/// Component item Menu icon bellow a ImageSlider
class CategoryIconValue extends StatelessWidget {
  List<Products> products;

  String icon1, icon2, icon3, icon4, title1, title2, title3, title4, id1, id2, id3, id4;
  GestureTapCallback tap1, tap2, tap3, tap4;

  CategoryIconValue(
      {this.products,
        this.icon1,
      this.tap1,
      this.icon2,
      this.tap2,
      this.icon3,
      this.tap3,
      this.icon4,
      this.tap4,
      this.title1,
      this.title2,
      this.title3,
      this.title4,
      this.id1,
      this.id2,
      this.id3,
      this.id4
      });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        InkWell(
          onTap: (){
            if(id1.isEmpty){
              return;
            }
              Navigator.push(context, PageRouteBuilder(
                  pageBuilder: (_, __, ___) => new menuDetail(products, id1, title1, icon1),
                  transitionDuration: Duration(milliseconds: 750),

                  /// Set animation with opacity
                  transitionsBuilder:
                      (_, Animation<double> animation, __, Widget child) {
                    return Opacity(
                      opacity: animation.value,
                      child: child,
                    );
                  }));
          },
          child: Column(
            children: <Widget>[
              Image.network(
                icon1,
                height: 48.2,
              ),
              Padding(padding: EdgeInsets.only(top: 7.0)),
              Text(
                title1,
                style: TextStyle(
                  fontFamily: "Sans",
                  fontSize: 10.0,
                  fontWeight: FontWeight.w500,
                ),
              )
            ],
          ),
        ),
        InkWell(
          onTap: (){
            if(id2.isEmpty){
              return;
            }
            Navigator.push(context, PageRouteBuilder(
                pageBuilder: (_, __, ___) => new menuDetail(products, id2, title2, icon2),
                transitionDuration: Duration(milliseconds: 750),

                /// Set animation with opacity
                transitionsBuilder:
                    (_, Animation<double> animation, __, Widget child) {
                  return Opacity(
                    opacity: animation.value,
                    child: child,
                  );
                }));
          },
          child: Column(
            children: <Widget>[
              Image.network(
                icon2,
                height: 48.2,
              ),
              Padding(padding: EdgeInsets.only(top: 7.0)),
              Text(
                title2,
                style: TextStyle(
                  fontFamily: "Sans",
                  fontSize: 10.0,
                  fontWeight: FontWeight.w500,
                ),
              )
            ],
          ),
        ),
        InkWell(
          onTap: (){
            if(id3.isEmpty){
              return;
            }
            Navigator.push(context, PageRouteBuilder(
                pageBuilder: (_, __, ___) => new menuDetail(products, id3, title3, icon3),
                transitionDuration: Duration(milliseconds: 750),

                /// Set animation with opacity
                transitionsBuilder:
                    (_, Animation<double> animation, __, Widget child) {
                  return Opacity(
                    opacity: animation.value,
                    child: child,
                  );
                }));
          },
          child: Column(
            children: <Widget>[
              Image.network(
                icon3,
                height: 48.2,
              ),
              Padding(padding: EdgeInsets.only(top: 7.0)),
              Text(
                title3,
                style: TextStyle(
                  fontFamily: "Sans",
                  fontSize: 10.0,
                  fontWeight: FontWeight.w500,
                ),
              )
            ],
          ),
        ),
        InkWell(
          onTap: (){
            if(id4.isEmpty){
              return;
            }
            Navigator.push(context, PageRouteBuilder(
                pageBuilder: (_, __, ___) => new menuDetail(products, id4, title4, icon4),
                transitionDuration: Duration(milliseconds: 750),

                /// Set animation with opacity
                transitionsBuilder:
                    (_, Animation<double> animation, __, Widget child) {
                  return Opacity(
                    opacity: animation.value,
                    child: child,
                  );
                }));
          },
          child: Column(
            children: <Widget>[
              Image.network(
                icon4,
                height: 48.2,
              ),
              Padding(padding: EdgeInsets.only(top: 7.0)),
              Text(
                title4,
                style: TextStyle(
                  fontFamily: "Sans",
                  fontSize: 10.0,
                  fontWeight: FontWeight.w500,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

var _customTextStyleBlue = TextStyle(
    fontFamily: "Gotik",
    color: Color(0xFFEC008C),
    fontWeight: FontWeight.w700,
    fontSize: 15.0);
