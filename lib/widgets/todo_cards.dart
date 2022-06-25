import 'dart:developer';
import 'dart:typed_data';

import 'package:blurhash/blurhash.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_course/info_page.dart';
import 'package:flutter_course/main.dart';
import 'package:flutter_course/models/config.dart';
import 'package:flutter_course/widgets/shimmer_widget.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart' as blurhash;

class  ToDoCard extends StatelessWidget {

  final String title;
  final String body;
  final Timestamp date;
  final String img1;
  final String img2;
  final String img3;
  final String pdf;
  final String id;
  final String map;
  final bool isAdmin;
  Function myFunc;

  String popupTitle = "";
  String popupDesc = "";

  ToDoCard({required this.title, required this.body, required this.date, required this.img1, required this.img2, required this.img3, required this.pdf, required this.id, required this.map, required this.isAdmin, required this.myFunc,});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async{

        log("click :" + title);

        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => InfoPage(title: title, body: body, date: date, img1: img1, img2: img2, img3: img3, pdf: pdf, id: id, map: map, myFunc: myFunc)
          )
        );
          
      },
      child: FractionallySizedBox(
        widthFactor: 1,
        child: Card(
          margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
          child: Container(   
            decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromRGBO(255, 255, 255, 1),
                      Color.fromRGBO(245,245, 245, 1),
                    ],
                  ),
                  boxShadow:const  [
                    //background color of box
                    BoxShadow(
                      color: Color.fromRGBO(0, 50, 70, 1),
                      blurRadius: 15.0, // soften the shadow
                      spreadRadius: 2.0, //extend the shadow
                      offset: Offset(
                        5.0, // Move to right 10  horizontally
                        5.0, // Move to bottom 10 Vertically
                      ),
                    )
                  ],
                ),
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
            child : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[  
                  Container(
                    margin: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [ 
                       isAdmin ? IconButton(
                          padding: const EdgeInsets.fromLTRB(0, 0, 30, 0),
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.delete),
                          iconSize: 22,
                          onPressed: () async {

                            var connectivityResult = await (Connectivity().checkConnectivity());
                            if (connectivityResult != ConnectivityResult.none) {

                              final isYes = await showCupertinoDialog(
                                context: context, 
                                builder: createDialog
                              );

                              if(isYes == true){

                                log("delete " + title + "uuid: " + id);
                                _deleteDocument(img1, img2, img3, pdf);
                                myFunc(id); // updateList
                              }
                            }
                            else{
                              popupDesc = "Vous n'etes pas connecté à internet.";
                              popupTitle = "Erreur";
                              
                              await showCupertinoDialog(
                                        context: context, 
                                        builder: createMessage
                              );
                            }

                          },
                        ) : Container(),
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                   margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                   child: Text(
                      body,
                      maxLines: 5,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),

              

                  if(img1.isNotEmpty)
                  Container(
                   margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                   decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(0),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF000A0C),
                          Color(0xFF000A0C),
                        ],
                      ),
                   ),
                   constraints: BoxConstraints(
                     maxHeight: MediaQuery.of(context).size.height / 1.5,
                   ),
                   child: !Config.isLoading ? ClipRRect(      ///
                    borderRadius: BorderRadius.circular(0),
                    child: Image.network(
                        img1,
                        width: double.infinity,
                        errorBuilder:
                        (BuildContext context, Object exception, StackTrace? stackTrace) {
                              return Container(height: 0,);
                        },
                    ),
                  ) : buildListShimmer(context),
                  ),
                  
                  if(img1.isEmpty)
                  Container(),

                  Container(
                   padding: const EdgeInsets.fromLTRB(0, 7, 0, 0),
                   margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                   child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                       Text(
                        DateFormat('d/M/y').format(date.toDate()),
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
                  //Icon(
                    //completed ? Icons.check : Icons.close,
                    //color: completed ? Colors.green : Colors.red,
                  //),
                ],
              )
            ),
          )
        )
      )
    );
  }

  void _deleteDocument(String img1, String img2, String img3, String pdf) async {

        try{

        FirebaseFirestore.instance
        .collection("news")
        .where("date", isEqualTo : date)
        .get().then((value){
          value.docs.forEach((element) {
           FirebaseFirestore.instance.collection("news").doc(element.id).delete().then((value){
             print("Success deleting!");
           });
          });
        });
      }
      catch(e){print("Error deleting");}

      try{

        if(img1.isNotEmpty){

          FirebaseStorage.instance.refFromURL(img1).delete();
      }
        if(img2.isNotEmpty){

          FirebaseStorage.instance.refFromURL(img2).delete();
      }
        if(img3.isNotEmpty){

          FirebaseStorage.instance.refFromURL(img3).delete();
      }
        if(pdf.isNotEmpty){

          //final refPDF = FirebaseStorage.instance.ref().child("pdf/"+"${pdf}.pdf");
          FirebaseStorage.instance.ref("pdf/"+"${pdf}.pdf").delete();
      }

    }
    catch(e){print("Error deleting files.");}
  }

  Widget buildListShimmer(BuildContext context) => ListTile(
     /* leading: ShimmerWidget.circular(
        width: 64, 
        height: 64, 
        shapeBorder: RoundedRectangleBorder(
           borderRadius: BorderRadius.circular(5),
        ),
      ), 
      title: const ShimmerWidget.rectangular(height: 16),
      subtitle: const ShimmerWidget.rectangular(height: 14), */
      contentPadding: const EdgeInsets.all(0),
      title: ShimmerWidget.circular(
        width: double.infinity, 
        height: MediaQuery.of(context).size.width / 1.1, 
        shapeBorder: RoundedRectangleBorder(
           borderRadius: BorderRadius.circular(0),
        ),
      ), 
  );

    Widget buildBlurHash(BuildContext context) => 
                     const SizedBox.expand(
                          child: Center(
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: blurhash.BlurHash(hash: "assets/test.jpg"),
                            ),
                          ),

    );
  

  Widget createDialog(BuildContext context) => CupertinoAlertDialog(
         title: const Text("Confirmation", style: TextStyle(fontSize:18)),
         content: Column(
           children: [
             Lottie.asset(
              "assets/bin.json",
              animate: true,
              height: 70,
             ), 
             const Text("Etes-vous sure de vouloir supprimer cette annonce ?", style: TextStyle(fontSize:16)),
           ],
         ),
         actions: [
           CupertinoDialogAction(
             child: const Text("Non"),
             onPressed: () => Navigator.pop(context,false),
           ),
           CupertinoDialogAction(
             child: const Text("Oui"),
             onPressed: () => Navigator.pop(context,true),
           ),
         ],
  );
  Widget createMessage(BuildContext context) => CupertinoAlertDialog(
         title: Text(popupTitle, style: TextStyle(fontSize:18)),
         content: Column(
           children: [
             Lottie.asset(
              "assets/wifi.json",
              animate: true,
              height: 60,
             ), 
             Text(popupDesc, style: TextStyle(fontSize:16)),
           ],
         ),
         actions: [
           CupertinoDialogAction(
             child: const Text("Ok"),
             onPressed: () => Navigator.pop(context,false),
           ),
         ],
  );


  Future<String> blurHashEncode(String? path) async {

    ByteData bytes = await rootBundle.load(path!);
    Uint8List pixels = bytes.buffer.asUint8List();
    var blurHash = await BlurHash.encode(pixels, 4, 3);
    return blurHash;
  }

  void blurHashDecode(blurhash) async {

    Uint8List imageDataBytes;
    try {
      imageDataBytes = await BlurHash.decode(blurhash, 20, 12);
    } on PlatformException catch (e) {
      print(e.message);
    }
  }
  
}