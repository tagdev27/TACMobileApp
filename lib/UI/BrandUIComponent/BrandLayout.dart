import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:treva_shop_flutter/Library/date_picker/datetime_picker_formfield.dart';
import 'package:treva_shop_flutter/ListItem/socialtree.dart';
import 'package:treva_shop_flutter/UI/BrandUIComponent/BrandDetail.dart';
import 'package:treva_shop_flutter/ListItem/BrandDataList.dart';
import 'package:treva_shop_flutter/UI/HomeUIComponent/Search.dart';
import 'package:treva_shop_flutter/UI/LoginOrSignup/Login.dart';
import 'package:treva_shop_flutter/Utils/colors.dart';
import 'package:treva_shop_flutter/Utils/general.dart';
import 'package:treva_shop_flutter/Utils/progress.dart';
import 'package:treva_shop_flutter/Utils/storage.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class brand extends StatefulWidget {
  @override
  _brandState createState() => _brandState();
}

class _brandState extends State<brand> {
  StorageSystem ss = new StorageSystem();
  bool logged = false;
  ProgressDisplay pd;
  final formKey = new GlobalKey<FormState>();

  List<SocialTree> mySocialTree = new List();
  int eventCount = 0;
  String _email = '';

  bool hasGoogleToken = false, reloadToken = false;
  dynamic GoogleToken = {};
  int google_events_counts = 0;
  dynamic google_events_list = {};
  List<SocialEvents> googleEvents = new List();
  List<SocialEvents> userSelectedGoogleEvents = new List();
  List<Map<int, bool>> selectedGoogleEvents = new List();
  String google_picture = '';

  bool hasFacebookToken = false;
  dynamic FacebookToken = {};
  String facebook_id = '',
      facebook_gender = '',
      facebook_birthday = '',
      google_social_tree_key = '';

  TextEditingController t1 = new TextEditingController(text: '');
  TextEditingController t2 = new TextEditingController(text: '');
  TextEditingController t3 = new TextEditingController(text: '');
  TextEditingController t4 = new TextEditingController(text: '');
  TextEditingController t5 = new TextEditingController(text: '');
  TextEditingController t6 = new TextEditingController(text: '');
  TextEditingController t7 = new TextEditingController(text: '');

  TextEditingController e1 = new TextEditingController(text: '');
  String _event_date = '';
  TextEditingController e2 = new TextEditingController(text: '');

  List<String> genders = ['male', 'female'];
  String selected_gender = 'male';
  List<String> manual_events = new List();

  final dateFormat = DateFormat("yyyy-MM-dd");
  File _fileImage = null;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pd = new ProgressDisplay(context);
    String user = ss.getItem('user');
    setState(() {
      logged = user.isNotEmpty;
    });
    google_social_tree_key = FirebaseDatabase.instance.reference().push().key;
    checkGoogleToken();
  }

  bool _inAsyncCall = false,
      display_google_view = false,
      display_manual_view = false;

  /// Custom text header for bottomSheet
  final _fontCostumSheetBotomHeader = TextStyle(
      fontFamily: "Berlin",
      color: Colors.black54,
      fontWeight: FontWeight.w600,
      fontSize: 16.0);

  /// Custom text for bottomSheet
  final _fontCostumSheetBotom = TextStyle(
      fontFamily: "Sans",
      color: Colors.black45,
      fontWeight: FontWeight.w400,
      fontSize: 16.0);

  /// Create Modal BottomSheet (SortBy)
  void _modalBottomSheetOptions() {
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return SingleChildScrollView(
            child: new Container(
              height: 200.0,
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(padding: EdgeInsets.only(top: 20.0)),
                  Text("ADD USING", style: _fontCostumSheetBotomHeader),
                  Padding(padding: EdgeInsets.only(top: 20.0)),
                  Container(
                    width: 500.0,
                    color: Colors.black26,
                    height: 0.5,
                  ),
                  Padding(padding: EdgeInsets.only(top: 25.0)),
                  InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        googleAdding();
//                        Navigator.of(context).push(MaterialPageRoute(
//                            builder: (BuildContext context) => new Menu()));
                      },
                      child: Text(
                        "Google Calendar",
                        style: _fontCostumSheetBotom,
                      )),
                  Padding(padding: EdgeInsets.only(top: 25.0)),
                  InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          display_manual_view = true;
                          display_google_view = false;
                        });
//                        Navigator.of(context).push(MaterialPageRoute(
//                            builder: (BuildContext context) => new Menu()));
                      },
                      child: Text(
                        "Manual Inputting",
                        style: _fontCostumSheetBotom,
                      )),
                  Padding(padding: EdgeInsets.only(top: 25.0)),
                ],
              ),
            ),
          );
        });
  }

  checkGoogleToken() {
    if (logged) {
      Map<String, dynamic> _user = json.decode(ss.getItem("user"));
      setState(() {
        _email = '${_user['email']}';
      });
      Firestore.instance.collection('users').document(_email).get().then((u) {
        Map<String, dynamic> user = u.data;
        if (user['Tokens'] != null) {
          setState(() {
            hasGoogleToken = true;
            GoogleToken = user['Tokens'];
          });
        }
        if (user['Facebook'] != null) {
          setState(() {
            hasFacebookToken = true;
            FacebookToken = user['Facebook'];
            facebook_id = user['facebook_id'];
            facebook_gender = user['gender'];
            facebook_birthday = user['birthday'];
          });
        }
        if (user['picture'] != null) {
          setState(() {
            this.google_picture = user['picture'];
          });
        }
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

  @override
  Widget build(BuildContext context) {
    /// Component appbar
    var _appbar = AppBar(
      backgroundColor: Color(0xFFFFFFFF),
      elevation: 0.0,
      iconTheme: IconThemeData(color: Color(MyColors.primary_color)),
      centerTitle: true,
      title: Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: Text(
          "Social Tree",
          style: TextStyle(
              fontFamily: "Gotik",
              fontSize: 20.0,
              color: Colors.black54,
              fontWeight: FontWeight.w700),
        ),
      ),
      actions: <Widget>[
        (logged)
            ? FlatButton.icon(
                onPressed: _modalBottomSheetOptions,
                icon: Icon(Icons.add),
                label: Text('ADD'))
            : Text('')
      ],
    );
    /*
    * slivers: <Widget>[
                SliverPadding(
                  padding: EdgeInsets.only(top: 0.0),
                  sliver: SliverFixedExtentList(
                      itemExtent: 145.0,
                      delegate: SliverChildBuilderDelegate(
                        /// Calling itemCard Class for constructor card
                              (context, index) => itemCard(brandData[index]),
                          childCount: brandData.length)),
                ),
              ],
    * */

    /// Hero animation for image
    final hero = Hero(
      tag: 'hero-tag-social-tree',
      child: new DecoratedBox(
        decoration: new BoxDecoration(
          image: new DecorationImage(
              fit: BoxFit.cover,
              image: new AssetImage('assets/imgPromo/social-tree-hero.png')),
          shape: BoxShape.rectangle,
        ),
        child: Container(
          height: 65.0,
          margin: EdgeInsets.only(top: 130.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: <Color>[
                  new Color(0x00FFFFFF),
                  new Color(0xFFFFFFFF),
                ],
                stops: [
                  0.0,
                  1.0
                ],
                begin: FractionalOffset(0.0, 0.0),
                end: FractionalOffset(0.0, 1.0)),
          ),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Scaffold(

          /// Calling variable appbar
          appBar: _appbar,
          body: (logged)
              ? ModalProgressHUD(
                  opacity: 0.3,
                  inAsyncCall: _inAsyncCall,
                  progressIndicator: CircularProgressIndicator(),
                  color: Color(MyColors.button_text_color),
                  child: (!display_google_view && !display_manual_view)
                      ? Container(
                          width: MediaQuery.of(context).size.width,
                          color: Colors.white,
                          child: SingleChildScrollView(
                            /// Create List Menu
                            child: Container(
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  hero,
                                  Padding(
                                    padding:
                                        EdgeInsets.only(top: 20.0, left: 15.0),
                                    child: Row(
                                      children: <Widget>[
                                        Image.network(
                                          "https://tacgifts.com/assets/images/social-tree/Cake.png",
                                          height: 50.0,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 12.0, top: 8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                "Set that reminder",
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 25.0),
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
                                    padding: const EdgeInsets.only(
                                        left: 20.0, right: 20.0, top: 0.0),
                                    child: Text(
                                      "Our Social Tree Feature is designed for you to ensure you are connected with your loved ones for those "
                                      "special moments without the need of you remembering the dates and occasion. When you sign up simply"
                                      " input the required details and we would do the rest!\n\n"
                                      "So kindly do us the honour of filling in necessary details that will help actualize "
                                      "a gifting experience for your loved ones. Regardless of geography, "
                                      "TAC can help you gift your friends and family members here in Nigeria. The experience is mind-blowing. Just TAC it!",
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 15.0,
                                          height: 1.4),
                                      textAlign: TextAlign.justify,
                                    ),
                                  ),
                                  Container(
                                    child: Image.network(
                                        'https://tacgifts.com/assets/images/social-tree/Reminder_card.png'),
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                      : display_google_view ? googleView() : ManualView())
              : NotLoggedIn()),
    );
  }

  googleAdding() {
    if (reloadToken) {
      _handleGoogleSignIn();
      return;
    }
    if (!hasGoogleToken) {
      _handleGoogleSignIn();
      return;
    }
    accessEventsFromGoogleResult();
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      final GoogleSignIn _googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'profile',
          'https://www.googleapis.com/auth/calendar.events.readonly',
        ],
      );
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      pd.displayDialog("Please wait...");
      Map<String, dynamic> updateUserData = new Map();
      updateUserData['Tokens'] = {
        'oauthAccessToken': googleAuth.accessToken,
        'oauthIdToken': googleAuth.idToken,
        'providerId': 'google.com',
        'signInMethod': 'google.com'
      };
      await Firestore.instance
          .collection('users')
          .document(_email)
          .updateData(updateUserData);
      pd.dismissDialog();
      setState(() {
        GoogleToken = updateUserData['Tokens'];
      });
      accessEventsFromGoogleResult();
    } catch (err) {
      print('google err = $err');
    }
    return null;
  }

  accessEventsFromGoogleResult() {
    setState(() {
      display_google_view = true;
      display_manual_view =  false;
      _inAsyncCall = true;
    });
    dynamic oauth_access_token = GoogleToken['oauthAccessToken'];
    dynamic googleApiHeader = {
      'Authorization': 'Bearer $oauth_access_token',
      'Accept': 'application/json'
    };
    http.get('https://www.googleapis.com/calendar/v3/calendars/primary/events?key=AIzaSyAu77RE_S5__DnrmaR1LKJvqtNNyR0mSzo', headers: googleApiHeader).then((res){
      //print(res.body);
      dynamic r = json.decode(res.body);
      if(r['error'] != null){
        setState(() {
          _inAsyncCall = false;
          reloadToken = true;
          display_google_view = false;
        });
        new GeneralUtils().neverSatisfied(context, 'Error', 'User access token expired. Please try again..');
        return;
      }
      setState(() {
        reloadToken = false;
        hasGoogleToken = true;
        google_events_list = r;
      });
      List<dynamic> items = r['items'];
      int index = 0;
      items.forEach((ms){
        String event_name = ms['summary'];
        dynamic start_date = ms['start'];
        String event_date = start_date['dateTime'];
        if (event_date == null) {
          event_date = start_date['date'];
        }
        DateTime date = DateTime.parse(event_date);
        SocialEvents se = new SocialEvents(event_name, event_date, date.millisecond, date.day, date.month - 1, date.year, google_social_tree_key, _email);
        Map<int, bool> mp = new Map();
        mp[index] = false;
        setState(() {
          googleEvents.add(se);
          selectedGoogleEvents.add(mp);
        });
        index++;
      });
      setState(() {
        _inAsyncCall = false;
      });
    }).catchError((err){
      setState(() {
        _inAsyncCall = false;
        reloadToken = true;
        display_google_view = false;
      });
      new GeneralUtils().neverSatisfied(context, 'Error', 'User access token expired. Please try again..');
    });
  }

  Widget googleView() {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Colors.white,
      child: SingleChildScrollView(
        /// Create List Menu
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                    icon: Icon(Icons.keyboard_backspace, size: 32.0, color: Colors.redAccent,),
                    onPressed: () {
                      setState(() {
                        display_google_view = false;
                        display_manual_view = false;
                        googleEvents.clear();
                        selectedGoogleEvents.clear();
                        userSelectedGoogleEvents.clear();
                      });
                    }),
              ),
              generateListTileOfEventsFromGoogle(),
              InkWell(
                onTap: saveSelectionData,
                child: Padding(
                  padding: EdgeInsets.all(30.0),
                  child: Container(
                    height: 55.0,
                    child: Text(
                      "Submit Selections",
                      style: TextStyle(
                          color: Colors.white,
                          letterSpacing: 0.2,
                          fontFamily: "Sans",
                          fontSize: 18.0,
                          fontWeight: FontWeight.w800),
                    ),
                    alignment: FractionalOffset.center,
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(color: Colors.black38, blurRadius: 15.0)
                        ],
                        borderRadius: BorderRadius.circular(30.0),
                        gradient: LinearGradient(colors: <Color>[
                          Color(0xFF121940),
                          Color(0xFF6E48AA)
                        ])),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void removeAndAddSelectionFromMap(int index, bool value){
    selectedGoogleEvents.removeAt(index);
    Map<int, bool> mp = new Map();
    mp[index] = value;
    selectedGoogleEvents.insert(index, mp);
    print('index at $index and map is ${selectedGoogleEvents[index][index]}');
  }

  Widget generateListTileOfEventsFromGoogle() {
    if (googleEvents.isEmpty) {
      return Text('');
    }
    List<Widget> ev = new List();
    for (int i = 0; i < googleEvents.length; i++) {
      SocialEvents se = googleEvents[i];
      Map<int, bool> mp = selectedGoogleEvents[i];
      ev.add(Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        child: ListTile(
          title: Text(
            se.event_name ?? '',
            style: _fontCostumSheetBotomHeader,
          ),
          subtitle: Text(
            se.event_date ?? '',
            style: _fontCostumSheetBotom,
          ),
          trailing: FlatButton(onPressed: (){
            print('index at $i and map is ${mp[i]}');
            if(mp[i] == true){
              setState(() {
                userSelectedGoogleEvents.remove(se);
                //mp[i] = false;
                removeAndAddSelectionFromMap(i, false);
              });
            }else {
              setState(() {
                userSelectedGoogleEvents.add(se);
//                mp[i] = true;
                removeAndAddSelectionFromMap(i, true);
              });
            }
          }, child: Text((mp[i] == true) ? 'SELECTED' : 'SELECT', style: (mp[i] == true) ? _fontCostumSheetBotom.copyWith(color: Color(MyColors.primary_color)) : _fontCostumSheetBotom.copyWith(color: Colors.grey))),
          leading: Icon(
            Icons.event_available,
          ),
        ),
      ));
      ev.add(Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: Divider(
            height: 1.0,
            color: Colors.grey,
          )));
    }
    return Container(
      child: Column(
        children: ev,
      ),
    );
  }

  saveSelectionData() async {
    try {
      if (userSelectedGoogleEvents.isEmpty) {
        new GeneralUtils().neverSatisfied(
            context, 'Error', 'Please select at least one event.');
        return;
      }
      setState(() {
        _inAsyncCall = true;
      });

      SocialTree st = new SocialTree(
          google_social_tree_key,
          _email,
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          google_picture,
          'google',
          FieldValue.serverTimestamp());

      Firestore.instance.collection('social-tree').document(
          google_social_tree_key).setData(st.toJSON()).then((d) {
        userSelectedGoogleEvents.forEach((e) async {
          String id = FirebaseDatabase.instance
              .reference()
              .push()
              .key;
          await Firestore.instance.collection('social-tree-events')
              .document(id)
              .setData(e.toJSON());
        });

        setState(() {
          googleEvents.clear();
          selectedGoogleEvents.clear();
          userSelectedGoogleEvents.clear();
          _inAsyncCall = false;
          display_manual_view = false;
          display_google_view = false;
        });
        new GeneralUtils().showToast('Member successfully added.');
      }).catchError((err) {
        setState(() {
          _inAsyncCall = false;
        });
        new GeneralUtils().neverSatisfied(
            context, 'Error', 'An error occurred, please try again.');
      });
    }catch(e) {
      print(e);
      setState(() {
        _inAsyncCall = false;
      });
      new GeneralUtils().neverSatisfied(context, 'Error', 'An error occurred, please try again.');
    }
  }

  Widget ManualView() {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Colors.white,
      child: SingleChildScrollView(
        /// Create List Menu
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                    icon: Icon(Icons.keyboard_backspace, size: 32.0, color: Colors.redAccent,),
                    onPressed: () {
                      setState(() {
                        display_google_view = false;
                        display_manual_view = false;
                      });
                    }),
              ),
              Form(
                key: formKey,
                child: Column(
                  children: <Widget>[
                    Padding(padding: EdgeInsets.symmetric(vertical: 0.0)),
                    InkWell(child:Container(
                      height: 100.0,
                      width: 100.0,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2.5),
                          boxShadow: [
                            BoxShadow(color: Colors.black38, blurRadius: 15.0)
                          ],
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: (_fileImage == null) ? NetworkImage('https://tacadmin.firebaseapp.com/assets/img/default-avatar.png') : FileImage(_fileImage))),
                    ), onTap: getImage,),
                    Text(
                      'click above image to upload',
                      style:
                      _fontCostumSheetBotom,
                    ),
                    Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
                    textFromField(
                      t1,
                      icon: Icons.person,
                      password: false,
                      placeholder: "First Name*",
                      inputType: TextInputType.text,
                    ),
                    Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
                    textFromField(
                      t2,
                      icon: Icons.person,
                      password: false,
                      placeholder: "Last Name*",
                      inputType: TextInputType.text,
                    ),
                    Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
                    textFromField(
                      t3,
                      icon: Icons.phone,
                      password: false,
                      placeholder: "Phone Number (optional)",
                      inputType: TextInputType.phone,
                    ),
                    Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
                    textFromField(
                      t4,
                      icon: Icons.email,
                      password: false,
                      placeholder: "Email Address (optional)",
                      inputType: TextInputType.emailAddress,
                    ),
                    //gender
                    Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
                    dropDownField(),
                    Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
                    textFromField(
                      t5,
                      icon: Icons.supervised_user_circle,
                      password: false,
                      placeholder: "Relationship*",
                      inputType: TextInputType.text,
                    ),
                    Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
                    textFromField(
                      t6,
                      icon: Icons.work,
                      password: false,
                      placeholder: "Occupation (optional)",
                      inputType: TextInputType.text,
                    ),
                    Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
                    textFromField(
                      t7,
                      icon: Icons.home,
                      password: false,
                      placeholder: "Address (optional)",
                      inputType: TextInputType.text,
                    ),
                    Padding(padding: EdgeInsets.symmetric(vertical: 10.0)),
                    Text(
                      'Add Events With Name & Date',
                      style:
                          _fontCostumSheetBotomHeader.copyWith(fontSize: 20.0),
                    ),
                    Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          textFromFieldEvents(
                            e1,
                            icon: Icons.edit,
                            password: false,
                            placeholder: "Event Name*",
                            inputType: TextInputType.text,
                          ),
//                          textFromFieldEvents(e2,
//                            icon: Icons.date_range,
//                            password: false,
//                            placeholder: "Event Date*",
//                            inputType: TextInputType.text,
//                          ),
                          Padding(
                              padding: EdgeInsets.only(left: 10.0, right: 0.0),
                              child: Container(
                                  width:
                                      MediaQuery.of(context).size.width / 2.8,
                                  height: 60.0,
                                  alignment: AlignmentDirectional.center,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14.0),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                            blurRadius: 10.0,
                                            color: Colors.black12)
                                      ]),
                                  padding: EdgeInsets.only(
                                      left: 10.0,
                                      right: 0.0,
                                      top: 0.0,
                                      bottom: 0.0),
                                  child: Theme(
                                      data: ThemeData(
                                        hintColor: Colors.transparent,
                                      ),
                                      child: new DateTimeField(
                                        format: dateFormat,
                                        onChanged: (date) {
                                          _event_date = date.toString();
                                        },
                                        controller: e2,
                                        decoration: new InputDecoration(
                                          labelText: 'Event Date*',
                                          alignLabelWithHint: true,
                                          hasFloatingPlaceholder: true,
                                          border: InputBorder.none,
                                            labelStyle: TextStyle(
                                                fontSize: 13.0,
                                                fontFamily: 'Sans',
                                                letterSpacing: 0.3,
                                                color: Colors.black38,
                                                fontWeight: FontWeight.w600)
                                        ),
                                        onShowPicker: (context, currentValue) {
                                          return showDatePicker(
                                              context: context,
                                              firstDate: DateTime(1900),
                                              initialDate: currentValue ??
                                                  DateTime.now(),
                                              lastDate: DateTime(2500));
                                        },
                                      )))),
                          FlatButton(
                              onPressed: _addEventDialog, child: Text('ADD'))
                        ],
                      ),
                    ),
                    Padding(padding: EdgeInsets.symmetric(vertical: 10.0)),

                    generateListTileOfEvents(),

                    InkWell(
                      onTap: saveManualInputData,
                      child: Padding(
                        padding: EdgeInsets.all(30.0),
                        child: Container(
                          height: 55.0,
                          child: Text(
                            "Submit Member",
                            style: TextStyle(
                                color: Colors.white,
                                letterSpacing: 0.2,
                                fontFamily: "Sans",
                                fontSize: 18.0,
                                fontWeight: FontWeight.w800),
                          ),
                          alignment: FractionalOffset.center,
                          decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(color: Colors.black38, blurRadius: 15.0)
                              ],
                              borderRadius: BorderRadius.circular(30.0),
                              gradient: LinearGradient(colors: <Color>[
                                Color(0xFF121940),
                                Color(0xFF6E48AA)
                              ])),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //add event name and date to manual_event separated by |
  _addEventDialog() {
    if (e1.text.isEmpty || e2.text.isEmpty) {
      return;
    }
    manual_events.add("${e1.text}|${e2.text}|$_event_date");
    setState(() {
      e1.clear();
      e2.clear();
    });
  }

  Widget generateListTileOfEvents() {
    if (manual_events.isEmpty) {
      return Text('');
    }
    List<Widget> ev = new List();
    for (int i = 0; i < manual_events.length; i++) {
      List<String> item = manual_events[i].split('|');
      String title = item[0];
      String date = item[1];
      ev.add(Padding(
        padding: EdgeInsets.symmetric(horizontal: 30.0),
        child: ListTile(
          title: Text(
            title,
            style: _fontCostumSheetBotomHeader,
          ),
          subtitle: Text(
            date,
            style: _fontCostumSheetBotom,
          ),
          trailing: IconButton(
              icon: Icon(
                Icons.close,
                color: Colors.red,
              ),
              onPressed: () {
                setState(() {
                  manual_events.removeAt(i);
                });
              }),
          leading: Icon(
            Icons.event_available,
          ),
        ),
      ));
      ev.add(Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.0),
          child: Divider(
            height: 1.0,
            color: Colors.grey,
          )));
    }
    return Container(
      child: Column(
        children: ev,
      ),
    );
  }

  saveManualInputData() async {
    try {
      if (t1.text.isEmpty || t2.text.isEmpty || t5.text.isEmpty) {
        new GeneralUtils().neverSatisfied(
            context, 'Error', 'Please fill all fields marked with *');
        return;
      }
      if (manual_events.isEmpty) {
        new GeneralUtils().neverSatisfied(
            context, 'Error', 'Please add at least one event.');
        return;
      }
      setState(() {
        _inAsyncCall = true;
      });

      List<SocialEvents> events = new List();
      String key = FirebaseDatabase.instance
          .reference()
          .push()
          .key;

      manual_events.forEach((item) {
        List<String> v = item.split('|');
        DateTime dt = DateTime.parse(v[2]);
        SocialEvents se = new SocialEvents(
            v[0],
            v[1],
            dt.millisecond,
            dt.day,
            dt.month - 1,
            dt.year,
            key,
            _email);
        events.add(se);
      });

      String image_url = 'https://tacadmin.firebaseapp.com/assets/img/default-avatar.png';
      if (_fileImage != null) {
        String key = FirebaseDatabase.instance
            .reference()
            .push()
            .key;
        final StorageReference ref = FirebaseStorage.instance.ref().child(
            'social-tree').child('$key.jpg');
        final StorageUploadTask uploadTask = ref.putFile(_fileImage);
        StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
        String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
        image_url = downloadUrl;
      }
      
      SocialTree st = new SocialTree(key, _email, '${t1.text} ${t2.text}', selected_gender, t5.text, t6.text, t7.text, t3.text, t4.text, image_url, 'manual', FieldValue.serverTimestamp());
      
      Firestore.instance.collection('social-tree').document(key).setData(st.toJSON()).then((d){

        events.forEach((e) async {
          String id = FirebaseDatabase.instance
              .reference()
              .push()
              .key;
          await Firestore.instance.collection('social-tree-events').document(id).setData(e.toJSON());
        });

        setState(() {
          manual_events.clear();
          t1.clear();
          t2.clear();
          t3.clear();
          t4.clear();
          t5.clear();
          t6.clear();
          t7.clear();
          e1.clear();
          e2.clear();
          _inAsyncCall = false;
          display_manual_view = false;
          display_google_view = false;
        });
        new GeneralUtils().showToast('Member successfully added.');

      }).catchError((err){
        setState(() {
          _inAsyncCall = false;
        });
        new GeneralUtils().neverSatisfied(context, 'Error', 'An error occurred, please try again.');
      });
    }catch(e) {
      print(e);
     setState(() {
       _inAsyncCall = false;
     });
     new GeneralUtils().neverSatisfied(context, 'Error', 'An error occurred, please try again.');
    }
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    form.save();
    return form.validate();
  } //not used

  //dropdown custom class
  Widget dropDownField() {
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
            child: DropdownButton(
              items: genders.map((m) {
                return DropdownMenuItem<String>(
                  value: m,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Icon(Icons.verified_user, color: Colors.black38,),
                      Padding(padding: EdgeInsets.only(left: 15.0), child: Text(
                        m,
                        textAlign: TextAlign.left,
                      ),)
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String item) {
                setState(() {
                  selected_gender = item;
                });
              },
              value: selected_gender,
              hint: Text(
                'male',
                textAlign: TextAlign.right,
              ),
              underline: Divider(
                height: 0.0,
                color: Colors.white,
              ),
              isExpanded: true,//icon: Icon(Icons.verified_user),
              style: TextStyle(
                  fontSize: 15.0,
                  fontFamily: 'Sans',
                  letterSpacing: 0.3,
                  color: Colors.black38,
                  fontWeight: FontWeight.w600),
            )),
      ),
    );
  }

  /// textfromfield custom class
  Widget textFromField(TextEditingController _controller,
      {String placeholder,
      IconData icon,
      TextInputType inputType,
      bool password}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.0),
      child: Container(
        width: MediaQuery.of(context).size.width,
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
            controller: _controller,
            decoration: InputDecoration(
                border: InputBorder.none,
                labelText: placeholder,
                icon: Icon(
                  icon,
                  color: Colors.black38,
                ),
                fillColor: Color(MyColors.primary_color),
                focusColor: Color(MyColors.primary_color),
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

  /// textfromfield custom class
  Widget textFromFieldEvents(TextEditingController _controller,
      {String placeholder,
      IconData icon,
      TextInputType inputType,
      bool password}) {
    return Padding(
      padding: EdgeInsets.only(left: 30.0, right: 0.0),
      child: Container(
        width: MediaQuery.of(context).size.width / 3.2,
        height: 60.0,
        alignment: AlignmentDirectional.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.0),
            color: Colors.white,
            boxShadow: [BoxShadow(blurRadius: 10.0, color: Colors.black12)]),
        padding: EdgeInsets.only(left: 10.0, right: 0.0, top: 0.0, bottom: 0.0),
        child: Theme(
          data: ThemeData(
            hintColor: Colors.transparent,
          ),
          child: TextFormField(
            obscureText: password,
            controller: _controller,
            decoration: InputDecoration(
                border: InputBorder.none,
                labelText: placeholder,
                labelStyle: TextStyle(
                    fontSize: 13.0,
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

/// Constructor for itemCard for List Menu
class itemCard extends StatelessWidget {
  /// Declaration and Get data from BrandDataList.dart
  final Brand brand;
  itemCard(this.brand);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            PageRouteBuilder(
                pageBuilder: (_, __, ___) => new brandDetail(null, null),
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
                      image: AssetImage(brand.img), fit: BoxFit.cover),
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
