import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:treva_shop_flutter/ListItem/GiftBaskets.dart';
import 'package:treva_shop_flutter/ListItem/main-category.dart';
import 'package:treva_shop_flutter/UI/BrandUIComponent/BrandDetail.dart';
import 'package:treva_shop_flutter/UI/HomeUIComponent/MoreCategory.dart';
import 'package:treva_shop_flutter/UI/HomeUIComponent/Search.dart';
import 'package:treva_shop_flutter/Utils/colors.dart';
import 'package:treva_shop_flutter/Utils/general.dart';
import 'package:treva_shop_flutter/Utils/progress.dart';

class MoreMenu extends StatefulWidget {

  final List<Products> products;
  MoreMenu(this.products);

  @override
  State<StatefulWidget> createState() => _MoreMenu();
}

class _MoreMenu extends State<MoreMenu> {
  List<MainCategory> menus = new List();

  bool _inAsyncCall = false;

  Future<void> getMainCategories() async {
    setState(() {
      _inAsyncCall = true;
    });
    var query = await Firestore.instance
        .collection('db')
        .document('tacadmin')
        .collection('main-categories')
        .where('deleted', isEqualTo: false)
        .getDocuments();
    query.documents.forEach((snapshot) {
      Map<String, dynamic> mn = snapshot.data;
      MainCategory mc = MainCategory(mn['id'], mn['name'], mn['image']);
      if (!mounted) return;
      setState(() {
        menus.add(mc);
      });
    });
    setState(() {
      _inAsyncCall = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMainCategories();
  }

  @override
  Widget build(BuildContext context) {
    /// Component appbar
    var _appbar = AppBar(
      backgroundColor: Color(0xFFFFFFFF),
      elevation: 0.0,
      iconTheme: IconThemeData(
        color: Color(MyColors.primary_color),
      ),
      title: Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: Text(
          "Menu",
          style: TextStyle(
              fontFamily: "Gotik",
              fontSize: 20.0,
              color: Colors.black54,
              fontWeight: FontWeight.w700),
        ),
      ),
      leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back)),
      actions: <Widget>[
        InkWell(
          onTap: () {
            Navigator.of(context).push(PageRouteBuilder(
                pageBuilder: (_, __, ___) => new searchAppbar(widget.products)));
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Icon(
              Icons.search,
              size: 27.0,
              color: Colors.black54,
            ),
          ),
        )
      ],
    );

    return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Scaffold(
          /// Calling variable appbar
          appBar: _appbar,
          body: ModalProgressHUD(
              opacity: 0.3,
              inAsyncCall: _inAsyncCall,
              progressIndicator: CircularProgressIndicator(),
              color: Color(MyColors.button_text_color),
              child: Container(
                color: Colors.white,
                child: CustomScrollView(
                  /// Create List Menu
                  slivers: <Widget>[
                    SliverPadding(
                      padding: EdgeInsets.only(top: 0.0),
                      sliver: SliverFixedExtentList(
                          itemExtent: 145.0,
                          delegate: SliverChildBuilderDelegate(

                              /// Calling itemCard Class for constructor card
                              (context, index) => itemCard(widget.products, menus[index]),
                              childCount: menus.length)),
                    ),
                  ],
                ),
              )),
        ));
  }
}

/// Constructor for itemCard for List Menu
class itemCard extends StatelessWidget {
  /// Declaration and Get data from BrandDataList.dart
  final MainCategory brand;
  final List<Products> products;
  itemCard(this.products, this.brand);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            PageRouteBuilder(
                pageBuilder: (_, __, ___) =>
                    new MoreCategory(products, brand.name, menus_id: brand.id, sub_cat: null),
                transitionDuration: Duration(milliseconds: 600),
                transitionsBuilder:
                    (_, Animation<double> animation, __, Widget child) {
                  return Opacity(
                    opacity: animation.value,
                    child: child,
                  );
                }),
          );
        },
        child: Container(
          height: 130.0,
          width: 400.0,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(15.0))),
          child: Hero(
            tag: 'hero-tag-${brand.id}',
            child: Material(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                  image: DecorationImage(
                      image: NetworkImage(brand.icon), fit: BoxFit.cover),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFABABAB).withOpacity(0.3),
                      blurRadius: 1.0,
                      spreadRadius: 2.0,
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(15.0)),
                    color: Colors.black12.withOpacity(0.1),
                  ),
                  child: Center(
                    child: Text(
                      brand.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: "Berlin",
                        fontSize: 35.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
