import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
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
import 'package:sign_button/sign_button.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:twitter_login/entity/auth_result.dart';
import 'package:twitter_login/twitter_login.dart';
import 'package:video_player/video_player.dart';


class LoginPage extends StatefulWidget {

  bool hasInternet;
  LoginPage({required this.hasInternet});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with WidgetsBindingObserver {

  String popupTitle = "";
  String popupBody = "";
  String popupBtn = "";
  String popupLottie = "";
  double? popupHeight = 70;

  final formKey = GlobalKey<FormState>();

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

    _videoController = VideoPlayerController.asset(
        'assets/video.mp4')
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
                            opacity: 0.8,
                            duration: const Duration(milliseconds: 1000),
                            child: AspectRatio(
                              aspectRatio: _videoController!.value.aspectRatio,
                              child: VideoPlayer(_videoController!),
                            ),
                        ): Container(),
                )
              )),

              if(signup == false)
              ListView(
                //mainAxisAlignment: MainAxisAlignment.center,
                //crossAxisAlignment: CrossAxisAlignment.center,
                //shrinkWrap: true,
                children: [
                 
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
                          height: 70,
                          margin: const EdgeInsets.fromLTRB(50, 10, 50, 10),
                          child: TextFormField(
                            controller: _emailController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: "Email",
                              labelStyle: TextStyle(color: Color.fromRGBO(235, 235, 235, 1)),
                              fillColor: Colors.black54, filled: true,

                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(4)),
                                borderSide: BorderSide(width: 1,color: Colors.blueAccent),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(4)),
                                borderSide: BorderSide(width: 1,color: Colors.black),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(4)),
                                borderSide: BorderSide(width: 1,)
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(4)),
                                borderSide: BorderSide(width: 1,color: Colors.redAccent)
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(4)),
                                borderSide: BorderSide(width: 1.5,color: Colors.redAccent)
                              ),
                              
                              /*  hintStyle: TextStyle(
                                  color: Colors.blueAccent,
                              ),*/
                            ),
                            validator: (value){

                              final pattern = r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
                              final regExp = RegExp(pattern);

                              if(!regExp.hasMatch(value!)){

                                 return "Enter a valid email.";
                              }
                              else{
                                return null;
                              }
                            },
                            maxLength: 40,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                          ),
                        ),

                          Container(
                            height: 70,
                            margin: const EdgeInsets.fromLTRB(50, 0, 50, 0),
                            child: TextFormField(
                              obscureText: true,
                              controller: _passwordController,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                labelText: "Password",
                                labelStyle: TextStyle(color: Color.fromRGBO(235, 235, 235, 1)),
                                fillColor: Colors.black54, filled: true,

                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(4)),
                                  borderSide: BorderSide(width: 1,color: Colors.blueAccent),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(4)),
                                  borderSide: BorderSide(width: 1,color: Colors.black),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(4)),
                                  borderSide: BorderSide(width: 1,)
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(4)),
                                  borderSide: BorderSide(width: 1,color: Colors.redAccent)
                                ),
                                focusedErrorBorder: OutlineInputBorder(
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

                                 return "Some characters you entered are not allowed.";
                              }
                              else{
                                return null;
                              }
                            },
                            ),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(30, 5, 30, 0),
                          alignment: Alignment.center,
                          child: RoundedButtonWidget(buttonText: "    Login    ", width: 60, 
                            onpressed: () {  
                              
                              final isValid = formKey.currentState!.validate();
                              FocusScope.of(context).unfocus();
                              if(isValid){
                                signInWithEmail();
                              }
                            },
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(50, 0, 50, 10),
                          child: TextButton(
                            style: TextButton.styleFrom(
                                 textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal, fontStyle: FontStyle.italic),
                                 primary: Colors.white,
                            ),
                            child: const Text("Forgot password ?"),
                            onPressed: () async {

                              final isYes = await showCupertinoDialog(
                                  context: context, 
                                  builder: createDialog
                              ); 

                              if(isYes){

                                popupTitle = "Email sent !";
                                popupBody = "You can check your emails.";
                                popupBtn = "Open emails";
                                popupLottie="assets/success.json";
                                popupHeight = 70;

                                final isYes2 = await showCupertinoDialog(
                                  context: context, 
                                  builder: createMessage
                               ); 

                                if(isYes2){

                                  sendEmailVerification();
                                  openEmailApp();
                                }
                              }

                            },
                          ),
                        )
                      ],
                    ),
                  ),
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
                            "Social Login",
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                          Container( // Draw Line
                            width: 80,
                            height: 1,
                            color: Colors.white,
                          ),
                  ]),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: SignInButton.mini(
                      buttonType: ButtonType.google,
                      onPressed: () async {

                        await signInWithGoogle();

                        final FirebaseAuth auth = FirebaseAuth.instance;
                        final User? user = auth.currentUser;

                        if (user != null) {

                            String uid = user!.uid;
                            Timestamp dateNow = Timestamp.fromDate(DateTime.now());

                            FirebaseFirestore.instance
                              .collection("users")
                              .doc(uid)
                              .get()
                              .then((doc) {
                                if(doc.exists) {
                                  print("exists");
                                } else {
                                  
                                  CollectionReference db = FirebaseFirestore.instance.collection("users");
                                    db.doc(uid).set({"username" : uid, "date": dateNow})
                                      .then((value) => (){})
                                      .catchError((error) => print(error)); 
                                }
                              });

                          await Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => MyHomePage(hasInternet: widget.hasInternet,)
                              ),
                          );
                        }

                      },
                    ),
                  ),

                  Container(
                    margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: SignInButton.mini(
                      buttonType: ButtonType.twitter,
                      onPressed: () async {

                        await signInWithTwitter();

                        final FirebaseAuth auth = FirebaseAuth.instance;
                        final User? user = auth.currentUser;

                        if (user != null) {

                            String uid = user!.uid;
                            Timestamp dateNow = Timestamp.fromDate(DateTime.now());

                            FirebaseFirestore.instance
                              .collection("users")
                              .doc(uid)
                              .get()
                              .then((doc) {
                                if(doc.exists) {
                                  print("exists");
                                } else {
                                  
                                  CollectionReference db = FirebaseFirestore.instance.collection("users");
                                    db.doc(uid).set({"username" : uid, "date": dateNow})
                                      .then((value) => (){})
                                      .catchError((error) => print(error)); 
                                }
                              });

                          await Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => MyHomePage(hasInternet: widget.hasInternet,)
                              ),
                          );
                        }

                      },
                    ),
                  ),

                  Container(
                    margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: SignInButton.mini(
                      buttonType: ButtonType.apple,
                      onPressed: () async {
                        try{
                          
                          await signInWithApple();

                          final FirebaseAuth auth = FirebaseAuth.instance;
                          final User? user = auth.currentUser;
                       
                          if (user != null) {

                            String uid = user!.uid;
                            Timestamp dateNow = Timestamp.fromDate(DateTime.now());

                            FirebaseFirestore.instance
                              .collection("users")
                              .doc(uid)
                              .get()
                              .then((doc) {
                                if(doc.exists) {
                                  print("exists");
                                } else {
                                  
                                  CollectionReference db = FirebaseFirestore.instance.collection("users");
                                    db.doc(uid).set({"username" : uid, "date": dateNow})
                                      .then((value) => (){})
                                      .catchError((error) => print(error)); 
                                }
                              });

                            await Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => MyHomePage(hasInternet: widget.hasInternet,)
                                ),
                            );
                          }

                        }
                        catch(e){print(e);}
                      },
                    ),
                  ),
              ]),

              Container(
                margin: const EdgeInsets.fromLTRB(50, 0, 50, 10),
                child: TextButton(
                  style: TextButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal, fontStyle: FontStyle.italic),
                      primary: Colors.white,
                  ),
                  child: const Text("New user? Signup"),
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
                          height: 70,
                          margin: const EdgeInsets.fromLTRB(50, 10, 50, 10),
                          child: TextFormField(
                            controller: _usernameControllerREGISTER,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: "Username",
                              labelStyle: TextStyle(color: Color.fromRGBO(235, 235, 235, 1)),
                              fillColor: Colors.black54, filled: true,

                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(4)),
                                borderSide: BorderSide(width: 1,color: Colors.blueAccent),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(4)),
                                borderSide: BorderSide(width: 1,color: Colors.black),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(4)),
                                borderSide: BorderSide(width: 1,)
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(4)),
                                borderSide: BorderSide(width: 1,color: Colors.redAccent)
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(4)),
                                borderSide: BorderSide(width: 1.5,color: Colors.redAccent)
                              ),
                              
                              /*  hintStyle: TextStyle(
                                  color: Colors.blueAccent,
                              ),*/
                            ),
                            validator: (value){

                              final pattern = r'^[a-zA-Z0-9_\-]+$';
                              final regExp = RegExp(pattern);
               
                              if(value!.length < 3){
                                return 'Entrez au moins 3 caractères.';
                              }
                              else if(!regExp.hasMatch(value!)){

                                 return "Special characters are not allowed.";
                              }
                              else{
                                return null;
                              }
                            },
                            maxLength: 20,
                          ),
                        ),

                        Container(
                          height: 70,
                          margin: const EdgeInsets.fromLTRB(50, 10, 50, 10),
                          child: TextFormField(
                            controller: _emailControllerREGISTER,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: "Email",
                              labelStyle: TextStyle(color: Color.fromRGBO(235, 235, 235, 1)),
                              fillColor: Colors.black54, filled: true,

                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(4)),
                                borderSide: BorderSide(width: 1,color: Colors.blueAccent),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(4)),
                                borderSide: BorderSide(width: 1,color: Colors.black),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(4)),
                                borderSide: BorderSide(width: 1,)
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(4)),
                                borderSide: BorderSide(width: 1,color: Colors.redAccent)
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(4)),
                                borderSide: BorderSide(width: 1.5,color: Colors.redAccent)
                              ),
                              
                              /*  hintStyle: TextStyle(
                                  color: Colors.blueAccent,
                              ),*/
                            ),
                            validator: (value){

                              final pattern = r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
                              final regExp = RegExp(pattern);

                              if(!regExp.hasMatch(value!)){

                                 return "Enter a valid email.";
                              }
                              else{
                                return null;
                              }
                            },
                            maxLength: 40,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: [AutofillHints.email]
                          ),
                        ),

                          Container(
                            height: 70,
                            margin: const EdgeInsets.fromLTRB(50, 0, 50, 0),
                            child: TextFormField(
                              obscureText: true,
                              controller: _passwordControllerREGISTER,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                labelText: "Password",
                                labelStyle: TextStyle(color: Color.fromRGBO(235, 235, 235, 1)),
                                fillColor: Colors.black54, filled: true,

                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(4)),
                                  borderSide: BorderSide(width: 1,color: Colors.blueAccent),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(4)),
                                  borderSide: BorderSide(width: 1,color: Colors.black),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(4)),
                                  borderSide: BorderSide(width: 1,)
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(4)),
                                  borderSide: BorderSide(width: 1,color: Colors.redAccent)
                                ),
                                focusedErrorBorder: OutlineInputBorder(
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

                                 return "Some characters you entered are not allowed.";
                              }
                              else{
                                return null;
                              }
                            },
                            ),
                        ),

                        Container(
                          margin: const EdgeInsets.fromLTRB(30, 0, 30, 10),
                          alignment: Alignment.center,
                          child: RoundedButtonWidget(buttonText: "Create Account", width: 60, 
                            onpressed: () {  
                              
                              final isValid = formKey.currentState!.validate();
                              FocusScope.of(context).unfocus();
                              if(isValid){
                                registerWithEmail();
                              }
                            },
                          ),
                        ),

                        Container(
                          margin: const EdgeInsets.fromLTRB(50, 0, 50, 10),
                          child: TextButton(
                            style: TextButton.styleFrom(
                                 textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal, fontStyle: FontStyle.italic),
                                 primary: Colors.white,
                            ),
                            child: const Text("Back"),
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

  Future<void> registerWithEmail() async {

    try {

      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailControllerREGISTER.text,
        password: _passwordControllerREGISTER.text,
      );

      final FirebaseAuth auth = FirebaseAuth.instance;
      final User? user = auth.currentUser;

      if (user != null) {

          String uid = user.uid;
          Timestamp dateNow = Timestamp.fromDate(DateTime.now());

          FirebaseFirestore.instance
                              .collection("users")
                              .doc(uid)
                              .get()
                              .then((doc) {
                                if(doc.exists) {
                                  print("exists");
                                } else {
                                  
                                  CollectionReference db = FirebaseFirestore.instance.collection("users");
                                    db.doc(uid).set({"username" : _usernameControllerREGISTER.text, "date": dateNow})
                                      .then((value) => (){})
                                      .catchError((error) => print(error)); 
                                }
                              });

          sendEmailVerification();

          await Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MyHomePage(hasInternet: widget.hasInternet,)
             ),
          );
      }

    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        
        popupTitle = "Password too weak";
        popupBody = "Please, use a stronger password.";
        popupBtn = "Ok";
        popupLottie="assets/error.json";
        popupHeight = 90;

        final isYes2 = await showCupertinoDialog(
          context: context, 
          builder: createMessage
        ); 
        

      } else if (e.code == 'email-already-in-use') {
        log('The account already exists for that email.');
        
        popupTitle = "Account already exist";
        popupBody = "Please, use a different email.";
        popupBtn = "Ok";
        popupLottie="assets/error.json";
        popupHeight = 90;

        final isYes2 = await showCupertinoDialog(
          context: context, 
          builder: createMessage
        ); 
        
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> signInWithEmail() async {

    try {

        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

      final FirebaseAuth auth = FirebaseAuth.instance;
      final User? user = auth.currentUser;

      if (user != null) {
          await Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MyHomePage(hasInternet: widget.hasInternet,)
             ),
          );
      }

    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {

        popupTitle = "User Does not exist";
        popupBody = "Try a different email address.";
        popupBtn = "Ok";
        popupLottie="assets/error.json";
        popupHeight = 90;

        final isYes2 = await showCupertinoDialog(
          context: context, 
          builder: createMessage
        ); 

      } else if (e.code == 'wrong-password') {

        popupTitle = "Wrong password";
        popupBody = "This is not the password associated with this email.";
        popupBtn = "Ok";
        popupLottie="assets/error.json";
        popupHeight = 90;

        final isYes2 = await showCupertinoDialog(
          context: context, 
          builder: createMessage
        ); 
      }
    }
  }

  Future<void> openEmailApp() async {

    // Android: Will open mail app or show native picker.
    // iOS: Will open mail app if single mail app found.
    var result = await OpenMailApp.openMailApp();

    // If no mail apps found, show error
    if (!result.didOpen && !result.canOpen) {
      //showNoMailAppsDialog(context);
      log("no email app");

    // iOS: if multiple mail apps found, show dialog to select.
    // There is no native intent/default app system in iOS so
    // you have to do it yourself.
    } /* else if (!result.didOpen && result.canOpen) {
           showDialog(
            context: context,
            builder: (_) {
              return MailAppPickerDialog(
                mailApps: result.options,
              );
            },
          ); */
  }

  Future<void> sendEmailVerification() async {

    try{

      User? user = FirebaseAuth.instance.currentUser;

      if (user!= null && !user.emailVerified) {
        log("Email sent !");
        await user.sendEmailVerification();
      }
    }

    catch(e){print(e);}
  }

  Future<void> signInWithGoogle() async {

    try{

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

        // Create a new credential
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        );

        // Once signed in, return the UserCredential
        await FirebaseAuth.instance.signInWithCredential(credential);

    }
    catch(e){
      print(e);
    }
  }

  Future<void> signInWithTwitter() async {

    try{
      // Create a TwitterLogin instance
      final twitterLogin = TwitterLogin(
        apiKey: 'SoqljuKeOsrzUmUscWlCkTK6Q',
        apiSecretKey:'K29Mqmlis5qn0ZDeIZwf4awdYFCgHMYlPqGUXcl8uuaydHQ6mt',
        redirectURI: 'https://onlyfeet-7d2da.firebaseapp.com/__/auth/handler',
      );

      // Trigger the sign-in flow
      AuthResult authResult = await twitterLogin.login();

      // Create a credential from the access token
      final twitterAuthCredential = TwitterAuthProvider.credential(
        accessToken: authResult.authToken!,
        secret: authResult.authTokenSecret!,
      );

      // Once signed in, return the UserCredential
      await FirebaseAuth.instance.signInWithCredential(twitterAuthCredential);
    }
    catch(e){ print(e); }
  } 

  /////////////////////////////  APPLE  ///////////////////////////////

  /// Generates a cryptographically secure random nonce, to be included in a
  String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = math.Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }
  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<UserCredential> signInWithApple() async {
    
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    // Request credential for the currently signed in Apple account.
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
      webAuthenticationOptions: WebAuthenticationOptions(
                    // TODO: Set the `clientId` and `redirectUri` arguments to the values you entered in the Apple Developer portal during the setup
                    clientId:
                        'com.lordly.authentification',
                    redirectUri: Uri.parse(
                      'https://onlyfeet-7d2da.firebaseapp.com/__/auth/handler',
                    ),
                  ),
    );

    // Create an `OAuthCredential` from the credential returned by Apple.
    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );

    // Sign in the user with Firebase. If the nonce we generated earlier does
    // not match the nonce in `appleCredential.identityToken`, sign in will fail.
    return await FirebaseAuth.instance.signInWithCredential(oauthCredential);
  }

  /////////////////////// END APPLE ///////////////////////////////////////////////////

  Future<void> signOut() async {

      try {
        final User? firebaseUser = await FirebaseAuth.instance.currentUser;
        
          if (firebaseUser != null) {
              await GoogleSignIn().signOut();
              await FirebaseAuth.instance.signOut().then((value) => {
              log("logout")});
          } 

      } catch (e) {
        print(e);
      }
  }

  Future<void> deleteUser() async {

    try {

      await FirebaseAuth.instance.currentUser!.delete();

    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        log('The user must reauthenticate before this operation can be executed.');
      }
    }
  }

  Future<void> reauthentificateUser() async {

    // Prompt the user to enter their email and password
    String email = 'barry.allen@example.com';
    String password = 'SuperSecretPassword!';

    // Create a credential
    AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);

    // Reauthenticate
    await FirebaseAuth.instance.currentUser!.reauthenticateWithCredential(credential);
  }

  Future<void> verifyPhoneNumber() async {

    final FirebaseAuth auth = FirebaseAuth.instance;

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+33695568272',
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {

          // ANDROID ONLY!

          // Sign the user in (or link) with the auto-generated credential
          await auth.signInWithCredential(credential);

      },
      verificationFailed: (FirebaseAuthException e) async {

          if (e.code == 'invalid-phone-number') {
            log('The provided phone number is not valid.');
          }

        // Handle other errors
      },
      codeSent: (String verificationId, int? resendToken) async {

        // Update the UI - wait for the user to enter the SMS code
        String smsCode = 'xxxx';

        // Create a PhoneAuthCredential with the code
        PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode);

        // Sign the user in (or link) with the credential
        await auth.signInWithCredential(credential);

      },
      codeAutoRetrievalTimeout: (String verificationId) async {


      },
    );
  }


  Future fetchOffers() async { // in-app payments

    final offerings = await PurchaseApi.fetchOffers();

    if(offerings.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No plan found")));
    }
    else{

      final packages = offerings
         .map((offer) => offer.availablePackages)
         .expand((pair) => pair)
         .toList();

      await PurchaseApi.purchasePackage(packages.first);
    }
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