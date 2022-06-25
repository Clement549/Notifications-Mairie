import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
//import 'dart:js' as js;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_course/api/pdf_api.dart';
import 'package:flutter_course/image_selection/user_image.dart';
import 'package:flutter_course/map_page.dart';
import 'package:flutter_course/map_page_picker.dart';
import 'package:flutter_course/models/utils.dart';
import 'package:flutter_course/pdf_viewer_page.dart';
import 'package:flutter_course/widgets/rounded_button_widget.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart' show kIsWeb; // flutter run -d chrome --web-renderer html  // flutter build web --web-renderer html --release


class NewTodo extends StatefulWidget {

  String? topic = "none";
  final Function(String title, String body, Timestamp date, String img1, String img2, String img3, String pdf, String map, String topic, String id) addTodo;

  NewTodo({required this.addTodo, required this.topic});

  @override
  State<StatefulWidget> createState() => _NewTodoState();
}

class _NewTodoState extends State<NewTodo> {

  final formKey = GlobalKey<FormState>();

  TextEditingController _titleController = TextEditingController();
  TextEditingController _bodyController = TextEditingController();

  String imageUrl1 = '';
  String imageUrl2 = '';
  String imageUrl3 = '';

  String PDFPath = '';
  Uint8List PDFBytes = Uint8List.fromList('xxx'.codeUnits); // initialize null;
  String PDFUrl = '';

  String map = '';

  String popupTitle = "";
  String popupDesc = "";
  String popupLottie = "";
  double? popupHeight = 0;

  bool isUploading = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _willPop(context),
        child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          height: MediaQuery.of(context).size.height / 1.13,//double.infinity,
          margin: const EdgeInsets.fromLTRB(20,0,20,0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(   
                      child:Center(
                        child: IconButton(
                            icon: const Icon(Icons.arrow_drop_down),
                            iconSize: 40,
                            color: const Color.fromRGBO(80, 80, 80, 1),
                            //tooltip: 'Increase volume by 10',
                            onPressed: () {
                              if(isUploading == false)
                              Navigator.of(context).pop();
                            },
                        ),
                      ),
                ),

                Form(
                  key: formKey,
                  child: Column(
                    children:[
                      Container(
                        child: TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: "Titre",
                            //border: OutlineInputBorder(),
                            /*focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blueAccent, width: 1.5),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black54, width: 1.0),
                            ),
                            errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.redAccent, width: 1.0),
                            ),
                            hintStyle: TextStyle(
                                color: Colors.blueAccent,
                            ),*/
                          ),
                          validator: (value){
                            if(value!.length < 5){
                              return 'Entrez au moins 5 caractères.';
                            }
                            else{
                              return null;
                            }
                          },
                          maxLength: 30,
                        ),
                      ),

                        Container(
                          child: TextFormField(
                            controller: _bodyController,
                            decoration: const InputDecoration(
                              labelText: "Description",
                              //border: OutlineInputBorder(),
                              /*focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blueAccent, width: 1.5),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black54, width: 1.0),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.redAccent, width: 1.0),
                              ),
                              hintStyle: TextStyle(
                                color: Colors.blueAccent,
                              ),*/
                            ),
                            maxLength: 500,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            validator: (value){
                            if(value!.length < 20){
                              return 'Entrez au moins 20 caractères.';
                            }
                            else{
                              return null;
                            }
                          },
                          ),
                      ),
                    ],
                  ),
                ),

                Container(
                  margin: const EdgeInsets.fromLTRB(0, 5, 0, 10),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: <Widget>[ 
                          Container(
                            margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                            child: UserImage(
                              
                              onFileChanged: (imageUrl) {
                                setState(() {
                                  this.imageUrl1 = imageUrl;
                                });
                              }
                            ),
                          ),
                          if(imageUrl1.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            child: UserImage(
                              onFileChanged: (imageUrl) {
                                setState(() {
                                  this.imageUrl2 = imageUrl;
                                });
                              }
                            ),
                          ),
                          if(imageUrl2.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                            child: UserImage(
                              onFileChanged: (imageUrl) {
                                setState(() {
                                  this.imageUrl3 = imageUrl;
                                });
                              }
                            ),
                          ),
                        ],
                      ), 
                  ),
                ),

                Container(
                  margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  alignment: Alignment.center,
                  child:Column(
                    children: [
                    Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [ 
                      Container(
                            margin: const EdgeInsets.fromLTRB(0, 0, 5, 5),
                            alignment: Alignment.center,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                              primary: Colors.blueAccent,
                              ),
                              child: const Text(
                                "Ajouter PDF",
                                style: TextStyle(color: Colors.white),
                                ),
                              onPressed: ()async{

                                if(!kIsWeb){

                                  File? file = await PDFApi.pickFile();

                                  if (file == null) return;
                                  setState(() {
                                    PDFPath = file.path;
                                  });
                                  
                                  openPDF(context,file);

                                  FocusScope.of(context).unfocus(); // close keyboard
                                }
                                else{

                                  Uint8List? uint8List = await PDFApi.pickFileWeb();

                                  if (uint8List == null) return;
                                  setState(() {
                                    PDFBytes = uint8List;
                                  });
                                }

                              },
                          ),
                        ),

                          Container(
                            
                            margin: const EdgeInsets.fromLTRB(5, 0, 0, 5),
                            alignment: Alignment.center,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.blueAccent,
                              ),
                              
                              child: const Text(
                                  "Ajouter localisation",
                                    style: TextStyle(color: Colors.white),
                                    ),
                              onPressed: ()async{

                                if(!kIsWeb){
                                        
                                  var pos = await Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => MapScreenPicker()
                                        ),
                                      );

                                  if(pos != null){
                                    
                                    setState(() {
                                      map=pos;
                                    });
                                  }

                                  FocusScope.of(context).unfocus(); // close keyboard

                                }
                                else{

                                  //js.context.callMethod('open', ["https://www.google.com/maps/search/?api=1&query=${45.toString()},${2.toString()}"]);
                                }
                              },
                            ),
                          ),     
                        ],
                      ),
                      
                          Container(
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [ 

                                Container(height: 5,),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                  if(PDFPath.isNotEmpty || PDFBytes == Uint8List.fromList('xxx'.codeUnits))
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints(),
                                    icon: const Icon(Icons.close),
                                    iconSize: 16,
                                    color: const Color.fromRGBO(80, 80, 80, 1),
                                    onPressed: () {
                                      if(isUploading == false){
                                        setState(() {
                                          PDFPath="";
                                        });
                                      }
                                    },
                                  ),
                                  if(PDFPath.isNotEmpty || PDFBytes == Uint8List.fromList('xxx'.codeUnits))
                                  Text(
                                  "   PDF ajouté: " + path.basename(PDFPath),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.green,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  ), 
                                  if(PDFPath.isNotEmpty || PDFBytes == Uint8List.fromList('xxx'.codeUnits))
                                  const Icon(Icons.check, color: Colors.green, size: 12,),       

                                  ],
                                ),

                                Container(height: 10,),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center, 
                                  children: [
                                  if(map.isNotEmpty)
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints(),
                                    icon: const Icon(Icons.close),
                                    iconSize: 16,
                                    color: const Color.fromRGBO(80, 80, 80, 1),
                                    onPressed: () {
                                      if(isUploading == false){
                                        setState(() {
                                          map="";
                                        });
                                      }
                                    },
                                  ),
                                  if(map.isNotEmpty)
                                  const Text(
                                  "   Localisation ajoutée",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.green,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  ), 
                                  if(map.isNotEmpty)
                                  const Icon(Icons.check, color: Colors.green, size: 12,),
                                  
                                  ],
                                ),
                              ],
                            ),
                          ),
                    ],
                  ),    
                ),

                Container(
                  margin: const EdgeInsets.fromLTRB(30, 0, 30, 10),
                  alignment: Alignment.center,
                  child: RoundedButtonWidget(buttonText: "ENVOYER NOTIFICATION", width: 60, onpressed: () =>  sendNotif()),
                ),
                  
              ],
            ),
            
          ),
        ),
      ),
    );
  }


  void sendNotif() async {

    FocusScope.of(context).unfocus(); // close keyboard
    final isValid = formKey.currentState!.validate();

    if(_bodyController.text.length >=20 && _titleController.text.length >= 5){

      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult != ConnectivityResult.none) {

        final isYes = await showCupertinoDialog(
                context: context, 
                builder: createDialog
              );

              if(isYes == true){

                    isUploading = true;

                    EasyLoading.show(
                        status: 'Patientez svp...',
                    );
               
                    String url1 = "";
                    String url2 = "";
                    String url3 = "";

                    if(imageUrl1.isNotEmpty){
                      url1 = await UserImageState.uploadFile(imageUrl1);
                    }
                    if(imageUrl2.isNotEmpty){
                      url2 = await UserImageState.uploadFile(imageUrl2);
                    }
                    if(imageUrl3.isNotEmpty){
                      url3 = await UserImageState.uploadFile(imageUrl3);
                    }
                    if(PDFPath.isNotEmpty){

                      PDFUrl = await PDFApi.uploadFirebase(PDFPath, PDFBytes);
                    }

                    DateTime date = DateTime.now();
                    Timestamp dateNow = Timestamp.fromDate(date);
                    //String date = DateFormat('d/M/y').format(dateNow);

                    String id = Uuid().v4().toString();

                    CollectionReference news = FirebaseFirestore.instance.collection("news");
                    await news.add({"title": _titleController.text, "body": _bodyController.text, "img1": url1, "img2": url2, "img3": url3,"pdf": PDFUrl, "date": dateNow, "map": map, "topic": widget.topic, "id": id,})
                        .then((value) => (){})
                        .catchError((error) => print(error)); 

                    widget.addTodo(_titleController.text, _bodyController.text, dateNow, url1, url2, url3, PDFUrl, map, widget.topic!, id);
                    
                    if(url1.isNotEmpty){
                       await Future.delayed(const Duration(milliseconds: 2000),(){});
                    }

                    EasyLoading.dismiss();
                    isUploading = false;

                    Utils.showTopSnackBar(context,"Notification envoyée !", "Votre annonce a bien été publiée.", Colors.green);

                    Navigator.of(context).pop();
              }
      }
      else{

            popupDesc = "Vous n'etes pas connecté à internet.";
            popupTitle = "Erreur";
            popupLottie = "wifi.json";
            popupHeight = 60;
            
            await showCupertinoDialog(
                      context: context, 
                      builder: createMessage
            );
      }
    }
    else{

      popupDesc = "Le titre et la description sont des champs obligatoires.";
      popupTitle = "Erreur";
      popupLottie = "error.json";
      popupHeight = 90;
      
      await showCupertinoDialog(
                context: context, 
                builder: createMessage
              );
    }
  }

  void openPDF(BuildContext context, File file) => Navigator.of(context).push(
    MaterialPageRoute(builder: (context) => PDFViewerPage(file: file)),
  );
  
  Widget createDialog(BuildContext context) => CupertinoAlertDialog(
         title: const Text("Confirmation", style: TextStyle(fontSize:18)),
         content: Column(
           children: [
             Lottie.asset(
              "assets/plane.json",
              animate: true,
              height: 80,
             ), 
             const Text("Etes-vous sûre de vouloir publier cette annonce ?", style: TextStyle(fontSize:16)),
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
              "assets/" + popupLottie,
              animate: true,
              height: popupHeight,
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


  Future<bool> _willPop(BuildContext context) {
    
    final completer = Completer<bool>();

    if(isUploading == false){
      completer.complete(true);
      Navigator.pop(context);
    }
    else{
      completer.complete(false);
    }

    return completer.future;
  }
}