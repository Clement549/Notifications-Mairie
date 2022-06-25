//flutter build appbundle --release --target-platform=android-arm64   // android
//flutter build ipa   // ios

//firebase use <project_name>

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_course/api/purchase_api.dart';
import 'package:flutter_course/main.dart';
import 'package:flutter_course/widgets/rounded_button_widget.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lottie/lottie.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_button/sign_button.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:twitter_login/entity/auth_result.dart';
import 'package:twitter_login/twitter_login.dart';
import 'package:video_player/video_player.dart';


class ConnexionPage extends StatefulWidget {

  bool hasInternet;
  ConnexionPage({required this.hasInternet});

  @override
  _ConnexionPageState createState() => _ConnexionPageState();
}

class _ConnexionPageState extends State<ConnexionPage> with WidgetsBindingObserver {

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  String popupTitle = "";
  String popupBody = "";
  String popupBtn = "";
  String popupLottie = "";
  double? popupHeight = 70;

  final formKey = GlobalKey<FormState>();

  String selectedCommune = "";

  TextEditingController _emailController = TextEditingController();
  //TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  TextEditingController _emailControllerREGISTER = TextEditingController();
  TextEditingController _usernameControllerREGISTER = TextEditingController();
  TextEditingController _passwordControllerREGISTER = TextEditingController();

  VideoPlayerController? _videoController;
  final player = AudioPlayer();

  bool signup = false;

  @override
  void initState() {

    WidgetsBinding.instance!.addObserver(this); // detect app go background / close
    super.initState();

    loadCommunes();

    _videoController = VideoPlayerController.asset(
        'assets/menu.mp4')
        ..initialize().then((_) {
          _videoController!.setLooping(true);
          _videoController!.setVolume(0.0);
          Timer(const Duration(milliseconds: 100), () {
            setState(() {
              _videoController!.play();
        });
      });
    });

    //player.setFilePath("assets/two_feet.mp3");
    //player.play();
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state){ // check app go background / resume
    super.didChangeAppLifecycleState(state);

    if(state == AppLifecycleState.inactive || state == AppLifecycleState.detached) return;

    final isBackground = state == AppLifecycleState.paused;

    if(isBackground){
      log("app in background");
    }
    else{
      log("app in foreground");
    }
  }
  @override
  void dispose() {

    super.dispose();
    if (_videoController != null) {
      _videoController!.dispose();
      _videoController = null;
    }
    
    player.dispose();
  }

List<String> communes = [];
List<String> passwords = [];

Future loadCommunes() async {

  await FirebaseFirestore.instance.collection("communes").orderBy('nom', descending: false).get().then((querySnapshot) {
              querySnapshot.docs.forEach((result) {

                      setState((){
                        communes.add(result.data()["nom"]);
                        passwords.add(result.data()["mdp"]);
                      });
              });
       });
}

@override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: ShaderMask(
      shaderCallback: (rect) {
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
                    Colors.black,
                    Colors.black.withOpacity(0.6),
                  ],
                  stops: const [
                    1,//0.6,
                    1//1.0
                  ],
        ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
      },
      blendMode: BlendMode.dstIn,
      child:  GestureDetector(
      onTap: () {FocusScope.of(context).unfocus();},
      child: Container(
        color: Colors.black,
        child:Center(
          child: Stack(
            children: [
              SizedBox.expand(child: FittedBox(fit: BoxFit.cover,child: SizedBox(
                width: _videoController!.value.size.width ?? 0,
                height: _videoController!.value.size.height ?? 0,
                child: _videoController!.value.isInitialized
                        ? AnimatedOpacity(
                            opacity: 0.5,
                            duration: const Duration(milliseconds: 1000),
                            child: AspectRatio(
                              aspectRatio: _videoController!.value.aspectRatio,
                              child: VideoPlayer(_videoController!),
                            ),
                        ): Container(),
                )
              )),

              /*  Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                  fit: BoxFit.cover,
                              colorFilter: 
                  ColorFilter.mode(Colors.black.withOpacity(0.5), 
                  BlendMode.dstATop),
                  image: AssetImage(
                    'assets/bck.png',
                    
                  ),
               ))), */

              if(signup == false)
              ListView(
                //mainAxisAlignment: MainAxisAlignment.center,
                //crossAxisAlignment: CrossAxisAlignment.center,
                //shrinkWrap: true,
                children: [

                  Container(height: 100,),
                 
                  Container(
                          height: 60,
                          margin: const EdgeInsets.fromLTRB(30, 50, 30, 30),
                          child: Image.asset(
                              "assets/splash.png",
                          ),
                        ),
                Form(
                    key: formKey,
                    child: Column(
                      children:[

                      Container(
                        margin: const EdgeInsets.fromLTRB(50, 5, 50, 5),
                        height: 50,
                        alignment: Alignment.center,
                        
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.99),
                          borderRadius: const BorderRadius.all(Radius.circular(5)),
                        ),
                        child: DropdownSearch<String>(
                          mode: Mode.MENU,
                          showSelectedItems: true,
                          items: communes,
                          //popupItemDisabled: (String s) => s.startsWith('I'),
                          onChanged: (item) => selectedCommune = item!,
                          //selectedItem: communes[0],
                          popupBackgroundColor: Colors.white.withOpacity(0.99),
                          popupBarrierColor: Colors.black12,
                        ),
                      ),
   
                        Container(
                          margin: const EdgeInsets.fromLTRB(30, 5, 30, 0),
                          alignment: Alignment.center,
                          child: RoundedButtonWidget(buttonText: " Se connecter ", width: 60, 
                            onpressed: () async {  
                              
                              final isValid = formKey.currentState!.validate();
                              FocusScope.of(context).unfocus();
                              if(isValid){

                                if(selectedCommune != ""){
                                
                                    final SharedPreferences prefs = await _prefs;
                                    setState(() {
                                      prefs.setString("topic", selectedCommune);
                                      prefs.setBool("isAdmin", false);
                                    });

                                     Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) =>  MyHomePage(hasInternet: true, topic: selectedCommune, isAdmin: false)));
                                }
                              }
                            },
                          ),
                        ),
                       
                      ],
                    ),
                  ),
                  Container(height: 10,),
                  Row( 
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children:[
                          Container( // Draw Line
                            width: 80,
                            height: 1,
                            color: Colors.white,
                          ),
                          Container(
                          margin: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                          child: const Text(
                            "Admin",
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                          Container( // Draw Line
                            width: 80,
                            height: 1,
                            color: Colors.white,
                          ),
                  ]),

              

              Container(
                margin: const EdgeInsets.fromLTRB(50, 0, 50, 10),
                child: TextButton(
                  style: TextButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal, fontStyle: FontStyle.italic),
                      primary: Colors.white,
                  ),
                  child: const Text("Connexion administrateur"),
                  onPressed: () async {

                    setState(() {
                       signup = true;
                    });
                  },
                ),
              ),
              
            ],
          ),
          if(signup == true)
          ListView(
                //mainAxisAlignment: MainAxisAlignment.center,
                //crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  Container(height: 100,),
                 
                  Container(
                          height: 60,
                          margin: const EdgeInsets.fromLTRB(30, 50, 30, 30),
                          child: Image.asset(
                              "assets/splash.png",
                          ),
                        ),
                Form(
                    key: formKey,
                    child: Column(
                      children:[
                        
                        
                        Container(
                        margin: const EdgeInsets.fromLTRB(50, 5, 50, 5),
                        height: 50,
                        alignment: Alignment.center,
                        
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.99),
                          borderRadius: const BorderRadius.all(Radius.circular(5)),
                        ),
                        child: DropdownSearch<String>(
                          mode: Mode.MENU,
                          showSelectedItems: true,
                          items: communes,
                          //popupItemDisabled: (String s) => s.startsWith('I'),
                          onChanged: (item) => selectedCommune = item!,
                          //selectedItem: communes[0],
                          popupBackgroundColor: Colors.white.withOpacity(0.99),
                          popupBarrierColor: Colors.black12,
                          
                        ),
                      ),

                          Container(
                            height: 68,
                            margin: const EdgeInsets.fromLTRB(50, 0, 50, 0),
                            child: TextFormField(
                              obscureText: true,
                              controller: _passwordControllerREGISTER,
                              style: const TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                labelText: "Mot de passe",
                                labelStyle: const TextStyle(color: Colors.black87),
                                fillColor: Colors.white.withOpacity(0.99), filled: true,

                                focusedBorder: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(4)),
                                  borderSide: BorderSide(width: 1,color: Colors.blueAccent),
                                ),
                                enabledBorder: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(4)),
                                  borderSide: BorderSide(width: 1,color: Colors.black),
                                ),
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(4)),
                                  borderSide: BorderSide(width: 1,)
                                ),
                                errorBorder: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(4)),
                                  borderSide: BorderSide(width: 1,color: Colors.redAccent)
                                ),
                                focusedErrorBorder: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(4)),
                                  borderSide: BorderSide(width: 1.5,color: Colors.redAccent)
                                ),
                                /*
                                hintStyle: TextStyle(
                                  color: Colors.blueAccent,
                                ),*/
                              ),
                              maxLength: 20,
                              keyboardType: TextInputType.visiblePassword,
                              autofillHints: [AutofillHints.password],
                              validator: (value){

                              final pattern = r'^[a-zA-Z0-9&$#!=_\-\?]+$';
                              final regExp = RegExp(pattern);

                              if(value!.length < 6){
                                return 'Entrez au moins 6 caractères.';
                              }
                              else if(!regExp.hasMatch(value!)){

                                 return "Caractères non autorisés.";
                              }
                              else{
                                return null;
                              }
                            },
                            ),
                        ),

                        Container(
                          margin: const EdgeInsets.fromLTRB(30, 10, 30, 0),
                          alignment: Alignment.center,
                          child: RoundedButtonWidget(buttonText: " Se connecter ", width: 60, 
                            onpressed: () async {  
                              // ADMIN
                              final isValid = formKey.currentState!.validate();
                              FocusScope.of(context).unfocus();
                              if(isValid){
                                if(selectedCommune != ""){

                                  int i = communes.indexOf(selectedCommune);

                                  if(passwords[i] == _passwordControllerREGISTER.text){
                                
                                    final SharedPreferences prefs = await _prefs;
                                    setState(() {
                                      prefs.setString("topic", selectedCommune);
                                      prefs.setBool("isAdmin", true);
                                    });

                                     Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) =>  MyHomePage(hasInternet: true, topic: selectedCommune, isAdmin: true)));
                                  }
                                  else{

                                    popupTitle = "Erreur";
                                    popupBody = "Mot de passe Incorrect.";
                                    popupBtn = "OK";
                                    popupLottie="assets/error.json";
                                    popupHeight = 70;

                                    await showCupertinoDialog(
                                      context: context, 
                                      builder: createMessage
                                    ); 
                                  }
                                }
                              }
                            },
                          ),
                        ),

                     /*    Container(
                          margin: const EdgeInsets.fromLTRB(50, 0, 50, 10),
                          child: TextButton(
                            style: TextButton.styleFrom(
                                 textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal, fontStyle: FontStyle.italic),
                                 primary: Colors.white,
                            ),
                            child: const Text("Mot de passe oublié ?"),
                            onPressed: () async {

                              final isYes = await showCupertinoDialog(
                                  context: context, 
                                  builder: createDialog
                              ); 

                              if(isYes){

                                popupTitle = "Email envoyé !";
                                popupBody = "You can check your emails.";
                                popupBtn = "Open emails";
                                popupLottie="assets/success.json";
                                popupHeight = 70;

                                final isYes2 = await showCupertinoDialog(
                                  context: context, 
                                  builder: createMessage
                               ); 

                                if(isYes2){

                                }
                              }

                            },
                          ),
                        ),    */

                        Container(
                          margin: const EdgeInsets.fromLTRB(50, 0, 50, 10),
                          child: TextButton(
                            style: TextButton.styleFrom(
                                 textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal, fontStyle: FontStyle.italic),
                                 primary: Colors.white,
                            ),
                            child: const Text("Retour"),
                            onPressed: () async {

                              setState(() {
                                 signup = false;
                              });
                            },
                          ),
                        )
                      ],
                    ),
                  ),           
            ],
          ),

        ]),
        ),
      ),
    ),
    ),
    );
  }




 Widget createDialog(BuildContext context) => CupertinoAlertDialog(
         title: const Text("Forgot Password", style: TextStyle(fontSize:18)),
         content: Column(
           children: [
             Lottie.asset(
              "assets/plane.json",
              animate: true,
              height: 80,
             ), 
             const Text("Do you want to receive an email to change your password ?", style: TextStyle(fontSize:16)),
           ],
         ),
         actions: [
           CupertinoDialogAction(
             child: const Text("No"),
             onPressed: () => Navigator.pop(context,false),
           ),
           CupertinoDialogAction(
             child: const Text("Yes"),
             onPressed: () => Navigator.pop(context,true),
           ),
         ],
  );

   Widget createMessage(BuildContext context) => CupertinoAlertDialog(
         title: Text(popupTitle, style: TextStyle(fontSize:18)),
         content: Column(
           children: [
             Lottie.asset(
              popupLottie,
              animate: true,
              height: popupHeight,
             ), 
             Text(popupBody, style: TextStyle(fontSize:16)),
           ],
         ),
         actions: [
           CupertinoDialogAction(
             child: Text(popupBtn),
             onPressed: () => Navigator.pop(context,true),
           ),
         ],
  );

}