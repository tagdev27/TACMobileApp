import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:treva_shop_flutter/UI/BottomNavigationBar.dart';
import 'package:treva_shop_flutter/Utils/colors.dart';
import 'package:treva_shop_flutter/Utils/general.dart';
import 'package:treva_shop_flutter/Utils/storage.dart';
import 'package:treva_shop_flutter/main.dart';

class settingAcount extends StatefulWidget {
  @override
  _settingAcountState createState() => _settingAcountState();
}

class _settingAcountState extends State<settingAcount> {
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

  StorageSystem ss = new StorageSystem();
  String _fn = '', _ln = '', _email = '', _phone = '', _dob = '', _gender = '';

  bool _inAsyncCall = false;

  Future<void> getUser() async {
    setState(() {
      _inAsyncCall = true;
    });
    if (ss.getItem("user") != '') {
      Map<String, dynamic> user = json.decode(ss.getItem("user"));
      if (!mounted) return;
      setState(() {
        _fn = '${user['fn']}';
        _ln = '${user['ln']}';
        _email = '${user['email']}';
      });
    }

    final user =
        await Firestore.instance.collection('users').document(_email).get();
    Map<String, dynamic> dt = user.data;
    _fn = dt['firstname'];
    _ln = dt['lastname'];
    _phone = (dt['phone'] == null) ? 'Not available. Update now' : dt['phone'];
    _dob =
        (dt['birthday'] == null) ? 'Not available. Update now' : dt['birthday'];
    _gender =
        (dt['gender'] == null) ? 'Not available. Update now' : dt['gender'];

    setState(() {
      _inAsyncCall = false;
    });
  }

  final _controller = new TextEditingController(text: '');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Setting Acount",
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18.0,
                color: Colors.black54,
                fontFamily: "Gotik"),
          ),
          centerTitle: true,
          iconTheme: IconThemeData(color: Color(MyColors.primary_color)),
          elevation: 0.0,
        ),
        body: ModalProgressHUD(
          opacity: 0.3,
          inAsyncCall: _inAsyncCall,
          progressIndicator: CircularProgressIndicator(),
          color: Color(MyColors.button_text_color),
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 15.0, top: 15.0, left: 20.0),
                    child: Text(
                      'Account',
                      style: _txtCustomHead.copyWith(),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  divider(),
                  generateAccountLayout(),
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: InkWell(
                        onTap: () {
                          logout();
                        },
                        child: Container(
                          height: 70.0,
                          width: MediaQuery.of(context).size.width,
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 13.0, left: 20.0, bottom: 15.0),
                            child: Text(
                              "Logout",
                              style: _txtCustomHead.copyWith(color: Colors.red),
                            ),
                          ),
                        )),
                  )
                ],
              ),
            ),
          ),
        ));
  }

  Widget divider() {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 20.0),
      child: Divider(
        color: Colors.black12,
        height: 0.5,
      ),
    );
  }

  Widget generateAccountLayout() {
    return Container(
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text(
              'First Name',
              style: TextStyle(
                  color: Color(MyColors.primary_color),
                  fontSize: 12.0,
                  fontFamily: "Popins"),
            ),
            subtitle: Text(
              _fn,
              style: TextStyle(color: Colors.black, fontSize: 18.0),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: Color(MyColors.primary_color),
              size: 18.0,
            ),
            enabled: true,
            onTap: () {
              onListTileClicked(
                  'firstname', true, false, false, false, "First Name");
            },
          ),
          divider(),
          ListTile(
            title: Text(
              'Last Name',
              style: TextStyle(
                  color: Color(MyColors.primary_color),
                  fontSize: 12.0,
                  fontFamily: "Popins"),
            ),
            subtitle: Text(
              _ln,
              style: TextStyle(color: Colors.black, fontSize: 18.0),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: Color(MyColors.primary_color),
              size: 18.0,
            ),
            enabled: true,
            onTap: () {
              onListTileClicked(
                  'lastname', true, false, false, false, "Last Name");
            },
          ),
          divider(),
          ListTile(
            title: Text(
              'Phone Number',
              style: TextStyle(
                  color: Color(MyColors.primary_color),
                  fontSize: 12.0,
                  fontFamily: "Popins"),
            ),
            subtitle: Text(
              _phone,
              style: TextStyle(color: Colors.black, fontSize: 18.0),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: Color(MyColors.primary_color),
              size: 18.0,
            ),
            enabled: true,
            onTap: () {
              onListTileClicked(
                  'phone', false, true, false, false, "Phone Number");
            },
          ),
          divider(),
          ListTile(
            title: Text(
              'Email Address',
              style: TextStyle(
                  color: Color(MyColors.primary_color),
                  fontSize: 12.0,
                  fontFamily: "Popins"),
            ),
            subtitle: Text(
              _email,
              style: TextStyle(color: Colors.black, fontSize: 18.0),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: Color(MyColors.primary_color),
              size: 18.0,
            ),
            enabled: true,
          ),
          divider(),
          ListTile(
            title: Text(
              'Date of Birth',
              style: TextStyle(
                  color: Color(MyColors.primary_color),
                  fontSize: 12.0,
                  fontFamily: "Popins"),
            ),
            subtitle: Text(
              _dob,
              style: TextStyle(color: Colors.black, fontSize: 18.0),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: Color(MyColors.primary_color),
              size: 18.0,
            ),
            enabled: true,
            onTap: () {
              onListTileClicked(
                  'birthday', false, false, true, false, "Date of Birth");
            },
          ),
          divider(),
          ListTile(
            title: Text(
              'Gender',
              style: TextStyle(
                  color: Color(MyColors.primary_color),
                  fontSize: 12.0,
                  fontFamily: "Popins"),
            ),
            subtitle: Text(
              _gender,
              style: TextStyle(color: Colors.black, fontSize: 18.0),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: Color(MyColors.primary_color),
              size: 18.0,
            ),
            enabled: true,
            onTap: () {
              onListTileClicked('gender', false, false, false, true, "Gender");
            },
          ),
          divider(),
        ],
      ),
    );
  }

  onListTileClicked(String fieldName, bool isText, bool isPhone, bool isDate,
      bool isGender, String title) {
    List<String> genders = ['male', 'female'];
    String selected_gender = 'male';

    Widget what_widget_to_use = null;

    if (isText || isPhone || isDate) {
      what_widget_to_use = Container(
        height: 50.0,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15.0,
                  spreadRadius: 0.0)
            ]),
        child: TextFormField(
            controller: _controller,
            keyboardType: (isText)
                ? TextInputType.text
                : (isPhone) ? TextInputType.phone : TextInputType.datetime,
            decoration: InputDecoration(
                hintText: (isDate) ? "MM/DD/YYYY" : "Enter your $title",
                border: InputBorder.none,
                hintStyle: TextStyle(
                    color: Colors.black54,
                    fontFamily: "Gotik",
                    fontWeight: FontWeight.w400))),
      );
    }

    if (isGender) {
      what_widget_to_use = DropdownButton(
        items: genders.map((m) {
          return DropdownMenuItem<String>(
            value: m,
            child: Text(
              m,
              textAlign: TextAlign.right,
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
        isExpanded: true,
        style: TextStyle(
            letterSpacing: 0.1,
            fontSize: 18.0,
            color: Colors.black,
            fontFamily: ""),
      );
    }

    return showDialog<Null>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text('Update Profile Information'),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                new Text('Please enter your update $title'),
                Container(
                  height: 10.0,
                ),
                what_widget_to_use,
                Container(
                  height: 10.0,
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
            new FlatButton(
              child: new Text(
                'OK',
                style: TextStyle(color: Color(MyColors.primary_color)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                if(isText || isPhone || isDate){
                  if(_controller.text.isEmpty){
                    return;
                  }
                }
                if(isDate) {
                  String val = _controller.text;
                  List<String> vals = _controller.text.split('/');
                  if(!val.contains('/') || vals.length != 3) {
                    new GeneralUtils().neverSatisfied(
                        context, 'Error', 'Date of Birth is in incorrect format.');
                    return;
                  }
                }
                setState(() {
                  _inAsyncCall = true;
                });
                saveUpdatedDataOnline(fieldName, isText, isPhone, isDate, isGender, selected_gender);
              },
            ),
          ],
        );
      },
    );
  }

  saveUpdatedDataOnline(String fieldname, bool isText, bool isPhone, bool isDate,
      bool isGender, String gender_result) {
    Map<String, dynamic> data = new Map();
    if(isText || isPhone || isDate){
      data[fieldname] = _controller.text;
    }
    if(isGender) {
      data[fieldname] = gender_result;
    }
    Firestore.instance.collection('users').document(_email).updateData(data).then((done){
      setState(() {
        if(isPhone) {
          _phone = _controller.text;
        }
        if(isDate) {
          _dob = _controller.text;
        }
        if(isGender) {
          _gender = gender_result;
        }
        if(isText){
          if(fieldname == 'firstname'){
            _fn = _controller.text;
          }else {
            _ln = _controller.text;
          }
        }
      });
      saveDataLocally();
      setState(() {
        _inAsyncCall = false;
        _controller.clear();
      });
      new GeneralUtils().neverSatisfied(
          context, 'Success', 'Saved Successfully.');
    }).catchError((err){
      setState(() {
        _inAsyncCall = false;
      });
      new GeneralUtils().neverSatisfied(
          context, 'Error', 'An error occurred. Please try again');
    });
  }

  saveDataLocally() {
    Map<String, dynamic> userData = new Map();
    userData['email'] = _email;
    userData['fn'] = _fn;
    userData['ln'] = _ln;
    userData['gender'] = _gender;
    userData['dob'] = _dob;
    userData['phone'] = _phone;
    ss.setPrefItem('user', jsonEncode(userData));
  }

  logout() {
    return showDialog<Null>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text('Confirmation'),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                new Text('Are you sure you want to logout?'),
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
            new FlatButton(
              child: new Text(
                'OK',
                style: TextStyle(color: Color(MyColors.primary_color)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _inAsyncCall = true;
                });
                afterLogout();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> afterLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      await FirebaseAuth.instance.signInAnonymously();
      setState(() {
        _inAsyncCall = false;
      });
      String user = ss.getItem('user');
      if (user.isEmpty) {
        ss.clearPref();
        ss.disposePref();
      }
      ss.setPrefItem('loggedin', 'signInAnonymously');
      Navigator.of(context).pushReplacement(PageRouteBuilder(
          pageBuilder: (_, __, ___) =>
          new SplashScreen()));
    }catch (err) {
      setState(() {
        _inAsyncCall = false;
      });
      new GeneralUtils().neverSatisfied(
          context, 'Error',
          'An error occurred. Please try again $err');
    }
  }
}

class setting extends StatelessWidget {
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

  String head, sub1, sub2, sub3;

  setting({this.head, this.sub1, this.sub2, this.sub3});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: Container(
        height: 235.0,
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 15.0, top: 15.0),
                child: Text(
                  head,
                  style: _txtCustomHead,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 20.0),
                child: Divider(
                  color: Colors.black12,
                  height: 0.5,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        sub1,
                        style: _txtCustomSub,
                      ),
                      Icon(
                        Icons.keyboard_arrow_right,
                        color: Colors.black38,
                      )
                    ]),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 20.0),
                child: Divider(
                  color: Colors.black12,
                  height: 0.5,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        sub2,
                        style: _txtCustomSub,
                      ),
                      Icon(
                        Icons.keyboard_arrow_right,
                        color: Colors.black38,
                      )
                    ]),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 20.0),
                child: Divider(
                  color: Colors.black12,
                  height: 0.5,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        sub3,
                        style: _txtCustomSub,
                      ),
                      Icon(
                        Icons.keyboard_arrow_right,
                        color: Colors.black38,
                      )
                    ]),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 20.0),
                child: Divider(
                  color: Colors.black12,
                  height: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
