import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_course/widgets/zoom_image.dart';
import 'package:lottie/lottie.dart';

class PopupInfo extends StatefulWidget {

  String title = "";
  String body = "";
  String lottie = "";
  String btn1 = "";

  PopupInfo({required this.title, required this.body, required this.lottie, required this.btn1,});


  @override
  PopupInfoState createState() => PopupInfoState();
}

class PopupInfoState extends State<PopupInfo> {

@override
 Widget build(BuildContext context) => CupertinoAlertDialog(
         title: Text(widget.title, style: TextStyle(fontSize:18)),
         content: Column(
           children: [
             Lottie.asset(
              widget.lottie,
              animate: true,
              height: 70,
             ), 
             Text(widget.body, style: TextStyle(fontSize:16)),
           ],
         ),
         actions: [
           CupertinoDialogAction(
             child: Text(widget.btn1),
             onPressed: () => Navigator.pop(context,true),
           ),
         ],
  );
}