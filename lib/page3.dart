import 'dart:developer';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_course/api/pdf_api.dart';
import 'package:flutter_course/pdf_viewer_page.dart';

class Page3 extends StatefulWidget {

  @override
  _Page3State createState() => _Page3State();
}

class _Page3State extends State<Page3> {

  @override
  Widget build(BuildContext context) {
    return Container(
              child: Center(
                child: Column(
                  children: [
                    ElevatedButton(
                      child: const Text("PDF"),
                      onPressed: ()async{
                        final url="dummy.pdf";
                        final file = await PDFApi.loadFirebase(url);
                        if(file != null){
                          openPDF(context,file);
                        }
                        else{
                          log("file doesn't exist");
                        }
                      },
                    ),
                    ElevatedButton(
                      child: const Text("Pick file"),
                      onPressed: ()async{
                        final file = await PDFApi.pickFile();
                        if (file == null) return;
                        openPDF(context,file);

                        var connectivityResult = await (Connectivity().checkConnectivity());
                        if (connectivityResult != ConnectivityResult.none) {
                          
                        //  final response = await PDFApi.uploadFirebase(file.path);
                        }
                      },
                    ),
                  ],
                ),
              ),
    );
  }

  void openPDF(BuildContext context, File file) => Navigator.of(context).push(
    MaterialPageRoute(builder: (context) => PDFViewerPage(file: file)),
  );
}
