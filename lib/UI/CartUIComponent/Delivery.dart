import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:treva_shop_flutter/UI/BottomNavigationBar.dart';
import 'package:treva_shop_flutter/UI/CartUIComponent/Payment.dart';
import 'package:treva_shop_flutter/Utils/backgroud_utils.dart';
import 'package:treva_shop_flutter/Utils/colors.dart';
import 'package:treva_shop_flutter/Utils/general.dart';
import 'package:treva_shop_flutter/Utils/storage.dart';

class delivery extends StatefulWidget {

  @override
  _deliveryState createState() => _deliveryState();

}

class _deliveryState extends State<delivery> {

  StorageSystem ss = new StorageSystem();
  final formKey = GlobalKey<FormState>();
  String fn, ln, num, email;
  String _fn, _ln, _email, _num;
  String fullname, phone, address, city, state = 'select option', country = 'select option', instructions, card_message;

  List<String> stateList = ["select option", "Lagos"];
  List<String> countryList = ["select option", "Nigeria"];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
  }

  void getUser() {
    if(ss.getItem("user") != ''){
      Map<String, dynamic> user = json.decode(ss.getItem("user"));
      if(!mounted) return;
      setState(() {
        _fn = '${user['fn']}';
        _ln = '${user['ln']}';
        _email = '${user['email']}';
        _num = (user['phone'] != null) ? (user[phone] != "Not available. Update now") ? '${user['phone']}' : '' : '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: InkWell(
            onTap: () {
              Navigator.of(context).pop(false);
            },
            child: Icon(Icons.arrow_back)),
        elevation: 0.0,
        title: Text(
          "Delivery",
          style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18.0,
              color: Colors.black54,
              fontFamily: "Gotik"),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Color(MyColors.primary_color)),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(top: 30.0),
          color: Colors.white,
          child: Form(key: formKey, child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(padding: EdgeInsets.all(20.0), child: Text(
                  "User Details",
                  style: TextStyle(
                      letterSpacing: 0.1,
                      fontSize: 18.0,
                      color: Color(MyColors.primary_color),
                      fontWeight: FontWeight.bold,
                      fontFamily: ""),
                ),),
                Divider(height: 1.0,),
                ListTile(
                  title: Text(
                    "First Name",
                    style: TextStyle(
                        letterSpacing: 0.1,
                        fontSize: 16.0,
                        color: Colors.grey,
                        fontFamily: ""),
                  ),
                  trailing: Container(
                    width: 210.0,
                    child: TextFormField(
                      decoration: InputDecoration(
                          hintText: "First Name",
                          hintStyle: TextStyle(color: Colors.black54),
                      border: InputBorder.none),
                      keyboardType: TextInputType.text,
                      style: TextStyle(
                          letterSpacing: 0.1,
                          fontSize: 18.0,
                          color: Colors.black,
                          fontFamily: ""),
                      autofocus: true,
                      validator: (value) => value.isEmpty ? 'Please enter firstname' : null,
                      onSaved: (value) => fn = value,
                      textAlign: TextAlign.right,
                      initialValue: _fn,
                    ),
                  ),
                ),
                Divider(height: 1.0,),
                ListTile(
                  title: Text(
                    "Last Name",
                    style: TextStyle(
                        letterSpacing: 0.1,
                        fontSize: 16.0,
                        color: Colors.grey,
                        fontFamily: ""),
                  ),
                  trailing: Container(
                    width: 210.0,
                    child: TextFormField(
                      decoration: InputDecoration(
                          hintText: "Last Name",
                          hintStyle: TextStyle(color: Colors.black54),
                          border: InputBorder.none),
                      keyboardType: TextInputType.text,
                      style: TextStyle(
                          letterSpacing: 0.1,
                          fontSize: 18.0,
                          color: Colors.black,
                          fontFamily: ""),
                      autofocus: true,
                      validator: (value) => value.isEmpty ? 'Please enter lastname' : null,
                      onSaved: (value) => ln = value,
                      textAlign: TextAlign.right,
                      initialValue: _ln,
                    ),
                  ),
                ),
                Divider(height: 1.0,),
                ListTile(
                  title: Text(
                    "Phone Number",
                    style: TextStyle(
                        letterSpacing: 0.1,
                        fontSize: 16.0,
                        color: Colors.grey,
                        fontFamily: ""),
                  ),
                  trailing: Container(
                    width: 210.0,
                    child: TextFormField(
                      decoration: InputDecoration(
                          hintText: "Phone Number",
                          hintStyle: TextStyle(color: Colors.black54),
                          border: InputBorder.none),
                      keyboardType: TextInputType.phone,
                      style: TextStyle(
                          letterSpacing: 0.1,
                          fontSize: 18.0,
                          color: Colors.black,
                          fontFamily: ""),
                      autofocus: true,
                      validator: (value) => value.isEmpty ? 'Please enter number' : null,
                      onSaved: (value) => num = value,
                      textAlign: TextAlign.right,
                      initialValue: _num,
                    ),
                  ),
                ),
                Divider(height: 1.0,),
                ListTile(
                  title: Text(
                    "Email Address",
                    style: TextStyle(
                        letterSpacing: 0.1,
                        fontSize: 16.0,
                        color: Colors.grey,
                        fontFamily: ""),
                  ),
                  trailing: Container(
                    width: 210.0,
                    child: TextFormField(
                      decoration: InputDecoration(
                          hintText: "Email Address",
                          hintStyle: TextStyle(color: Colors.black),
                          border: InputBorder.none),
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(
                          letterSpacing: 0.1,
                          fontSize: 18.0,
                          color: Colors.black,
                          fontFamily: ""),
                      autofocus: true,
                      validator: (value) => value.isEmpty ? 'Please enter email' : null,
                      onSaved: (value) => email = value,
                      textAlign: TextAlign.right,
                      initialValue: _email,
                    ),
                  ),
                ),
                Divider(height: 1.0,),
                Padding(padding: EdgeInsets.all(20.0), child: Text(
                  "Recipient Details",
                  style: TextStyle(
                      letterSpacing: 0.1,
                      fontSize: 18.0,
                      color: Color(MyColors.primary_color),
                      fontWeight: FontWeight.bold,
                      fontFamily: ""),
                ),),
                Divider(height: 1.0,),
                ListTile(
                  title: Text(
                    "Full Name",
                    style: TextStyle(
                        letterSpacing: 0.1,
                        fontSize: 16.0,
                        color: Colors.grey,
                        fontFamily: ""),
                  ),
                  trailing: Container(
                    width: 210.0,
                    child: TextFormField(
                      decoration: InputDecoration(
                          hintText: "Full name",
                          hintStyle: TextStyle(color: Colors.black),
                          border: InputBorder.none),
                      keyboardType: TextInputType.text,
                      style: TextStyle(
                          letterSpacing: 0.1,
                          fontSize: 18.0,
                          color: Colors.black,
                          fontFamily: ""),
                      autofocus: true,
                      validator: (value) => value.isEmpty ? 'Please enter full name' : null,
                      onSaved: (value) => fullname = value,
                      textAlign: TextAlign.right,
                      initialValue: '',
                    ),
                  ),
                ),
                Divider(height: 1.0,),
                ListTile(
                  title: Text(
                    "Phone Number",
                    style: TextStyle(
                        letterSpacing: 0.1,
                        fontSize: 16.0,
                        color: Colors.grey,
                        fontFamily: ""),
                  ),
                  trailing: Container(
                    width: 210.0,
                    child: TextFormField(
                      decoration: InputDecoration(
                          hintText: "Phone Number",
                          hintStyle: TextStyle(color: Colors.black),
                          border: InputBorder.none),
                      keyboardType: TextInputType.phone,
                      style: TextStyle(
                          letterSpacing: 0.1,
                          fontSize: 18.0,
                          color: Colors.black,
                          fontFamily: ""),
                      autofocus: true,
                      validator: (value) => value.isEmpty ? 'Please enter phone number' : null,
                      onSaved: (value) => phone = value,
                      textAlign: TextAlign.right,
                      initialValue: '',
                    ),
                  ),
                ),
                Divider(height: 1.0,),
                ListTile(
                  title: Text(
                    "Home Address",
                    style: TextStyle(
                        letterSpacing: 0.1,
                        fontSize: 16.0,
                        color: Colors.grey,
                        fontFamily: ""),
                  ),
                  trailing: Container(
                    width: 210.0,
                    child: TextFormField(
                      decoration: InputDecoration(
                          hintText: "Home Address",
                          hintStyle: TextStyle(color: Colors.black),
                          border: InputBorder.none),
                      keyboardType: TextInputType.text,
                      style: TextStyle(
                          letterSpacing: 0.1,
                          fontSize: 18.0,
                          color: Colors.black,
                          fontFamily: ""),
                      autofocus: true,
                      validator: (value) => value.isEmpty ? 'Please enter address' : null,
                      onSaved: (value) => address = value,
                      textAlign: TextAlign.right,
                      initialValue: '',
                    ),
                  ),
                ),
                Divider(height: 1.0,),
                ListTile(
                  title: Text(
                    "City/Town",
                    style: TextStyle(
                        letterSpacing: 0.1,
                        fontSize: 16.0,
                        color: Colors.grey,
                        fontFamily: ""),
                  ),
                  trailing: Container(
                    width: 210.0,
                    child: TextFormField(
                      decoration: InputDecoration(
                          hintText: "City/Town",
                          hintStyle: TextStyle(color: Colors.black),
                          border: InputBorder.none),
                      keyboardType: TextInputType.text,
                      style: TextStyle(
                          letterSpacing: 0.1,
                          fontSize: 18.0,
                          color: Colors.black,
                          fontFamily: ""),
                      autofocus: true,
                      validator: (value) => value.isEmpty ? 'Please enter city' : null,
                      onSaved: (value) => city = value,
                      textAlign: TextAlign.right,
                      initialValue: '',
                    ),
                  ),
                ),
                Divider(height: 1.0,),
                ListTile(
                  title: Text(
                    "State",
                    style: TextStyle(
                        letterSpacing: 0.1,
                        fontSize: 16.0,
                        color: Colors.grey,
                        fontFamily: ""),
                  ),
                  trailing: Container(
                    width: 150.0,
                    child: DropdownButton(items: stateList.map((m) {
                      return DropdownMenuItem<String>(
                        value: m,
                        child: Text(m, textAlign: TextAlign.right,),
                      );
                    }).toList(),
                        onChanged: (String item){
                      setState(() {
                        state = item;
                      });
                    },
                    value: state,
                      hint: Text('select option', textAlign: TextAlign.right,),
                      underline: Divider(height: 0.0,color: Colors.white,),
                      isExpanded: true,
                      style: TextStyle(
                          letterSpacing: 0.1,
                          fontSize: 18.0,
                          color: Colors.black,
                          fontFamily: ""),
                    ),
                  ),
                ),
                Divider(height: 1.0,),
                ListTile(
                  title: Text(
                    "Country",
                    style: TextStyle(
                        letterSpacing: 0.1,
                        fontSize: 16.0,
                        color: Colors.grey,
                        fontFamily: ""),
                  ),
                  trailing: Container(
                    width: 150.0,
                    child: DropdownButton(items: countryList.map((m) {
                      return DropdownMenuItem<String>(
                        value: m,
                        child: Text(m, textAlign: TextAlign.right,),
                      );
                    }).toList(),
                      onChanged: (String item){
                        setState(() {
                          country = item;
                        });
                      },
                      value: country,
                      hint: Text('select option', textAlign: TextAlign.right,),
                      underline: Divider(height: 0.0,color: Colors.white,),
                      isExpanded: true,
                      style: TextStyle(
                          letterSpacing: 0.1,
                          fontSize: 18.0,
                          color: Colors.black,
                          fontFamily: ""),
                    ),
                  ),
                ),
                Divider(height: 1.0,),
                Padding(padding: EdgeInsets.all(20.0), child: Text(
                  "Extra Details",
                  style: TextStyle(
                      letterSpacing: 0.1,
                      fontSize: 18.0,
                      color: Color(MyColors.primary_color),
                      fontWeight: FontWeight.bold,
                      fontFamily: ""),
                ),),
                Divider(height: 1.0,),
                ListTile(
                  title: Text(
                    "Instructions",
                    style: TextStyle(
                        letterSpacing: 0.1,
                        fontSize: 16.0,
                        color: Colors.grey,
                        fontFamily: ""),
                  ),
                  trailing: Container(
                    width: 210.0,
                    child: TextFormField(
                      decoration: InputDecoration(
                          hintText: "Special Instructions",
                          hintStyle: TextStyle(color: Colors.black),
                          border: InputBorder.none),
                      keyboardType: TextInputType.text,
                      style: TextStyle(
                          letterSpacing: 0.1,
                          fontSize: 18.0,
                          color: Colors.black,
                          fontFamily: ""),
                      autofocus: true,
                      onSaved: (value) => instructions = value,
                      textAlign: TextAlign.right,
                      initialValue: '',
                    ),
                  ),
                ),
                Divider(height: 1.0,),
//                ListTile(
//                  title: Text(
//                    "Gift Card Message",
//                    style: TextStyle(
//                        letterSpacing: 0.1,
//                        fontSize: 16.0,
//                        color: Colors.grey,
//                        fontFamily: ""),
//                  ),
//                  trailing: Container(
//                    width: 210.0,
//                    child: TextFormField(
//                      decoration: InputDecoration(
//                          hintText: "Gift Card Message",
//                          hintStyle: TextStyle(color: Colors.black),
//                          border: InputBorder.none),
//                      keyboardType: TextInputType.text,
//                      style: TextStyle(
//                          letterSpacing: 0.1,
//                          fontSize: 18.0,
//                          color: Colors.black,
//                          fontFamily: ""),
//                      autofocus: true,
//                      onSaved: (value) => card_message = value,
//                      textAlign: TextAlign.right,
//                      initialValue: '',
//                    ),
//                  ),
//                ),
//                Divider(height: 1.0,),
                InkWell(
                  onTap: () {
                    gotoPayment();
                  },
                  child: Container(
                    height: 55.0,
                    width: 300.0,
                    margin: EdgeInsets.only(left: 20.0, right: 20.0, top: 40.0),
                    decoration: BoxDecoration(
                        color: Color(MyColors.primary_color),
                        borderRadius: BorderRadius.all(Radius.circular(40.0))),
                    child: Center(
                      child: Text(
                        "Go to payment",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16.5,
                            letterSpacing: 1.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.0,)
              ],
            )
            ),
          ),
        ),
    );
  }

  void gotoPayment() {
    if(validateForm()){
      if(state == 'select option' || country == 'select option'){
        GeneralUtils().neverSatisfied(context, 'Error', 'Please select all dropdown items');
        return;
      }
      Map<String, dynamic> details = Map();
      details['address'] = address;
      details['card_message'] = "";//card_message;
      details['country'] = country;
      details['email'] = email;
      details['firstname'] = fn;
      details['fullname'] = fullname;
      details['lastname'] = ln;
      details['phone'] = num;
      details['recipientphone'] = phone;
      details['specialinstructions'] = instructions;
      details['state'] = state;
      details['town'] = city;

      Navigator.of(context).pushReplacement(PageRouteBuilder(
          pageBuilder: (_, __, ___) => payment(details)));
    }
  }

  bool validateForm() {
    final form = formKey.currentState;
    form.save();
    return form.validate();
  }
}
