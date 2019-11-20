import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:treva_shop_flutter/UI/AcountUIComponent/AboutApps.dart';
import 'package:treva_shop_flutter/UI/AcountUIComponent/CallCenter.dart';
import 'package:treva_shop_flutter/UI/AcountUIComponent/Message.dart';
import 'package:treva_shop_flutter/UI/LoginOrSignup/ChoseLoginOrSignup.dart';
import 'package:treva_shop_flutter/UI/AcountUIComponent/CreditCardSetting.dart';
import 'package:treva_shop_flutter/UI/AcountUIComponent/MyOrders.dart';
import 'package:treva_shop_flutter/UI/AcountUIComponent/Notification.dart';
import 'package:treva_shop_flutter/UI/AcountUIComponent/SettingAcount.dart';
import 'package:treva_shop_flutter/UI/LoginOrSignup/Login.dart';
import 'package:treva_shop_flutter/UI/LoginOrSignup/Signup.dart';
import 'package:treva_shop_flutter/Utils/colors.dart';
import 'package:treva_shop_flutter/Utils/general.dart';
import 'package:treva_shop_flutter/Utils/storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_editor/image_editor.dart';

class profil extends StatefulWidget {
  @override
  _profilState createState() => _profilState();
}

/// Custom Font
var _txt = TextStyle(
  color: Colors.black,
  fontFamily: "Sans",
);

/// Get _txt and custom value of Variable for Name User
var _txtName = _txt.copyWith(fontWeight: FontWeight.w700, fontSize: 17.0);

/// Get _txt and custom value of Variable for Edit text
var _txtEdit = _txt.copyWith(color: Colors.black26, fontSize: 15.0);

/// Get _txt and custom value of Variable for Category Text
var _txtCategory = _txt.copyWith(
    fontSize: 14.5, color: Colors.black54, fontWeight: FontWeight.w500);

class _profilState extends State<profil> {
  StorageSystem ss = new StorageSystem();
  bool logged = false, profileImageLoaded = false;
  String _fn,
      _ln,
      _email,
      profile_picture =
          'https://tacadmin.firebaseapp.com/assets/img/default-avatar.png';

  File _fileImage;

  bool _inAsyncCall = false;
  
  double progress_count = 0.0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
    String user = ss.getItem('user');
    setState(() {
      logged = user.isNotEmpty;
    });
  }

  void getUser() {
    if (ss.getItem("user") != '') {
      Map<String, dynamic> user = json.decode(ss.getItem("user"));
      if (!mounted) return;
      setState(() {
        _fn = '${user['fn']}';
        _ln = '${user['ln']}';
        _email = '${user['email']}';
      });
      getUserProfileImage();
    }
  }

  getUserProfileImage() async {
    DocumentSnapshot user =
        await Firestore.instance.collection('users').document(_email).get();
    Map<String, dynamic> data = user.data;
    if (data['picture'] != null) {
      if (!mounted) return;
      setState(() {
        profile_picture = data['picture'];
        profileImageLoaded = true;
      });
    }
  }

  Future<void> getImage() async {
    return showDialog<Null>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text('Source'),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                new Text('Select image source'),
                Container(
                  height: 10.0,
                ),
                ListTile(
                  title: Text('Camera'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    var image =
                        await ImagePicker.pickImage(source: ImageSource.camera);
                    setState(() {
                      _fileImage = image;
                    });
                    uploadAndUpdateProfileImage();
                  },
                ),
                Divider(
                  height: 1.0,
                  color: Colors.black,
                ),
                ListTile(
                  title: Text('Gallery'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    var image = await ImagePicker.pickImage(
                        source: ImageSource.gallery);
                    setState(() {
                      _fileImage = image;
                    });
                    uploadAndUpdateProfileImage();
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  
  Future<void> uploadAndUpdateProfileImage() async {
    //print(_fileImage.path);
//    final editorOption = ImageEditorOption();
//    editorOption.addOption(FlipOption());
//    editorOption.addOption(ClipOption(height: 640, width: 640, x: 0, y: 0));
//    editorOption.addOption(RotateOption(360));
//    editorOption.outputFormat = OutputFormat.jpeg(75);
//    File _editedImage = await ImageEditor.editFileImageAndGetFile(file: _fileImage.absolute, imageEditorOption: editorOption);

    setState(() {
      _inAsyncCall = true;
    });

    String key = FirebaseDatabase.instance.reference().push().key;
    final StorageReference ref = FirebaseStorage.instance.ref().child('users').child('$key.jpeg');
    final StorageUploadTask uploadTask = ref.putFile(_fileImage);
    uploadTask.events.listen((event) {
      setState(() {
        progress_count = ((event.snapshot.bytesTransferred.toDouble() / event.snapshot.totalByteCount.toDouble()) * 100).ceilToDouble() / 100;
        //print('$progress_count %');
      });
    }).onError((err){
      setState(() {
        _inAsyncCall = false;
      });
      new GeneralUtils().neverSatisfied(context, 'Error', 'An error occurred. Please try again.');
    });
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    
    await Firestore.instance.collection('users').document(_email).updateData({'picture': downloadUrl});

    setState(() {
      _inAsyncCall = false;
      profile_picture = downloadUrl;
    });
    new GeneralUtils().neverSatisfied(context, 'Success', 'Picture uploaded successfully');
  }

  @override
  Widget build(BuildContext context) {
//    setState(() {
//      progress_count = 0.0;
//      _inAsyncCall = true;
//    });
    /// Declare MediaQueryData
    MediaQueryData mediaQueryData = MediaQuery.of(context);

    /// To Sett PhotoProfile,Name and Edit Profile
    var _profile = Padding(
      padding: EdgeInsets.only(
        top: 185.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Container(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                height: 100.0,
                width: 100.0,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2.5),
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: (profileImageLoaded)
                            ? NetworkImage(profile_picture)
                            : NetworkImage(profile_picture))),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text(
                  "$_fn $_ln",
                  style: _txtName,
                ),
              ),
              InkWell(
                onTap: getImage,
                child: Padding(
                  padding: const EdgeInsets.only(top: 0.0),
                  child: Text(
                    "Edit Profile Image",
                    style: _txtEdit,
                  ),
                ),
              ),
            ],
          ),
          Container(),
        ],
      ),
    );

    final color =  AlwaysStoppedAnimation<Color>(Color(MyColors.primary_color));
    return (logged)
        ? ModalProgressHUD(
        opacity: 0.3,
        inAsyncCall: _inAsyncCall,
        progressIndicator: CircularProgressIndicator(value: progress_count, strokeWidth: 3.0, valueColor: color),
        color: Color(MyColors.button_text_color),
        child: SingleChildScrollView(
            child: Container(
              color: Colors.white,
              child: Stack(
                children: <Widget>[
                  /// Setting Header Banner
                  Container(
                    height: 240.0,
                    color: Colors.deepPurpleAccent,
//              decoration: BoxDecoration(
//                  image: DecorationImage(
//                      image: AssetImage("assets/img/headerProfile.png"),
//                      fit: BoxFit.cover)),
                  ),

                  /// Calling _profile variable
                  _profile,
                  Padding(
                    padding: const EdgeInsets.only(top: 360.0),
                    child: Column(
                      /// Setting Category List
                      children: <Widget>[
                        /// Call category class
//                  category(
//                    txt: "Notification",
//                    padding: 35.0,
//                    image: "assets/icon/notification.png",
//                    tap: () {
//                      Navigator.of(context).push(PageRouteBuilder(
//                          pageBuilder: (_, __, ___) => new notification()));
//                    },
//                  ),
//                  Padding(
//                    padding: const EdgeInsets.only(
//                        top: 20.0, left: 85.0, right: 30.0),
//                    child: Divider(
//                      color: Colors.black12,
//                      height: 2.0,
//                    ),
//                  ),
                        category(
                          txt: "My Orders",
                          padding: 35.0,
                          image: "assets/icon/creditAcount.png",
                          tap: () {
                            Navigator.of(context).push(PageRouteBuilder(
                                pageBuilder: (_, __, ___) =>
                                    new creditCardSetting()));
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 20.0, left: 85.0, right: 30.0),
                          child: Divider(
                            color: Colors.black12,
                            height: 2.0,
                          ),
                        ),
//                  category(
//                    txt: "Message",
//                    padding: 26.0,
//                    image: "assets/icon/chat.png",
//                    tap: () {
//                      Navigator.of(context).push(PageRouteBuilder(
//                          pageBuilder: (_, __, ___) => new chat()));
//                    },
//                  ),
//                  Padding(
//                    padding: const EdgeInsets.only(
//                        top: 20.0, left: 85.0, right: 30.0),
//                    child: Divider(
//                      color: Colors.black12,
//                      height: 2.0,
//                    ),
//                  ),
                        category(
                          txt: "Track Orders",
                          padding: 23.0,
                          image: "assets/icon/truck.png",
                          tap: () {
                            Navigator.of(context).push(PageRouteBuilder(
                                pageBuilder: (_, __, ___) => new order()));
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 20.0, left: 85.0, right: 30.0),
                          child: Divider(
                            color: Colors.black12,
                            height: 2.0,
                          ),
                        ),
                        category(
                          txt: "Account Settings",
                          padding: 30.0,
                          image: "assets/icon/setting.png",
                          tap: () {
                            Navigator.of(context).push(PageRouteBuilder(
                                pageBuilder: (_, __, ___) =>
                                    new settingAcount()));
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 20.0, left: 85.0, right: 30.0),
                          child: Divider(
                            color: Colors.black12,
                            height: 2.0,
                          ),
                        ),
                        category(
                          txt: "Call Center",
                          padding: 30.0,
                          image: "assets/icon/callcenter.png",
                          tap: () {
                            Navigator.of(context).push(PageRouteBuilder(
                                pageBuilder: (_, __, ___) => new callCenter()));
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 20.0, left: 85.0, right: 30.0),
                          child: Divider(
                            color: Colors.black12,
                            height: 2.0,
                          ),
                        ),
                        category(
                          padding: 38.0,
                          txt: "About Apps",
                          image: "assets/icon/aboutapp.png",
                          tap: () {
                            Navigator.of(context).push(PageRouteBuilder(
                                pageBuilder: (_, __, ___) => new aboutApps()));
                          },
                        ),
                        Padding(padding: EdgeInsets.only(bottom: 20.0)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ))
        : NotLoggedIn();
  }
}

/// Component category class to set list
class category extends StatelessWidget {
  @override
  String txt, image;
  GestureTapCallback tap;
  double padding;

  category({this.txt, this.image, this.tap, this.padding});

  Widget build(BuildContext context) {
    return InkWell(
      onTap: tap,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 15.0, left: 30.0),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(right: padding),
                  child: Image.asset(
                    image,
                    height: 25.0,
                  ),
                ),
                Text(
                  txt,
                  style: _txtCategory,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NotLoggedIn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Container(
      width: 500.0,
      color: Colors.white,
      height: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
                padding:
                    EdgeInsets.only(top: mediaQueryData.padding.top + 50.0)),
            Image.asset(
              "assets/imgIllustration/IlustrasiCart.png",
              height: 300.0,
            ),
            Padding(padding: EdgeInsets.only(bottom: 10.0)),
            Text(
              "User must be logged in",
              style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 18.5,
                  color: Colors.black26.withOpacity(0.2),
                  fontFamily: "Popins"),
            ),
            Padding(padding: EdgeInsets.only(bottom: 10.0)),
            InkWell(
              onTap: () {
                new StorageSystem().disposePref();
                Navigator.of(context).pushReplacement(PageRouteBuilder(
                    pageBuilder: (_, __, ___) => new loginScreen()));
              },
              child: ButtonBlackBottom(),
            )
          ],
        ),
      ),
    );
  }
}

class ButtonBlackBottom extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(30.0),
      child: Container(
        height: 55.0,
        width: 600.0,
        child: Text(
          "Login",
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
