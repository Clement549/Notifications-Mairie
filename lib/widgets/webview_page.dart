import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // flutter run -d chrome --web-renderer html  // flutter build web --web-renderer html --release
import 'package:web_browser/web_browser.dart';
import 'package:webviewx/webviewx.dart';


class WebViewPage extends StatefulWidget {
  
  final String url;

  WebViewPage({required this.url});


  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  final flutterWebviewPlugin = FlutterWebviewPlugin();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    flutterWebviewPlugin.dispose();
    super.dispose();
  }

  bool isLoading = true;

  @override
  Widget build(BuildContext context) {

    if(!kIsWeb){
      return Material(
        type: MaterialType.transparency,
        child: WebviewScaffold(
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
            title: const Text('Aide'),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.star),
                tooltip: "Noter l'application",
                onPressed: () {
                  log("rate app");
                  rateApp();
                },
              ),
            ],
          ),
          url: widget.url,
          //userAgent: 'Fake',
          //clearCookies: false,
          //clearCache: false,
          //hidden: true,
          //appCacheEnabled: true,
          //supportMultipleWindows: true,
        ),
      );
    }
    else{

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
                title: const Text('Aide'),
              ),
              body: Stack(
                children: <Widget>[
                  WebViewX(
                    initialContent: widget.url,
                    javascriptMode: JavascriptMode.unrestricted,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 1.05,
                    onPageFinished: (finish) {
                      setState(() {
                        isLoading = false;
                      });
                    },
                  ),
                  isLoading ? Center( child: CircularProgressIndicator(),)
                            : Stack(),
                ],
              ),
      );
    }
  }

  Future rateApp() async {

        final InAppReview inAppReview = InAppReview.instance;

        if (await inAppReview.isAvailable()) {
            inAppReview.requestReview();
            //inAppReview.openStoreListing(appStoreId: "375380948");
        }
  }
}