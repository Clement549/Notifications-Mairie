//flutter build appbundle --release --target-platform=android-arm64
import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:devicelocale/devicelocale.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter_course/chat_page.dart';
import 'package:flutter_course/connexion_page.dart';
import 'package:flutter_course/profil_page.dart';
import 'package:flutter_course/provider/theme_provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_course/introduction_page.dart';
import 'package:flutter_course/local_notification_service.dart';
import 'package:flutter_course/login_page.dart';
import 'package:flutter_course/map_page.dart';
import 'package:flutter_course/menu_page.dart';
import 'package:flutter_course/messaging.dart';
import 'package:flutter_course/models/config.dart';
import 'package:flutter_course/models/todo.dart';
import 'package:flutter_course/models/utils.dart';
import 'package:flutter_course/page2.dart';
import 'package:flutter_course/stripe/home.dart';
import 'package:flutter_course/stripe/register.dart';
import 'package:flutter_course/widgets/camera.dart';
import 'package:flutter_course/widgets/new_todo.dart';
import 'package:flutter_course/widgets/shimmer_widget.dart';
import 'package:flutter_course/widgets/todo_cards.dart';
import 'package:flutter_course/widgets/webview_page.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb; // flutter run -d chrome --web-renderer html  // flutter build web --web-renderer html --release
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_ios/in_app_purchase_ios.dart';
import 'package:in_app_purchase_ios/store_kit_wrappers.dart';

List<CameraDescription> cameras = [];

String topic = "none";  //saved in prefs
bool? isAdmin = true;  // saved in prefs
Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  //MobileAds.instance.initialize();

  SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
  ]);
  
  if(!kIsWeb){
    cameras = await availableCameras(); // camera

    if (defaultTargetPlatform == TargetPlatform.android) {
       InAppPurchaseAndroidPlatformAddition.enablePendingPurchases();
    }
  }

  if(!kIsWeb){
    if (Platform.isAndroid) {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle (
        systemNavigationBarColor: Colors.black, // navigation bar color // 0xff + 6 digits hex
        statusBarColor: Colors.black, // status bar color
        //statusBarBrightness: Brightness.dark,//status bar brigtness
        //statusBarIconBrightness:Brightness.dark , //status barIcon Brightness
        systemNavigationBarDividerColor: Colors.black,//Navigation bar divider color
        systemNavigationBarIconBrightness: Brightness.light, //navigation bar icon 
      ));

      //SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge); // hide nav/top bars
    }
  }
  
  configLoading(); // loading indicator init

  bool hasInternet = false;
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult != ConnectivityResult.none) {

      hasInternet = true;

      await Firebase.initializeApp();

      FirebaseMessaging messaging = FirebaseMessaging.instance;
      NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
      );

      if(!kIsWeb){
         await FirebaseMessaging.instance.subscribeToTopic(topic);
      }
  }

  final SharedPreferences prefs = await _prefs;
  //await prefs.clear(); // reset
  topic = prefs.getString("topic") ?? "none";
  isAdmin = prefs.getBool("isAdmin") ?? false;

  runApp(MyApp(hasInternet: hasInternet, topic: topic, isAdmin: isAdmin));
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.green
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = true
    ..dismissOnTap = false;
}

Future sendNotification(title, body, date, img1, img2, img3, pdf, map, myFunc, id, topic) async {

  final response = await Messaging.sendToAll(
      title: title,
      body: body,
      date: date,
      img1: img1,
      img2: img2,
      img3: img3,
      pdf: pdf,
      map: map,
      myFunc: myFunc,
      id: id,
      topic: topic,
  );

  if(response.statusCode != 200) {

    log("Error while sending notif");
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {

    log("Handling a background message: ${message.messageId}");
  }


class MyApp extends StatelessWidget{

   //final _initialization = Firebase.initializeApp();
    bool hasInternet;
    String? topic = "none";
    bool? isAdmin;
    MyApp({required this.hasInternet, this.topic, this.isAdmin});

    @override
    Widget build(BuildContext context) => ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      builder: (context, _) {

        LocalNotificationService.initialize(context);
        
        final text = Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark
            ? "DarkTheme"
            : "LightTheme";

        return WillPopScope(
          onWillPop: () async {
            //MinimizeApp.minimizeApp();
            //return false;
            return true;
          },
          child: OverlaySupport(
            child: MaterialApp(
              title:'Annonces',
              /*theme: ThemeData(
                primarySwatch: Colors.blue,
              ), */
              themeMode: ThemeMode.system,
              theme: MyThemes.lightTheme,
              darkTheme: MyThemes.lightTheme, //darkTheme
              debugShowCheckedModeBanner: false,
              home: AuthenticationWrapper(hasInternet: hasInternet, topic: topic, isAdmin: isAdmin), //myHomePage() marche pour web
              builder: EasyLoading.init(),
              routes: {
                "red": (_) => MyHomePage(hasInternet: hasInternet, topic: topic, isAdmin: isAdmin),
                "green": (_) => MyHomePage(hasInternet: hasInternet, topic: topic, isAdmin: isAdmin),
              },
            ),
          ),
        );
      }
    );
}


class AuthenticationWrapper extends StatelessWidget {

    bool hasInternet;
    String? topic;
    bool? isAdmin;
    AuthenticationWrapper({required this.hasInternet, this.topic, this.isAdmin});
  
  @override
  Widget build(BuildContext context) {
   
   //final FirebaseAuth auth = FirebaseAuth.instance;
   //final User? user = auth.currentUser;

    if (topic == "none") {
      log("Utilisateur Non connecté.");
      return ConnexionPage(hasInternet: hasInternet,);
    }

    log("Utilisateur connecté !");
    return MyHomePage(hasInternet: hasInternet, topic: topic, isAdmin: isAdmin,);
  }
}


Future<void> _signOut() async {

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


class MyHomePage extends StatefulWidget{

  bool hasInternet;
  String? topic = "none";
  bool? isAdmin;
  MyHomePage({required this.hasInternet, this.topic, this.isAdmin});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  StreamSubscription? subscription; // check internet

  bool ignoreFirstConnexion = true; //

  InterstitialAd? interstitialAd;
  RewardedAd? rewardedAd;
  bool isLoaded = false;

  void updatePrefs() async {

    final SharedPreferences prefs = await _prefs;
    final int counter = (prefs.getInt('counter') ?? 0) + 1;

    topic = widget.topic!;
    isAdmin = widget.isAdmin!;

    setState(() {
      //prefs.setString("topic", widget.topic!);
      //prefs.setBool("isAdmin", widget.isAdmin!);
    });

  }

  @override
  void initState() {

    updatePrefs();

    if(widget.hasInternet){

      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {

        final id = message.data["id"];
        final title = message.data["title"];
        final body = message.data["body"];
        final date = message.data["date"];
        final img1 = message.data["img1"];
        final img2 = message.data["img2"];
        final img3 = message.data["img3"];
        final pdf = message.data["pdf"];
        final map = message.data["map"];
        final topic = message.data["topic"];

        log("date: " + date);

        String seconds = "";
        String nanoseconds = "";

        for(int i=0; i<date.length; i++) {
          if(i>= 19 && i <= 27){
             seconds += date[i];
          }
          else if(i>= 43 && i <= 50){
             nanoseconds += date[i];
          }
        }

        log("sec: " + seconds);
        log("nano: " + nanoseconds);

        Timestamp timestamp = Timestamp(int.parse(seconds), int.parse(nanoseconds));

         if(isAdmin == false){
              _addTodoNotif(title, body, Timestamp.now(), img1, img2, img3, pdf, map, topic, id);

              scrollTop();
         }

         ///////////////////

        log('Got a message whilst in the foreground!');
        log('Message data: ${message.data}');

        if (message.notification != null) {
          log('Message also contained a notification: ${message.notification}');
        }

        //LocalNotificationService.display(message);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((message){

        if(message != null){
            
            final routeFromMessage = message.data["route"];
            //Navigator.of(context).pushNamed(routeFromMessage); // Handling click action on Push notification like navigation while app is in background (app opened).
            final id = message.data["id"];
            final title = message.data["title"];
            final body = message.data["body"];
            final date = message.data["date"];
            final img1 = message.data["img1"];
            final img2 = message.data["img2"];
            final img3 = message.data["img3"];
            final pdf = message.data["pdf"];
            final map = message.data["map"];
            final topic = message.data["topic"];

            if(isAdmin == false){
              _addTodoNotif(title, body, Timestamp.now(), img1, img2, img3, pdf, map, topic, id);

              scrollTop();
            }
        }
      });

      FirebaseMessaging.instance.getInitialMessage().then((message) { //Handling click action on Push notification like navigation while app is in background (app closed).
        if(message!= null){
          
          final id = message.data["id"];
          final title = message.data["title"];
          final body = message.data["body"];
          final date = message.data["date"];
          final img1 = message.data["img1"];
          final img2 = message.data["img2"];
          final img3 = message.data["img3"];
          final pdf = message.data["pdf"];
          final map = message.data["map"];

          scrollTop();
        }
      });


      getData();
      loadData();

      if(!kIsWeb){
         checkVersion();
         //loadAd(true);
      }

      //checkCountry();
    }
    
    subscription = Connectivity().onConnectivityChanged.listen(showConnectivityBar);

    EasyLoading.addStatusCallback((status) {
      print('EasyLoading Status $status');
      if (status == EasyLoadingStatus.dismiss) {
        //_timer?.cancel();
      }
    });

    super.initState();
  }

  @override
  void dispose(){
    subscription!.cancel();
    WidgetsBinding.instance!.removeObserver(this);

    todos.clear();
    super.dispose();
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

  void loadAd(bool rewarded) async {

    if(rewarded){
      RewardedAd.load(
        adUnitId: 'ca-app-pub-3940256099942544/5224354917',
        request: AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {

            setState((){
              isLoaded = true;
              this.rewardedAd = ad;
            });
            print("ad laoded");

          },
          onAdFailedToLoad: (LoadAdError error) {
            print('RewardedAd failed to load: $error');
          },
        ),
      );
    }
    else{

      InterstitialAd.load(
        adUnitId: 'ca-app-pub-3940256099942544/1033173712',
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            
            setState((){
              isLoaded = true;
              this.interstitialAd=ad;
            });
            print("ad laoded");

          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error');
          },
        ));
      }
  }

  Future<String> checkCountry() async {

    Response data = await http.get(Uri.parse("http://ip-api.com/json"));

    Map dataMap = jsonDecode(data.body);
    String country = dataMap['country'];

    String? language = await Devicelocale.currentLocale;
    log("country: " + country + "  language: " + language!);
    return country;
  }

  Future checkVersion() async {

    try{

      String version = "";

      PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
        String appName = packageInfo.appName;
        String packageName = packageInfo.packageName;
        version = packageInfo.version;
        String buildNumber = packageInfo.buildNumber;
      });

      String serverVersion = "";

      if (Platform.isAndroid) {

          await FirebaseFirestore.instance.collection("server").get().then((querySnapshot) {
                    querySnapshot.docs.forEach((result) {
                        serverVersion = result.data()["android_version"];
                    });
          });
      }
      else{

        await FirebaseFirestore.instance.collection("server").get().then((querySnapshot) {
                    querySnapshot.docs.forEach((result) {
                        serverVersion = result.data()["ios_version"];
                    });
          });
      }

      if(version != serverVersion){

        log("serv: " + serverVersion);
        log("app: " + version);

        final isYes = await showCupertinoDialog(
              context: context, 
              builder: createDialog
        ); 

        if(isYes){
          StoreRedirect.redirect();
        }
      }
      
    }
    catch(e){}
  }

  Future getData() async {

    try{

      log("Topic: " + topic);
      
       await FirebaseFirestore.instance.collection("news").orderBy('date', descending: true).get().then((querySnapshot) {
              querySnapshot.docs.forEach((result) {

                      if(result.data()["topic"] == topic){ // affciher seulement infos relative a la commune (topic)

                        setState((){
                          todos.add(Todo(
                            id: result.data()["id"],
                            title: result.data()["title"],
                            body: result.data()["body"],
                            date: result.data()["date"],
                            img1: result.data()["img1"],
                            img2: result.data()["img2"],
                            img3: result.data()["img3"],
                            pdf: result.data()["pdf"],
                            map: result.data()["map"],
                            topic: result.data()["topic"],
                            myFunc: updateList,
                        ));
                        });

                      }
              });
       });

       todos.forEach((Todo todo) => precacheImage(NetworkImage(todo.img1), context)); // load images
    }
    catch(e){}

  }

   updateList(id){
    setState(() {
      log("Uuid:" + id);
      todos.removeWhere((todo) => todo.id == id);
    });

    Utils.showTopSnackBar(context, "Annonce supprimée !", "Cette annonce n'apparaitra plus.", Colors.green);
  }


  Future loadData() async {
    
    setState(() {
      Config.isLoading = true;
    });
    log(Config.isLoading.toString());

    await Future.delayed(const Duration(milliseconds: 6000),(){});

  if (this.mounted) {
      setState(() {
        Config.isLoading = false;
      });
      log(Config.isLoading.toString());
    }
  }

  void showConnectivityBar(ConnectivityResult result) async {

    if(widget.hasInternet == false){
       ignoreFirstConnexion = false;
    }

    if(ignoreFirstConnexion == false){
    
    final _hasInternet = result != ConnectivityResult.none;
    final message = _hasInternet
       ? "Vous etes reconnecté à internet !"
       : "Vous n'etes plus connecté à internet.";
    final color = _hasInternet ? Colors.green : Colors.red;

    // show a notification at top of screen.
    Utils.showTopSnackBar(context, 'Connexion Internet', message, color);

    if(widget.hasInternet == false){

        log("Loading App now with have Internet !");
     
        await Firebase.initializeApp();

        FirebaseMessaging messaging = FirebaseMessaging.instance;
        NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
        );

        await FirebaseMessaging.instance.subscribeToTopic(widget.topic!);

        FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

        FirebaseMessaging.onMessage.listen((RemoteMessage message) {

          final title = message.data["title"];
          final body = message.data["body"];
          final date = message.data["date"];
          final img1 = message.data["img1"];
          final img2 = message.data["img2"];
          final img3 = message.data["img3"];
          final pdf = message.data["pdf"];
          final map = message.data["map"];
          final id = message.data["id"];

          if(isAdmin == false){
              _addTodoNotif(title, body, Timestamp.now(), img1, img2, img3, pdf, map, topic, id);

              scrollTop();
          }

          /////////////////

          log('Got a message whilst in the foreground!');
          log('Message data: ${message.data}');

          if (message.notification != null) {
            log('Message also contained a notification: ${message.notification}');
          }

          //LocalNotificationService.display(message);
        });

        FirebaseMessaging.onMessageOpenedApp.listen((message){

          if(message != null){
              
              final routeFromMessage = message.data["route"];
              //Navigator.of(context).pushNamed(routeFromMessage); // Handling click action on Push notification like navigation while app is in background (app opened).
              
              final title = message.data["title"];
              final body = message.data["body"];
              final date = message.data["date"];
              final img1 = message.data["img1"];
              final img2 = message.data["img2"];
              final img3 = message.data["img3"];
              final pdf = message.data["pdf"];
              final map = message.data["map"];
              final id = message.data["id"];

              if(isAdmin == false){
                 _addTodoNotif(title, body, Timestamp.now(), img1, img2, img3, pdf, map, topic, id);

                 scrollTop();
              }           
          }
        });

        FirebaseMessaging.instance.getInitialMessage().then((message) { //Handling click action on Push notification like navigation while app is in background (app closed).
          if(message!= null){
            
            final title = message.data["title"];
            final body = message.data["body"];
            final date = message.data["date"];
            final img1 = message.data["img1"];
            final img2 = message.data["img2"];
            final img3 = message.data["img3"];
            final pdf = message.data["pdf"];
            final map = message.data["map"];
            final id = message.data["id"];

            scrollTop();
          }
        });


        getData();
        loadData();

        checkVersion();
    }

    setState(() {
      if(widget.hasInternet == false){
         widget.hasInternet = _hasInternet;
      }
    });

    }
    else{
      ignoreFirstConnexion = false;
    }
  }

////////////////////////////////////////////////////////////////////////////////////////////////////////////

  static List<Todo> todos = [
    //Todo(id: Uuid(), title :"Evenement Important", body:"Thalassius vero ea tempestate praefectus praetorio praesens ipse quoque adrogantis ingenii, considerans incitationem eius ad multorum augeri discrimina, non maturitate vel consiliis mitigabat, ut aliquotiens celsae potestates iras principum molliverunt, sed adversando iurgandoque cum parum congrueret, eum ad rabiem potius evibrabat, Augustum actus eius exaggerando creberrime docens, idque, incertum qua mente, ne lateret adfectans. quibus mox Caesar acrius efferatus, velut contumaciae quoddam vexillum altius erigens, sine respectu salutis alienae vel suae ad vertenda opposita instar rapidi fluminis irrevocabili impetu ferebatur.", date:"09/10/21", img1:"https://source.unsplash.com/random", pdf:"", img2:"",img3:"", map:"",),
    //Todo(id: Uuid(), title :"Evenement Important", body:"Thalassius vero ea tempestate praefectus praetorio praesens ipse quoque adrogantis ingenii, considerans incitationem eius ad multorum augeri discrimina, non maturitate vel consiliis mitigabat, ut aliquotiens celsae potestates iras principum molliverunt, sed adversando iurgandoque cum parum congrueret, eum ad rabiem potius evibrabat, Augustum actus eius exaggerando creberrime docens, idque, incertum qua mente, ne lateret adfectans. quibus mox Caesar acrius efferatus, velut contumaciae quoddam vexillum altius erigens, sine respectu salutis alienae vel suae ad vertenda opposita instar rapidi fluminis irrevocabili impetu ferebatur.", date:"09/10/21", img1:"https://images.unsplash.com/photo-1517487771519-951ba4ce60b0?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1965&q=80", img2:"",img3:"", pdf:"",map:""),
    //Todo(id: Uuid(), title :"Evenement Important", body:"Thalassius vero ea tempestate praefectus praetorio praesens ipse quoque adrogantis ingenii, considerans incitationem eius ad multorum augeri discrimina, non maturitate vel consiliis mitigabat, ut aliquotiens celsae potestates iras principum molliverunt, sed adversando iurgandoque cum parum congrueret, eum ad rabiem potius evibrabat, Augustum actus eius exaggerando creberrime docens, idque, incertum qua mente, ne lateret adfectans. quibus mox Caesar acrius efferatus, velut contumaciae quoddam vexillum altius erigens, sine respectu salutis alienae vel suae ad vertenda opposita instar rapidi fluminis irrevocabili impetu ferebatur.", date:"09/10/21", img1:"https://images.unsplash.com/photo-1578185926328-db56802411f1?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1170&q=80", img2:"",img3:"", pdf:"",map:""),
    //Todo(id: Uuid(), title :"Evenement Important", body:"Thalassius vero ea tempestate praefectus praetorio praesens ipse quoque adrogantis ingenii, considerans incitationem eius ad multorum augeri discrimina, non maturitate vel consiliis mitigabat, ut aliquotiens celsae potestates iras principum molliverunt, sed adversando iurgandoque cum parum congrueret, eum ad rabiem potius evibrabat, Augustum actus eius exaggerando creberrime docens, idque, incertum qua mente, ne lateret adfectans. quibus mox Caesar acrius efferatus, velut contumaciae quoddam vexillum altius erigens, sine respectu salutis alienae vel suae ad vertenda opposita instar rapidi fluminis irrevocabili impetu ferebatur.", date:"09/10/21", img1:"https://images.unsplash.com/photo-1472997239248-a99b26e937e5?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=1824&q=80", img2:"",img3:"", pdf:"",map:""),
    //Todo(id: Uuid(), title :"Evenement Important", body:"Thalassius vero ea tempestate praefectus praetorio praesens ipse quoque adrogantis ingenii, considerans incitationem eius ad multorum augeri discrimina, non maturitate vel consiliis mitigabat, ut aliquotiens celsae potestates iras principum molliverunt, sed adversando iurgandoque cum parum congrueret, eum ad rabiem potius evibrabat, Augustum actus eius exaggerando creberrime docens, idque, incertum qua mente, ne lateret adfectans. quibus mox Caesar acrius efferatus, velut contumaciae quoddam vexillum altius erigens, sine respectu salutis alienae vel suae ad vertenda opposita instar rapidi fluminis irrevocabili impetu ferebatur.", date:"09/10/21", img1:"https://source.unsplash.com/random", pdf:"", img2:"",img3:"",map:""),
    //Todo(id: Uuid(), title :"Evenement Important", body:"Thalassius vero ea tempestate praefectus praetorio praesens ipse quoque adrogantis ingenii, considerans incitationem eius ad multorum augeri discrimina, non maturitate vel consiliis mitigabat, ut aliquotiens celsae potestates iras principum molliverunt, sed adversando iurgandoque cum parum congrueret, eum ad rabiem potius evibrabat, Augustum actus eius exaggerando creberrime docens, idque, incertum qua mente, ne lateret adfectans. quibus mox Caesar acrius efferatus, velut contumaciae quoddam vexillum altius erigens, sine respectu salutis alienae vel suae ad vertenda opposita instar rapidi fluminis irrevocabili impetu ferebatur.", date:"09/10/21", img1:"https://source.unsplash.com/random", pdf:"", img2:"",img3:"",map:""),
    //Todo(id: Uuid(), title :"Evenement Important", body:"Thalassius vero ea tempestate praefectus praetorio praesens ipse quoque adrogantis ingenii, considerans incitationem eius ad multorum augeri discrimina, non maturitate vel consiliis mitigabat, ut aliquotiens celsae potestates iras principum molliverunt, sed adversando iurgandoque cum parum congrueret, eum ad rabiem potius evibrabat, Augustum actus eius exaggerando creberrime docens, idque, incertum qua mente, ne lateret adfectans. quibus mox Caesar acrius efferatus, velut contumaciae quoddam vexillum altius erigens, sine respectu salutis alienae vel suae ad vertenda opposita instar rapidi fluminis irrevocabili impetu ferebatur.", date:"09/10/21", img1:"https://source.unsplash.com/random", pdf:"", img2:"",img3:"",map:""),
    //Todo(id: Uuid(), title :"Evenement Important", body:"Thalassius vero ea tempestate praefectus praetorio praesens ipse quoque adrogantis ingenii, considerans incitationem eius ad multorum augeri discrimina, non maturitate vel consiliis mitigabat, ut aliquotiens celsae potestates iras principum molliverunt, sed adversando iurgandoque cum parum congrueret, eum ad rabiem potius evibrabat, Augustum actus eius exaggerando creberrime docens, idque, incertum qua mente, ne lateret adfectans. quibus mox Caesar acrius efferatus, velut contumaciae quoddam vexillum altius erigens, sine respectu salutis alienae vel suae ad vertenda opposita instar rapidi fluminis irrevocabili impetu ferebatur.", date:"09/10/21", img1:"https://source.unsplash.com/random", pdf:"", img2:"",img3:"",map:""),
  ];

  void showAddTodoModal(BuildContext context) async {

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.none) {

        showModalBottomSheet(context: context, builder: (bCtx){
          return NewTodo(addTodo: _addTodo, topic: topic);
        }, isScrollControlled: true,);

    }
    else{

            await showCupertinoDialog(
                      context: context, 
                      builder: createMessage
            );

    }
  }

  void _addTodo(String title, String body, Timestamp date , String img1, String img2, String img3, String pdf, String map, String id, String topic) async {
  
    if(title.isNotEmpty && body.isNotEmpty){

      setState((){

        todos.insert(0,Todo(
          id: id,
          title: title,
          body: body,
          date: date,
          img1: img1,
          img2: img2,
          img3: img3,
          pdf: pdf,
          map: map,
          topic: topic,
          myFunc: updateList,
        ));

        if(todos.length > 10){ // nb max de news

          Todo lastTodo = todos[todos.length-1];
          todos.removeLast();

          _deleteDocument(lastTodo.img1, lastTodo.img2, lastTodo.img3, lastTodo.pdf, lastTodo.date);

          log("delete last");
        }

      });

      scrollTop();

      await sendNotification(title,body, date, img1, img2, img3, pdf, map, updateList, id, topic);
    }
  }

  void _addTodoNotif(String title, String body, Timestamp date , String img1, String img2, String img3, String pdf, String map, String topic, String id,) async {
  
    log("add Todo because of notif received.");

    if(title.isNotEmpty && body.isNotEmpty){
      setState((){
        todos.insert(0,Todo(
          id: id,
          title: title,
          body: body,
          date: date,
          img1: img1,
          img2: img2,
          img3: img3,
          pdf: pdf,
          map: map,
          topic: topic,
          myFunc: updateList,
        ));
      });

      //scrollTop();
    }
  }

  void _deleteDocument(String img1, String img2, String img3, String pdf, Timestamp date) async {

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

  void scrollTop(){

    scrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
  }

////////////////////////////////////////////////////////////////////////////////////////////////////////////

  int currentPageIndex = 0;

  var pageController = PageController();

  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {

    if(!kIsWeb){
      if (Platform.isAndroid) {
        //FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE); // can work for 1 page only
        //FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
      }
    }

    return GestureDetector(
      child: Scaffold(   
        floatingActionButton: _getFAB(),

        backgroundColor: const Color.fromRGBO(250, 250, 250, 1), //const Color.fromRGBO(250, 250, 250, 1) 
        
       body: DoubleBackToCloseApp(
        snackBar: const SnackBar(
            content: Text('Appuyez à nouveau pour quitter'),
        ),
        child: Container(
         decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                       Color(0xFF021D21),
                       Color(0xFF000A0C),
                    ],
                  ),
                ),
         child: CustomScrollView(
          controller: scrollController,
          slivers:[
          SliverAppBar(
            toolbarHeight: 50,
            title: const Text("Annonces"),
            centerTitle: true,
            snap: true,
            floating: true,
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
            elevation: 30,
            shadowColor: Colors.black,
            actions: [
            IconButton(
              onPressed: () async {

                if (await Connectivity().checkConnectivity() != ConnectivityResult.none) {

                  /*  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            WebViewPage(url: 'https://www.webstage.fr/'),
                      ),
                    )  */
                  final SharedPreferences prefs = await _prefs;
                                    setState(() {
                                      prefs.setString("topic", "none");
                                      prefs.setBool("isAdmin", false);
                                    });
                  try{
                    await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
                  }
                  catch(e){print(e);}
                  
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) =>  ConnexionPage(hasInternet: true,)));

                }
                else{

                  await showCupertinoDialog(
                      context: context, 
                      builder: createMessage
                  );
                }
                 
                /* await launch(
                    "https://en.wikipedia.org/wiki/Saint-Martin-Valmeroux",
                    forceSafariVC: false,
                    forceWebView: false,
                    enableJavaScript: false,
                    headers: <String, String>{'my_header_key': 'my_header_value'},
                  ), */
              }, 
              //icon: const Icon(Icons.help_rounded),
              icon: const Icon(Icons.logout_rounded),
              color: Colors.white,
            ),
          ],
          ),

           if(widget.hasInternet)
           if(todos.isNotEmpty)
           SliverList(
              // Use a delegate to build items as they're scrolled on screen.
              delegate: SliverChildBuilderDelegate( 
                // The builder function returns a ListTile with a title that
                // displays the index of the current item.
                (context, i) =>  ToDoCard(
                                    title: todos[i].title, 
                                    body: todos[i].body,
                                    date: todos[i].date,
                                    img1: todos[i].img1,
                                    img2: todos[i].img2,
                                    img3: todos[i].img3,
                                    pdf: todos[i].pdf,
                                    id: todos[i].id,
                                    map: todos[i].map,
                                    isAdmin: isAdmin!,
                                    myFunc: updateList,
                                  ),
                // Builds 1000 ListTiles
                childCount: todos.length,
              ),
            ),

            if(widget.hasInternet == false)
            SliverList(
              delegate: SliverChildBuilderDelegate( 
                // The builder function returns a ListTile with a title that
                // displays the index of the current item.
                (context, i) =>  Container(
                                   margin: EdgeInsets.fromLTRB(10, MediaQuery.of(context).size.height / 2.5, 10, 200),
                                   child: Center(
                                     child: Column(
                                     mainAxisAlignment: MainAxisAlignment.center,
                                     crossAxisAlignment: CrossAxisAlignment.center,
                                     children: const [ 
                                      Text(
                                        "Aucune connexion internet.", 
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.normal,
                                          color: Colors.white,
                                          fontStyle: FontStyle.normal,
                                        ),
                                      ),
                                     ],
                                   ),
                                 ),
                               ),
                childCount: 1,
              ),
            ),
             
        ],       
      ),
    ),
    ),
    ));
  }


  

  
  Widget _getFAB() {
    
    if (isAdmin == false) {
      return Container();
    } else {
      return FloatingActionButton(
          elevation: 1,
          child:Container(

          width: 60,
          height: 60,
          
          child: const Icon(Icons.add,color: Colors.white,),//Theme.of(context).primaryColor),

          decoration: const BoxDecoration(
                shape: BoxShape.circle, // circular shape
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
                      blurRadius: 3.0, // soften the shadow
                      spreadRadius: 0.8, //extend the shadow
                      offset: Offset(
                        0, // Move to right 10  horizontally
                        0, // Move to bottom 10 Vertically
                      ),
                    )
                  ],
              ),
         ),
         onPressed: () async {

              //////  DISPLAY ADS  ////////
              
              /*if(isLoaded){
                rewardedAd!.show(onUserEarnedReward: (RewardedAd ad, RewardItem rewardItem) {
                  log("AD WATCH ENTIRELY !");
                });

                rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
                  onAdShowedFullScreenContent: (RewardedAd ad) =>
                    print('$ad onAdShowedFullScreenContent.'),
                  onAdDismissedFullScreenContent: (RewardedAd ad) {
                    log('$ad onAdDismissedFullScreenContent.');
                    ad.dispose();
                  },
                  onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
                    print('$ad onAdFailedToShowFullScreenContent: $error');
                    ad.dispose();
                  },
                  onAdImpression: (RewardedAd ad) => print('$ad impression occurred.'),
                );

                setState((){
                  isLoaded = false;
                });
                loadAd(true);

              } */
              
              showAddTodoModal(context);
          },
      );
    }
  }

 Widget createDialog(BuildContext context) => CupertinoAlertDialog(
         title: const Text("Mise à jour disponible", style: TextStyle(fontSize:18)),
         content: Column(
           children: [
             Lottie.asset(
              "assets/update.json",
              animate: true,
              height: 100,
             ), 
             const Text("il est fortement recommandé de mettre votre application à jour.", style: TextStyle(fontSize:16)),
           ],
         ),
         actions: [
           CupertinoDialogAction(
             child: const Text("Plus tard"),
             onPressed: () => Navigator.pop(context,false),
           ),
           CupertinoDialogAction(
             child: const Text("Ok !"),
             onPressed: () => Navigator.pop(context,true),
           ),
         ],
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
}