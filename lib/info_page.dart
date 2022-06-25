import 'dart:developer';
import 'dart:io';
//import 'dart:js' as js;
//import 'dart:html' as html;
import 'package:firebase_storage/firebase_storage.dart' as storage;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_course/api/pdf_api.dart';
import 'package:flutter_course/map_page.dart';
import 'package:flutter_course/models/todo.dart';
import 'package:flutter_course/pdf_viewer_page.dart';
import 'package:flutter_course/widgets/gallery_widget.dart';
import 'package:flutter_course/widgets/rounded_button_widget.dart';
import 'package:flutter_course/widgets/webview_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:uuid/uuid.dart';

class InfoPage extends StatefulWidget {

  final String title;
  final String body;
  final Timestamp date;
  final String img1;
  final String img2;
  final String img3;
  final String pdf;
  final String id;
  final String map;
  Function myFunc;

  InfoPage({required this.title, required this.body, required this.date, required this.img1, required this.img2, required this.img3, required this.pdf, required this.id, required this.map, required this.myFunc});

  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {

  int imgCounter = 0;

  final List<String> urlImages = [];

  @override
  void initState(){

    if(widget.img1.isNotEmpty){imgCounter++; setState(() => urlImages.add(widget.img1));}
    if(widget.img2.isNotEmpty){imgCounter++; setState(() => urlImages.add(widget.img2));}
    if(widget.img3.isNotEmpty){imgCounter++; setState(() => urlImages.add(widget.img3));}

    super.initState();
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if(widget.img1.isNotEmpty)
    precacheImage(NetworkImage(widget.img1), context);
    if(widget.img2.isNotEmpty)
    precacheImage(NetworkImage(widget.img2), context);
    if(widget.img3.isNotEmpty)
    precacheImage(NetworkImage(widget.img3), context);
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromRGBO(100, 198, 214, 1),
                      Color.fromRGBO(0,152, 242, 1),
                    ],
                  ),
                  boxShadow: [
                    //background color of box
                    BoxShadow(
                      color: Color.fromRGBO(0, 50, 70, 1),
                      blurRadius: 5.0, // soften the shadow
                      spreadRadius: 1.0, //extend the shadow
                      offset: Offset(
                        0, // Move to right 10  horizontally
                        0, // Move to bottom 10 Vertically
                      ),
                    )
                  ],
                ),
            ),
        centerTitle: false,
        title: Text(widget.title),
        actions: [

        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromRGBO(255, 255, 255, 1),
                      Color.fromRGBO(245,245, 245, 1),
                    ],
                  ),
                ),
        child: ListView(
          children: [  

            if(imgCounter != 0)      
            Center(
              child: GestureDetector(child: ClipRRect(
                      borderRadius: BorderRadius.circular(0),
                      child: Image.network(
                          widget.img1,
                          width: MediaQuery.of(context).size.width / 1,
                          errorBuilder:
                          (BuildContext context, Object exception, StackTrace? stackTrace) {
                                return Container(height: 0,);
                          },
                      ),
                ),
                onTap: openGallery,
              ),
            ),
            if(imgCounter>1)
            Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(5),
              child: Text(
                'Image 1/${urlImages.length}',
                style: TextStyle(color: Colors.black.withOpacity(0.5), fontSize: 12, fontStyle: FontStyle.italic),
              )
            ),
            
            if(imgCounter == 0)   
            Container(),

            Container (
              margin: const EdgeInsets.fromLTRB(10, 15, 10, 10),
              child:Text(
                      widget.body,
                      //maxLines: 5,
                      //softWrap: true,
                      //overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
              ),
            ),

            Container (
              margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                      DateFormat('d/M/y').format(widget.date.toDate()),
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          fontStyle: FontStyle.italic,
                          color: Color.fromRGBO(10, 10, 10, 1),
                        ),
                      ),
                    ],
              ),
            ),

            Container(
              margin: const EdgeInsets.fromLTRB(20, 5, 20, 10),
              alignment: Alignment.center,
              child:Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if(widget.pdf.isNotEmpty)
                    RoundedButtonWidget(buttonText: "Voir PDF", width: 60, onpressed: () async {  
                      var connectivityResult = await (Connectivity().checkConnectivity());
                      if (connectivityResult != ConnectivityResult.none) {
                        if(!kIsWeb){
                           loadPDF(widget.pdf); 
                        }
                        else{

                          String ref = await storage.FirebaseStorage.instance.refFromURL("gs://onlyfeet-7d2da.appspot.com")
                                             .child('pdf')
                                             .child('${widget.pdf}.pdf')
                                             .getDownloadURL();
                                        

                          //js.context.callMethod('open', [ref]);
                          //html.window.open('https://stackoverflow.com/questions/ask', 'new tab');

                        }
                      }
                      else{

                        await showCupertinoDialog(
                         context: context, 
                         builder: createMessage
                        );
                      }
                    }
                  ),

                  if(widget.map.isNotEmpty)
                  RoundedButtonWidget(buttonText: "Voir Localisation", width: 80, onpressed: () async { 
                    var connectivityResult = await (Connectivity().checkConnectivity());
                    if (connectivityResult != ConnectivityResult.none) {

                      if(!kIsWeb){
                        await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => MapScreen(map: widget.map.split(','))),
                        );
                      }
                      else{
 
                         List<String> co = widget.map.split(',');

                         //js.context.callMethod('open', ["https://www.google.com/maps/search/?api=1&query=${co[0]},${co[1]}"]);
                         Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  WebViewPage(url: "https://www.google.com/maps/search/?api=1&query=${co[0]},${co[1]}"),
                            ),
                          );
                      }
                    }
                    else{

                        await showCupertinoDialog(
                         context: context, 
                         builder: createMessage
                        );
                    }
                  }
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void loadPDF(String url) async {

        File? file = await PDFApi.loadFirebase(url);
        openPDF(context, file!);
    }

  void openPDF(BuildContext context, File file) => Navigator.of(context).push(
    MaterialPageRoute(builder: (context) => PDFViewerPage(file: file)),
  );

  Widget createMessage(BuildContext context) => CupertinoAlertDialog(
         title: Text("Erreur", style: TextStyle(fontSize:18)),
         content: Column(
           children: [
             Lottie.asset(
              "assets/wifi.json",
              animate: true,
              height: 60,
             ), 
             const Text("Vous n'etes pas connecté à internet.", style: TextStyle(fontSize:16)),
           ],
         ),
         actions: [
           CupertinoDialogAction(
             child: const Text("Ok"),
             onPressed: () => Navigator.pop(context,false),
           ),
         ],
  );


  void openGallery() => Navigator.of(context).push(MaterialPageRoute(

        builder: (_) => GalleryWidget(urlImages: urlImages),
      ),
    );
}