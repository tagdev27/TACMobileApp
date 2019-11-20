import 'dart:async';
import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:treva_shop_flutter/UI/BottomNavigationBar.dart';
import 'package:treva_shop_flutter/UI/LoginOrSignup/Login.dart';
import 'package:treva_shop_flutter/UI/LoginOrSignup/LoginAnimation.dart';
import 'package:treva_shop_flutter/UI/LoginOrSignup/Signup.dart';
import 'package:treva_shop_flutter/Utils/backgroud_utils.dart';
import 'package:treva_shop_flutter/Utils/email_service.dart';
import 'package:treva_shop_flutter/Utils/general.dart';
import 'package:treva_shop_flutter/Utils/progress.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:treva_shop_flutter/Utils/storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

class Signup extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> with TickerProviderStateMixin {
  //Animation Declaration
  AnimationController sanimationController;
  AnimationController animationControllerScreen;
  Animation animationScreen;
  var tap = 0;

  final formKey = new GlobalKey<FormState>();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  ProgressDisplay pd;
  StorageSystem ss = new StorageSystem();

  String msgId = '';

  String mEmail = '',
      mPassword = '',
      fullname = '';

  /// Set AnimationController to initState
  @override
  void initState() {
    sanimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800))
          ..addStatusListener((statuss) {
            if (statuss == AnimationStatus.dismissed) {
              setState(() {
                tap = 0;
              });
            }
          });
    // TODO: implement initState
    super.initState();
    pd = new ProgressDisplay(context);
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    getTokenAndDeviceInfo();
    String cc = ss.getItem('currency');
      if (cc.isEmpty) {
        new Utils().getUserIpDetails();
      }
  }

  getTokenAndDeviceInfo() async {
    _firebaseMessaging.getToken().then((token) {
      msgId = token;
    });

//    try {
//      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
//      if(Platform.isAndroid) {
//        if (deviceInfo.androidInfo != null) {
//          AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
//          device_info = androidInfo.androidId;
//          print('devAnd = $device_info');
//        }
//      }else if(Platform.isIOS) {
//        if (deviceInfo.iosInfo != null) {
//          IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
//          device_info = iosInfo.identifierForVendor;
//          print('deviOS = $device_info');
//        }
//      }
//    }catch(e){
//      print(e.toString());
//    }
  }

  /// Dispose animationController
  @override
  void dispose() {
    super.dispose();
    sanimationController.dispose();
  }

  /// Playanimation set forward reverse
  Future<Null> _PlayAnimation() async {
    try {
      await sanimationController.forward();
      await sanimationController.reverse();
    } on TickerCanceled {}
  }

  /// Component Widget layout UI
  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    mediaQueryData.devicePixelRatio;
    mediaQueryData.size.height;
    mediaQueryData.size.width;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            /// Set Background image in layout
            decoration: BoxDecoration(
                image: DecorationImage(
              image: AssetImage("assets/img/backgroundgirl.png"),
              fit: BoxFit.cover,
            )),
            child: Container(
              /// Set gradient color in image
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(0, 0, 0, 0.2),
                    Color.fromRGBO(0, 0, 0, 0.3)
                  ],
                  begin: FractionalOffset.topCenter,
                  end: FractionalOffset.bottomCenter,
                ),
              ),

              /// Set component layout
              child: ListView(
                padding: EdgeInsets.all(0.0),
                children: <Widget>[
                  Stack(
                    alignment: AlignmentDirectional.bottomCenter,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Container(
                            alignment: AlignmentDirectional.topCenter,
                            child: Column(
                              children: <Widget>[
                                /// padding logo
                                Padding(
                                    padding: EdgeInsets.only(
                                        top:
                                            mediaQueryData.padding.top + 10.0)),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Image(
                                      image: AssetImage("assets/img/Logo.png"),
                                      height: 70.0,
                                    ),
                                    Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10.0)),

                                    /// Animation text treva shop accept from login layout
                                    Hero(
                                      tag: "Tac",
                                      child: Text(
                                        "TAC Online Gift Shop",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0.6,
                                            fontFamily: "Sans",
                                            color: Colors.white,
                                            fontSize: 20.0),
                                      ),
                                    ),
                                  ],
                                ),

                                /// ButtonCustomFacebook
                                Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 10.0)),
                                tap == 0
                                    ? InkWell(
                                        splashColor: Colors.yellow,
                                        onTap: () {
                                          signupWithFacebook();
                                        },
                                        child: buttonCustomFacebook(),
                                      )
                                    : new LoginAnimation(
                                        animationController:
                                            sanimationController.view,
                                      ),

                                /// ButtonCustomGoogle
                                Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 7.0)),
                                tap == 0
                                    ? InkWell(
                                        splashColor: Colors.yellow,
                                        onTap: () {
                                          signupWithGoogle();
                                        },
                                        child: buttonCustomGoogle(),
                                      )
                                    : new LoginAnimation(
                                        animationController:
                                            sanimationController.view,
                                      ),

                                /// Set Text
                                Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 10.0)),
                                Text(
                                  "OR",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 0.2,
                                      fontFamily: 'Sans',
                                      fontSize: 17.0),
                                ),

                                Form(
                                  key: formKey,
                                  child: Column(
                                    children: <Widget>[
                                      /// TextFromField Name
                                      Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10.0)),
                                      textFromField(
                                        icon: Icons.person,
                                        password: false,
                                        placeholder: "Full name",
                                        inputType: TextInputType.text,
                                      ),

                                      /// TextFromField Email
                                      Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 5.0)),
                                      textFromField(
                                        icon: Icons.email,
                                        password: false,
                                        placeholder: "Email",
                                        inputType: TextInputType.emailAddress,
                                      ),

                                      /// TextFromField Password
                                      Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 5.0)),
                                      textFromField(
                                        icon: Icons.vpn_key,
                                        password: true,
                                        placeholder: "Password",
                                        inputType: TextInputType.text,
                                      )
                                    ],
                                  ),
                                ),

                                /// Button Login
                                FlatButton(
                                    padding: EdgeInsets.only(top: 0.0),
                                    onPressed: () {
                                      Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  new loginScreen()));
                                    },
                                    child: Text(
                                      " Have Acount? Sign In",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13.0,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: "Sans"),
                                    )),
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: mediaQueryData.padding.top + 80.0,
                                      bottom: 0.0),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),

                      /// Set Animaion after user click buttonLogin
                      tap == 0
                          ? InkWell(
                              splashColor: Colors.yellow,
                              onTap: () {
                                signupWithEmailAndPassword();
                              },
                              child: buttonBlackBottom(),
                            )
                          : new LoginAnimation(
                              animationController: sanimationController.view,
                            )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  signupWithGoogle() {
    _handleGoogleSignIn();
  }

  signupWithFacebook() {
    _handleFacebookSignIn();
  }

  signupWithEmailAndPassword() {
    if (!validateAndSave()) {
      return;
    }
    if (!fullname.contains(' ')) {
      pd.displayMessage(context, 'Error', 'Enter full name');
      return;
    }
    pd.displayDialog("Please wait...");
    FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: mEmail, password: mPassword)
        .then((user) {
      user.sendEmailVerification();
      checkFirestoreAndRedirect(mEmail, null, null, user);
    }).catchError((err) {
      pd.dismissDialog();
      pd.displayMessage(context, 'Error', '${err.toString()}');
    });
  }

  checkFirestoreAndRedirect(String email, GoogleSignInAuthentication googleAuth,
      GoogleSignInAccount googleUser, FirebaseUser firebaseUser) async {
    String gp = ss.getItem('currency');
    Map<String, dynamic> data = jsonDecode(gp);
    if (googleAuth != null) {
      Map<String, dynamic> newUserData = new Map();
      newUserData['Tokens'] = {
        'oauthAccessToken': googleAuth.accessToken,
        'oauthIdToken': googleAuth.idToken,
        'providerId': 'google.com',
        'signInMethod': 'google.com'
      };
      String id = FirebaseDatabase.instance.reference().push().key;
      newUserData['id'] = id;
      newUserData['blocked'] = false;
      newUserData['country'] = data['country'];
      newUserData['created_date'] = new DateTime.now().toString();
      newUserData['email'] = email;
      newUserData['firstname'] = googleUser.displayName.split(' ')[0];
      newUserData['lastname'] = googleUser.displayName.split(' ')[1];
      newUserData['userId'] = firebaseUser.uid;
      newUserData['picture'] = googleUser.photoUrl;
      newUserData['msgId'] = msgId;
      Firestore.instance
          .collection('users')
          .document(email.toLowerCase())
          .setData(newUserData)
          .then((v) {
        Map<String, dynamic> userData = new Map();
        userData['email'] = email;
        userData['fn'] = googleUser.displayName.split(' ')[0];
        userData['ln'] = googleUser.displayName.split(' ')[1];

        ss.setPrefItem('loggedin', 'true');
        ss.setPrefItem('user', jsonEncode(userData));
        sendEmail(googleUser.displayName.split(' ')[0]);
      });
    }else {
      Map<String, dynamic> newUserData = new Map();
      String id = FirebaseDatabase.instance.reference().push().key;
      newUserData['id'] = id;
      newUserData['blocked'] = false;
      newUserData['country'] = data['country'];
      newUserData['created_date'] = new DateTime.now().toString();
      newUserData['email'] = email;
      newUserData['firstname'] = fullname.split(' ')[0];
      newUserData['lastname'] = fullname.split(' ')[1];
      newUserData['userId'] = firebaseUser.uid;
      newUserData['picture'] = 'https://tacadmin.firebaseapp.com/assets/img/default-avatar.png';
      newUserData['msgId'] = msgId;
      Firestore.instance
          .collection('users')
          .document(email.toLowerCase())
          .setData(newUserData)
          .then((v) {
        Map<String, dynamic> userData = new Map();
        userData['email'] = email;
        userData['fn'] = fullname.split(' ')[0];
        userData['ln'] = fullname.split(' ')[1];
        ss.setPrefItem('loggedin', 'true');
        ss.setPrefItem('user', jsonEncode(userData));
        sendEmail(fullname.split(' ')[0]);
      });
    }
  }

  Future<void> sendEmail(String fullname) async {
    EmailService emailService = new EmailService();

    String inner_products = "";
    int index = 2;

    var query = await Firestore.instance.collection('db').document('tacadmin').collection('products').limit(3).getDocuments();

    query.documents.forEach((pro){
        Map<String, dynamic> p = pro.data;
        if(index % 2 == 0){//left
          inner_products += buildHtml(index, true, p);
        }else {
          inner_products += buildHtml(index, false, p);
        }
        inner_products += """<div style="height:32px;line-height:32px;font-size:30px">&nbsp;</div>""";
        index = index + 1;
    });

    String email_body = emailService.getRegistrationBody(inner_products);

    http.post("https://avidprintsconcierge.com/emailsending/register.php?sender_email=$mEmail&sender_name=$fullname", body: {'body':email_body}).then((res){
      pd.dismissDialog();
      setState(() {
        tap = 1;
      });
      new LoginAnimation(
        animationController: sanimationController.view,
      );
      _PlayAnimation();
      return tap;
    });

  }

  String buildHtml(int index, bool isLeft, Map<String, dynamic> p){
    if(isLeft){
      return """
      <table cellpadding="0" cellspacing="0" border="0" width="88%"
          style="width:100%!important;min-width:100%;max-width:100%;border-width:1px;border-style:solid;border-color:#e8e8e8;border-bottom:none;border-left:none;border-right:none">

          <tbody>
              <tr>

                  <td align="center" valign="top">

                      <div class="m_8651446753593829059mob_b2"
                          style="display:inline-block;vertical-align:top;width:460px">

                          <table class="m_8651446753593829059mob_btn" cellpadding="0"
                              cellspacing="0" border="0" width="440"
                              style="width:440px;max-width:440px">

                              <tbody>
                                  <tr>

                                      <td align="left" valign="top">

                                          <div
                                              style="height:32px;line-height:32px;font-size:30px">
                                              &nbsp;</div>

                                          <font face="'Source Sans Pro', sans-serif"
                                              color="#27cbcc"
                                              style="font-size:22px;line-height:28px;font-weight:600">

                                              <span
                                                  style="font-family:'Source Sans Pro',Arial,Tahoma,Geneva,sans-serif;color:#27cbcc;font-size:22px;line-height:28px;font-weight:600">

                                                  ${index - 1}. ${p['name']}

                                              </span>

                                          </font>

                                          <div
                                              style="height:13px;line-height:13px;font-size:11px">
                                              &nbsp;</div>

                                          <font face="'Source Sans Pro', sans-serif"
                                              color="#5E5E5E"
                                              style="font-size:17px;line-height:20px">

                                              <span
                                                  style="font-family:'Source Sans Pro',Arial,Tahoma,Geneva,sans-serif;color:#5e5e5e;font-size:17px;line-height:20px">

                                                  ${p['description']}

                                              </span>

                                          </font>

                                          <div
                                              style="height:20px;line-height:14px;font-size:12px">
                                              &nbsp;</div>

                                          <a href="https://tacgifts.com/home/product/${p['menu_link']}"
                                              style="display:block;font-family:'Source Sans Pro',Verdana,Tahoma,Geneva,sans-serif;color:#ff9800;font-size:15px;line-height:18px;text-decoration:none;white-space:nowrap;text-transform:uppercase"
                                              target="_blank"
                                              data-saferedirecturl="https://www.google.com/url?q=https://tacgifts.com/home/product/${p['menu_link']}">

                                              <font face="'Source Sans Pro', sans-serif"
                                                  color="#ff9800"
                                                  style="font-size:15px;line-height:18px;text-decoration:none;white-space:nowrap;text-transform:uppercase">

                                                  <span
                                                      style="font-family:'Source Sans Pro',Verdana,Tahoma,Geneva,sans-serif;color:#ff9800;font-size:15px;line-height:18px;text-decoration:none;white-space:nowrap;text-transform:uppercase;border:1px solid #ff9800;padding:10px;border-radius:5px;background-color:#ff9800;color:#ffffff">

                                                      Shop Now

                                                  </span>

                                              </font>

                                          </a>

                                      </td>

                                  </tr>

                              </tbody>
                          </table>

                      </div>



                      <div class="m_8651446753593829059mob_b2"
                          style="display:inline-block;text-align:center;vertical-align:middle;width:180px;height:100%">

                          <table class="m_8651446753593829059mob_btn" cellpadding="0"
                              cellspacing="0" border="0" width="160"
                              style="width:160px;max-width:160px">

                              <tbody>
                                  <tr>

                                      <td align="left" valign="top">

                                          <div
                                              style="height:32px;line-height:32px;font-size:30px">
                                              &nbsp;</div>

                                          <a href="#m_8651446753593829059_"
                                              style="display:block;max-width:100%">

                                              <img src="${p['pictures'][0]}"
                                                  alt="img" width="100%" border="0"
                                                  style="display:block;width:100%"
                                                  class="CToWUd">

                                          </a>



                                      </td>

                                  </tr>

                              </tbody>
                          </table>

                      </div>



                  </td>

              </tr>

          </tbody>
      </table>
      """;
    }else {
      return """
      <table cellpadding="0" cellspacing="0" border="0" width="88%"
                                    style="width:100%!important;min-width:100%;max-width:100%;border-width:1px;border-style:solid;border-color:#e8e8e8;border-bottom:none;border-left:none;border-right:none">

                                    <tbody>
                                        <tr>

                                            <td align="center" valign="top">

                                                <div class="m_8651446753593829059mob_b2"
                                                    style="display:inline-block;text-align:center;vertical-align:middle;width:180px;height:100%">

                                                    <table class="m_8651446753593829059mob_btn" cellpadding="0"
                                                        cellspacing="0" border="0" width="160"
                                                        style="width:160px;max-width:160px">

                                                        <tbody>
                                                            <tr>

                                                                <td align="left" valign="top">

                                                                    <div
                                                                        style="height:32px;line-height:32px;font-size:30px">
                                                                        &nbsp;</div>

                                                                    <a href="#m_8651446753593829059_"
                                                                        style="display:block;max-width:100%">

                                                                        <img src="${p['pictures'][0]}"
                                                                            alt="img" width="100%" border="0"
                                                                            style="display:block;width:100%"
                                                                            class="CToWUd">

                                                                    </a>



                                                                </td>

                                                            </tr>

                                                        </tbody>
                                                    </table>

                                                </div>



                                                <div class="m_8651446753593829059mob_b2"
                                                    style="display:inline-block;vertical-align:top;width:460px">

                                                    <table class="m_8651446753593829059mob_btn" cellpadding="0"
                                                        cellspacing="0" border="0" width="440"
                                                        style="width:440px;max-width:440px">

                                                        <tbody>
                                                            <tr>

                                                                <td align="left" valign="top">

                                                                    <div
                                                                        style="height:32px;line-height:32px;font-size:30px">
                                                                        &nbsp;</div>

                                                                    <font face="'Source Sans Pro', sans-serif"
                                                                        color="#27cbcc"
                                                                        style="font-size:22px;line-height:28px;font-weight:600">

                                                                        <span
                                                                            style="font-family:'Source Sans Pro',Arial,Tahoma,Geneva,sans-serif;color:#27cbcc;font-size:22px;line-height:28px;font-weight:600">

                                                                            ${index - 1}. ${p['name']}

                                                                        </span>

                                                                    </font>

                                                                    <div
                                                                        style="height:13px;line-height:13px;font-size:11px">
                                                                        &nbsp;</div>

                                                                    <font face="'Source Sans Pro', sans-serif"
                                                                        color="#5E5E5E"
                                                                        style="font-size:17px;line-height:20px">

                                                                        <span
                                                                            style="font-family:'Source Sans Pro',Arial,Tahoma,Geneva,sans-serif;color:#5e5e5e;font-size:17px;line-height:20px">

                                                                            ${p['description']}

                                                                        </span>

                                                                    </font>

                                                                    <div
                                                                        style="height:20px;line-height:14px;font-size:12px">
                                                                        &nbsp;</div>

                                                                    <a href="https://tacgifts.com/home/product/${p['menu_link']}"
                                                                        style="display:block;font-family:'Source Sans Pro',Verdana,Tahoma,Geneva,sans-serif;color:#ff9800;font-size:15px;line-height:18px;text-decoration:none;white-space:nowrap;text-transform:uppercase"
                                                                        target="_blank"
                                                                        data-saferedirecturl="https://www.google.com/url?q=https://tacgifts.com/home/product/${p['menu_link']}">

                                                                        <font face="'Source Sans Pro', sans-serif"
                                                                            color="#ff9800"
                                                                            style="font-size:15px;line-height:18px;text-decoration:none;white-space:nowrap;text-transform:uppercase">

                                                                            <span
                                                                                style="font-family:'Source Sans Pro',Verdana,Tahoma,Geneva,sans-serif;color:#ff9800;font-size:15px;line-height:18px;text-decoration:none;white-space:nowrap;text-transform:uppercase;border:1px solid #ff9800;padding:10px;border-radius:5px;background-color:#ff9800;color:#ffffff">

                                                                                Shop Now

                                                                            </span>

                                                                        </font>

                                                                    </a>

                                                                </td>

                                                            </tr>

                                                        </tbody>
                                                    </table>

                                                </div>



                                            </td>

                                        </tr>

                                    </tbody>
                                </table>
      """;
    }
  }

  Future<FirebaseUser> _handleGoogleSignIn() async {
    try {
      final GoogleSignIn _googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'profile',
          'https://www.googleapis.com/auth/calendar.events.readonly',
        ],
      );
      final FirebaseAuth _auth = FirebaseAuth.instance;
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final FirebaseUser user = await _auth.signInWithCredential(credential);
      pd.displayDialog("Please wait...");
      checkFirestoreAndRedirect(mEmail, googleAuth, googleUser, user);
      return user;
    }catch(e){
      print('ex === ${e.toString()}');
    }
    return null;
  }

  Future<void> _handleFacebookSignIn() async {
    final facebookLogin = FacebookLogin();
    final result = await facebookLogin.logIn(['email','user_birthday', 'user_gender']);//'user_friends',
    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final FirebaseAuth _auth = FirebaseAuth.instance;
        final AuthCredential credential = FacebookAuthProvider.getCredential(accessToken: result.accessToken.token);
        final FirebaseUser user = await _auth.signInWithCredential(credential);
        print(user);
        //pd.displayDialog("Please wait...");
        //checkFirestoreAndRedirect(mEmail, null, null, user);
        //_sendTokenToServer(result.accessToken.token);
        //_showLoggedInUI();
        break;
      case FacebookLoginStatus.cancelledByUser:
        //_showCancelledMessage();
        break;
      case FacebookLoginStatus.error:
        new GeneralUtils().neverSatisfied(context, 'Error', result.errorMessage);
        break;
    }
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    form.save();
    return form.validate();
  }

  /// textfromfield custom class
  Widget textFromField({String placeholder, IconData icon, TextInputType inputType, bool password, bool isFullname}){
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.0),
      child: Container(
        height: 60.0,
        alignment: AlignmentDirectional.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.0),
            color: Colors.white,
            boxShadow: [BoxShadow(blurRadius: 10.0, color: Colors.black12)]),
        padding:
        EdgeInsets.only(left: 20.0, right: 30.0, top: 0.0, bottom: 0.0),
        child: Theme(
          data: ThemeData(
            hintColor: Colors.transparent,
          ),
          child: TextFormField(
            obscureText: password,
            validator: (value) => value.isEmpty ? 'Please enter value' : null,
            onSaved: (value) =>
            (password) ? mPassword = value : isFullname ? fullname = value : mEmail = value,
            decoration: InputDecoration(
                border: InputBorder.none,
                labelText: placeholder,
                icon: Icon(
                  icon,
                  color: Colors.black38,
                ),
                labelStyle: TextStyle(
                    fontSize: 15.0,
                    fontFamily: 'Sans',
                    letterSpacing: 0.3,
                    color: Colors.black38,
                    fontWeight: FontWeight.w600)),
            keyboardType: inputType,
          ),
        ),
      ),
    );
  }
}

/// textfromfield custom class
//class textFromField extends StatelessWidget {
//  bool password;
//  String placeholder;
//  IconData icon;
//  TextInputType inputType;
//
//  textFromField({this.placeholder, this.icon, this.inputType, this.password});
//
//  @override
//  Widget build(BuildContext context) {
//    return Padding(
//      padding: EdgeInsets.symmetric(horizontal: 30.0),
//      child: Container(
//        height: 60.0,
//        alignment: AlignmentDirectional.center,
//        decoration: BoxDecoration(
//            borderRadius: BorderRadius.circular(14.0),
//            color: Colors.white,
//            boxShadow: [BoxShadow(blurRadius: 10.0, color: Colors.black12)]),
//        padding:
//            EdgeInsets.only(left: 20.0, right: 30.0, top: 0.0, bottom: 0.0),
//        child: Theme(
//          data: ThemeData(
//            hintColor: Colors.transparent,
//          ),
//          child: TextFormField(
//            obscureText: password,
//            decoration: InputDecoration(
//                border: InputBorder.none,
//                labelText: placeholder,
//                icon: Icon(
//                  icon,
//                  color: Colors.black38,
//                ),
//                labelStyle: TextStyle(
//                    fontSize: 15.0,
//                    fontFamily: 'Sans',
//                    letterSpacing: 0.3,
//                    color: Colors.black38,
//                    fontWeight: FontWeight.w600)),
//            keyboardType: inputType,
//          ),
//        ),
//      ),
//    );
//  }
//}

///buttonCustomFacebook class
class buttonCustomFacebook extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Container(
        alignment: FractionalOffset.center,
        height: 49.0,
        width: 500.0,
        decoration: BoxDecoration(
          color: Color.fromRGBO(107, 112, 248, 1.0),
          borderRadius: BorderRadius.circular(40.0),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 15.0)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              "assets/img/icon_facebook.png",
              height: 25.0,
            ),
            Padding(padding: EdgeInsets.symmetric(horizontal: 7.0)),
            Text(
              "Signup With Facebook",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.0,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Sans'),
            ),
          ],
        ),
      ),
    );
  }
}

///buttonCustomGoogle class
class buttonCustomGoogle extends StatelessWidget {
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
            Image.asset(
              "assets/img/google.png",
              height: 25.0,
            ),
            Padding(padding: EdgeInsets.symmetric(horizontal: 7.0)),
            Text(
              "Signup With Google",
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

///ButtonBlack class
class buttonBlackBottom extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(30.0),
      child: Container(
        height: 55.0,
        width: 600.0,
        child: Text(
          "Sign Up",
          style: TextStyle(
              color: Colors.white,
              letterSpacing: 0.2,
              fontFamily: "Sans",
              fontSize: 18.0,
              fontWeight: FontWeight.w800),
        ),
        alignment: FractionalOffset.center,
        decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 15.0)],
            borderRadius: BorderRadius.circular(30.0),
            gradient: LinearGradient(
                colors: <Color>[Color(0xFF121940), Color(0xFF6E48AA)])),
      ),
    );
  }
}
