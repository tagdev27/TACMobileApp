import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:treva_shop_flutter/UI/BottomNavigationBar.dart';
import 'package:treva_shop_flutter/UI/LoginOrSignup/ChoseLoginOrSignup.dart';
import 'package:treva_shop_flutter/UI/HomeUIComponent/Home.dart';
import 'package:treva_shop_flutter/UI/LoginOrSignup/Login.dart';
import 'package:treva_shop_flutter/UI/OnBoarding.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:treva_shop_flutter/Utils/storage.dart';

import 'Utils/backgroud_utils.dart';

/// Run first apps open
main() {
  //initPlatformState();
  Firestore.instance.settings(persistenceEnabled: true);
  runApp(myApp());
}

//Future<void> initPlatformState() async {
//  await FlutterFreshchat.init(
//      appID: "b59cf05f-9c18-4176-b41b-4deac7dc35fc", appKey: "d318009f-2023-49c5-a324-3e9c32103144");
//}

/// Set orienttation
class myApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    /// To set orientation always portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    ///Set color status bar
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent, //or set color with: Color(0xFF0000FF)
    ));
    return new MaterialApp(
      title: "TAC Online Gift Shop",
      theme: ThemeData(
          brightness: Brightness.light,
          backgroundColor: Colors.white,
          primaryColorLight: Colors.white,
          primaryColorBrightness: Brightness.light,
          primaryColor: Colors.white),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      /// Move splash screen to ChoseLogin Layout
      /// Routes
      routes: <String, WidgetBuilder>{
        "login": (BuildContext context) => new onBoarding(),
        "choose": (BuildContext context) => new ChoseLogin()
      },
    );
  }
}

/// Component UI
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

/// Component UI
class _SplashScreenState extends State<SplashScreen> {

  StorageSystem ss = new StorageSystem();

  @override
  /// Setting duration in splash screen
  startTime() async {
    return new Timer(Duration(milliseconds: 4500), NavigatorPage);
  }
  /// To navigate layout change
  Future NavigatorPage() async {
    //ss.clearPref();
    String logged = ss.getItem('loggedin');
    //print('logged ========$logged');
    if(logged.isEmpty){
      Navigator.of(context).pushReplacementNamed("login");
    }else {
      if(logged == 'signInAnonymously'){
//        FirebaseAuth.instance.signOut().then((v){
//
//        });
        ss.clearPref();
        Navigator.of(context).pushReplacementNamed("choose");
        return;
      }else{
        if(logged == 'true'){
          Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                  pageBuilder: (_, __, ___) =>
                  new bottomNavigationBar()));
        }else {
          FirebaseAuth.instance.signOut().then((v){
            ss.clearPref();
            Navigator.of(context).pushReplacementNamed("login");
          });
        }
      }
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    String user = ss.getItem('user');
    if(user.isEmpty) {
      ss.clearPref();
      ss.disposePref();
    }
    super.dispose();
  }
  /// Declare startTime to InitState
  @override
  void initState() {
    super.initState();
    startTime();
  }

  /// Code Create UI Splash Screen
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        /// Set Background image in splash screen layout (Click to open code)
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/img/tac_bg.png'), fit: BoxFit.cover)),
        child: Container(
          /// Set gradient black in image splash screen (Click to open code)
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(0, 0, 0, 0.3),
                    Color.fromRGBO(0, 0, 0, 0.4)
                  ],
                  begin: FractionalOffset.topCenter,
                  end: FractionalOffset.bottomCenter)),
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 30.0),
                    ),
                    /// Text header "Welcome To" (Click to open code)
                    Text(
                      "Welcome to",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w200,
                        fontFamily: "Sans",
                        fontSize: 19.0,
                      ),
                    ),
                    /// Animation text Treva Shop to choose Login with Hero Animation (Click to open code)
                    Hero(
                      tag: "Tac",
                      child: Text(
                        "TAC - Online \nGift Shop",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Sans',
                          fontWeight: FontWeight.w900,
                          fontSize: 35.0,
                          letterSpacing: 0.4,
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
