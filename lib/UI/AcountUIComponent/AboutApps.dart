import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:treva_shop_flutter/Utils/colors.dart';
import 'package:treva_shop_flutter/Utils/general.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';

class aboutApps extends StatefulWidget {
  @override
  _aboutAppsState createState() => _aboutAppsState();
}

class _aboutAppsState extends State<aboutApps> {
  static var _txtCustomHead = TextStyle(
    color: Colors.black54,
    fontSize: 17.0,
    fontWeight: FontWeight.w600,
    fontFamily: "Gotik",
  );

  static var _txtCustomSub = TextStyle(
    color: Colors.black38,
    fontSize: 15.0,
    fontWeight: FontWeight.w500,
    fontFamily: "Gotik",
  );

  Future<Null> _launchInWebViewOrVC(String url) async {
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: true, forceWebView: true);
    } else {
      new GeneralUtils()
          .neverSatisfied(context, 'Error', 'Cannot open parameter.');
    }
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
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
    getSocialLinks();
  }

  String facebook_link = '', twitter_link = '', instagram_link = '';

  Future<void> getSocialLinks() async {
    final query = await Firestore.instance
        .collection('db')
        .document('tacadmin')
        .collection('settings')
        .document('store')
        .get();
    Map<String, dynamic> dt = query.data;
    setState(() {
      facebook_link = dt['facebook_url'];
      twitter_link = dt['twitter_url'];
      instagram_link = dt['instagram_url'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "About Application",
          style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15.0,
              color: Colors.black54,
              fontFamily: "Gotik"),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(MyColors.primary_color)),
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Divider(
                  height: 0.5,
                  color: Colors.black12,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10.0, left: 15.0),
                child: Row(
                  children: <Widget>[
                    Image.network(
                      "https://tacgifts.com/assets/images/icon/logo.png",
                      height: 50.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "TAC",
                            style: _txtCustomSub.copyWith(
                                fontWeight: FontWeight.w600),
                          ),
                          Text(
                            "Online Messager Gift Shop",
                            style: _txtCustomSub,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Divider(
                  height: 0.5,
                  color: Colors.black12,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  "TAC is an e-commerce gifting services platform that aims at connecting users irrespective "
                  "of their geographical locations to their loved ones through purchase and exchange of gifts and"
                  " other concierge services in the celebration of notable and memorable events such as Birthdays,"
                  " Wedding anniversaries, Promotions, Baby showers, special seasons etc.\n\n"
                  "TAC’s desire is to provide exceptional gifts for all of life’s special occasion. "
                  "With our wide range of gifts & gifting Services from personalized gifts to fresh flowers to gourmet gifts, "
                  "we give you variety of amazing options to create a memorable experience for your loved ones on their special day. "
                  "We’re your number one Gifting destination for every special occasion.",
                  style: _txtCustomSub,
                  textAlign: TextAlign.justify,
                ),
              ),
              InkWell(
                onTap: () {
                  _launchURL(instagram_link);
                },
                child:
                    buttonCustom("instagram", "Connect with us on Instagram"),
              ),
              Container(
                height: 10.0,
              ),
              InkWell(
                onTap: () {
                  _launchURL(facebook_link);
                },
                child: buttonCustom("facebook", "Connect with us on Facebook"),
              ),
              Container(
                height: 10.0,
              ),
              InkWell(
                onTap: () {
                  _launchURL(twitter_link);
                },
                child: buttonCustom("twitter", "Connect with us on Twitter"),
              ),
              Container(
                height: 30.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class buttonCustom extends StatelessWidget {
  final String type, text;

  buttonCustom(this.type, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Container(
        alignment: FractionalOffset.center,
        height: 49.0,
        width: 500.0,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10.0)],
          borderRadius: BorderRadius.circular(40.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
//            Image.asset(
//              "assets/img/icon_facebook.png",
//              height: 25.0,
//            ),
            (type == "twitter")
                ? SvgPicture.asset(
                    'assets/svg/twitter.svg',
                    height: 25.0,
                    color: Color(0XFF1DA1F2),
                  )
                : (type == "facebook")
                    ? SvgPicture.asset(
                        'assets/svg/facebook.svg',
                        height: 25.0,
                        color: Color(0XFF4172B8),
                      )
                    : SvgPicture.asset(
                        'assets/svg/instagram.svg',
                        height: 25.0,
                        color: Color(0XFFE4405F),
                      ),
            Padding(padding: EdgeInsets.symmetric(horizontal: 7.0)),
            Text(
              text,
              style: TextStyle(
                  color: Colors.black26,
                  fontSize: 15.0,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Sans'),
            )
          ],
        ),
      ),
    );
  }
}
