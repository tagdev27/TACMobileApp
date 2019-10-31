import 'package:flutter/material.dart';

class chat extends StatefulWidget {
 @override
 _chatState createState() => _chatState();
}

class _chatState extends State<chat> {

 @override
 initState() {
    // TODO: implement initState
    super.initState();
    showConvo();
 }

 void showConvo() async {
//  await FlutterFreshchat.init(
//      appID: "b59cf05f-9c18-4176-b41b-4deac7dc35fc", appKey: "d318009f-2023-49c5-a324-3e9c32103144");
//  await FlutterFreshchat.showConversations(tags: const [], title: 'CHAT_SCREEN_TITLE');
 }

 @override
 Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
   appBar: AppBar(
    title: Text(
     "Message",
     style: TextStyle(
         fontWeight: FontWeight.w700,
         fontSize: 22.0,
         letterSpacing: 2.0,
         color: Colors.black54,
         fontFamily: "Berlin"),
    ),
    iconTheme: IconThemeData(
     color: const Color(0xFF6991C7),
    ),
    centerTitle: true,
    elevation: 0.0,
    backgroundColor: Colors.white,
   ),
   body: Container(
    color: Colors.white,
    width: 500.0,
    child: Column(
     crossAxisAlignment: CrossAxisAlignment.center,
     children: <Widget>[
      Padding(padding: EdgeInsets.only(top: 150.0)),
      Image.asset(
       "assets/img/notmessage.png",
       height: 200.0,
      ),
      Padding(padding: EdgeInsets.only(bottom: 20.0)),
      Text(
       "Not Message Yet",
       style: TextStyle(
           fontWeight: FontWeight.w700,
           fontSize: 19.5,
           color: Colors.black54,
           fontFamily: "Gotik"),
      ),
     ],
    ),
   ),
  );
 }
}
