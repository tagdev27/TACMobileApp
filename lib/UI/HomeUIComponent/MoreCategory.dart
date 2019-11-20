import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:treva_shop_flutter/ListItem/GiftBaskets.dart';
import 'package:treva_shop_flutter/ListItem/category.dart';
import 'package:treva_shop_flutter/ListItem/main-category.dart';
import 'package:treva_shop_flutter/UI/BrandUIComponent/BrandDetail.dart';
import 'package:treva_shop_flutter/UI/HomeUIComponent/Search.dart';
import 'package:treva_shop_flutter/Utils/backgroud_utils.dart';
import 'package:treva_shop_flutter/Utils/colors.dart';
import 'package:treva_shop_flutter/Utils/progress.dart';

class MoreCategory extends StatefulWidget {
  final String menus_id, main_cat_name;
  final List<Category> sub_cat;
  final List<Products> products;

  MoreCategory(this.products, this.main_cat_name, {this.menus_id, this.sub_cat});

  @override
  State<StatefulWidget> createState() => _MoreCategory();
}

class _MoreCategory extends State<MoreCategory> {
  List<Category> sub_cat = new List();

  bool _inAsyncCall = false;

  getCategories() {
    setState(() {
      _inAsyncCall = true;
    });
    new Utils().getSubCategoriesFromMainCategoryID(widget.menus_id).then((cat) {
      if (mounted) {
        setState(() {
          sub_cat = cat;
        });
      }
    });
    setState(() {
      _inAsyncCall = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.sub_cat == null) {
      getCategories();
    }
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
          "Category - ${widget.main_cat_name}",
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
                pageBuilder: (_, __, ___) =>
                    new searchAppbar(widget.products)));
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
                              (context, index) => (widget.sub_cat != null)
                                  ? itemCard(widget.sub_cat[index], widget.products)
                                  : itemCard(sub_cat[index], widget.products),
                              childCount: (widget.sub_cat != null)
                                  ? widget.sub_cat.length
                                  : sub_cat.length)),
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
  final List<Products> all_products;
  final Category brand;
  itemCard(this.brand, this.all_products);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            PageRouteBuilder(
                pageBuilder: (_, __, ___) => new brandDetail(brand,all_products),
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
                      image: NetworkImage(brand.image), fit: BoxFit.cover),
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
